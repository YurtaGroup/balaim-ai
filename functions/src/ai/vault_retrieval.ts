// Balam Vault — retrieval layer for the grounded AI doctor.
//
// Before each chat turn, we pull the top-N most relevant processed
// vault items for the member the conversation is about, and format
// them as a text block that prefixes the user's message.
//
// Why it's dumb-by-design (keyword + recency, not embeddings):
// - Volume is tiny per family (~50 docs/yr at the high end), so a
//   linear scan of 30 items is <5ms of Firestore read time.
// - Keyword overlap on the extracted summary + diagnoses + meds +
//   raw text is ≥90% as effective as embeddings when N <= 50.
// - When any single family crosses ~500 vault items we'll add an
//   embedding index; not a day sooner. Premature embedding = burnt
//   money.
//
// Availability > retrieval quality: this function never blocks the
// chat path. Any error or timeout → caller treats it as "no vault
// context available" and the chat runs exactly as before.

import * as admin from "firebase-admin";

export interface VaultRetrievalOptions {
  max?: number;       // top-N to return (default 3)
  maxChars?: number;  // cap on the total text block (default 2400)
  lookbackDays?: number; // ignore items older than this (default 730 = ~2 yrs)
}

/** Returns a formatted text block to inject into the chat prompt,
 * or null if there's nothing relevant (or retrieval failed). */
export async function retrieveVaultContext(
  uid: string,
  memberId: string,
  query: string,
  opts: VaultRetrievalOptions = {}
): Promise<string | null> {
  const max = opts.max ?? 3;
  const maxChars = opts.maxChars ?? 2400;
  const lookbackDays = opts.lookbackDays ?? 730;

  try {
    const snap = await admin
      .firestore()
      .collection(`vault/${uid}/items`)
      .where("memberId", "==", memberId)
      .where("status", "==", "processed")
      .orderBy("uploadedAt", "desc")
      .limit(30)
      .get();

    if (snap.empty) return null;

    const queryTokens = tokenize(query);
    const now = Date.now();
    const lookbackMs = lookbackDays * 24 * 60 * 60 * 1000;

    interface Scored {
      score: number;
      item: VaultRetrievalItem;
    }

    const scored: Scored[] = [];
    for (const doc of snap.docs) {
      const d = doc.data();
      const uploadedAt = toDate(d.uploadedAt);
      const dateOfService = toDate(d.dateOfService) ?? uploadedAt;
      if (!uploadedAt) continue;
      const ageMs = now - uploadedAt.getTime();
      if (ageMs > lookbackMs) continue;

      const keywordScore = scoreKeywords(queryTokens, d);
      // Recency decay: linear from 1.0 (today) to 0 (lookback horizon).
      const recencyScore = Math.max(0, 1 - ageMs / lookbackMs);
      const score = keywordScore * 0.7 + recencyScore * 0.3;

      if (score <= 0) continue;

      scored.push({
        score,
        item: {
          id: doc.id,
          docType: String(d.docType ?? "other"),
          providerName: (d.providerName as string | null) ?? null,
          dateISO: toISODate(dateOfService ?? uploadedAt),
          summary: String(d.summary ?? ""),
          diagnoses: asStringArray(d.diagnoses),
          medications: (Array.isArray(d.medications) ? d.medications : [])
            .filter((m): m is Record<string, unknown> => typeof m === "object" && m !== null)
            .map((m) => formatMed(m))
            .filter((s) => s.length > 0),
          flagsForReview: asStringArray(d.flagsForReview),
        },
      });
    }

    scored.sort((a, b) => b.score - a.score);
    const top = scored.slice(0, max).map((s) => s.item);
    if (top.length === 0) return null;

    return formatBlock(top, maxChars);
  } catch (e) {
    // Silent skip on any read failure — the chat path is NOT allowed
    // to depend on retrieval succeeding. Log once so we notice patterns.
    console.warn("[vault_retrieval] skipped", { uid, memberId, err: String(e) });
    return null;
  }
}

// ─── Internals ───────────────────────────────────────────────────

interface VaultRetrievalItem {
  id: string;
  docType: string;
  providerName: string | null;
  dateISO: string;
  summary: string;
  diagnoses: string[];
  medications: string[];
  flagsForReview: string[];
}

