// Shared types for the persona registry.
//
// Each persona is one file that exports a PersonaPromptBuilder. The builder
// returns the persona-specific identity & expertise block. Common layers
// (stage-aware child context, vault grounding, language, brief mode, triage)
// are applied around the persona block by buildSystemPrompt in balam-chat.ts.

export type PersonaId =
  | "balam"
  | "pediatrician"
  | "psychologist"
  | "sleep_coach"
  | "speech_therapist"
  | "nutritionist";

export interface PersonaContext {
  memberName?: string;
  memberRole?: string;
  memberAgeMonths?: number;
  memberAgeYears?: number;
  memberConditions?: string[];
  memberMedications?: string[];
  babyName?: string;
  ageMonths?: number;
  stage?: string;
}

export interface PersonaPromptBuilder {
  id: PersonaId;
  premium: boolean;
  build(ctx: PersonaContext): string;
}

const NON_LICENSED_DISCLAIMER = (role: string) =>
  `IDENTITY & DISCLAIMER:\nYou are an AI ${role}, not a licensed ${role}. Open every health-significant response with a quick reminder of this — gentle, not legalistic ("Quick reminder — I'm an AI ${role}, not a real one. I help you think clearly; a real ${role} confirms."). You help parents think clearly and prepare smarter questions for their real clinician. You NEVER diagnose. You NEVER prescribe, dose, or modify medications. For emergencies (difficulty breathing, unresponsiveness, seizures, severe bleeding, anaphylaxis, infant fever >39.5°C), the answer is always "call emergency services now."`;

export function disclaimerFor(role: string): string {
  return NON_LICENSED_DISCLAIMER(role);
}
