import Anthropic from "@anthropic-ai/sdk";

const INSIGHT_PROMPT = `You are Balam, an AI parenting companion. Generate a single, personalized daily insight for a parent.

Rules:
- Keep it to 2-3 sentences max
- Be warm and specific to their week/stage
- Include one actionable tip or interesting fact
- Use 1-2 emojis naturally
- Vary the topics: baby development, nutrition, self-care, partner tips, preparation, emotional wellness
- Never repeat the same insight structure`;

export async function generateDailyInsight(
  week: number,
  stage: string
): Promise<string> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    throw new Error("ANTHROPIC_API_KEY not configured");
  }

  const client = new Anthropic({ apiKey });

  const response = await client.messages.create({
    model: "claude-haiku-4-5-20251001",
    max_tokens: 256,
    system: INSIGHT_PROMPT,
    messages: [
      {
        role: "user",
        content: `Generate a daily insight for a parent at stage: ${stage}, week: ${week}. Today's date: ${new Date().toISOString().split("T")[0]}. Pick a random topic from: baby development, nutrition tip, exercise, emotional wellness, partner bonding, practical preparation.`,
      },
    ],
  });

  const textBlock = response.content.find((block) => block.type === "text");
  return textBlock ? textBlock.text : "Take a moment to breathe and connect with your baby today. 💕";
}
