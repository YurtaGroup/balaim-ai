import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import {
  MONTESSORI_CATEGORIES,
  MontessoriCategoryId,
  SENSITIVE_PERIODS,
  SensitivePeriodId,
  activeSensitivePeriods,
} from "./taxonomy";

/**
 * Daily Montessori invitation generator.
 *
 * One invitation per child per day. Composed by Claude using:
 *   - child age (sensitive period activation)
 *   - the last few observations Mom has logged (so "follow the child")
 *   - how yesterday's invitation landed (loved → press on; lost
 *     interest → switch categories; too early → revisit later)
 *
 * Hard rules in the system prompt (engineered to refuse the
 * Pinterest-Montessori failure modes):
 *   - No purchases. No Amazon. No "buy a Pikler triangle." Use what's
 *     in the home.
 *   - No screens. No crafts. No "Montessori-aesthetic" rainbow bins.
 *   - ≤2-line setup. ≤8 minutes of Mom involvement.
 *   - ONE invitation. Not three.
 *
 * Premium gating: free tier gets 1/week (the most recent ISO week's
 * invitation persists; new requests within the same week return the
 * existing doc). Premium gets one per day. Server-enforced — the
 * client cannot forge.
 */

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");
const MAX_FREE_INVITATIONS_PER_WEEK = 1;

interface MemberSnapshot {
  id: string;
  name: string;
  firstName: string;
  ageMonths: number | null;
}

interface ObservationLite {
  note: string;
  summary: string | null;
  sensitivePeriods: string[];
  montessoriCategory: string | null;
  createdAt: Date;
}

interface YesterdayLanding {
  title: string;
  category: string | null;
  feedback: "loved" | "lost_interest" | "too_early" | null;
}

interface InvitationDoc {
  memberId: string;
  date: string; // YYYY-MM-DD (UTC)
  title: string;
  whyOneLine: string;
  setupSteps: string[]; // ≤2 entries
  category: MontessoriCategoryId;
  sensitivePeriods: SensitivePeriodId[];
  ageMonthsAtComposition: number | null;
  setupMinutes: number;
  generatedAt: admin.firestore.FieldValue;
  // Mom-mutable feedback. Set later via direct Firestore update.
  triedAt?: admin.firestore.Timestamp | null;
  feedback?: "loved" | "lost_interest" | "too_early" | null;
  feedbackAt?: admin.firestore.Timestamp | null;
}

