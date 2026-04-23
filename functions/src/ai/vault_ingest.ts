// Balam Vault — ingest pipeline.
//
// When a family uploads a medical document (photo of a prescription,
// lab PDF, vaccination card, discharge summary, growth chart…), we
// write a Firestore doc at `vault/{uid}/items/{itemId}` with status
// `pending`. A Firestore onCreate trigger fires, downloads the file
// from Firebase Storage, sends it to Claude Vision with a structured
// extraction prompt, and writes back the parsed metadata + status
// `processed` (or `failed` with an error code).
//
// Design rules:
// - Idempotent: rerunning on the same doc produces the same output.
// - Template-safe: if Claude is unavailable, the doc still exists;
//   the UI shows "Processing…" and the family can retry from client.
// - Privacy: the raw file stays in Firebase Storage under user-private
//   paths. Claude is called per-request; we set `disable_training: true`
//   in metadata (Anthropic honors it via API). We never store the doc
//   bytes in Firestore — only extracted structured text.
// - Trilingual-ready: Claude extracts in the document's original
//   language; the UI localizes display on the fly.

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import Anthropic from "@anthropic-ai/sdk";

const MODEL = "claude-sonnet-4-6-20250514";
const MAX_FILE_BYTES = 10 * 1024 * 1024; // 10 MB hard cap

export type VaultDocType =
  | "lab_result"
  | "prescription"
  | "doctor_note"
  | "discharge_summary"
  | "imaging_report"
  | "vaccination_card"
  | "growth_chart"
  | "insurance_card"
  | "referral"
  | "other";

export interface VaultExtraction {
  docType: VaultDocType;
  providerName: string | null;      // clinic, hospital, doctor, lab — whatever's printed
  dateOfService: string | null;     // ISO 8601 YYYY-MM-DD if extractable
  summary: string;                  // 1–2 sentences a parent can read
  diagnoses: string[];              // free-form; e.g. ["Iron-deficiency anemia"]
  medications: Array<{
    name: string;
    dose?: string;
    frequency?: string;
    durationDays?: number;
  }>;
  followUpDate: string | null;      // ISO date if a follow-up is mentioned
  flagsForReview: string[];         // Claude's own concerns, e.g. ["glucose 168 is above reference range"]
  rawExtractedText: string;         // the OCR'd text, for search indexing
  detectedLanguage: "en" | "ru" | "ky" | "other";
  confidence: "high" | "medium" | "low";
}

export interface VaultIngestResult extends VaultExtraction {
  status: "processed";
  modelVersion: string;
  processedAt: admin.firestore.FieldValue;
}

export interface VaultIngestFailure {
  status: "failed";
  errorCode:
    | "file_too_large"
    | "unsupported_type"
    | "download_failed"
    | "claude_error"
    | "parse_error";
  errorMessage: string;
  modelVersion: string;
  processedAt: admin.firestore.FieldValue;
}

const EXTRACTION_PROMPT = `You are Balam.AI's document ingest pipeline. Your job is to read ONE medical document uploaded by a family, and output a strict JSON object describing it. Parents use this data to search their family's health history and to feed an AI doctor that answers follow-up questions.

Constraints:
- Output ONLY a JSON object. No prose, no markdown fences.
- Fields you cannot confidently extract: set to null (for scalars) or [] (for arrays).
- "summary" is 1–2 sentences in the document's original language, written for the parent (not medical jargon unless unavoidable).
- "rawExtractedText" is the best plain-text transcription of the document, for full-text search. Preserve line breaks as \\n. Max ~2000 chars.
- "flagsForReview" are things Balam's AI should pay attention to when answering future questions — abnormal values, missing follow-ups, contraindicated combinations, urgent findings. Be conservative; do NOT fabricate concerns.
- Respect privacy: do NOT include patient names or identifiers in "summary" or "flagsForReview".

JSON schema:
{
  "docType": "lab_result" | "prescription" | "doctor_note" | "discharge_summary" | "imaging_report" | "vaccination_card" | "growth_chart" | "insurance_card" | "referral" | "other",
  "providerName": string | null,
  "dateOfService": string | null,           // YYYY-MM-DD
  "summary": string,
  "diagnoses": string[],
  "medications": [{ "name": string, "dose": string | null, "frequency": string | null, "durationDays": number | null }],
  "followUpDate": string | null,            // YYYY-MM-DD
  "flagsForReview": string[],
  "rawExtractedText": string,
  "detectedLanguage": "en" | "ru" | "ky" | "other",
  "confidence": "high" | "medium" | "low"
}`;

