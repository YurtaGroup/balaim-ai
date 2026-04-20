import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { balamChat as balamChatInternal } from "./ai/balam-chat";
import { generateDailyInsight } from "./ai/daily-insights";
import {
  runScheduleEngineForAllUsers,
  runScheduleEngineForUser,
} from "./ai/notices";

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

    // Rate-limit pre-flight. A blocked call returns a soft message
    // rather than an error so the UI renders it as a normal Claude reply.
    const rl = await checkAndIncrementRateLimit(request.auth.uid);
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
    const result = await runScheduleEngineForAllUsers();
    functions.logger.info("[proactiveNotices] run complete", result);
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
    const result = await runScheduleEngineForUser(uid, userDoc.data() ?? {});
    return result;
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
