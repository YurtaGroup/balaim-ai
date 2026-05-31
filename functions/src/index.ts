import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { balamChat as balamChatInternal } from "./ai/balam-chat";
import { isPremiumPersona, isValidPersonaId } from "./ai/personas";
import { generateDailyInsight } from "./ai/daily-insights";
import { generateDailyBrief, BriefMember } from "./ai/daily-brief";
import { retrieveVaultContext } from "./ai/vault_retrieval";
import {
  runScheduleEngineForAllUsers,
  runScheduleEngineForUser,
  runTrendEngineForUser,
} from "./ai/notices";
import {
  classifyAndRecord,
  BoxReading,
  ReadingType,
} from "./ai/box_interpretation";
import { MemberSnapshot } from "./data/milestones";
import { buildOnVaultItemCreated } from "./ai/vault_ingest";
import { onMoodCheckinCreated as onMoodCheckinCreatedImpl } from "./mood/onMoodCheckinCreated";
import { onObservationCreated as onObservationCreatedImpl } from "./montessori/onObservationCreated";
import { generateDailyInvitation as generateDailyInvitationImpl } from "./montessori/generateDailyInvitation";
import { setPremiumFromReceipt as setPremiumFromReceiptImpl } from "./billing/setPremiumFromReceipt";
import { setDoctorClaim as setDoctorClaimImpl } from "./admin/setDoctorClaim";
import { screenConsultDraft as screenConsultDraftImpl } from "./consult/screenConsultDraft";
import { generateDoctorBrief as generateDoctorBriefImpl } from "./consult/generateDoctorBrief";
import { generateFollowUps as generateFollowUpsImpl } from "./consult/generateFollowUps";
import { onConsultMessageCreated as onConsultMessageCreatedImpl } from "./consult/onConsultMessageCreated";
import {
  scheduledSundayChapters as scheduledSundayChaptersImpl,
  generateSundayChapterManual as generateSundayChapterManualImpl,
} from "./jobs/sunday_chapter";

admin.initializeApp();

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

// ============================================================
// RATE LIMITS (beta-safe caps)
// ============================================================
//
// Per-user daily cap: keeps a single enthusiastic tester from burning
// through $10 of Claude credit in an afternoon.
// Global daily cap: hard kill-switch — if the entire beta cohort
// collectively exceeds this, every further call returns a friendly
// "try again tomorrow" message without touching Anthropic.
// Both counters live in Firestore under `usage/...` and reset at UTC
// midnight by key (no explicit cleanup job needed — stale docs are fine).

const MAX_PER_USER_PER_DAY = 30;   // ~$0.25-$1 per user / day worst case
const MAX_GLOBAL_PER_DAY = 500;    // hard ceiling across all beta users

function todayKey(): string {
  // YYYY-MM-DD UTC
  return new Date().toISOString().slice(0, 10);
}

interface RateLimitResult {
  allowed: boolean;
  reason?: "user_limit" | "global_limit";
  userCount?: number;
  globalCount?: number;
}

