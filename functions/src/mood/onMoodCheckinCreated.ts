import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import { scanForCrisis } from "./crisisKeywords";
import { generateMoodReply } from "./respondToMood";

/**
 * Trigger: enrich a freshly written mood check-in.
 *
 * Two-write flow on purpose:
 *   1. Crisis scan + flag + moodState/summary rollup (fast, sync work
 *      Mom needs the UI to react to immediately — crisis escalation
 *      buttons must surface even if Claude is slow or unreachable).
 *   2. Claude "warm friend" reply persisted on the same check-in doc
 *      (slower, optional — failure here never blocks step 1).
 *
 * The client subscribes to the doc and renders progressively: thinking
 * pill → reply text once aiReply lands.
 */

interface CheckinDoc {
  level?: number;
  note?: string;
  voiceUrl?: string;
  voiceTranscript?: string;
  createdAt?: admin.firestore.Timestamp;
}

interface SummaryDoc {
  last7DaysAvg: number | null;
  last30DaysAvg: number | null;
  count7: number;
  count30: number;
  streakHardDays: number;
  trend: "improving" | "stable" | "declining" | "unknown";
  lastCheckinAt: admin.firestore.Timestamp | null;
  lastCheckinLevel: number | null;
  hasUnacknowledgedCrisis: boolean;
  updatedAt: admin.firestore.FieldValue;
}

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const HARD_DAY_THRESHOLD = 2; // levels 1 ("drowning") and 2 ("hard") count as hard

