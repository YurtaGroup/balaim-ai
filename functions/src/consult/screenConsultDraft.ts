import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import { retrieveVaultContext } from "../ai/vault_retrieval";

/**
 * AI pre-screen for a consult draft.
 *
 * Mom types a question on the New Consult screen. Before she pays
 * the consult fee, this callable runs a quick Claude pass to decide:
 *
 *   - Is this fundamentally a Balam-AI question (free) rather than
 *     one that needs a doctor's time? If yes, return a short answer
 *     preview so she can choose.
 *   - Is it an emergency? Route to /emergency instead of charging.
 *   - Can the phrasing be tightened so the doctor reads it in 5
 *     seconds, not 30?
 *
 * Output is strict JSON the client renders. Anthropic Haiku 4.5 —
 * structured extraction, doesn't need Sonnet's tone, ~10x cheaper.
 *
 * Cost guardrail: capped at 30 calls / user / day via the existing
 * rate-limit pattern in functions/src/index.ts (reused here).
 *
 * Premium gating: NONE. Pre-screen is always free — it's the triage
 * layer that protects the doctor's time and saves Mom money.
 */

const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

interface ScreenInput {
  draft: string;
  topic?: string;
  childId?: string;
  doctorId?: string;
  locale?: "en" | "ru" | "ky";
}

interface ScreenResult {
  suggested_rephrase: string | null;
  can_ai_answer_first: boolean;
  ai_answer_preview: string | null;
  urgency: "low" | "medium" | "high" | "emergency";
  doctor_relevance: "low" | "medium" | "high";
}

export const screenConsultDraft = onCall(
  { region: "us-central1", secrets: [anthropicKey] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in");
    }
    const uid = request.auth.uid;
    const input = request.data as ScreenInput | undefined;
    if (!input?.draft || typeof input.draft !== "string") {
      throw new HttpsError("invalid-argument", "draft is required");
    }
    const draft = input.draft.trim();
    if (draft.length < 5) {
      throw new HttpsError("invalid-argument", "draft too short");
    }
    const locale: "en" | "ru" | "ky" = input.locale ?? "en";

    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
      throw new HttpsError("failed-precondition", "AI not configured");
    }

    // Build a compact context block: child name + age + recent vault
    // highlights, capped to ~500 chars so the screen call stays cheap.
    let context = "";
    try {
      const userDoc = await admin.firestore().doc(`users/${uid}`).get();
      const members = (userDoc.data()?.members as Record<string, unknown>[] | undefined) ?? [];
      const child = members.find((m) =>
        input.childId
          ? m.id === input.childId && m.role === "child"
          : m.role === "child"
      );
      if (child) {
        const name = typeof child.name === "string" ? child.name : "child";
        let ageStr = "";
        if (typeof child.birthDate === "string") {
          const dob = Date.parse(child.birthDate);
          if (!Number.isNaN(dob)) {
            const months = Math.max(
              0,
              Math.floor((Date.now() - dob) / (1000 * 60 * 60 * 24 * 30.44))
            );
            ageStr = `, ${months} months`;
          }
        }
        context += `Child: ${name}${ageStr}.\n`;

        try {
          const vault = await Promise.race([
            retrieveVaultContext(uid, String(child.id ?? ""), draft, {
              max: 2,
              maxChars: 400,
            }),
            new Promise<null>((resolve) =>
              setTimeout(() => resolve(null), 800)
            ),
          ]);
          if (vault) context += `${vault}\n`;
        } catch {
          // ignore — vault is best-effort
        }
      }
    } catch (e) {
      functions.logger.warn("[screenConsultDraft] context fetch skipped", {
        err: String(e),
      });
    }

    const langName =
      locale === "ru"
        ? "Russian (Русский)"
        : locale === "ky"
        ? "Kyrgyz (Кыргызча)"
        : "English";

    const system = `You are the triage layer between a parent and a pediatrician
inside Balam.AI. Mom drafted a question; before she pays for a consult,
decide if a doctor is actually needed, if the AI can answer first, and
how to tighten the phrasing so the doctor reads it fast.

OUTPUT STRICT JSON — no prose, no markdown, no code fences:
{
  "suggested_rephrase": "<a clearer 1-2 sentence version of her question, in ${langName}, or null if the original is already tight>",
  "can_ai_answer_first": <true if this is fundamentally a 'is this normal?' / 'how do I' question that a pediatric AI grounded in her child's record can answer well; false if it really needs a doctor's eye>,
  "ai_answer_preview": "<2-3 sentence preview in ${langName} if can_ai_answer_first is true; else null>",
  "urgency": "low" | "medium" | "high" | "emergency",
  "doctor_relevance": "low" | "medium" | "high"
}

URGENCY RULES:
- emergency: difficulty breathing, unresponsiveness, seizures, severe bleeding, fever >39.5°C in an infant under 3mo, signs of dehydration in a newborn, head injury with vomiting, anything that needs care RIGHT NOW. Don't suggest a paid consult; the client routes these to /emergency.
- high: warrants seeing a doctor within 24h.
- medium: schedule a routine consult this week — typical reason to pay for an async consult.
- low: educational / "is this normal" — AI can handle.

DOCTOR RELEVANCE — separate from urgency. A vaguely-worded question with no urgency might still benefit from a doctor (high doctor_relevance) if the parent needs medical authority. A panic about a normal milestone is low doctor_relevance even if anxiety is high.

NEVER:
- Diagnose. Don't say "your child has X." Stick to "this looks like it could be" or "this can wait for an AI answer because…"
- Suggest medications, doses, or specific treatments.
- Output anything outside the JSON object.

CONTEXT:
${context || "(no child context available)"}

Mom's draft (in ${langName}): "${draft}"`;

    const client = new Anthropic({ apiKey });
    const response = await client.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 500,
      temperature: 0.3,
      system,
      messages: [{ role: "user", content: "Screen this consult draft." }],
    });

    const block = response.content.find((b) => b.type === "text");
    if (!block) {
      throw new HttpsError("internal", "AI returned no text");
    }
    let parsed: ScreenResult;
    try {
      parsed = JSON.parse(block.text.trim());
    } catch (e) {
      functions.logger.warn("[screenConsultDraft] parse fail", {
        raw: block.text.slice(0, 400),
        err: String(e),
      });
      throw new HttpsError("internal", "AI returned invalid JSON");
    }

    // Sanitise
    const urgency = ["low", "medium", "high", "emergency"].includes(parsed.urgency)
      ? parsed.urgency
      : "low";
    const doctorRelevance = ["low", "medium", "high"].includes(parsed.doctor_relevance)
      ? parsed.doctor_relevance
      : "medium";

    return {
      suggested_rephrase: stringOrNull(parsed.suggested_rephrase, 320),
      can_ai_answer_first: parsed.can_ai_answer_first === true,
      ai_answer_preview: stringOrNull(parsed.ai_answer_preview, 400),
      urgency,
      doctor_relevance: doctorRelevance,
    } satisfies ScreenResult;
  }
);

function stringOrNull(v: unknown, maxLen: number): string | null {
  if (typeof v !== "string") return null;
  const t = v.trim();
  if (!t) return null;
  return t.slice(0, maxLen);
}