export const generateDailyInvitation = onCall(
  { region: "us-central1", secrets: [anthropicKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const uid = request.auth.uid;
    const memberId = String(request.data?.memberId ?? "");
    if (!memberId) {
      throw new HttpsError("invalid-argument", "memberId required");
    }

    const db = admin.firestore();
    const today = todayKey();
    const docId = `${memberId}__${today}`;
    const docRef = db.doc(`users/${uid}/invitations/${docId}`);

    // Idempotent: if today's invitation already exists, return it.
    const existing = await docRef.get();
    if (existing.exists) {
      return { invitation: serialise(existing.id, existing.data() ?? {}) };
    }

    // Free-tier gate: max 1 invitation per ISO week. Premium = daily.
    const premium = await isPremium(uid);
    if (!premium) {
      const weekStart = startOfIsoWeekUtc();
      const recent = await db
        .collection(`users/${uid}/invitations`)
        .where("generatedAt", ">=", admin.firestore.Timestamp.fromDate(weekStart))
        .limit(MAX_FREE_INVITATIONS_PER_WEEK + 1)
        .get();
      if (recent.size >= MAX_FREE_INVITATIONS_PER_WEEK) {
        const mostRecent = recent.docs[0];
        return {
          invitation: serialise(mostRecent.id, mostRecent.data() ?? {}),
          limitReached: true,
        };
      }
    }

    const member = await loadMember(uid, memberId);
    if (!member) {
      throw new HttpsError("not-found", "Child not found");
    }
    const observations = await loadRecentObservations(uid, memberId);
    const yesterday = await loadYesterdayLanding(uid, memberId, today);

    const composed = await composeInvitation({
      member,
      observations,
      yesterday,
    });
    if (!composed) {
      throw new HttpsError("internal", "Invitation composer failed");
    }

    const doc: InvitationDoc = {
      memberId,
      date: today,
      title: composed.title,
      whyOneLine: composed.why,
      setupSteps: composed.setupSteps,
      category: composed.category,
      sensitivePeriods: composed.sensitivePeriods,
      ageMonthsAtComposition: member.ageMonths,
      setupMinutes: composed.setupMinutes,
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      triedAt: null,
      feedback: null,
      feedbackAt: null,
    };

    await docRef.set(doc);
    const written = await docRef.get();
    return { invitation: serialise(written.id, written.data() ?? {}) };
  }
);

async function isPremium(uid: string): Promise<boolean> {
  try {
    const snap = await admin.firestore().doc(`users/${uid}`).get();
    return (snap.data()?.premium as boolean) === true;
  } catch {
    return false;
  }
}

async function loadMember(
  uid: string,
  memberId: string
): Promise<MemberSnapshot | null> {
  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  const data = userDoc.data();
  if (!data) return null;
  const members = (data.members as Record<string, unknown>[] | undefined) ?? [];
  const m = members.find((row) => row?.id === memberId && row?.role === "child");
  if (!m) return null;
  const name = typeof m.name === "string" ? m.name.trim() : "";
  if (!name) return null;
  let ageMonths: number | null = null;
  if (typeof m.birthDate === "string") {
    const dob = Date.parse(m.birthDate);
    if (!Number.isNaN(dob)) {
      ageMonths = Math.max(
        0,
        Math.floor((Date.now() - dob) / (1000 * 60 * 60 * 24 * 30.44))
      );
    }
  }
  return {
    id: memberId,
    name,
    firstName: name.split(" ")[0] ?? name,
    ageMonths,
  };
}

async function loadRecentObservations(
  uid: string,
  memberId: string
): Promise<ObservationLite[]> {
  const snap = await admin
    .firestore()
    .collection(`users/${uid}/observations`)
    .orderBy("createdAt", "desc")
    .limit(8)
    .get();
  const out: ObservationLite[] = [];
  for (const doc of snap.docs) {
    const d = doc.data();
    if (d.childId && d.childId !== memberId) continue;
    const createdAt = d.createdAt?.toDate?.() ?? null;
    if (!createdAt) continue;
    out.push({
      note: typeof d.note === "string" ? d.note.trim() : "",
      summary: typeof d.summary === "string" ? d.summary.trim() : null,
      sensitivePeriods: Array.isArray(d.sensitivePeriods)
        ? (d.sensitivePeriods as string[])
        : [],
      montessoriCategory:
        typeof d.montessoriCategory === "string" ? d.montessoriCategory : null,
      createdAt,
    });
  }
  return out.slice(0, 5);
}

async function loadYesterdayLanding(
  uid: string,
  memberId: string,
  todayKeyStr: string
): Promise<YesterdayLanding | null> {
  // Walk back day-by-day up to 5 days to find the most recent
  // invitation that has Mom feedback attached. Skip days with no
  // invitation so a 1/week free user still gets meaningful context.
  for (let i = 1; i <= 5; i++) {
    const dayKey = addDaysIso(todayKeyStr, -i);
    const docId = `${memberId}__${dayKey}`;
    const snap = await admin.firestore().doc(`users/${uid}/invitations/${docId}`).get();
    if (!snap.exists) continue;
    const d = snap.data() ?? {};
    const feedback = (d.feedback as YesterdayLanding["feedback"]) ?? null;
    if (!feedback) continue;
    return {
      title: typeof d.title === "string" ? d.title : "",
      category: typeof d.category === "string" ? d.category : null,
      feedback,
    };
  }
  return null;
}

interface ComposedInvitation {
  title: string;
  why: string;
  setupSteps: string[];
  category: MontessoriCategoryId;
  sensitivePeriods: SensitivePeriodId[];
  setupMinutes: number;
}

async function composeInvitation({
  member,
  observations,
  yesterday,
}: {
  member: MemberSnapshot;
  observations: ObservationLite[];
  yesterday: YesterdayLanding | null;
}): Promise<ComposedInvitation | null> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) return null;

  const active = member.ageMonths != null
    ? activeSensitivePeriods(member.ageMonths)
    : [];

  const periodLines = Object.entries(SENSITIVE_PERIODS)
    .map(([id, p]) => `- ${id} (${p.label}, ${p.startMonths}-${p.endMonths}mo): ${p.summary}`)
    .join("\n");
  const categoryLines = Object.entries(MONTESSORI_CATEGORIES)
    .map(([id, c]) => `- ${id} (${c.label}): ${c.summary}`)
    .join("\n");

  const obsLines = observations.length === 0
    ? "(no observations logged yet — pick from the active sensitive periods only)"
    : observations
        .map((o) => {
          const tags = [
            o.montessoriCategory ?? "",
            ...o.sensitivePeriods,
          ]
            .filter((t) => t.length > 0)
            .join(", ");
          return `- "${o.note || o.summary || ""}"${tags ? ` [${tags}]` : ""}`;
        })
        .join("\n");

  const yesterdayLine = yesterday
    ? `Yesterday's invitation "${yesterday.title}" (${yesterday.category ?? "?"}) → Mom marked it "${yesterday.feedback}". Adjust: ${adjustHint(yesterday.feedback)}.`
    : "(no recent feedback)";

  const ageLine = member.ageMonths != null
    ? `${member.firstName} is ${member.ageMonths} months old. Active sensitive periods: ${active.join(", ") || "none in window"}.`
    : `${member.firstName}'s age is unknown — choose age-agnostic practical-life work that suits 12-36 months.`;

  const system = `You are a Montessori-trained pediatric coach composing ONE
"Invitation" for ${member.firstName} for today. An Invitation is a tiny offering
in the prepared environment — never a lesson, never a craft. The parent reads
it as a friend's suggestion, sets up in under 60 seconds, then steps back.

HARD RULES (break any of these and the product fails):
1. NEVER suggest a purchase. No Amazon. No Lovevery. No "buy a Pikler triangle"
   or "Montessori shelf" or "wooden activity toy". Use what is already in the
   home: kitchen items, laundry, bath, water, paper, cloth, real food.
2. NEVER suggest screen-based work for the child. No apps, no videos, no
   "look at this on the phone".
3. NEVER suggest a craft. Crafts are end-product driven; Montessori work is
   process driven. No glue, no glitter, no "make a card".
4. NEVER frame this as a lesson, a flashcard drill, or a curriculum. The
   parent OFFERS; the child takes it or doesn't. "Follow the child."
5. Output MUST be one activity. Not a list of three. Not options.
6. Setup must fit in ≤2 short steps (≤90 chars each). Total adult involvement
   ≤ 8 minutes. (The child may stay much longer; the adult sits and observes.)

SENSITIVE PERIODS (use these ids verbatim in your output):
${periodLines}

MONTESSORI CATEGORIES (pick exactly one id):
${categoryLines}

VOICE: warm, specific, ≤2 line "why" the parent will actually read. No
buzzwords. No "engaging your child's curiosity". Concrete: "she's matching
everything right now" / "his hands want real work".

OUTPUT — strict JSON object, nothing else (no markdown, no prose):
{
  "title": "<≤40 chars, e.g. 'Sock-matching basket'>",
  "why": "<≤140 chars, one warm sentence about what this matches in ${member.firstName} right now>",
  "setup_steps": ["<step 1, ≤90 chars>", "<step 2, ≤90 chars>"],
  "category": "<exactly one category id>",
  "sensitive_periods": ["<one or more period ids>"],
  "setup_minutes": <integer 1-8>
}`;

  const user = `${ageLine}

Recent observations Mom has logged (most recent first):
${obsLines}

${yesterdayLine}

Compose today's Invitation.`;

  const client = new Anthropic({ apiKey });
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 500,
    temperature: 0.85,
    system,
    messages: [{ role: "user", content: user }],
  });

  const block = response.content.find((b) => b.type === "text");
  if (!block) return null;
  const raw = block.text.trim();
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const title = stringClamp(parsed.title, 40);
    const why = stringClamp(parsed.why, 140);
    const stepsRaw = Array.isArray(parsed.setup_steps) ? parsed.setup_steps : [];
    const setupSteps = stepsRaw
      .filter((s): s is string => typeof s === "string")
      .map((s) => stringClamp(s, 90))
      .filter((s) => s.length > 0)
      .slice(0, 2);
    const category = sanitiseCategory(parsed.category);
    const periods = sanitisePeriods(parsed.sensitive_periods);
    const minutes = sanitiseMinutes(parsed.setup_minutes);
    if (!title || !why || setupSteps.length === 0 || !category) return null;
    return {
      title,
      why,
      setupSteps,
      category,
      sensitivePeriods: periods,
      setupMinutes: minutes,
    };
  } catch (e) {
    functions.logger.warn("[invitation] parse failed", {
      raw: raw.slice(0, 400),
      err: String(e),
    });
    return null;
  }
}