async function checkAndIncrementRateLimit(uid: string): Promise<RateLimitResult> {
  const db = admin.firestore();
  const day = todayKey();
  const userRef = db.doc(`usage/${uid}/daily/${day}`);
  const globalRef = db.doc(`usage/_global/daily/${day}`);

  return db.runTransaction<RateLimitResult>(async (tx) => {
    const [userSnap, globalSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(globalRef),
    ]);
    const userCount = ((userSnap.data() ?? {}).count as number) ?? 0;
    const globalCount = ((globalSnap.data() ?? {}).count as number) ?? 0;

    if (userCount >= MAX_PER_USER_PER_DAY) {
      return { allowed: false, reason: "user_limit", userCount, globalCount };
    }
    if (globalCount >= MAX_GLOBAL_PER_DAY) {
      return { allowed: false, reason: "global_limit", userCount, globalCount };
    }

    tx.set(userRef, { count: userCount + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    tx.set(globalRef, { count: globalCount + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return { allowed: true, userCount: userCount + 1, globalCount: globalCount + 1 };
  });
}

function rateLimitMessage(locale: string, reason: "user_limit" | "global_limit"): string {
  if (reason === "user_limit") {
    switch (locale) {
      case "ru":
        return "Ты достиг(ла) дневного лимита сообщений Balam AI. Попробуй завтра — или запиши вопрос на консультацию к врачу прямо сейчас.";
      case "ky":
        return "Balam AI'нын күндүк билдирүү чегине жеттиңиз. Эртең кайра аракет кылыңыз — же азыр эле дарыгер менен кеңешип алыңыз.";
      default:
        return "You have reached today's Balam AI message limit. Try again tomorrow — or start a consult with a real doctor right now.";
    }
  }
  // global_limit
  switch (locale) {
    case "ru":
      return "Balam AI сейчас занят — отвечает большому числу семей. Попробуй снова через час.";
    case "ky":
      return "Balam AI азыр көптөгөн үй-бүлөлөргө жооп берип жатат. Бир саатан кийин кайра аракет кылыңыз.";
    default:
      return "Balam AI is serving a lot of families right now. Please try again in an hour.";
  }
}

function friendlyErrorMessage(locale: string): string {
  switch (locale) {
    case "ru":
      return "Я сейчас немного перегружен. Попробуй задать вопрос ещё раз через пару минут. 💕";
    case "ky":
      return "Азыр бир аз оорчулугум бар. Бир-эки мүнөттөн кийин кайра сурасаң, жардам бере алам. 💕";
    default:
      return "I'm having a moment right now. Please try again in a couple of minutes. 💕";
  }
}

// ============================================================
// FREE-TIER GATE (the SaaS line)
// ============================================================
//
// Free plan: 3 Balam AI questions per ISO week. Balam Premium:
// unlimited. This is the authoritative, server-side gate — the
// client cannot forge its way past it. Premium status is read from
// `users/{uid}.premium`, which a RevenueCat webhook keeps in sync
// (see ONBOARDING / Phase 3 notes). Counter doc:
// `usage/{uid}/weekly/{YYYY-Www}` — resets by key, no cleanup job.

const MAX_FREE_AI_PER_WEEK = 3;

function isoWeekKey(): string {
  const now = new Date();
  const date = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate())
  );
  const dayNum = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(
    ((date.getTime() - yearStart.getTime()) / 86400000 + 1) / 7
  );
  return `${date.getUTCFullYear()}-W${String(weekNo).padStart(2, "0")}`;
}

/** Authoritative premium check — never trust the client. */
async function isPremium(uid: string): Promise<boolean> {
  try {
    const snap = await admin.firestore().doc(`users/${uid}`).get();
    return (snap.data()?.premium as boolean) === true;
  } catch {
    return false;
  }
}

/** Returns false (and does NOT increment) once the free user is over the weekly cap. */
async function checkAndIncrementWeekly(uid: string): Promise<boolean> {
  const db = admin.firestore();
  const ref = db.doc(`usage/${uid}/weekly/${isoWeekKey()}`);
  return db.runTransaction<boolean>(async (tx) => {
    const snap = await tx.get(ref);
    const count = ((snap.data() ?? {}).count as number) ?? 0;
    if (count >= MAX_FREE_AI_PER_WEEK) return false;
    tx.set(
      ref,
      { count: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );
    return true;
  });
}

function freeTierMessage(locale: string): string {
  switch (locale) {
    case "ru":
      return "Ты использовал(а) бесплатные вопросы Balam на этой неделе. Открой Balam Premium — безлимитные вопросы о здоровье и развитии ребёнка. 🐆";
    case "ky":
      return "Бул жумада Balam'дын акысыз суроолорун колдондуңуз. Balam Premium'ду ачыңыз — бала ден соолугу боюнча чексиз суроолор. 🐆";
    default:
      return "You've used your free Balam questions for this week. Unlock Balam Premium for unlimited questions about your child's health and development. 🐆";
  }
}

// ============================================================
// AI ENDPOINTS
// ============================================================

/**
 * Balam AI Chat — personalized parenting AI powered by Claude.
 *
 * 2nd-gen callable function (avoids the missing default Compute Engine
 * service account that blocks 1st-gen deploys on this project).
 *
 * Accepts: { message, userContext: { locale, briefMode, stage, week, babyName, ageMonths, recentTracking }, history: [{role, text}] }
 * Returns: { response: string, triage: { urgency, reason } | null }
 */
export const balamChat = onCall(
  { secrets: [anthropicKey], region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be signed in to use Balam AI"
      );
    }

    const { message, userContext, history } = request.data as {
      message?: string;
      userContext?: Record<string, unknown>;
      history?: unknown;
    };

    if (!message || typeof message !== "string") {
      throw new HttpsError("invalid-argument", "Message is required");
    }

    const locale = (userContext?.locale as string) ?? "en";
    const uid = request.auth.uid;

    // Emergency mode (M3). The client sets this when the chat originated
    // from the red emergency button. We force AI Pediatrician, force
    // brief mode (panicked parents need short answers), and bypass the
    // weekly free-tier gate so the 3am promise stays unconditional. The
    // per-user / global daily cost caps still apply — those are
    // cost-protection, not a SaaS lever.
    const emergencyMode = userContext?.emergencyMode === true;

    // Persona selection (M1 + M3). Validate against the registry; unknown
    // ids silently fall back to Balam (the free default). Premium personas
    // require the premium entitlement — for a free user, we don't reject
    // the request, we just drop them back onto Balam so the chat never
    // dead-ends. Emergency mode overrides everything and pins to
    // pediatrician regardless of premium status or client selection.
    const rawPersonaId = userContext?.personaId;
    const personaId =
      typeof rawPersonaId === "string" && isValidPersonaId(rawPersonaId)
        ? rawPersonaId
        : "balam";
    const premium = await isPremium(uid);
    let effectivePersonaId: string;
    if (emergencyMode) {
      effectivePersonaId = "pediatrician";
    } else if (isPremiumPersona(personaId) && !premium) {
      effectivePersonaId = "balam";
    } else {
      effectivePersonaId = personaId;
    }

    // Free-tier gate (the SaaS line). Free users get 3 questions/week;
    // premium is unlimited. Checked before the cost-protection caps so a
    // gated free user never consumes the beta Claude budget. A blocked
    // call returns a soft message with limitReached:true — the client
    // shows the paywall instead of rendering it as a chat reply. Skipped
    // entirely when emergencyMode is on (the 3am promise).
    if (!premium && !emergencyMode) {
      const withinFreeTier = await checkAndIncrementWeekly(uid);
      if (!withinFreeTier) {
        return {
          response: freeTierMessage(locale),
          triage: null,
          limitReached: true,
        };
      }
    }

    // Rate-limit pre-flight. A blocked call returns a soft message
    // rather than an error so the UI renders it as a normal Claude reply.
    const rl = await checkAndIncrementRateLimit(uid);
    if (!rl.allowed && rl.reason) {
      return {
        response: rateLimitMessage(locale, rl.reason),
        triage: null,
      };
    }

    // Normal path — call Claude. Catch any Anthropic failure (e.g. billing,
    // 5xx, rate limit from Anthropic itself) and return a soft message so
    // testers never see a raw error stack.
    try {
      const result = await balamChatInternal(
        message,
        {
          uid: request.auth.uid,
          ...(userContext ?? {}),
          personaId: effectivePersonaId,
          // Emergency answers must be short — override any client value.
          briefMode: emergencyMode ? true : (userContext?.briefMode === true),
        },
        Array.isArray(history) ? history : []
      );
      return result;
    } catch (err) {
      functions.logger.error("[balamChat] downstream error", { err });
      return {
        response: friendlyErrorMessage(locale),
        triage: null,
      };
    }
  }
);

