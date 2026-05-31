/**
 * The Montessori taxonomy Balam reads and writes.
 *
 * These are the canonical IDs that flow through observations,
 * invitations, and the Child timeline. Keep this in lockstep with the
 * Dart-side enum in `lib/features/montessori/montessori_taxonomy.dart`
 * — both sides must speak the same vocabulary or the tagger will
 * write keys the UI doesn't render.
 *
 * Source: Maria Montessori's identified sensitive periods (windows of
 * peak neuroplasticity for a specific kind of learning) and the six
 * Practical curriculum areas. The age ranges are the Montessori
 * tradition's; pediatric milestone overlap is handled separately.
 */

export type SensitivePeriodId =
  | "order"
  | "language"
  | "movement"
  | "small_objects"
  | "refinement_of_senses"
  | "social"
  | "writing"
  | "reading";

export const SENSITIVE_PERIODS: Record<
  SensitivePeriodId,
  { label: string; startMonths: number; endMonths: number; summary: string }
> = {
  order: {
    label: "Order",
    startMonths: 12,
    endMonths: 36,
    summary:
      "Categorising, sequences, putting things in their place. Repetition is the point.",
  },
  language: {
    label: "Language",
    startMonths: 0,
    endMonths: 72,
    summary:
      "Peak 18-36 months. Words, naming, the 3-period lesson, real conversation.",
  },
  movement: {
    label: "Movement",
    startMonths: 0,
    endMonths: 48,
    summary:
      "Gross + fine motor. Crawling, walking, carrying, balancing, pouring.",
  },
  small_objects: {
    label: "Small objects",
    startMonths: 12,
    endMonths: 30,
    summary:
      "Pincer grasp, tiny details, transferring beads/seeds, the world in small things.",
  },
  refinement_of_senses: {
    label: "Refinement of senses",
    startMonths: 24,
    endMonths: 72,
    summary:
      "Matching by colour/shape/sound/texture. Sensorial work; differences become finer.",
  },
  social: {
    label: "Social behaviour",
    startMonths: 30,
    endMonths: 60,
    summary:
      "Manners, grace and courtesy, taking turns, group meals, helping others.",
  },
  writing: {
    label: "Writing",
    startMonths: 42,
    endMonths: 54,
    summary:
      "Sandpaper letters, tracing, finger to paper. Often before reading in Montessori.",
  },
  reading: {
    label: "Reading",
    startMonths: 48,
    endMonths: 66,
    summary:
      "Decoding phonetic words; built on the writing sensitive period.",
  },
};

export function activeSensitivePeriods(ageMonths: number): SensitivePeriodId[] {
  if (ageMonths < 0) return [];
  return (Object.keys(SENSITIVE_PERIODS) as SensitivePeriodId[]).filter((id) => {
    const p = SENSITIVE_PERIODS[id];
    return ageMonths >= p.startMonths && ageMonths <= p.endMonths;
  });
}

export type MontessoriCategoryId =
  | "practical_life"
  | "language"
  | "sensorial"
  | "motor"
  | "math"
  | "cultural";

export const MONTESSORI_CATEGORIES: Record<
  MontessoriCategoryId,
  { label: string; summary: string }
> = {
  practical_life: {
    label: "Practical Life",
    summary:
      "Real tasks with real tools — pouring, washing, dressing, food prep. The foundation, not the extra.",
  },
  language: {
    label: "Language",
    summary:
      "Naming, conversation, the 3-period lesson, songs, books read together.",
  },
  sensorial: {
    label: "Sensorial",
    summary:
      "Matching, sorting, grading by size/colour/sound/texture. Auto-correcting materials.",
  },
  motor: {
    label: "Motor",
    summary:
      "Gross + fine motor — carrying, climbing, balancing, pincer grasp, bilateral coordination.",
  },
  math: {
    label: "Math",
    summary:
      "Concrete first — counting real objects, one-to-one correspondence, the golden beads later.",
  },
  cultural: {
    label: "Cultural",
    summary:
      "Geography, botany, music, art — exposure to the wider world. Concrete experience first.",
  },
};

/**
 * Pediatric milestone IDs the tagger may attach to an observation when
 * the Montessori work also satisfies a developmental milestone. These
 * mirror the keys used in `functions/src/data/milestones.ts` so the
 * pediatrician PDF and the Child timeline overlay can join cleanly.
 *
 * Free-form for now — the tagger emits ID + label; the milestone
 * provider canonicalises later. Avoids a hard fail when Claude proposes
 * a label not in our seed list.
 */
export interface PediatricMilestoneTag {
  id: string;
  label: string;
  ageMonthsApprox?: number;
}
