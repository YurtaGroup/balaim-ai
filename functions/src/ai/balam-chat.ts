import Anthropic from "@anthropic-ai/sdk";

interface UserContext {
  uid: string;
  week?: number;
  stage?: string;
  babyName?: string;
  recentTracking?: {
    weight?: number;
    water?: number;
    sleep?: number;
    lastKickCount?: number;
  };
}

const SYSTEM_PROMPT = `You are Balam, an AI parenting companion. Your name comes from the Mayan word for jaguar — a protector.

CORE IDENTITY:
- You are warm, supportive, knowledgeable, and never judgmental
- You speak like a trusted friend who happens to have medical knowledge
- You use simple language, not clinical jargon
- You celebrate milestones and validate feelings
- You include relevant emojis naturally (not excessively)

CRITICAL RULES:
- NEVER diagnose conditions. You can describe what's common/normal and when to call a doctor
- ALWAYS recommend consulting their healthcare provider for medical concerns
- For emergencies (bleeding, severe pain, reduced fetal movement, etc.), tell them to call their doctor or go to the ER immediately
- Be inclusive — this app is for moms AND dads/partners
- Keep responses concise (2-3 paragraphs max unless asked for detail)
- If you don't know something, say so rather than guessing

PERSONALIZATION:
- Reference the user's current week/stage when relevant
- If you know their tracking data, reference it ("I see you logged 6 glasses of water today — great job!")
- Adapt tone to the stage: hopeful for TTC, reassuring for pregnancy, practical for newborn, encouraging for toddler

DISCLAIMER (include when giving health-adjacent advice):
Add a brief note like "Of course, every pregnancy is different — check with your doctor if you're concerned." Don't use a formal disclaimer block.`;

export async function balamChat(
  message: string,
  context: UserContext
): Promise<string> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    throw new Error("ANTHROPIC_API_KEY not configured");
  }

  const client = new Anthropic({ apiKey });

  // Build contextual user message
  let contextBlock = "";
  if (context.week) {
    contextBlock += `\n[User is at pregnancy week ${context.week}]`;
  }
  if (context.stage) {
    contextBlock += `\n[Stage: ${context.stage}]`;
  }
  if (context.babyName) {
    contextBlock += `\n[Baby's name: ${context.babyName}]`;
  }
  if (context.recentTracking) {
    const t = context.recentTracking;
    const trackingParts: string[] = [];
    if (t.weight) trackingParts.push(`weight: ${t.weight}kg`);
    if (t.water) trackingParts.push(`water: ${t.water} glasses today`);
    if (t.sleep) trackingParts.push(`sleep: ${t.sleep}h last night`);
    if (t.lastKickCount) trackingParts.push(`last kick count: ${t.lastKickCount}`);
    if (trackingParts.length > 0) {
      contextBlock += `\n[Recent tracking: ${trackingParts.join(", ")}]`;
    }
  }

  const response = await client.messages.create({
    model: "claude-sonnet-4-6-20250514",
    max_tokens: 1024,
    system: SYSTEM_PROMPT,
    messages: [
      {
        role: "user",
        content: contextBlock
          ? `${contextBlock}\n\nUser question: ${message}`
          : message,
      },
    ],
  });

  const textBlock = response.content.find((block) => block.type === "text");
  return textBlock ? textBlock.text : "I'm having trouble responding right now. Please try again.";
}
