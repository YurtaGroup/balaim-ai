// Balam Daily Brief — the agent does the work overnight.
//
// One generation per user per child per day. Written to
// users/{uid}/dailyBriefs/{memberId__YYYY-MM-DD}. The Home tab streams
// today's brief and renders it as the hero card.
//
// Voice: a witness, not a coach. Specific to this child, not averages.
// Confident, kind, calibrated. No "consult your pediatrician" reflexes.
// Personal pronouns ("Maya did X" not "your baby"). One small win if we
// have it. One thing coming next. No medical lecturing.

import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";

export interface BriefMember {
  id: string;
  name: string;
  birthDate?: string;
  stage?: "newborn" | "infant" | "toddler" | "preschool";
  conditions?: string[];
  medications?: string[];
}

export interface BriefCta {
  label: string;
  type: "chat" | "share" | "next" | "emergency";
  prefill?: string;
  shareText?: string;
}

export interface DailyBrief {
  memberId: string;
  memberName: string;
  date: string;            // YYYY-MM-DD
  locale: "en" | "ru" | "ky";
  headline: string;        // one short line ("Maya is 8 months, 2 days.")
  body: string;            // 2-3 short sentences, warm and specific
  ctas: BriefCta[];        // 1-3 actions max
  generatedAt: admin.firestore.FieldValue;
  source: "claude" | "fallback";
}

const SYSTEM_PROMPT = `You are Balam — a quiet, smart friend who knows this family's child. You're not a doctor, not a coach, not a chart. You're a witness.

Your job: write today's brief for this parent. They will open the app and see this as the first thing. It should feel like a friend texting them at 7am: "hey, here's where we are today."

Voice rules — these are non-negotiable:
- Use the child's name. Never "your baby" or "your child" — always the name.
- Be specific to THIS child's data. Never reference averages, percentiles, or "babies your age." Comparison is poison.
- Be confident. Don't hedge with "consult your pediatrician." If the data is clear, say what it says.
- Be brief. Headline = one short line stating where we are today. Body = 2 to 3 short sentences. That's it.
- Be kind. The parent is tired. Lead with something settling, not anxious.
- One small win if you have any data to draw on (recent record, good lab, milestone). One thing coming next if there's a notice. Never both unless you can fit them in 3 sentences.
- No emojis in the body. One emoji in the headline is okay if it lands. Otherwise none.
- No clinical disclaimers. No "I'm not a doctor." The parent already knows.

Output format — return ONLY a JSON object, no prose around it:
{
  "headline": "...",
  "body": "...",
  "ctas": [
    { "label": "Open in chat", "type": "chat", "prefill": "..." },
    { "label": "Send to Dad", "type": "share", "shareText": "..." },
    { "label": "What's next this week", "type": "next" }
  ]
}

The CTA "prefill" is the question this brief teaches the parent to ask Balam next. The CTA "shareText" is a 1-line text-to-spouse version (the partner is NOT on the app — write it like a normal SMS, no app jargon). Keep 1 to 3 CTAs; omit any that don't fit the brief.

The locale field will tell you which language to write in. Match it exactly. Localize the CTA labels too.`;

export async function generateDailyBrief(input: {
  uid: string;
  member: BriefMember;
  locale: "en" | "ru" | "ky";
  vaultDigest: string | null;      // recent records summary (or null)
  activeNotices: string[];          // current notice titles (en preferred)
  recentMoment: string | null;     // last moment caption (or null)
}): Promise<DailyBrief> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  const today = new Date().toISOString().slice(0, 10);
  const ageString = ageDescription(input.member.birthDate);

  if (!apiKey) {
    return fallbackBrief(input.member, today, input.locale, ageString);
  }

  const userMessage = buildUserMessage(input, ageString);

  try {
    const client = new Anthropic({ apiKey });
    const response = await client.messages.create({
      model: "claude-sonnet-4-6",
      max_tokens: 512,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: userMessage }],
    });

    const textBlock = response.content.find((b) => b.type === "text");
    if (!textBlock || textBlock.type !== "text") {
      return fallbackBrief(input.member, today, input.locale, ageString);
    }

    const parsed = parseBriefJson(textBlock.text);
    if (!parsed) {
      return fallbackBrief(input.member, today, input.locale, ageString);
    }

    return {
      memberId: input.member.id,
      memberName: input.member.name,
      date: today,
      locale: input.locale,
      headline: parsed.headline,
      body: parsed.body,
      ctas: parsed.ctas,
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      source: "claude",
    };
  } catch (e) {
    console.warn("[dailyBrief] generation failed, using fallback", { err: String(e) });
    return fallbackBrief(input.member, today, input.locale, ageString);
  }
}