/**
 * Generate daily insight for a user based on their stage/week
 * Triggered by Cloud Scheduler (cron) or manually
 */
export const dailyInsight = functions
  .runWith({ secrets: ["ANTHROPIC_API_KEY"] })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be signed in"
      );
    }

    const { week, stage, ageMonths, babyName } = data;
    const insight = await generateDailyInsight(week, stage, ageMonths, babyName);

    // Save to Firestore
    await admin.firestore().collection("insights").add({
      uid: context.auth.uid,
      insight,
      week,
      stage,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

    return { insight };
  });

// ============================================================
// DAILY BRIEF — the agent does the work overnight
// ============================================================
//
// Generates one brief per (user, child, day). The Flutter Home tab
// streams today's brief from users/{uid}/dailyBriefs and renders it as
// the hero card. Client calls dailyBriefGenerate on first open if no
// brief exists for today; scheduledDailyBriefs runs at 03:00 UTC daily
// for warm hits across active users.

export const dailyBriefGenerate = onCall(
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
    const locale = normalizeLocale(request.data?.locale);

    const brief = await composeBriefForMember(uid, memberId, locale);
    if (!brief) {
      throw new HttpsError("not-found", "Member not found");
    }
    await writeBrief(uid, brief);
    return { brief: serializeBrief(brief) };
  }
);

