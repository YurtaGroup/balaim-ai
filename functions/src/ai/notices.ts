// The App That Notices — proactive nudges engine.
//
// Engine 1 (schedule): evaluates every household member against the
// milestone table in ../data/milestones.ts. For each milestone whose
// `applies()` predicate fires AND that hasn't fired for this member
// within its `repeatIntervalDays` window, writes a notice to Firestore.
//
// Engine 2 (trend): queried separately from tracking data. Not yet
// implemented — day-2 scope.
//
// Design choices worth knowing:
// - The engine ships FULLY FUNCTIONAL without any Claude call.
//   Template copy from milestones.ts is written verbatim. This is
//   intentional so the feature survives Anthropic credit outages.
// - Claude enhancement is opt-in per invocation and degrades to
//   templates on any failure.
// - Dedup is based on (memberId, milestoneId, lastFiredAt) in the
//   `notices/{uid}/_state/{memberId-milestoneId}` sentinel doc,
//   NOT on reading back the user-facing notices collection. This
//   keeps the dedup cheap and survives user dismissal / deletion.

import * as admin from "firebase-admin";
import { ALL_MILESTONES, MemberSnapshot, Milestone, L3 } from "../data/milestones";

export interface NoticeDocument {
  memberId: string;
  memberName: string;
  milestoneId: string;
  type: "schedule" | "trend";
  urgency: "low" | "medium" | "high";
  title: L3;
  body: L3;
  action: { route: string; label: L3 };
  createdAt: admin.firestore.FieldValue;
  dismissedAt?: admin.firestore.Timestamp;
  actedAt?: admin.firestore.Timestamp;
}

export interface RunResult {
  householdsEvaluated: number;
  membersEvaluated: number;
  noticesFired: number;
  noticesSuppressed: number;
  errors: string[];
}

/** Evaluate all users' households and fire any pending schedule notices.
 * Safe to call on demand or on a cron. Idempotent within
 * `repeatIntervalDays` of the last fire of each (member, milestone) pair. */
export async function runScheduleEngineForAllUsers(): Promise<RunResult> {
  const db = admin.firestore();
  const usersSnap = await db.collection("users").get();

  const result: RunResult = {
    householdsEvaluated: 0,
    membersEvaluated: 0,
    noticesFired: 0,
    noticesSuppressed: 0,
    errors: [],
  };

  for (const userDoc of usersSnap.docs) {
    try {
      const r = await runScheduleEngineForUser(userDoc.id, userDoc.data());
      result.householdsEvaluated += 1;
      result.membersEvaluated += r.membersEvaluated;
      result.noticesFired += r.noticesFired;
      result.noticesSuppressed += r.noticesSuppressed;
    } catch (e) {
      result.errors.push(`uid=${userDoc.id}: ${String(e)}`);
    }
  }
  return result;
}

/** Run the engine for a single user. Exposed for the callable variant
 * so a specific account can be tested end-to-end without a full fleet run. */