export const onMoodCheckinCreated = functions
  .runWith({
    secrets: ["ANTHROPIC_API_KEY"],
    memory: "256MB",
    timeoutSeconds: 30,
  })
  .firestore.document("users/{uid}/moodCheckins/{checkinId}")
  .onCreate(async (snap, context) => {
    const uid = context.params.uid as string;
    const checkinId = context.params.checkinId as string;
    const data = snap.data() as CheckinDoc | undefined;
    if (!data) return;

    const db = admin.firestore();

    // 1) Crisis scan against any free-text the user provided. v1 ships
    // with note only; the voice transcript field is wired here so the
    // Tuesday voice-memo work just writes `voiceTranscript` and the
    // scan picks it up without any change to this trigger.
    const haystack = [data.note ?? "", data.voiceTranscript ?? ""]
      .filter((s) => s && s.length > 0)
      .join("\n");
    const crisis = scanForCrisis(haystack);

    const checkinUpdate: Record<string, unknown> = {
      enrichedAt: admin.firestore.FieldValue.serverTimestamp(),
      flaggedCrisis: crisis.matched,
    };
    if (crisis.matched) {
      checkinUpdate.crisisPhrase = crisis.phrase;
      checkinUpdate.crisisLocale = crisis.locale;
      // Operational logging only — no content, just count + locale.
      functions.logger.warn("[mood] crisis phrase detected", {
        uid,
        checkinId,
        locale: crisis.locale,
      });
    }

    await snap.ref.update(checkinUpdate);

    // 2) Recompute the rolling summary from the last 30 days of
    // check-ins. We query all of them (cap 200) and fold in-memory —
    // this collection is tiny per user and the alternative (transactions
    // + counter docs) is more failure-prone than it's worth at our
    // current scale.
    const cutoff30 = admin.firestore.Timestamp.fromMillis(
      Date.now() - 30 * MS_PER_DAY
    );
    const recent = await db
      .collection(`users/${uid}/moodCheckins`)
      .where("createdAt", ">=", cutoff30)
      .orderBy("createdAt", "desc")
      .limit(200)
      .get();

    const rows: { level: number; createdAt: Date; flagged: boolean }[] = [];
    for (const doc of recent.docs) {
      const d = doc.data() as CheckinDoc & { flaggedCrisis?: boolean };
      const level = typeof d.level === "number" ? d.level : null;
      const created = d.createdAt?.toDate() ?? null;
      if (level == null || created == null) continue;
      rows.push({
        level,
        createdAt: created,
        flagged: d.flaggedCrisis === true,
      });
    }
    // The newly-created doc may not yet appear in the query result
    // (Firestore secondary index can lag). Patch it in so the summary
    // is internally consistent on the very first check-in.
    const justNow = data.createdAt?.toDate() ?? new Date();
    const alreadyIncluded = rows.some(
      (r) => Math.abs(r.createdAt.getTime() - justNow.getTime()) < 500
    );
    if (typeof data.level === "number" && !alreadyIncluded) {
      rows.unshift({
        level: data.level,
        createdAt: justNow,
        flagged: crisis.matched,
      });
    }

    const now = Date.now();
    const last7 = rows.filter(
      (r) => now - r.createdAt.getTime() <= 7 * MS_PER_DAY
    );
    const last30 = rows; // already capped above

    const avg = (arr: typeof rows) =>
      arr.length === 0 ? null : arr.reduce((s, r) => s + r.level, 0) / arr.length;

    // Hard-day streak: walk back day-by-day from today; for each day,
    // pick the most recent check-in (avoids double-counting) and stop
    // when we hit a day with a level above the threshold or no entry.
    const streakHardDays = computeHardStreak(rows);

    // Trend: compare avg of the most recent 3 entries to the 4 before.
    // Small windows are noisy on purpose — Today's Debrief should only
    // ever surface a strong signal.
    const trend = computeTrend(rows);

    // Unacknowledged crisis: any flagged check-in in the last 24h. The
    // "ack" mechanism is the user opening the mood thread (Thursday
    // work); for Monday it's enough to surface the flag itself.
    const hasUnacknowledgedCrisis = rows.some(
      (r) => r.flagged && now - r.createdAt.getTime() < MS_PER_DAY
    );

    const summary: SummaryDoc = {
      last7DaysAvg: avg(last7),
      last30DaysAvg: avg(last30),
      count7: last7.length,
      count30: last30.length,
      streakHardDays,
      trend,
      lastCheckinAt: data.createdAt ?? null,
      lastCheckinLevel: typeof data.level === "number" ? data.level : null,
      hasUnacknowledgedCrisis,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.doc(`users/${uid}/moodState/summary`).set(summary, { merge: true });

    // 3) Warm-friend reply. Best-effort: if Anthropic is unreachable,
    // billing-out, or slow we drop the reply quietly. The Home card
    // falls back to "Balam's writing back…" indefinitely on this
    // path — better than a wrong-toned canned message in a moment
    // that needs to be right.
    try {
      const userDoc = await db.doc(`users/${uid}`).get();
      const userData = userDoc.data() ?? {};
      const locale = normalizeLocale(userData.localeCode);

      const momDisplayName =
        typeof userData.displayName === "string" ? userData.displayName : "";
      const momFirstName = momDisplayName.split(" ")[0]?.trim() || null;

      const members = (userData.members as Record<string, unknown>[] | undefined) ?? [];
      const child = pickPrimaryChild(members, userData.selectedMemberId as string | undefined);

      const reply = await generateMoodReply({
        level: typeof data.level === "number" ? data.level : 3,
        note: data.note ?? null,
        voiceTranscript: data.voiceTranscript ?? null,
        momFirstName,
        childFirstName: child?.firstName ?? null,
        childAgeMonths: child?.ageMonths ?? null,
        locale,
        flaggedCrisis: crisis.matched,
      });

      if (reply && reply.length > 0) {
        await snap.ref.update({
          aiReply: reply,
          aiRepliedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      functions.logger.warn("[mood] aiReply skipped", {
        uid,
        checkinId,
        err: String(e),
      });
    }
  });

function pickPrimaryChild(
  members: Record<string, unknown>[],
  selectedMemberId: string | undefined
): { firstName: string; ageMonths: number | null } | null {
  if (members.length === 0) return null;
  const isChild = (m: Record<string, unknown>) => m?.role === "child";

  // Prefer the explicitly-selected member if it's a child.
  let pick: Record<string, unknown> | undefined;
  if (selectedMemberId) {
    pick = members.find((m) => m.id === selectedMemberId && isChild(m));
  }
  pick ??= members.find(isChild);
  if (!pick) return null;

  const name = typeof pick.name === "string" ? pick.name : "";
  const firstName = name.split(" ")[0]?.trim() || "";
  if (!firstName) return null;

  let ageMonths: number | null = null;
  const birth = pick.birthDate;
  if (typeof birth === "string") {
    const dob = Date.parse(birth);
    if (!Number.isNaN(dob)) {
      ageMonths = Math.max(0, Math.floor((Date.now() - dob) / (30.44 * MS_PER_DAY)));
    }
  }
  return { firstName, ageMonths };
}

function normalizeLocale(raw: unknown): "en" | "ru" | "ky" {
  if (raw === "ru" || raw === "ky") return raw;
  return "en";
}

function computeHardStreak(
  rows: { level: number; createdAt: Date }[]
): number {
  if (rows.length === 0) return 0;
  // Bucket by local-UTC date string. We walk back from today's bucket.
  const byDay = new Map<string, number>(); // dayKey -> min level that day
  for (const r of rows) {
    const key = dayKey(r.createdAt);
    const cur = byDay.get(key);
    if (cur == null || r.level < cur) {
      byDay.set(key, r.level);
    }
  }
  let streak = 0;
  for (let i = 0; i < 30; i++) {
    const d = new Date(Date.now() - i * MS_PER_DAY);
    const key = dayKey(d);
    const level = byDay.get(key);
    if (level == null) break;
    if (level <= HARD_DAY_THRESHOLD) {
      streak += 1;
    } else {
      break;
    }
  }
  return streak;
}

function computeTrend(
  rows: { level: number; createdAt: Date }[]
): SummaryDoc["trend"] {
  if (rows.length < 5) return "unknown";
  const sorted = [...rows].sort(
    (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
  );
  const recent3 = sorted.slice(0, 3);
  const prior4 = sorted.slice(3, 7);
  if (prior4.length === 0) return "unknown";
  const avgRecent = recent3.reduce((s, r) => s + r.level, 0) / recent3.length;
  const avgPrior = prior4.reduce((s, r) => s + r.level, 0) / prior4.length;
  const delta = avgRecent - avgPrior;
  if (delta >= 0.5) return "improving";
  if (delta <= -0.5) return "declining";
  return "stable";
}

function dayKey(d: Date): string {
  return d.toISOString().slice(0, 10); // YYYY-MM-DD UTC
}
