import 'package:flutter/material.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// AI personas the parent can switch between. The id string is sent to
/// the Cloud Function (`personaId` in userContext) and must match
/// `functions/src/ai/personas/index.ts` exactly.
enum PersonaId {
  balam('balam'),
  pediatrician('pediatrician'),
  psychologist('psychologist'),
  sleepCoach('sleep_coach'),
  speechTherapist('speech_therapist'),
  nutritionist('nutritionist');

  const PersonaId(this.serverId);
  final String serverId;

  static PersonaId fromServerId(String? id) {
    if (id == null) return PersonaId.balam;
    for (final p in PersonaId.values) {
      if (p.serverId == id) return p;
    }
    return PersonaId.balam;
  }
}

class Persona {
  final PersonaId id;
  final String emoji;
  final Color color;
  final bool premium;
  final String Function(String lang) label;
  final String Function(String lang) tagline;

  const Persona({
    required this.id,
    required this.emoji,
    required this.color,
    required this.premium,
    required this.label,
    required this.tagline,
  });

  String get serverId => id.serverId;
}

const _balamColor = AppColors.primary;
const _pediColor = Color(0xFF2A9D8F);
const _psyColor = Color(0xFF8E7CC3);
const _sleepColor = Color(0xFF264653);
const _speechColor = Color(0xFFE9C46A);
const _nutritionColor = Color(0xFFE76F51);

final List<Persona> kPersonas = [
  Persona(
    id: PersonaId.balam,
    emoji: '🐆',
    color: _balamColor,
    premium: false,
    label: (lang) => tr(lang, en: 'Balam', ru: 'Balam', ky: 'Balam'),
    tagline: (lang) => tr(lang,
        en: 'Montessori parenting coach',
        ru: 'Монтессори-педагог',
        ky: 'Монтессори мугалим'),
  ),
  Persona(
    id: PersonaId.pediatrician,
    emoji: '🩺',
    color: _pediColor,
    premium: true,
    label: (lang) => tr(lang,
        en: 'AI Pediatrician',
        ru: 'AI Педиатр',
        ky: 'AI Педиатр'),
    tagline: (lang) => tr(lang,
        en: 'Symptoms, fevers, “should I call a doctor?”',
        ru: 'Симптомы, температура, «к врачу или нет?»',
        ky: 'Симптомдор, ысык, «дарыгерге барабызбы?»'),
  ),
  Persona(
    id: PersonaId.psychologist,
    emoji: '🧠',
    color: _psyColor,
    premium: true,
    label: (lang) => tr(lang,
        en: 'AI Psychologist',
        ru: 'AI Психолог',
        ky: 'AI Психолог'),
    tagline: (lang) => tr(lang,
        en: 'Tantrums, big feelings, mom mental health',
        ru: 'Истерики, эмоции, мама-психология',
        ky: 'Эмоциялар, истерика, эненин психологиясы'),
  ),
  Persona(
    id: PersonaId.sleepCoach,
    emoji: '🌙',
    color: _sleepColor,
    premium: true,
    label: (lang) => tr(lang,
        en: 'AI Sleep Coach',
        ru: 'AI Тренер по сну',
        ky: 'AI Уйку коучу'),
    tagline: (lang) => tr(lang,
        en: 'Naps, night wakings, sleep schedules',
        ru: 'Дневной сон, ночные просыпания, режим',
        ky: 'Күндүзгү уйку, түнкү ойгонуу, режим'),
  ),
  Persona(
    id: PersonaId.speechTherapist,
    emoji: '💬',
    color: _speechColor,
    premium: true,
    label: (lang) => tr(lang,
        en: 'AI Speech Therapist',
        ru: 'AI Логопед',
        ky: 'AI Логопед'),
    tagline: (lang) => tr(lang,
        en: 'Language milestones, late talkers',
        ru: 'Этапы речи, поздно заговорившие',
        ky: 'Сүйлөө этаптары, кеч сүйлөгөндөр'),
  ),
  Persona(
    id: PersonaId.nutritionist,
    emoji: '🥦',
    color: _nutritionColor,
    premium: true,
    label: (lang) => tr(lang,
        en: 'AI Nutritionist',
        ru: 'AI Нутрициолог',
        ky: 'AI Нутрициолог'),
    tagline: (lang) => tr(lang,
        en: 'Weaning, picky eaters, allergens',
        ru: 'Прикорм, привередливые едоки, аллергены',
        ky: 'Прикорм, тамак тандагандар, аллергендер'),
  ),
];

Persona personaById(PersonaId id) {
  return kPersonas.firstWhere(
    (p) => p.id == id,
    orElse: () => kPersonas.first,
  );
}
