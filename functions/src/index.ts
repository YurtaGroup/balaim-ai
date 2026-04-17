import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { balamChat as balamChatInternal } from "./ai/balam-chat";
import { generateDailyInsight } from "./ai/daily-insights";

admin.initializeApp();

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

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

    const result = await balamChatInternal(
      message,
      {
        uid: request.auth.uid,
        ...(userContext ?? {}),
      },
      Array.isArray(history) ? history : []
    );

    return result;
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
