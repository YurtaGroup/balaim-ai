import Anthropic from "@anthropic-ai/sdk";

/**
 * The warm-friend reply for the "Am I Okay" thread.
 *
 * This is NOT the parenting AI. Different rules, different voice,
 * different temperature. Mom logs how she's doing → 2-3 sentences back
 * that read like a friend who has been there. Never advice unless
 * asked, never platitudes, never "you've got this."
 *
 * When `flaggedCrisis` is true (crisis keyword detected upstream), the
 * reply switches to the acknowledge-then-bridge template that points
 * to Crisis Text Line + 988. The buttons themselves render in-app on
 * the bubble; the AI just earns the trust to make those buttons
 * tappable.
 */

export interface MoodReplyInput {
  level: number; // 1-5
  note: string | null;
  voiceTranscript: string | null;
  momFirstName: string | null;
  childFirstName: string | null;
  childAgeMonths: number | null;
  locale: "en" | "ru" | "ky";
  flaggedCrisis: boolean;
}

const LEVEL_DESCRIPTIONS: Record<number, string> = {
  1: "drowning",
  2: "hard",
  3: "meh",
  4: "ok",
  5: "great",
};

function buildSystemPrompt(locale: "en" | "ru" | "ky"): string {
  const langName =
    locale === "ru"
      ? "Russian (Русский)"
      : locale === "ky"
      ? "Kyrgyz (Кыргызча)"
      : "English";

  return `You are a friend Mom has known for years. She just told you how she is feeling — by tapping an emoji on a 1-5 scale, and optionally writing or speaking a sentence about it.

RULES (these are not suggestions — break any of them and the product fails):
- 2-3 sentences. Never more. No bullet points. No headings. No emoji except sparingly when the mood is light.
- Never start with "I'm sorry to hear that." Never say "you've got this." Never say "every mom feels this way." Never say "it gets better." Never sign off with a heart.
- Never give medical, mental-health, parenting, or productivity advice unless Mom explicitly asks for it. She did not ask.
- Never minimize what she feels. Never try to fix.
- Reflect what you heard, or ask one gentle question, or just sit with her. Read her words and pick — don't do all three.
- If you know the child's name, you may use it ONCE if it fits naturally. Never use it more. Never use it if she didn't mention the child.
- Match her energy. If she's flat or numb, be quiet and steady. If she's anxious, be calm and grounded. If she's okay, a single short warm line is plenty.
- No sign-off. Be a person, not a Hallmark card.

LANGUAGE: Respond ONLY in ${langName}. Never mix languages.

CRISIS BRANCH — if the input indicates self-harm, harm to the baby, suicidal ideation, or "I can't do this anymore" / "I can't keep going":
- First sentence: acknowledge the pain with weight. Something like "That sounds unbearable" or "What you're carrying right now is heavy."
- Second sentence: bridge to a real human. Phrase it as: "I want to make sure you're not alone with this. Will you reach out to Crisis Text Line (text HOME to 741741) or 988 right now? They can be with you in a way I can't."
- Do not add a third sentence. Do not say "you matter" or "it will get better."

Output the reply text only. No preamble, no XML tags, no quotation marks.`;
}

function buildUserTurn(input: MoodReplyInput): string {
  const parts: string[] = [];
  parts.push(`Mood: ${input.level}/5 (${LEVEL_DESCRIPTIONS[input.level] ?? "unknown"})`);
  if (input.momFirstName) parts.push(`Mom's name: ${input.momFirstName}`);
  if (input.childFirstName) {
    const age = input.childAgeMonths != null
      ? `${input.childFirstName} is ${input.childAgeMonths} months old`
      : `Her child: ${input.childFirstName}`;
    parts.push(age);
  }

  const words: string[] = [];
  if (input.note) words.push(input.note);
  if (input.voiceTranscript) words.push(input.voiceTranscript);
  if (words.length === 0) {
    parts.push("She didn't write anything — she just tapped the emoji.");
  } else {
    parts.push(`Her words: ${words.join(" / ")}`);
  }

  if (input.flaggedCrisis) {
    parts.push(
      "ALERT: this input matched the crisis keyword scan. You MUST use the CRISIS BRANCH template."
    );
  }

  return parts.join("\n");
}

export async function generateMoodReply(input: MoodReplyInput): Promise<string | null> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) return null;

  const client = new Anthropic({ apiKey });
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 220,
    temperature: 0.9,
    system: buildSystemPrompt(input.locale),
    messages: [{ role: "user", content: buildUserTurn(input) }],
  });

  const textBlock = response.content.find((b) => b.type === "text");
  if (!textBlock) return null;
  return textBlock.text.trim();
}