export const scheduledDailyBriefs = onSchedule(
  { schedule: "0 3 * * *", timeZone: "UTC", region: "us-central1", secrets: [anthropicKey] },
  async () => {
    const cutoff = Date.now() - 14 * 24 * 60 * 60 * 1000;
    const snap = await admin
      .firestore()
      .collection("users")
      .where("lastSeenAt", ">", new Date(cutoff))
      .get();
    let written = 0;
    let skipped = 0;
    for (const userDoc of snap.docs) {
      const data = userDoc.data();
      const members = ((data.members as unknown[]) ?? []) as Record<string, unknown>[];
      const children = members.filter((m) => m?.role === "child");
      if (children.length === 0) continue;
      const locale = normalizeLocale(data.localeCode);
      for (const child of children) {
        const memberId = String(child.id ?? "");
        if (!memberId) continue;
        try {
          const brief = await composeBriefForMember(userDoc.id, memberId, locale);
          if (brief) {
            await writeBrief(userDoc.id, brief);
            written += 1;
          } else {
            skipped += 1;
          }
        } catch (e) {
          functions.logger.warn("[dailyBrief] scheduled skip", {
            uid: userDoc.id,
            memberId,
            err: String(e),
          });
          skipped += 1;
        }
      }
    }
    functions.logger.info("[dailyBrief] scheduled run", { written, skipped });
  }
);

async function composeBriefForMember(
  uid: string,
  memberId: string,
  locale: "en" | "ru" | "ky"
) {
  const userDoc = await admin.firestore().doc(`users/${uid}`).get();
  if (!userDoc.exists) return null;
  const members = ((userDoc.data()?.members as unknown[]) ?? []) as Record<string, unknown>[];
  const memberRaw = members.find((m) => m && m.id === memberId);
  if (!memberRaw) return null;

  const member: BriefMember = {
    id: String(memberRaw.id ?? ""),
    name: String(memberRaw.name ?? "your child"),
    birthDate: typeof memberRaw.birthDate === "string" ? memberRaw.birthDate : undefined,
    stage: typeof memberRaw.stage === "string"
      ? (memberRaw.stage as BriefMember["stage"])
      : undefined,
    conditions: Array.isArray(memberRaw.conditions)
      ? (memberRaw.conditions as string[])
      : undefined,
    medications: Array.isArray(memberRaw.medications)
      ? (memberRaw.medications as string[])
      : undefined,
  };

  const [vaultDigest, activeNotices, recentMoment] = await Promise.all([
    retrieveVaultContext(uid, member.id, member.name, { max: 3, maxChars: 1600 }),
    fetchActiveNoticeTitles(uid, member.id, locale),
    fetchRecentMomentCaption(uid, member.id),
  ]);

  return generateDailyBrief({
    uid,
    member,
    locale,
    vaultDigest,
    activeNotices,
    recentMoment,
  });
}

async function fetchActiveNoticeTitles(
  uid: string,
  memberId: string,
  locale: "en" | "ru" | "ky"
): Promise<string[]> {
  try {
    const snap = await admin
      .firestore()
      .collection(`notices/${uid}/items`)
      .where("memberId", "==", memberId)
      .where("dismissedAt", "==", null)
      .orderBy("createdAt", "desc")
      .limit(5)
      .get();
    return snap.docs
      .map((d) => {
        const title = d.get("title") as Record<string, string> | undefined;
        if (!title) return null;
        return title[locale] ?? title.en ?? null;
      })
      .filter((t): t is string => typeof t === "string" && t.length > 0);
  } catch {
    return [];
  }
}

async function fetchRecentMomentCaption(uid: string, memberId: string): Promise<string | null> {
  try {
    const snap = await admin
      .firestore()
      .collection(`users/${uid}/moments`)
      .where("childId", "==", memberId)
      .orderBy("date", "desc")
      .limit(1)
      .get();
    if (snap.empty) return null;
    const caption = snap.docs[0].get("caption");
    return typeof caption === "string" && caption.length > 0 ? caption : null;
  } catch {
    return null;
  }
}

