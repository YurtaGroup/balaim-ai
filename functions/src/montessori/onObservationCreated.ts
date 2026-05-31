import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {
  MONTESSORI_CATEGORIES,
  MontessoriCategoryId,
  PediatricMilestoneTag,
  SENSITIVE_PERIODS,
  SensitivePeriodId,
  activeSensitivePeriods,
} from "./taxonomy";

/**
 * Trigger: take a freshly-logged Mom observation ("I noticed she pulled
 * all the pots out of the cabinet again") and enrich it with the
 * Montessori reading + matched pediatric milestones. This enrichment
 * is what makes the observation log a moat — without the tags, it's
 * just notes.
 *
 * Two reasons we run this server-side (not in the client):
 *   1. The tags inform tomorrow's invitation — the composer needs to
 *      trust them, so the client must not be able to forge them.
 *   2. The tag pass costs ~1¢ per observation. Doing it once on
 *      create is cheaper than re-tagging in the composer every day.
 */

interface ObservationDoc {
  childId?: string;
  note?: string;
  voiceTranscript?: string;
  createdAt?: admin.firestore.Timestamp;
}

interface MemberSnapshot {
  id: string;
  name: string;
  ageMonths: number | null;
}

interface ClaudeTagPayload {
  sensitive_periods: string[];
  montessori_category: string;
  milestones: { id: string; label: string; age_months_approx?: number }[];
  summary: string;
}

export const onObservationCreated = functions
  .runWith({
    secrets: ["ANTHROPIC_API_KEY"],
    memory: "256MB",
    timeoutSeconds: 30,
  })
  .firestore.document("users/{uid}/observations/{observationId}")
  .onCreate(async (snap, context) => {
    const uid = context.params.uid as string;
    const observationId = context.params.observationId as string;
    const data = snap.data() as ObservationDoc | undefined;
    if (!data) return;

    const text = [data.note ?? "", data.voiceTranscript ?? ""]
      .filter((s) => s && s.length > 0)
      .join("\n")
      .trim();

    if (!text) {
      // Nothing for the tagger to read yet — likely a voice memo that's
      // still being transcribed. Mark partially-enriched and bail; a
      // subsequent update will re-trigger via a follow-up function we
      // add when voice lands.
      await snap.ref.update({
        taggedAt: admin.firestore.FieldValue.serverTimestamp(),
        taggerStatus: "no_text_yet",
      });
      return;
    }

    let member: MemberSnapshot | null = null;
    try {
      member = await loadChildSnapshot(uid, data.childId);
    } catch (e) {
      functions.logger.warn("[observation] child lookup failed", {
        uid,
        observationId,
        err: String(e),
      });
    }

    const ageActive: SensitivePeriodId[] = member?.ageMonths != null
      ? activeSensitivePeriods(member.ageMonths)
      : [];

    let tags: ClaudeTagPayload | null = null;
    try {
      tags = await runTagger(text, member, ageActive);
    } catch (e) {
      functions.logger.warn("[observation] tagger error", {
        uid,
        observationId,
        err: String(e),
      });
    }

    const update: Record<string, unknown> = {
      taggedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (!tags) {
      update.taggerStatus = "failed";
    } else {
      update.taggerStatus = "tagged";
      update.sensitivePeriods = sanitisePeriods(tags.sensitive_periods);
      update.montessoriCategory = sanitiseCategory(tags.montessori_category);
      update.milestones = sanitiseMilestones(tags.milestones);
      update.summary = typeof tags.summary === "string"
        ? tags.summary.trim().slice(0, 280)
        : null;
    }

    await snap.ref.update(update);
  });

async function loadChildSnapshot(
  uid: string,
  childId: string | undefined
): Promise<MemberSnapshot | null> {
  if (!uid) return null;
  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  const userData = userDoc.data();
  if (!userData) return null;
  const members = (userData.members as Record<string, unknown>[] | undefined) ?? [];
  if (members.length === 0) return null;

  const isChild = (m: Record<string, unknown>) => m?.role === "child";
  let pick: Record<string, unknown> | undefined;

  if (childId) {
    pick = members.find((m) => m.id === childId && isChild(m));
  }
  pick ??= members.find(
    (m) => m.id === (userData.selectedMemberId as string | undefined) && isChild(m)
  );
  pick ??= members.find(isChild);
  if (!pick) return null;

  const name = typeof pick.name === "string" ? pick.name.trim() : "";
  if (!name) return null;

  let ageMonths: number | null = null;
  const birth = pick.birthDate;
  if (typeof birth === "string") {
    const dob = Date.parse(birth);
    if (!Number.isNaN(dob)) {
      ageMonths = Math.max(
        0,
        Math.floor((Date.now() - dob) / (1000 * 60 * 60 * 24 * 30.44))
      );
    }
  }

  return {
    id: String(pick.id ?? ""),
    name,
    ageMonths,
  };
}

async function runTagger(
  text: string,
  member: MemberSnapshot | null,
  activeIds: SensitivePeriodId[]
): Promise<ClaudeTagPayload | null> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) return null;

  const periodChoices = Object.entries(SENSITIVE_PERIODS)
    .map(([id, p]) => `- ${id} (${p.label}, ${p.startMonths}-${p.endMonths}mo): ${p.summary}`)
    .join("\n");
  const categoryChoices = Object.entries(MONTESSORI_CATEGORIES)
    .map(([id, c]) => `- ${id} (${c.label}): ${c.summary}`)
    .join("\n");

  const childLine = member
    ? `Child: ${member.name}${member.ageMonths != null ? `, ${member.ageMonths} months` : ""}.`
    : "Child age unknown.";
  const activeLine = activeIds.length > 0
    ? `Currently-active sensitive periods (age-based): ${activeIds.join(", ")}.`
    : "No age-based sensitive period window currently active (or age unknown).";

  const system = `You are a Montessori-trained pediatric coach tagging a parent's
observation. Read the observation and return a STRICT JSON object with these
fields and nothing else:

{
  "sensitive_periods": [<one or more ids from the list below; empty array if none applies>],
  "montessori_category": <exactly one id from the category list below>,
  "milestones": [{"id": "<short_snake_case_id>", "label": "<human>", "age_months_approx": <int|null>}, ...],
  "summary": "<one sentence, <=150 chars, plain reading of what the child is showing>"
}

SENSITIVE PERIOD CHOICES:
${periodChoices}

MONTESSORI CATEGORY CHOICES:
${categoryChoices}

PEDIATRIC MILESTONES: free-form. Tag the observation with any developmental
milestones it ALSO satisfies. Examples of valid ids: pincer_grasp,
two_word_phrases, runs_steadily, stacks_three_cubes, points_to_request,
follows_two_step, jumps_with_two_feet, dresses_self, draws_circle.
Use snake_case. Include age_months_approx when you can.

HARD RULES:
- Output JSON only. No markdown, no prose, no commentary. No leading or trailing whitespace.
- If the observation is too vague to tag, return {"sensitive_periods":[],"montessori_category":"practical_life","milestones":[],"summary":"<your best reading>"}.
- Never invent a sensitive period id outside the list. Never invent a category id outside the list.
- Milestones may be free-form but must be snake_case and concrete (a doer-verb).`;

  const user = `${childLine}
${activeLine}

Observation: ${text}`;

  const client = new Anthropic({ apiKey });
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 400,
    temperature: 0.4,
    system,
    messages: [{ role: "user", content: user }],
  });

  const textBlock = response.content.find((b) => b.type === "text");
  if (!textBlock) return null;
  const raw = textBlock.text.trim();
  try {
    const parsed = JSON.parse(raw) as ClaudeTagPayload;
    return parsed;
  } catch (e) {
    functions.logger.warn("[observation] failed to parse tagger JSON", {
      raw: raw.slice(0, 400),
      err: String(e),
    });
    return null;
  }
}