export async function runScheduleEngineForUser(
  uid: string,
  userData: Record<string, unknown>
): Promise<Pick<RunResult, "membersEvaluated" | "noticesFired" | "noticesSuppressed">> {
  const db = admin.firestore();
  const now = new Date();

  const members = parseMembers(userData);
  let fired = 0;
  let suppressed = 0;

  for (const member of members) {
    for (const milestone of ALL_MILESTONES) {
      if (!milestone.applies(member, now)) continue;

      const stateKey = `${member.id}-${milestone.id}`;
      const stateRef = db.doc(`notices/${uid}/_state/${stateKey}`);
      const stateSnap = await stateRef.get();
      const lastFiredAt = (stateSnap.data()?.lastFiredAt as admin.firestore.Timestamp | undefined)
        ?.toDate();

      // Dedup: first-fire OR re-fire interval elapsed
      const shouldFire =
        !lastFiredAt ||
        (milestone.repeatIntervalDays != null &&
          (now.getTime() - lastFiredAt.getTime()) / (1000 * 60 * 60 * 24) >=
            milestone.repeatIntervalDays);

      if (!shouldFire) {
        suppressed += 1;
        continue;
      }

      await writeNotice(uid, member, milestone);
      await stateRef.set(
        { lastFiredAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );
      fired += 1;
    }
  }

  return { membersEvaluated: members.length, noticesFired: fired, noticesSuppressed: suppressed };
}

function parseMembers(userData: Record<string, unknown>): MemberSnapshot[] {
  const rawList = (userData.members as unknown[]) ??
    (userData.children as unknown[]) ?? // legacy key
    [];
  return rawList
    .filter((m): m is Record<string, unknown> => typeof m === "object" && m !== null)
    .map((m) => ({
      id: String(m.id ?? ""),
      name: String(m.name ?? ""),
      role: (String(m.role ?? "child") as MemberSnapshot["role"]),
      birthDate: typeof m.birthDate === "string" ? m.birthDate : undefined,
      conditions: Array.isArray(m.conditions) ? (m.conditions as string[]) : undefined,
      gender: typeof m.gender === "string" ? m.gender : undefined,
    }))
    .filter((m) => m.id);
}

async function writeNotice(
  uid: string,
  member: MemberSnapshot,
  milestone: Milestone
): Promise<void> {
  const db = admin.firestore();
  const docRef = db.collection(`notices/${uid}/items`).doc();
  const notice: NoticeDocument = {
    memberId: member.id,
    memberName: member.name,
    milestoneId: milestone.id,
    type: "schedule",
    urgency: milestone.urgency,
    title: milestone.title,
    body: milestone.body,
    action: {
      route: milestone.action.route,
      label: milestone.action.label,
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await docRef.set(notice);
}

// ─── Engine 2: trend ──────────────────────────────────────────────
//
// Queries last 14 days of tracking entries per household member and
// fires notices when a clinically meaningful pattern shows up. Like
// Engine 1, ships with template copy (trilingual) and can be enhanced
// by Claude when Anthropic credit is available.
//
// Dedup: uses the same _state/{memberId-milestoneId} pattern but with
// synthetic "milestone" ids prefixed `trend-`. Re-fires after 7 days
// to avoid spamming if the pattern persists.

const TREND_DEDUP_INTERVAL_DAYS = 7;

interface TrackingEntry {
  memberId?: string;
  type: string;
  value?: number;
  timestamp: string;
  metadata?: Record<string, unknown>;
}

interface TrendHit {
  milestoneId: string; // e.g. 'trend-adult-bp-stage2'
  urgency: "low" | "medium" | "high";
  title: L3;
  body: L3;
  action: { route: string; label: L3 };
}

export async function runTrendEngineForUser(
  uid: string,
  userData: Record<string, unknown>
): Promise<Pick<RunResult, "membersEvaluated" | "noticesFired" | "noticesSuppressed">> {
  const db = admin.firestore();
  const now = new Date();
  const members = parseMembers(userData);

  const fourteenDaysAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);
  const trackingSnap = await db
    .collection(`users/${uid}/tracking`)
    .where("timestamp", ">=", fourteenDaysAgo.toISOString())
    .get();

  const entriesByMember = new Map<string, TrackingEntry[]>();
  for (const doc of trackingSnap.docs) {
    const d = doc.data() as TrackingEntry;
    // Entries with no memberId are pre-household-model legacy — skip for trend.
    if (!d.memberId) continue;
    const list = entriesByMember.get(d.memberId) ?? [];
    list.push(d);
    entriesByMember.set(d.memberId, list);
  }

  let fired = 0;
  let suppressed = 0;

  for (const member of members) {
    const entries = entriesByMember.get(member.id) ?? [];
    const hits = evaluateTrends(member, entries, now);
    for (const hit of hits) {
      const stateKey = `${member.id}-${hit.milestoneId}`;
      const stateRef = db.doc(`notices/${uid}/_state/${stateKey}`);
      const stateSnap = await stateRef.get();
      const lastFiredAt = (stateSnap.data()?.lastFiredAt as admin.firestore.Timestamp | undefined)
        ?.toDate();

      const shouldFire =
        !lastFiredAt ||
        (now.getTime() - lastFiredAt.getTime()) / (1000 * 60 * 60 * 24) >=
          TREND_DEDUP_INTERVAL_DAYS;

      if (!shouldFire) {
        suppressed += 1;
        continue;
      }

      await writeTrendNotice(uid, member, hit);
      await stateRef.set(
        { lastFiredAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );
      fired += 1;
    }
  }

  return { membersEvaluated: members.length, noticesFired: fired, noticesSuppressed: suppressed };
}

function evaluateTrends(member: MemberSnapshot, entries: TrackingEntry[], now: Date): TrendHit[] {
  const hits: TrendHit[] = [];
  const isChild = member.role === "child";

  // Helper: values of a type, most recent first
  const valuesOfType = (type: string) =>
    entries.filter((e) => e.type === type && typeof e.value === "number");

  if (!isChild) {
    // BP stage 2 — 3+ readings in last 14 days with systolic >= 140
    const bp = valuesOfType("bloodPressure");
    const stage2 = bp.filter((e) => (e.value ?? 0) >= 140);
    if (stage2.length >= 3) {
      hits.push({
        milestoneId: "trend-adult-bp-stage2",
        urgency: "high",
        title: {
          en: `${member.name}'s blood pressure keeps running high`,
          ru: `У ${member.name} давление стабильно повышенное`,
          ky: `${member.name}нын басымы туруктуу жогору`,
        },
        body: {
          en: `Balam has seen ${stage2.length} readings of systolic ${Math.round(avg(stage2))} or above in the last 14 days. That's Stage 2 hypertension — not an emergency right now, but persistent at that level warrants a same-week conversation with a doctor. Don't change any medication without talking to the prescriber.`,
          ru: `Balam видит ${stage2.length} показателя систолического давления ${Math.round(avg(stage2))} и выше за последние 14 дней. Это гипертония 2 стадии — не экстренно прямо сейчас, но устойчиво такие значения требуют разговора с врачом в ближайшую неделю. Не меняй лекарства без врача.`,
          ky: `Balam акыркы 14 күндө ${stage2.length} жолу ${Math.round(avg(stage2))} жана андан жогору систолалык басым көрдү. Бул 2-стадиядагы гипертония — азыр тез жардам керек эмес, бирок туруктуу мындай маанилер жума ичинде дарыгер менен сүйлөшүүнү талап кылат. Дарылар дарыгерсиз өзгөртпөңүз.`,
        },
        action: {
          route: "/professionals",
          label: {
            en: "Consult a doctor",
            ru: "Консультация врача",
            ky: "Дарыгер менен кеңеш",
          },
        },
      });
    }

    // Fasting glucose elevated — 2+ readings >= 126 in last 14 days
    const glucose = valuesOfType("bloodGlucose");
    const elevated = glucose.filter((e) => (e.value ?? 0) >= 126);
    if (elevated.length >= 2) {
      hits.push({
        milestoneId: "trend-adult-glucose-diabetic",
        urgency: "high",
        title: {
          en: `${member.name}'s fasting glucose is in the diabetic range`,
          ru: `Глюкоза натощак у ${member.name} — диабетический диапазон`,
          ky: `${member.name}нын ачкарын глюкозасы диабеттик диапазондо`,
        },
        body: {
          en: `${elevated.length} fasting readings at ${Math.round(avg(elevated))} or above in the last 14 days. Fasting glucose 126+ is the clinical threshold for diabetes. The right next step is an endocrinology consult — Jane Mone NP (trilingual) is the in-app option, or any GP.`,
          ru: `${elevated.length} показателей натощак ${Math.round(avg(elevated))} и выше за 14 дней. Глюкоза натощак 126+ — клинический порог диабета. Следующий шаг — консультация эндокринолога. В приложении это Джейн Мон (трёхязычная), или любой терапевт.`,
          ky: `Акыркы 14 күндө ${elevated.length} жолу ачкарын глюкоза ${Math.round(avg(elevated))} жана андан жогору. Ачкарын глюкоза 126+ — диабеттин клиникалык чеги. Кийинки туура кадам — эндокринолог менен кеңеш. Колдонмодо бул Джейн Мон (үч тилде), же каалаган терапевт.`,
        },
        action: {
          route: "/professionals",
          label: {
            en: "Consult an endocrinologist",
            ru: "К эндокринологу",
            ky: "Эндокринолог менен",
          },
        },
      });
    }
  }

  if (isChild) {
    // Weight plateau / loss for a baby under 12 months
    const am = ageMonthsOf(member, now);
    if (am != null && am < 12) {
      const weight = valuesOfType("weight").sort((a, b) => a.timestamp.localeCompare(b.timestamp));
      if (weight.length >= 2) {
        const oldest = weight[0];
        const newest = weight[weight.length - 1];
        const daysBetween =
          (new Date(newest.timestamp).getTime() - new Date(oldest.timestamp).getTime()) /
          (1000 * 60 * 60 * 24);
        const pctChange = ((newest.value! - oldest.value!) / oldest.value!) * 100;
        if (daysBetween >= 14 && pctChange < 2) {
          hits.push({
            milestoneId: "trend-baby-weight-plateau",
            urgency: "medium",
            title: {
              en: `${member.name}'s weight has plateaued`,
              ru: `Вес ${member.name} не прибавляется`,
              ky: `${member.name}нын салмагы өспөй жатат`,
            },
            body: {
              en: `Under a year old, steady weight gain is the biggest day-to-day signal that feeding is going well. ${member.name} has gone ${Math.round(daysBetween)} days with essentially no gain. Could be nothing (measurement variation, an off week), could be a sign feeding is off — worth a pediatrician's eyes this week.`,
              ru: `До года устойчивый набор веса — главный ежедневный сигнал, что с кормлением всё в порядке. ${member.name} ${Math.round(daysBetween)} дней практически не прибавил в весе. Может быть, ничего (погрешность измерений, сложная неделя), а может — сигнал о проблеме с кормлением. На этой неделе стоит показать педиатру.`,
              ky: `1 жашка чейин салмактын туруктуу өсүшү — тамактануу жакшы жүрүп жаткандыгынын эң негизги белгиси. ${member.name} ${Math.round(daysBetween)} күн бою дээрлик салмак кошкон жок. Эч нерсе эмес болушу мүмкүн (ченөө каталары, оор жума), бирок тамактануу менен көйгөй белгиси да болушу мүмкүн — ушул жумада педиатрга көрсөтүү керек.`,
            },
            action: {
              route: "/professionals",
              label: {
                en: "Book a pediatrician",
                ru: "Записаться к педиатру",
                ky: "Педиатрга жазылуу",
              },
            },
          });
        }
      }
    }
  }

  return hits;
}

function ageMonthsOf(m: MemberSnapshot, now: Date): number | null {
  if (!m.birthDate) return null;
  const bd = new Date(m.birthDate);
  return (now.getTime() - bd.getTime()) / (1000 * 60 * 60 * 24 * 30.44);
}

function avg(entries: TrackingEntry[]): number {
  if (entries.length === 0) return 0;
  const sum = entries.reduce((s, e) => s + (e.value ?? 0), 0);
  return sum / entries.length;
}

async function writeTrendNotice(uid: string, member: MemberSnapshot, hit: TrendHit): Promise<void> {
  const db = admin.firestore();
  const docRef = db.collection(`notices/${uid}/items`).doc();
  const notice: NoticeDocument = {
    memberId: member.id,
    memberName: member.name,
    milestoneId: hit.milestoneId,
    type: "trend",
    urgency: hit.urgency,
    title: hit.title,
    body: hit.body,
    action: hit.action,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await docRef.set(notice);
}