async function writeBrief(uid: string, brief: Awaited<ReturnType<typeof generateDailyBrief>>) {
  const docId = `${brief.memberId}__${brief.date}`;
  await admin
    .firestore()
    .doc(`users/${uid}/dailyBriefs/${docId}`)
    .set(brief, { merge: true });
}

function serializeBrief(brief: Awaited<ReturnType<typeof generateDailyBrief>>) {
  return {
    memberId: brief.memberId,
    memberName: brief.memberName,
    date: brief.date,
    locale: brief.locale,
    headline: brief.headline,
    body: brief.body,
    ctas: brief.ctas,
    source: brief.source,
  };
}

function normalizeLocale(raw: unknown): "en" | "ru" | "ky" {
  const s = typeof raw === "string" ? raw.toLowerCase().slice(0, 2) : "en";
  if (s === "ru") return "ru";
  if (s === "ky") return "ky";
  return "en";
}

// ============================================================
// PROACTIVE NOTICES — "The App That Notices"
// ============================================================

/**
 * Scheduled: run the proactive-notices schedule engine against every
 * household. Fires at 07:00 UTC daily; dedup is handled inside the
 * engine (per-member, per-milestone, per repeatIntervalDays window)
 * so it's safe to re-run.
 *
 * 2nd-gen scheduled function so it co-lives with balamChat's SA
 * model and doesn't hit the missing default-compute SA.
 */
export const proactiveNoticesScheduled = onSchedule(
  { schedule: "0 7 * * *", timeZone: "UTC", region: "us-central1" },
  async () => {
    // Engine 1 — schedule-based, all users
    const scheduleResult = await runScheduleEngineForAllUsers();
    functions.logger.info("[proactiveNotices] schedule engine", scheduleResult);

    // Engine 2 — trend-based, all users. Iterate users separately since
    // each tracking query is per-user and can't be batched like schedule.
    const usersSnap = await admin.firestore().collection("users").get();
    let trendFired = 0;
    let trendSuppressed = 0;
    const errors: string[] = [];
    for (const userDoc of usersSnap.docs) {
      try {
        const r = await runTrendEngineForUser(userDoc.id, userDoc.data());
        trendFired += r.noticesFired;
        trendSuppressed += r.noticesSuppressed;
      } catch (e) {
        errors.push(`uid=${userDoc.id}: ${String(e)}`);
      }
    }
    functions.logger.info("[proactiveNotices] trend engine", {
      trendFired,
      trendSuppressed,
      errors,
    });
  }
);

/**
 * Callable twin: lets us force-run the engine for the invoking user
 * without waiting for the cron. Useful during development + for the
 * verification steps.
 */
export const proactiveNoticesOnDemand = onCall(
  { region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const uid = request.auth.uid;
    const userDoc = await admin.firestore().doc(`users/${uid}`).get();
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "User profile not found");
    }
    const schedule = await runScheduleEngineForUser(uid, userDoc.data() ?? {});
    const trend = await runTrendEngineForUser(uid, userDoc.data() ?? {});
    return {
      schedule,
      trend,
      total: {
        membersEvaluated: Math.max(schedule.membersEvaluated, trend.membersEvaluated),
        noticesFired: schedule.noticesFired + trend.noticesFired,
        noticesSuppressed: schedule.noticesSuppressed + trend.noticesSuppressed,
      },
    };
  }
);

/**
 * FCM push when a new proactive notice lands. Locale-aware: picks the
 * title / body variant matching the user's saved language preference,
 * falls back to English.
 *
 * Kept a 1st-gen onCreate trigger for consistency with the existing
 * onNewInsight notification pattern. If we need to migrate off 1st-gen
 * later we'll move both together.
 */
export const onNewNotice = functions.firestore
  .document("notices/{uid}/items/{noticeId}")
  .onCreate(async (snap, context) => {
    const uid = context.params.uid;
    const data = snap.data();
    if (!data) return;

    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    const userData = userDoc.data();
    if (!userData?.fcmToken) return;

    const locale = (userData.localeCode as string) ?? "en";
    const pick = (field: Record<string, string> | undefined): string | undefined => {
      if (!field) return undefined;
      return field[locale] ?? field.en;
    };

    const title = pick(data.title) ?? "Balam noticed something";
    const body = pick(data.body) ?? "";
    const truncated = body.length > 140 ? body.slice(0, 137) + "…" : body;

    try {
      await admin.messaging().send({
        token: userData.fcmToken,
        notification: {
          title,
          body: truncated,
        },
        data: {
          type: "notice",
          noticeId: snap.id,
          memberId: (data.memberId as string) ?? "",
          route: ((data.action as Record<string, unknown>)?.route as string) ?? "/",
        },
      });
    } catch (err) {
      functions.logger.warn("[onNewNotice] FCM send failed", { err });
    }
  });