// Stop words are intentionally small — we want partial matches to
// fire on medical-adjacent terms (e.g. "bp", "meds", "headache").
const STOP_WORDS = new Set([
  "the", "a", "an", "and", "or", "but", "of", "for", "to", "in", "on", "at",
  "is", "it", "this", "that", "was", "were", "be", "been", "being",
  "my", "me", "i", "you", "your", "we", "our", "do", "does", "did",
  "what", "when", "where", "why", "how", "can", "could", "should",
  "would", "about", "any", "has", "have", "had",
]);

function tokenize(s: string): Set<string> {
  const out = new Set<string>();
  for (const raw of s.toLowerCase().split(/[^\p{L}\p{N}]+/u)) {
    if (!raw) continue;
    if (raw.length < 2) continue;
    if (STOP_WORDS.has(raw)) continue;
    out.add(raw);
  }
  return out;
}

function scoreKeywords(queryTokens: Set<string>, doc: Record<string, unknown>): number {
  if (queryTokens.size === 0) return 0.1; // low but non-zero so recency dominates when query is generic
  const haystack = [
    String(doc.summary ?? ""),
    asStringArray(doc.diagnoses).join(" "),
    (Array.isArray(doc.medications) ? doc.medications : [])
      .filter((m): m is Record<string, unknown> => typeof m === "object" && m !== null)
      .map((m) => String(m.name ?? ""))
      .join(" "),
    String(doc.rawExtractedText ?? ""),
    String(doc.docType ?? ""),
    String(doc.providerName ?? ""),
  ]
    .join(" ")
    .toLowerCase();

  let hits = 0;
  for (const t of queryTokens) {
    if (haystack.includes(t)) hits += 1;
  }
  return hits / queryTokens.size;
}

function formatBlock(items: VaultRetrievalItem[], maxChars: number): string {
  const header =
    "[Family Health Vault — relevant records for this conversation]\n" +
    "(These are real documents the family uploaded. Ground your answer in them; cite the date + provider briefly when you use them. If they don't contain what the parent is asking about, say so honestly.)\n";
  const blocks = items.map(formatItem);
  let text = header + blocks.join("\n\n");
  if (text.length > maxChars) text = text.slice(0, maxChars - 1) + "…";
  return text;
}

function formatItem(it: VaultRetrievalItem): string {
  const lines: string[] = [];
  const title = `${prettyDocType(it.docType)} · ${it.providerName ?? "—"} · ${it.dateISO}`;
  lines.push(`## ${title}`);
  if (it.summary) lines.push(`Summary: ${it.summary}`);
  if (it.diagnoses.length) lines.push(`Diagnoses: ${it.diagnoses.join("; ")}`);
  if (it.medications.length) lines.push(`Medications: ${it.medications.join("; ")}`);
  if (it.flagsForReview.length) lines.push(`Flags: ${it.flagsForReview.join(" · ")}`);
  return lines.join("\n");
}

function prettyDocType(t: string): string {
  switch (t) {
    case "lab_result":
      return "Lab result";
    case "prescription":
      return "Prescription";
    case "doctor_note":
      return "Doctor's note";
    case "discharge_summary":
      return "Discharge summary";
    case "imaging_report":
      return "Imaging report";
    case "vaccination_card":
      return "Vaccination card";
    case "growth_chart":
      return "Growth chart";
    case "insurance_card":
      return "Insurance card";
    case "referral":
      return "Referral";
    default:
      return "Document";
  }
}

function formatMed(m: Record<string, unknown>): string {
  const parts: string[] = [];
  const name = String(m.name ?? "").trim();
  if (!name) return "";
  parts.push(name);
  if (typeof m.dose === "string" && m.dose) parts.push(m.dose);
  if (typeof m.frequency === "string" && m.frequency) parts.push(m.frequency);
  return parts.join(" ");
}

function asStringArray(v: unknown): string[] {
  return Array.isArray(v) ? v.filter((x): x is string => typeof x === "string") : [];
}

function toDate(v: unknown): Date | null {
  if (v instanceof admin.firestore.Timestamp) return v.toDate();
  if (typeof v === "string") {
    const d = new Date(v);
    return isNaN(d.getTime()) ? null : d;
  }
  return null;
}

function toISODate(d: Date): string {
  return d.toISOString().slice(0, 10);
}
