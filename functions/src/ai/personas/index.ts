import { balamPersona } from "./balam";
import { pediatricianPersona } from "./pediatrician";
import { psychologistPersona } from "./psychologist";
import { sleepCoachPersona } from "./sleep_coach";
import { speechTherapistPersona } from "./speech_therapist";
import { nutritionistPersona } from "./nutritionist";
import type { PersonaId, PersonaPromptBuilder } from "./types";

export type { PersonaId, PersonaContext, PersonaPromptBuilder } from "./types";

const PERSONA_REGISTRY: Record<PersonaId, PersonaPromptBuilder> = {
  balam: balamPersona,
  pediatrician: pediatricianPersona,
  psychologist: psychologistPersona,
  sleep_coach: sleepCoachPersona,
  speech_therapist: speechTherapistPersona,
  nutritionist: nutritionistPersona,
};

export function getPersona(id: string | undefined | null): PersonaPromptBuilder {
  if (!id) return balamPersona;
  const persona = PERSONA_REGISTRY[id as PersonaId];
  return persona ?? balamPersona;
}

export function isPremiumPersona(id: string | undefined | null): boolean {
  return getPersona(id).premium;
}

export function isValidPersonaId(id: string | undefined | null): id is PersonaId {
  if (!id) return false;
  return id in PERSONA_REGISTRY;
}
