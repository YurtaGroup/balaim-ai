/**
 * Crisis keyword seed lists for the "Am I Okay" mood thread.
 *
 * !!! NOT CLINICALLY REVIEWED YET !!!
 * This is the engineering seed. Jane Mone NP must review and adjust
 * before this fires in production. The keyword scan is a first-line
 * trip-wire, NOT a screen — it exists to surface a human pathway
 * (Crisis Text Line / 988) when a phrase obviously calls for one.
 *
 * Rules for editing this list:
 * 1. Patterns are matched against the lower-cased Mom note + the
 *    transcribed voice memo. Match is a simple substring test on the
 *    normalised string, so each entry must be a short phrase, not a
 *    regex.
 * 2. Prefer high-confidence phrases over single words. "die" alone is
 *    a false-positive magnet ("I want to dye my hair") — only include
 *    phrases that read unambiguously as crisis-leaning in the
 *    parenting context.
 * 3. Never include rage-against-the-kid phrases that a tired Mom would
 *    say venting and not mean ("I could kill her", "I want to throw
 *    him out the window") UNLESS Jane Mone explicitly approves them
 *    after we have data showing how Moms actually phrase it. False
 *    positives here erode trust fastest.
 * 4. Russian + Kyrgyz entries kept short and idiomatic — full
 *    translation review by Jane Mone before live.
 */

export interface CrisisMatch {
  matched: true;
  phrase: string;
  locale: "en" | "ru" | "ky" | "unknown";
}

export interface NoCrisisMatch {
  matched: false;
}

export type CrisisScanResult = CrisisMatch | NoCrisisMatch;

const EN_CRISIS_PHRASES: readonly string[] = [
  // self-harm / suicidal ideation
  "kill myself",
  "killing myself",
  "want to die",
  "wanna die",
  "i want to die",
  "end my life",
  "end it all",
  "ending it",
  "no point in living",
  "no reason to live",
  "better off without me",
  "everyone would be better off",
  "suicide",
  "suicidal",
  "hurt myself",
  "harm myself",
  "cut myself",

  // harm-to-baby
  "hurt the baby",
  "hurt my baby",
  "harm the baby",
  "harm my baby",
  "shake the baby",
  "shake my baby",
  "drop the baby",
  "throw the baby",

  // exhaustion crossing into crisis
  "i can't do this anymore",
  "i can't go on",
  "cant keep going",
  "can't keep going",
  "i give up",
  "i am done",
  "im done",
  "i don't want to be here",
];

const RU_CRISIS_PHRASES: readonly string[] = [
  // self-harm / suicidal ideation (Russian)
  "хочу умереть",
  "хочется умереть",
  "не хочу жить",
  "не хочется жить",
  "покончить с собой",
  "покончу с собой",
  "убить себя",
  "убью себя",
  "сделать себе плохо",
  "причинить себе вред",
  "самоубийство",
  "суицид",
  "лучше без меня",
  "всем будет лучше без меня",
  "нет смысла жить",
  "не вижу смысла",

  // harm-to-baby (Russian)
  "сделать ребёнку плохо",
  "сделать ребенку плохо",
  "причинить вред ребёнку",
  "причинить вред ребенку",
  "встряхнуть ребёнка",
  "встряхнуть ребенка",

  // exhaustion crossing into crisis
  "больше не могу",
  "я больше не могу",
  "не могу так дальше",
  "сдаюсь",
  "я сдаюсь",
];

const KY_CRISIS_PHRASES: readonly string[] = [
  // self-harm / suicidal ideation (Kyrgyz) — Jane Mone review pending
  "өлгүм келет",
  "жашагым келбейт",
  "өзүмдү өлтүрөм",
  "өзүмдү өлтүргүм келет",
  "суицид",
  "мен жоксуз жакшы болот",
  "мен жоксуз баары жакшы",

  // harm-to-baby (Kyrgyz)
  "балама зыян",
  "баланы силкип",

  // exhaustion crossing into crisis
  "мындан ары чыдай албайм",
  "мындан ары мүмкүн эмес",
  "баш тарттым",
];

function normalise(text: string): string {
  return text.toLowerCase().replace(/\s+/g, " ").trim();
}

function scanLocale(
  haystack: string,
  phrases: readonly string[],
  locale: CrisisMatch["locale"]
): CrisisMatch | null {
  for (const phrase of phrases) {
    if (haystack.includes(phrase)) {
      return { matched: true, phrase, locale };
    }
  }
  return null;
}

/**
 * Scan a free-text input (Mom's note + any voice transcript concatenated)
 * for any seed crisis phrase across all three locales. We scan all three
 * regardless of the user's locale because code-switching is common
 * (Russian phrases inside a primarily-Kyrgyz note, English phrases
 * inside a Russian note, etc.).
 */
export function scanForCrisis(rawText: string): CrisisScanResult {
  if (!rawText) return { matched: false };
  const text = normalise(rawText);
  return (
    scanLocale(text, EN_CRISIS_PHRASES, "en") ??
    scanLocale(text, RU_CRISIS_PHRASES, "ru") ??
    scanLocale(text, KY_CRISIS_PHRASES, "ky") ?? { matched: false }
  );
}