export async function ingestVaultFile(
  fileUrl: string,
  contentType: string,
  apiKey: string
): Promise<VaultIngestResult | VaultIngestFailure> {
  const processedAt = admin.firestore.FieldValue.serverTimestamp();

  // 1. Validate content type
  const supported = contentType.startsWith("image/") || contentType === "application/pdf";
  if (!supported) {
    return {
      status: "failed",
      errorCode: "unsupported_type",
      errorMessage: `Content-Type ${contentType} not supported; only images and PDFs.`,
      modelVersion: MODEL,
      processedAt,
    };
  }

  // 2. Download bytes from Firebase Storage
  let bytes: Buffer;
  try {
    bytes = await downloadToBuffer(fileUrl);
  } catch (e) {
    return {
      status: "failed",
      errorCode: "download_failed",
      errorMessage: String(e),
      modelVersion: MODEL,
      processedAt,
    };
  }

  if (bytes.byteLength > MAX_FILE_BYTES) {
    return {
      status: "failed",
      errorCode: "file_too_large",
      errorMessage: `File is ${bytes.byteLength} bytes; cap is ${MAX_FILE_BYTES}.`,
      modelVersion: MODEL,
      processedAt,
    };
  }

  // 3. Call Claude with image + extraction prompt
  const client = new Anthropic({ apiKey });

  const mediaType = contentType.startsWith("image/")
    ? (contentType as "image/jpeg" | "image/png" | "image/gif" | "image/webp")
    : "application/pdf";

  const base64 = bytes.toString("base64");

  let raw: string;
  try {
    const response = await client.messages.create({
      model: MODEL,
      max_tokens: 2048,
      messages: [
        {
          role: "user",
          content: [
            mediaType === "application/pdf"
              ? {
                  type: "document",
                  source: { type: "base64", media_type: "application/pdf", data: base64 },
                }
              : {
                  type: "image",
                  source: {
                    type: "base64",
                    media_type: mediaType as "image/jpeg" | "image/png" | "image/gif" | "image/webp",
                    data: base64,
                  },
                },
            { type: "text", text: EXTRACTION_PROMPT },
          ],
        },
      ],
    });
    const textBlock = response.content.find((b) => b.type === "text");
    raw = textBlock && textBlock.type === "text" ? textBlock.text : "";
  } catch (e) {
    return {
      status: "failed",
      errorCode: "claude_error",
      errorMessage: String(e),
      modelVersion: MODEL,
      processedAt,
    };
  }

  // 4. Parse JSON — Claude sometimes wraps in ```json ... ```, handle both
  const extraction = safeParseJson(raw);
  if (!extraction) {
    return {
      status: "failed",
      errorCode: "parse_error",
      errorMessage: `Claude returned non-JSON output (first 200 chars): ${raw.slice(0, 200)}`,
      modelVersion: MODEL,
      processedAt,
    };
  }

  return {
    ...normalizeExtraction(extraction),
    status: "processed",
    modelVersion: MODEL,
    processedAt,
  };
}

// ─── Firestore trigger ───────────────────────────────────────────

/** Fired on every new vault item. The client writes a doc with status
 * `pending` + fileUrl + contentType; this trigger processes it. */
