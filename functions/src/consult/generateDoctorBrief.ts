import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import { retrieveVaultContext } from "../ai/vault_retrieval";

/**
 * Firestore trigger: when a new consultation lands, generate a
 * 30-second briefing the doctor sees at the top of the thread.
 *
 * Inputs (read fresh each call):
 *   - child snapshot (name, age in months, from users/{uid}.members)
 *   - vault highlights (last few records, via retrieveVaultContext)
 *   - recent observations (last 7 days, summary + sensitivePeriods)
 *   - mood summary (users/{uid}/moodState/summary — soft signal)
 *   - the consultation topic + first message
 *
 * Output: a warm-but-clinical 4-6 line briefing written for a busy
 * doctor. Persisted as `doctorBriefSummary` on the consultation doc.
 * Idempotent — re-running overwrites with the latest.
 *
 * Anthropic Sonnet 4.6 — tone and clinical voice matter here. Brief
 * is generated ONCE per consult, low volume, cost negligible.
 */

interface ConsultationDoc {
  uid?: string;
  parentName?: string;
  topic?: string;
  lastMessagePreview?: string;
  doctorId?: string;
}

export const generateDoctorBrief = functions
  .runWith({
    secrets: ["ANTHROPIC_API_KEY"],
    memory: "256MB",
    timeoutSeconds: 60,
  })
  .firestore.document("consultations/{consultId}")
  .onCreate(async (snap, context) => {
    const consultId = context.params.consultId as string;
    const data = snap.data() as ConsultationDoc | undefined;
    if (!data?.uid) return;

    const uid = data.uid;

    // 1. Child snapshot
    let childName = "the child";
    let childAgeMonths: number | null = null;
    let childId: string | null = null;
    try {
      const userDoc = await admin.firestore().doc(`users/${uid}`).get();
      const userData = userDoc.data() ?? {};
      const members = (userData.members as Record<string, unknown>[] | undefined) ?? [];
      const child = members.find((m) => m.role === "child");
      if (child) {
        childId = String(child.id ?? "");
        if (typeof child.name === "string") childName = child.name;
        if (typeof child.birthDate === "string") {
          const dob = Date.parse(child.birthDate);
          if (!Number.isNaN(dob)) {
            childAgeMonths = Math.max(
              0,
              Math.floor((Date.now() - dob) / (1000 * 60 * 60 * 24 * 30.44))
            );
          }
        }
      }
    } catch (e) {
      functions.logger.warn("[doctorBrief] child snapshot failed", {
        consultId,
        err: String(e),
      });
    }

    // 2. Vault highlights (best-effort)
    let vault = "";
    if (childId) {
      try {
        const v = await Promise.race([
          retrieveVaultContext(uid, childId, data.lastMessagePreview ?? "", {
            max: 4,
            maxChars: 800,
          }),
          new Promise<null>((resolve) => setTimeout(() => resolve(null), 1500)),
        ]);
        if (v) vault = v;
      } catch (e) {
        functions.logger.warn("[doctorBrief] vault retrieval failed", {
          consultId,
          err: String(e),
        });
      }
    }

    // 3. Recent observations (last 7 days, top 5)
    let recentObservations: string[] = [];
    try {
      const cutoff = admin.firestore.Timestamp.fromMillis(
        Date.now() - 7 * 24 * 60 * 60 * 1000
      );
      const snap = await admin
        .firestore()
        .collection(`users/${uid}/observations`)
        .where("createdAt", ">=", cutoff)
        .orderBy("createdAt", "desc")
        .limit(5)
        .get();
      for (const doc of snap.docs) {
        const d = doc.data();
        const summary = typeof d.summary === "string" ? d.summary : null;
        const note = typeof d.note === "string" ? d.note : null;
        const line = summary || note;
        if (line) recentObservations.push(line);
      }
    } catch (e) {
      functions.logger.warn("[doctorBrief] observations failed", {
        consultId,
        err: String(e),
      });
    }

    // 4. Mom mood signal (soft)
    let momMoodLine = "";
    try {
      const moodDoc = await admin
        .firestore()
        .doc(`users/${uid}/moodState/summary`)
        .get();
      if (moodDoc.exists) {
        const m = moodDoc.data() ?? {};
        const streak = (m.streakHardDays as number | undefined) ?? 0;
        const trend = (m.trend as string | undefined) ?? "unknown";
        if (streak >= 3) {
          momMoodLine = `Parent stress signal: ${streak} hard mood-check-in days in a row.`;
        } else if (trend === "declining") {
          momMoodLine = "Parent stress signal: mood trending down this week.";
        }
      }
    } catch (e) {
      // best-effort
    }

    // 5. Compose
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) return; // graceful no-op

    const system = `You are writing a 30-second briefing for a pediatrician who is
about to open an async consultation thread. Voice: warm, clinical,
specific. No medical advice. No diagnosis. No flourishes.

Format — exactly these blocks, plain text, each block on its own line,
no markdown:
${childName}${childAgeMonths != null ? `, ${childAgeMonths} months` : ""}
Topic: <topic in 4-7 words>
Recent: <2-3 short clauses from observations or vault highlights, semicolon-separated>
Parent's question: <one quoted sentence, max 100 chars>
What may be missing: <one short clause; what would help the doctor's reply (e.g. temperature today, specific timing, prior episodes)>
${momMoodLine ? `Parent: <one short clause based on the mood signal below; do not pathologise>` : ""}

Keep total length under 600 chars. No empty lines.`;

    const userPayload = `Topic: ${data.topic ?? "(none)"}
Parent's first message: ${data.lastMessagePreview ?? "(none)"}

Vault highlights:
${vault || "(none recent)"}

Recent observations (newest first):
${
  recentObservations.length === 0
    ? "(none in last 7 days)"
    : recentObservations.map((o) => `- ${o}`).join("\n")
}

${momMoodLine ? `Mood signal: ${momMoodLine}` : ""}`;

    let briefText: string | null = null;
    try {
      const client = new Anthropic({ apiKey });
      const response = await client.messages.create({
        model: "claude-sonnet-4-6",
        max_tokens: 500,
        temperature: 0.4,
        system,
        messages: [{ role: "user", content: userPayload }],
      });
      const block = response.content.find((b) => b.type === "text");
      if (block) briefText = block.text.trim();
    } catch (e) {
      functions.logger.warn("[doctorBrief] AI call failed", {
        consultId,
        err: String(e),
      });
    }

    if (!briefText) return;

    await snap.ref.update({
      doctorBriefSummary: briefText.slice(0, 1200),
      doctorBriefGeneratedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