function buildUserMessage(
  input: Parameters<typeof generateDailyBrief>[0],
  ageString: string
): string {
  const parts: string[] = [];
  parts.push(`Today is ${new Date().toISOString().slice(0, 10)}.`);
  parts.push(`Locale: ${input.locale}.`);
  parts.push(`Child: ${input.member.name}, ${ageString}.`);
  if (input.member.conditions?.length) {
    parts.push(`Known conditions: ${input.member.conditions.join(", ")}.`);
  }
  if (input.member.medications?.length) {
    parts.push(`Current medications: ${input.member.medications.join(", ")}.`);
  }
  if (input.vaultDigest) {
    parts.push(`\nRecent records in this child's vault:\n${input.vaultDigest}`);
  } else {
    parts.push(`\nNo records uploaded yet for this child.`);
  }
  if (input.activeNotices.length) {
    parts.push(`\nActive notices (things Balam is watching):\n- ${input.activeNotices.join("\n- ")}`);
  }
  if (input.recentMoment) {
    parts.push(`\nLast captured moment: "${input.recentMoment}"`);
  }
  parts.push(`\nWrite today's brief. JSON only.`);
  return parts.join("\n");
}

function parseBriefJson(raw: string): {
  headline: string;
  body: string;
  ctas: BriefCta[];
} | null {
  const trimmed = raw.trim();
  // Some models wrap JSON in ```json ... ``` — strip if so.
  const stripped = trimmed
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "");
  try {
    const obj = JSON.parse(stripped) as Record<string, unknown>;
    const headline = String(obj.headline ?? "").trim();
    const body = String(obj.body ?? "").trim();
    if (!headline || !body) return null;

    const rawCtas = Array.isArray(obj.ctas) ? obj.ctas : [];
    const ctas: BriefCta[] = [];
    for (const c of rawCtas) {
      if (!c || typeof c !== "object") continue;
      const rec = c as Record<string, unknown>;
      const label = String(rec.label ?? "").trim();
      const type = String(rec.type ?? "").trim();
      if (!label) continue;
      if (!["chat", "share", "next", "emergency"].includes(type)) continue;
      const cta: BriefCta = {
        label,
        type: type as BriefCta["type"],
      };
      if (typeof rec.prefill === "string") cta.prefill = rec.prefill;
      if (typeof rec.shareText === "string") cta.shareText = rec.shareText;
      ctas.push(cta);
      if (ctas.length >= 3) break;
    }
    return { headline, body, ctas };
  } catch {
    return null;
  }
}

function fallbackBrief(
  member: BriefMember,
  today: string,
  locale: "en" | "ru" | "ky",
  ageString: string
): DailyBrief {
  const headline = locale === "ru"
    ? `${member.name} — ${ageString}.`
    : locale === "ky"
    ? `${member.name} — ${ageString}.`
    : `${member.name} is ${ageString}.`;
  const body = locale === "ru"
    ? `Сегодня обычный день. Загрузите свежую запись или задайте Балам вопрос — и завтрашний бриф будет точнее.`
    : locale === "ky"
    ? `Бүгүн жөн күн. Жаңы жазуу кошуңуз же Балам'дан сураңыз — эртеңки маалыматтама тагыраак болот.`
    : `Quiet day in the data. Drop a fresh record or ask Balam something — tomorrow's brief gets sharper with every detail you add.`;
  const ctas: BriefCta[] = [
    {
      label: locale === "ru" ? "Спросить Балам" : locale === "ky" ? "Балам'дан сура" : "Ask Balam",
      type: "chat",
    },
  ];
  return {
    memberId: member.id,
    memberName: member.name,
    date: today,
    locale,
    headline,
    body,
    ctas,
    generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    source: "fallback",
  };
}

function ageDescription(birthDate?: string): string {
  if (!birthDate) return "newborn";
  const birth = new Date(birthDate);
  if (isNaN(birth.getTime())) return "newborn";
  const now = new Date();
  const diffMs = now.getTime() - birth.getTime();
  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  if (days < 14) return `${days} days old`;
  const months = Math.floor(days / 30.44);
  if (months < 24) {
    const remainderDays = days - Math.floor(months * 30.44);
    return remainderDays > 0
      ? `${months} months, ${remainderDays} days old`
      : `${months} months old`;
  }
  const years = Math.floor(months / 12);
  const remMonths = months - years * 12;
  return remMonths > 0 ? `${years} years, ${remMonths} months` : `${years} years old`;
}