/**
 * Scheduled: Generate daily insights for all active users
 * Runs every day at 7 AM UTC
 */
export const scheduledDailyInsights = functions.pubsub
  .schedule("0 7 * * *")
  .onRun(async () => {
    const usersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("stage", "in", ["pregnant", "newborn", "toddler"])
      .get();

    const batch = admin.firestore().batch();

    for (const doc of usersSnapshot.docs) {
      const userData = doc.data();
      // Compute ageMonths from babyBirthDate if available
      let ageMonths: number | undefined;
      if (userData.babyBirthDate) {
        const birth = new Date(userData.babyBirthDate);
        const now = new Date();
        ageMonths = Math.floor(
          (now.getTime() - birth.getTime()) / (30.44 * 24 * 60 * 60 * 1000)
        );
      }
      const insight = await generateDailyInsight(
        userData.currentWeek || 24,
        userData.stage || "pregnant",
        ageMonths,
        userData.babyName
      );

      const insightRef = admin.firestore().collection("insights").doc();
      batch.set(insightRef, {
        uid: doc.id,
        insight,
        week: userData.currentWeek,
        stage: userData.stage,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
    }

    await batch.commit();
    console.log(`Generated insights for ${usersSnapshot.size} users`);
  });

// ============================================================
// BALAM VAULT — document ingest pipeline
// ============================================================

/**
 * Fired when a client writes a new doc to `vault/{uid}/items/{id}`
 * with `status: 'pending'`. Downloads the uploaded file from Firebase
 * Storage, sends it to Claude Vision with a structured extraction
 * prompt, and writes back the parsed metadata (docType, provider,
 * date, diagnoses, medications, follow-up, flags, raw text) plus
 * `status: 'processed'`. On failure writes `status: 'failed'` with
 * an error code so the client can offer retry.
 *
 * 1st-gen onCreate trigger for consistency with `onNewInsight` +
 * `onNewNotice`. If we migrate off 1st-gen we'll move them together.
 */
export const onVaultItemCreated = buildOnVaultItemCreated(
  () => anthropicKey.value(),
  { secrets: ["ANTHROPIC_API_KEY"], memory: "512MB", timeoutSeconds: 60 }
);

// ============================================================
// BALAM BOX — clinical tier classifier callable
// ============================================================

/**
 * Submit a single Balam Box reading (BP / glucose / dipstick /
 * temperature / weight). The server classifies into Green/Yellow/
 * Orange/Red per Scope-of-Practice v0.1, writes notice + clinical
 * audit + (if Red) emergency doc, and returns the full classification
 * so the client can render the tier-appropriate UI immediately.
 *
 * Auth required. Member must belong to the authenticated user's
 * household (looked up on `users/{uid}.members`).
 */
export const submitBoxReading = onCall(
  { region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const uid = request.auth.uid;

    const reading = request.data?.reading as BoxReading | undefined;
    if (!reading || typeof reading !== "object") {
      throw new HttpsError("invalid-argument", "reading is required");
    }
    const validTypes: ReadingType[] = [
      "bloodPressure",
      "bloodGlucose",
      "dipstick",
      "temperature",
      "weight",
    ];
    if (!validTypes.includes(reading.type)) {
      throw new HttpsError("invalid-argument", `reading.type must be one of ${validTypes.join(", ")}`);
    }
    if (!reading.memberId || typeof reading.memberId !== "string") {
      throw new HttpsError("invalid-argument", "reading.memberId is required");
    }
    if (!reading.timestamp || typeof reading.timestamp !== "string") {
      reading.timestamp = new Date().toISOString();
    }

    // Resolve the member. Prefer server-side (authoritative) household
    // record; fall back to a client-supplied snapshot so the app works
    // even when local profile state hasn't yet synced to Firestore.
    // We persist any client-supplied member so subsequent calls are
    // fully server-authoritative.
    const userRef = admin.firestore().doc(`users/${uid}`);
    const userDoc = await userRef.get();
    const rawMembers = ((userDoc.data()?.members as unknown[]) ??
      (userDoc.data()?.children as unknown[]) ??
      []) as Record<string, unknown>[];
    let memberRaw = rawMembers.find((m) => m && m.id === reading.memberId);

    const clientMember = request.data?.member as Record<string, unknown> | undefined;
    if (!memberRaw && clientMember && clientMember.id === reading.memberId) {
      memberRaw = clientMember;
      // Persist back — upsert into users/{uid}.members for next time.
      const nextMembers = [...rawMembers, clientMember];
      await userRef.set({ members: nextMembers }, { merge: true });
    }

    if (!memberRaw) {
      throw new HttpsError(
        "not-found",
        "Member not found in household (and no client snapshot provided)"
      );
    }
    const member: MemberSnapshot = {
      id: String(memberRaw.id ?? ""),
      name: String(memberRaw.name ?? ""),
      role: (memberRaw.role as MemberSnapshot["role"]) ?? "other",
      birthDate: typeof memberRaw.birthDate === "string" ? memberRaw.birthDate : undefined,
      conditions: Array.isArray(memberRaw.conditions) ? (memberRaw.conditions as string[]) : undefined,
      gender: typeof memberRaw.gender === "string" ? memberRaw.gender : undefined,
    };

    const result = await classifyAndRecord(uid, member, reading);

    // Also append to the user's tracking log so it shows up in history
    // and feeds the existing trend engine on its next nightly run.
    await admin.firestore().collection(`users/${uid}/tracking`).add({
      memberId: member.id,
      type: reading.type,
      // Flatten the most commonly-queried numeric value for trend engine
      value:
        reading.type === "bloodPressure"
          ? reading.systolic ?? null
          : reading.type === "bloodGlucose"
          ? reading.glucose ?? null
          : reading.type === "temperature"
          ? reading.tempC ?? null
          : reading.type === "weight"
          ? reading.weightKg ?? null
          : null,
      payload: reading,
      timestamp: reading.timestamp,
      tier: result.tier,
      ruleId: result.ruleId,
      protocolVersion: result.protocolVersion,
    });

    return {
      tier: result.tier,
      ruleId: result.ruleId,
      protocolVersion: result.protocolVersion,
      reason: result.reason,
      noticeId: result.noticeId ?? null,
      auditId: result.auditId ?? null,
      emergencyId: result.emergencyId ?? null,
      emergency: result.emergency ?? null,
    };
  }
);

// ============================================================
// NOTIFICATION ENDPOINTS
// ============================================================

/**
 * Send push notification when a user gets a new insight
 */
export const onNewInsight = functions.firestore
  .document("insights/{insightId}")
  .onCreate(async (snap) => {
    const data = snap.data();
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(data.uid)
      .get();
    const userData = userDoc.data();

    if (userData?.fcmToken) {
      await admin.messaging().send({
        token: userData.fcmToken,
        notification: {
          title: "Your daily insight from Balam 🐆",
          body: data.insight.substring(0, 100) + "...",
        },
        data: {
          type: "insight",
          insightId: snap.id,
        },
      });
    }
  });

/**
 * Tracking reminder — nudge if no tracking activity in X hours
 */
export const trackingReminder = functions.pubsub
  .schedule("0 14,20 * * *") // 2 PM and 8 PM UTC
  .onRun(async () => {
    const sixHoursAgo = new Date(Date.now() - 6 * 60 * 60 * 1000);

    const usersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("stage", "==", "pregnant")
      .get();

    for (const doc of usersSnapshot.docs) {
      const userData = doc.data();
      if (!userData.fcmToken) continue;

      // Check last tracking entry
      const lastEntry = await admin
        .firestore()
        .collection("tracking")
        .where("userId", "==", doc.id)
        .orderBy("timestamp", "desc")
        .limit(1)
        .get();

      if (lastEntry.empty || lastEntry.docs[0].data().timestamp.toDate() < sixHoursAgo) {
        await admin.messaging().send({
          token: userData.fcmToken,
          notification: {
            title: "How are you feeling? 💕",
            body: "Take a moment to log your water intake, mood, or kick count.",
          },
          data: { type: "tracking_reminder" },
        });
      }
    }
  });

// ============================================================
// MOOD — "Am I Okay" thread
// ============================================================
//
// Trigger fires when Mom logs a mood check-in. Enriches the doc with a
// crisis-keyword flag and rolls up the moodState/summary aggregate that
// Today's Debrief reads for streak/silence prompts. Claude reply
// generation lands in a separate trigger later in the week.
export const onMoodCheckinCreated = onMoodCheckinCreatedImpl;

// ============================================================
// MONTESSORI — Observation log + daily Invitation
// ============================================================
//
// Trigger fires when Mom logs "I noticed ___" in the Child tab. A
// Claude tag pass writes the Montessori reading (sensitive periods,
// category) and any matched pediatric milestones back onto the doc.
// Those tags feed the daily Invitation composer.
export const onObservationCreated = onObservationCreatedImpl;

// Callable: compose today's Montessori Invitation for the active
// child. Idempotent — second call on the same day returns the same
// doc. Free-tier gated to 1/ISO week; premium = daily.
export const generateDailyInvitation = generateDailyInvitationImpl;

// ============================================================
// BILLING — Premium entitlement setter
// ============================================================
//
// The ONLY server-trusted path that writes `users/{uid}.premium`.
// Firestore rules block the field for clients. Client calls this
// callable after a RevenueCat purchase/restore; we verify with RC's
// REST API and set the flag.
//
// Wire `REVENUECAT_API_KEY` as a Firebase secret before launch:
//   firebase functions:secrets:set REVENUECAT_API_KEY
export const setPremiumFromReceipt = setPremiumFromReceiptImpl;

// ============================================================
// ADMIN — Doctor onboarding
// ============================================================
//
// Founder-gated callable that registers a doctor: assigns the
// `doctor: true` custom claim on their Firebase Auth user and
// writes/merges their `doctors/{id}` Firestore record. Idempotent.
// Doctors must have signed up via email/password first.
export const setDoctorClaim = setDoctorClaimImpl;

// ============================================================
// CONSULT — AI bridge (Phase 2)
// ============================================================
//
// Three coupled Cloud Functions that make Balam more than just a
// messaging app for doctors:
//
//   - screenConsultDraft: callable. Mom drafts a question; Haiku 4.5
//     decides if AI can answer it for free, if it's an emergency, or
//     if it's worth a paid consult. Mom sees the result before paying.
//
//   - generateDoctorBrief: Firestore onCreate trigger on consultations.
//     Sonnet 4.6 composes a 30-second briefing from child age, vault,
//     recent observations, and the parent's question. Doctor opens
//     the thread and sees the brief at the top.
//
//   - generateFollowUps: Firestore onCreate trigger on messages.
//     When the DOCTOR replies, Haiku 4.5 proposes 3 tappable follow-up
//     questions the parent might want to ask next. Posted as a sibling
//     "ai_followup_suggestion" message with `suggestedFollowUps`.
export const screenConsultDraft = screenConsultDraftImpl;
export const generateDoctorBrief = generateDoctorBriefImpl;
export const generateFollowUps = generateFollowUpsImpl;

// Push the other party when a consult message lands. Skips server-
// appended AI followup pills (those aren't chat).
export const onConsultMessageCreated = onConsultMessageCreatedImpl;

// ============================================================
// SUNDAY CHAPTER — the weekly narrated letter (Sprint 1)
// ============================================================
//
// One 60-second narrated chapter per parent per week. Cron scans hourly
// for parents at local Sun 19:00. Text-only in Sprint 1 (TTS gated on
// OPENAI_API_KEY — wire in step 5 after prompt review). E2EE migration
// happens in Sprint 3 — the composeChapter pure function in
// jobs/sunday_chapter.ts is the stable seam for that swap.
//
//   - scheduledSundayChapters: hourly cron. Picks parents whose local
//     time just crossed Sunday 19:00. Idempotent on weekId.
//   - generateSundayChapterManual: dogfood trigger. Call from
//     `firebase functions:shell` to fire one chapter on demand and read
//     the narrative inline before scaling to the cron.
export const scheduledSundayChapters = scheduledSundayChaptersImpl;
export const generateSundayChapterManual = generateSundayChapterManualImpl;
