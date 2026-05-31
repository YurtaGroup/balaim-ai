import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Firestore trigger: when the DOCTOR replies in a consultation thread,
 * append a sibling "ai_followup_suggestion" message with three tappable
 * follow-up questions the parent might want to ask next.
 *
 * Why this matters: most parents don't know what to ask after a
 * specialist replies. They re-read the doctor's message six times,
 * close the app, and the thread dies. Three pre-cooked follow-ups
 * raise the value-per-consult without spending more of the doctor's
 * time.
 *
 * Haiku 4.5 — three-string structured output, cost-sensitive call
 * that fires once per doctor message. Locale-aware (reads the
 * parent's user doc).
 *
 * Idempotency: the trigger checks if a sibling `ai_followup_suggestion`
 * for THIS doctor message already exists before composing. Safe
 * against Firestore double-deliveries.
 */

interface MessageDoc {
  fromDoctor?: boolean;
  kind?: string;
  text?: string;
  createdAt?: admin.firestore.Timestamp;
}

interface ConsultationDoc {
  uid?: string;
  topic?: string;
}

export const generateFollowUps = functions
  .runWith({
    secrets: ["ANTHROPIC_API_KEY"],
    memory: "256MB",
    timeoutSeconds: 30,
  })
  .firestore.document("consultations/{consultId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const consultId = context.params.consultId as string;
    const messageId = context.params.messageId as string;
    const data = snap.data() as MessageDoc | undefined;
    if (!data) return;
    // Only fire on doctor replies; skip the parent's own messages and
    // skip any prior AI followup suggestion to avoid recursion.
    if (data.fromDoctor !== true) return;
    if (data.kind === "ai_followup_suggestion") return;
    const doctorText = (data.text ?? "").trim();
    if (doctorText.length < 5) return;

    // Idempotency: bail if a followup for this doctor message already exists.
    const existing = await admin
      .firestore()
      .collection(`consultations/${consultId}/messages`)
      .where("kind", "==", "ai_followup_suggestion")
      .where("parentMessageId", "==", messageId)
      .limit(1)
      .get();
    if (!existing.empty) return;

    // Fetch consultation for context + locale lookup.
    const consultSnap = await admin
      .firestore()
      .doc(`consultations/${consultId}`)
      .get();
    const consult = consultSnap.data() as ConsultationDoc | undefined;
    if (!consult?.uid) return;

    let locale: "en" | "ru" | "ky" = "en";
    try {
      const u = await admin.firestore().doc(`users/${consult.uid}`).get();
      const raw = u.data()?.localeCode;
      if (raw === "ru" || raw === "ky") locale = raw;
    } catch {
      // best-effort
    }

    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) return;

    const langName =
      locale === "ru"
        ? "Russian (Русский)"
        : locale === "ky"
        ? "Kyrgyz (Кыргызча)"
        : "English";

    const system = `A pediatrician just replied to a parent in a paid async consult.
Most parents don't know what to ask next. Propose THREE short, specific
follow-up questions the parent might tap to send back.

Rules:
- Each follow-up is a complete question, ≤80 characters.
- Specific, not generic ("What dose for a 6-month-old?" not "What about dosing?").
- No advice. No diagnosis. Only questions.
- All three in ${langName}. Do NOT mix languages within one question.
- Build directly on the doctor's reply. If the doctor mentioned a sign to watch for, propose a follow-up about that sign. If they mentioned a med, propose a dose/timing question. If they recommended a visit, propose a "what should I bring" or "how soon" question.

OUTPUT STRICT JSON, NO MARKDOWN, NO PROSE:
{"followups": ["<q1>", "<q2>", "<q3>"]}`;

    const userPayload = `Topic: ${consult.topic ?? "(none)"}

Doctor's reply (in ${langName}):
"""
${doctorText}
"""

Compose three follow-up questions for the parent.`;

    let followups: string[] = [];
    try {
      const client = new Anthropic({ apiKey });
      const response = await client.messages.create({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 400,
        temperature: 0.7,
        system,
        messages: [{ role: "user", content: userPayload }],
      });
      const block = response.content.find((b) => b.type === "text");
      if (block) {
        const parsed = JSON.parse(block.text.trim()) as { followups?: unknown };
        if (Array.isArray(parsed.followups)) {
          followups = parsed.followups
            .filter((s): s is string => typeof s === "string")
            .map((s) => s.trim())
            .filter((s) => s.length > 0 && s.length <= 120)
            .slice(0, 3);
        }
      }
    } catch (e) {
      functions.logger.warn("[generateFollowUps] failed", {
        consultId,
        messageId,
        err: String(e),
      });
    }

    if (followups.length === 0) return;

    await admin
      .firestore()
      .collection(`consultations/${consultId}/messages`)
      .add({
        fromDoctor: false,
        kind: "ai_followup_suggestion",
        text: "", // pills carry the content; text stays empty
        photoUrl: null,
        suggestedFollowUps: followups,
        parentMessageId: messageId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  });