function adjustHint(
  feedback: "loved" | "lost_interest" | "too_early" | null
): string {
  switch (feedback) {
    case "loved":
      return "press on this thread — same category, slightly more complex variation";
    case "lost_interest":
      return "switch category. Try something different — likely a different sensitive period is calling";
    case "too_early":
      return "revisit later. Pick something more foundational she's already showing readiness for";
    default:
      return "freely choose";
  }
}

function stringClamp(v: unknown, n: number): string {
  if (typeof v !== "string") return "";
  return v.trim().slice(0, n);
}

function sanitiseCategory(v: unknown): MontessoriCategoryId | null {
  if (typeof v !== "string") return null;
  if (v in MONTESSORI_CATEGORIES) return v as MontessoriCategoryId;
  return null;
}

function sanitisePeriods(v: unknown): SensitivePeriodId[] {
  if (!Array.isArray(v)) return [];
  const allowed = new Set(Object.keys(SENSITIVE_PERIODS));
  return v
    .filter((p): p is string => typeof p === "string")
    .filter((p) => allowed.has(p))
    .slice(0, 3) as SensitivePeriodId[];
}

function sanitiseMinutes(v: unknown): number {
  if (typeof v !== "number") return 5;
  return Math.max(1, Math.min(8, Math.round(v)));
}

