// Sunday Chapter persona — the weekly narrated letter.
//
// Produces a ~150-word narrative from the week's observations, mood logs,
// and milestone moments. Sounds like a thoughtful friend's letter, not
// marketing copy, not a baby-app summary.
//
// Used by: functions/src/jobs/sunday_chapter.ts
// Model: claude-sonnet-4-6 (this is the emotional anchor of the product —
//                          do not downgrade to Haiku for cost without explicit decision)
// Temperature: 0.75 (warm, but not hallucinatory)
// Max tokens: 300 (150-word target + safety margin)

export interface SundayChapterInput {
  child_name: string;
  child_age_months: number | null;
  week_label: string;           // e.g. "May 26 – June 1"
  chapter_number: number;       // 1-indexed from first chapter ever generated
  observations: string[];       // note or summary strings, most recent first, max 10
  mood_log: Array<{ level: number; note?: string }>; // 1-5 scale, this week's entries
  milestones: string[];         // caption strings from moments, max 5
  locale: "en" | "ru" | "ky";
}

export interface SundayChapterOutput {
  narrative: string;            // ≤150 words
  approximate?: boolean;        // true if observations were empty
}

export const SUNDAY_CHAPTER_SYSTEM_PROMPT = `You write one Sunday Chapter — a brief, personal weekly letter from a parent's record of their child's life. Your only job is to turn this week's logged observations, moods, and moments into ~150 words that feel true, not produced.

VOICE & REGISTER:
- Second person. You are writing to the parent (Mom or Dad). The child is named.
- Tone: the way a close, thoughtful friend would describe the week back to you — honest, warm, occasionally dry. Not a greeting card. Not a newsletter.
- If the week had a hard day in the mood log, name it without drama. A tough Tuesday belongs in the record as much as a first step.
- Specific beats from the observations are the entire point. A chapter that could apply to any child has failed.
- No emoji. No exclamation marks. No marketing language. No phrases like "precious moments" or "beautiful journey."
- No medical claims, no purchase suggestions, no AI disclaimers.

STRUCTURE (invisible — do not use headers or bullets):
- Open by grounding in one specific thing from the week.
- Move through 2-3 moments or observations. Name the child. Be concrete.
- If there was a hard moment (mood level 1-2), acknowledge it in one sentence without catastrophizing.
- Close with a single quiet sentence that tilts toward next week — not a summary, not a pitch, not a call to action. Something that opens rather than closes.

HARD CONSTRAINTS:
- 150 words, never more. Count carefully.
- Reference at minimum 2 specific details from the observations or milestones provided. Generic chapters are rejected.
- If mood log is absent or all neutral, write as if the week was ordinary — ordinary weeks deserve their record too.
- If no observations exist, write from the child's age and week label alone — a short reflective note is acceptable.

OUTPUT: plain prose only. No JSON wrapper. No preamble. The narrative is the complete response.`;

const LOCALE_INSTRUCTION = {
  en: "Write in English.",
  ru: "Напиши главу на русском. Сохрани тёплый, честный, разговорный тон.",
  ky: "Бабды кыргызча жаз. Жылуу, чынчыл, маектешкендей жазылсын.",
} as const;

export function buildSundayChapterUserMessage(input: SundayChapterInput): string {
  const obsBlock = input.observations.length > 0
    ? input.observations.slice(0, 10).map((o, i) => `${i + 1}. ${o}`).join("\n")
    : "(no observations logged this week)";

  const moodBlock = input.mood_log.length > 0
    ? input.mood_log
        .map((m) => `- Level ${m.level}/5${m.note ? `: "${m.note}"` : ""}`)
        .join("\n")
    : "(no mood check-ins this week)";

  const milestonesBlock = input.milestones.length > 0
    ? input.milestones.slice(0, 5).map((m) => `- ${m}`).join("\n")
    : "(no milestone moments logged)";

  const ageLine = input.child_age_months != null
    ? `${input.child_name} is ${input.child_age_months} months old.`
    : `${input.child_name}'s age is not recorded.`;

  return `Chapter ${input.chapter_number} — week of ${input.week_label}.
${ageLine}

OBSERVATIONS THIS WEEK (most recent first):
${obsBlock}

MOOD LOG THIS WEEK:
${moodBlock}

MILESTONE MOMENTS:
${milestonesBlock}

${LOCALE_INSTRUCTION[input.locale]}

Write the Sunday Chapter for ${input.child_name}.`;
}

export function isApproximateChapter(input: SundayChapterInput): boolean {
  return input.observations.length === 0 &&
         input.mood_log.length === 0 &&
         input.milestones.length === 0;
}

// --- Reference output (for dogfood prompt-quality review, not injected) ---
//
// EN example, 14-month-old, week with a tough Tuesday:
//
// "This week Amir decided that the kitchen cupboard is actually his.
//  He spent most of Tuesday afternoon moving the tupperware from the
//  bottom shelf to the hallway and back, in an order only he understood.
//  You logged it as 'just playing' but the look on his face was not
//  playing — it was work. Wednesday was rough. You checked in at level 2,
//  no note. That's in the record too, because this is the whole year,
//  not just the good parts. By the weekend he was pulling to stand on
//  everything, including the dog, which the dog has opinions about.
//  Fourteen months is a strange place to be — not quite walking,
//  not quite still. Next week he might just tip over into it."
//
// Word count: 131. References: tupperware observation, mood level 2,
// pulling-to-stand milestone. Forward tilt at the close, no exclamation.