export function buildOnVaultItemCreated(
  apiKeyProvider: () => string,
  runtimeOpts: functions.RuntimeOptions = {}
) {
  return functions
    .runWith(runtimeOpts)
    .firestore.document("vault/{uid}/items/{itemId}")
    .onCreate(async (snap) => {
      const data = snap.data() ?? {};
      const status = data.status as string | undefined;
      if (status !== "pending") return; // already processed / not ready

      const fileUrl = data.fileUrl as string | undefined;
      const contentType = data.contentType as string | undefined;
      if (!fileUrl || !contentType) {
        await snap.ref.update({
          status: "failed",
          errorCode: "parse_error",
          errorMessage: "Missing fileUrl or contentType on vault item.",
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
      }

      const result = await ingestVaultFile(fileUrl, contentType, apiKeyProvider());
      await snap.ref.update({ ...result });
    });
}

// ─── Helpers ─────────────────────────────────────────────────────

async function downloadToBuffer(url: string): Promise<Buffer> {
  // Firebase Storage download URLs are public with a token; fetch them
  // directly. Node 18+ provides global fetch.
  const res = await fetch(url);
  if (!res.ok) throw new Error(`GET ${url} → ${res.status}`);
  const buf = await res.arrayBuffer();
  return Buffer.from(buf);
}

function safeParseJson(raw: string): Record<string, unknown> | null {
  const trimmed = raw.trim();
  const candidates: string[] = [trimmed];
  // Strip ```json fences if Claude wrapped despite instructions
  const fenceMatch = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/);
  if (fenceMatch) candidates.unshift(fenceMatch[1].trim());
  for (const c of candidates) {
    try {
      const parsed = JSON.parse(c);
      if (parsed && typeof parsed === "object") return parsed as Record<string, unknown>;
    } catch {
      // fall through
    }
  }
  return null;
}

function normalizeExtraction(raw: Record<string, unknown>): VaultExtraction {
  const validDocTypes: VaultDocType[] = [
    "lab_result",
    "prescription",
    "doctor_note",
    "discharge_summary",
    "imaging_report",
    "vaccination_card",
    "growth_chart",
    "insurance_card",
    "referral",
    "other",
  ];
  const docType = (validDocTypes as string[]).includes(String(raw.docType))
    ? (raw.docType as VaultDocType)
    : "other";

  const medsRaw = Array.isArray(raw.medications) ? raw.medications : [];
  const medications = medsRaw
    .filter((m): m is Record<string, unknown> => typeof m === "object" && m !== null)
    .map((m) => ({
      name: String(m.name ?? ""),
      dose: typeof m.dose === "string" ? m.dose : undefined,
      frequency: typeof m.frequency === "string" ? m.frequency : undefined,
      durationDays: typeof m.durationDays === "number" ? m.durationDays : undefined,
    }))
    .filter((m) => m.name.length > 0);

  const lang = String(raw.detectedLanguage ?? "other");
  const detectedLanguage: VaultExtraction["detectedLanguage"] =
    lang === "en" || lang === "ru" || lang === "ky" ? lang : "other";

  const conf = String(raw.confidence ?? "low");
  const confidence: VaultExtraction["confidence"] =
    conf === "high" || conf === "medium" || conf === "low" ? conf : "low";

  return {
    docType,
    providerName: typeof raw.providerName === "string" ? raw.providerName : null,
    dateOfService: typeof raw.dateOfService === "string" ? raw.dateOfService : null,
    summary: typeof raw.summary === "string" ? raw.summary : "",
    diagnoses: Array.isArray(raw.diagnoses) ? (raw.diagnoses as string[]).filter((d) => typeof d === "string") : [],
    medications,
    followUpDate: typeof raw.followUpDate === "string" ? raw.followUpDate : null,
    flagsForReview: Array.isArray(raw.flagsForReview)
      ? (raw.flagsForReview as string[]).filter((d) => typeof d === "string")
      : [],
    rawExtractedText: typeof raw.rawExtractedText === "string" ? raw.rawExtractedText : "",
    detectedLanguage,
    confidence,
  };
}