function todayKey(): string {
  return new Date().toISOString().slice(0, 10);
}

function addDaysIso(dayKey: string, delta: number): string {
  const d = new Date(`${dayKey}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + delta);
  return d.toISOString().slice(0, 10);
}

function startOfIsoWeekUtc(): Date {
  const now = new Date();
  const day = now.getUTCDay() || 7; // Monday = 1, Sunday = 7
  const monday = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  monday.setUTCDate(monday.getUTCDate() - (day - 1));
  return monday;
}

function serialise(id: string, raw: Record<string, unknown>) {
  const generatedAt = raw.generatedAt as admin.firestore.Timestamp | undefined;
  const triedAt = raw.triedAt as admin.firestore.Timestamp | undefined;
  const feedbackAt = raw.feedbackAt as admin.firestore.Timestamp | undefined;
  return {
    id,
    memberId: (raw.memberId as string) ?? "",
    date: (raw.date as string) ?? "",
    title: (raw.title as string) ?? "",
    whyOneLine: (raw.whyOneLine as string) ?? "",
    setupSteps: Array.isArray(raw.setupSteps) ? (raw.setupSteps as string[]) : [],
    category: (raw.category as string) ?? "practical_life",
    sensitivePeriods: Array.isArray(raw.sensitivePeriods)
      ? (raw.sensitivePeriods as string[])
      : [],
    ageMonthsAtComposition: (raw.ageMonthsAtComposition as number | null) ?? null,
    setupMinutes: (raw.setupMinutes as number) ?? 5,
    generatedAt: generatedAt ? generatedAt.toDate().toISOString() : null,
    triedAt: triedAt ? triedAt.toDate().toISOString() : null,
    feedback: (raw.feedback as string | null) ?? null,
    feedbackAt: feedbackAt ? feedbackAt.toDate().toISOString() : null,
  };
}