function sanitisePeriods(input: unknown): SensitivePeriodId[] {
  if (!Array.isArray(input)) return [];
  const allowed = new Set(Object.keys(SENSITIVE_PERIODS));
  return input
    .filter((v): v is string => typeof v === "string")
    .filter((v) => allowed.has(v))
    .slice(0, 4) as SensitivePeriodId[];
}

function sanitiseCategory(input: unknown): MontessoriCategoryId | null {
  if (typeof input !== "string") return null;
  if (input in MONTESSORI_CATEGORIES) return input as MontessoriCategoryId;
  return null;
}

function sanitiseMilestones(input: unknown): PediatricMilestoneTag[] {
  if (!Array.isArray(input)) return [];
  const out: PediatricMilestoneTag[] = [];
  for (const raw of input) {
    if (!raw || typeof raw !== "object") continue;
    const r = raw as Record<string, unknown>;
    const id = typeof r.id === "string" ? r.id.trim() : "";
    const label = typeof r.label === "string" ? r.label.trim() : "";
    if (!id || !label) continue;
    if (!/^[a-z0-9_]+$/i.test(id)) continue;
    const age =
      typeof r.age_months_approx === "number"
        ? Math.max(0, Math.min(120, Math.floor(r.age_months_approx)))
        : undefined;
    out.push({ id, label, ...(age != null ? { ageMonthsApprox: age } : {}) });
    if (out.length >= 5) break;
  }
  return out;
}
