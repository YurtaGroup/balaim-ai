import Anthropic from "@anthropic-ai/sdk";

const INSIGHT_PROMPT = `You are Balam, a Montessori-trained AI parenting teacher. Generate a single daily teaching moment for a parent.

Your insight should be ONE of these types (rotate naturally — never repeat the same type twice in a row):

1. DEVELOPMENTAL TEACHING: Explain something about their child's brain or body right now. "At X months, your child's brain is..." Help the parent understand WHY their child does what they do.
2. MONTESSORI ACTIVITY: A specific, practical activity they can do today at home with common household items. Include what to do and what skill it builds.
3. NORMAL vs CONCERNING: Address a common worry parents have at this age. "Many parents worry about [X] at this age. Here's what's typical..." Reassure with specifics.
4. CONNECTION MOMENT: A specific way to build attachment today — not generic "hug your kid" but something actionable and meaningful for this exact age.
5. SPEECH & LANGUAGE TIP: One specific thing they can do today to support language development at this age.
6. INDEPENDENCE BUILDING: A Montessori practical life activity — a way to let the child do something themselves that builds confidence.

Rules:
- 2-3 sentences max
- Be specific to their child's exact age, not generic
- Use the child's name if provided
- Include one actionable thing they can do TODAY
- Frame everything through respect for the child's developmental stage
- Use 1-2 emojis naturally
- Never repeat the same insight structure`;

export async function generateDailyInsight(
  week: number,
  stage: string,
  ageMonths?: number,
  babyName?: string
): Promise<string> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    throw new Error("ANTHROPIC_API_KEY not configured");
  }

  const client = new Anthropic({ apiKey });

  let userMessage = `Generate a daily Montessori teaching moment for a parent at stage: ${stage}`;

  if (stage === "toddler" || stage === "newborn") {
    const name = babyName || "their child";
    const age = ageMonths ?? 12;
    userMessage += `, child's name: ${name}, age: ${age} months`;
  } else {
    userMessage += `, pregnancy week: ${week}`;
  }

  userMessage += `. Today's date: ${new Date().toISOString().split("T")[0]}. Pick a random topic type from the list in your instructions.`;

  const response = await client.messages.create({
    model: "claude-haiku-4-5-20251001",
    max_tokens: 256,
    system: INSIGHT_PROMPT,
    messages: [
      {
        role: "user",
        content: userMessage,
      },
    ],
  });

  const textBlock = response.content.find((block) => block.type === "text");
  return textBlock ? textBlock.text : "Take a moment to connect with your little one today — 10 minutes of fully present play is more powerful than you know. 💕";
}
