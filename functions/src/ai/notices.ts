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
