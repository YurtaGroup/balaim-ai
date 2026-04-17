import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../main.dart' show localeProvider;
import '../../../shared/models/baby_month_data.dart';
import '../../../shared/models/pregnancy_week_data.dart';
import '../../journey/providers/journey_provider.dart';

class TodayFocus {
  final String title;
  final String body;
  final String aiPrefill;
  final IconData icon;

  const TodayFocus({
    required this.title,
    required this.body,
    required this.aiPrefill,
    required this.icon,
  });
}

// ─── Locale helpers ────────────────────────────────────────────────
// Providers can't access BuildContext, so localize via locale code
// read off the shared localeProvider.

String _resolveLocale(Ref ref) {
  final code = ref.watch(localeProvider)?.languageCode;
  if (code == 'ru' || code == 'ky') return code!;
  return 'en';
}

String _pick(L3 l3, String locale) => switch (locale) {
      'ru' => l3.ru,
      'ky' => l3.ky,
      _ => l3.en,
    };

String _weekLabel(int week, String locale) => switch (locale) {
      'ru' => 'Неделя $week',
      'ky' => '$week-жума',
      _ => 'Week $week',
    };

// Domain titles — the 4 rotating sections for baby/toddler focus card.
const _domainPhysical = L3(en: 'Physical Development', ru: 'Физическое развитие', ky: 'Физикалык өнүгүү');
const _domainCognitive = L3(en: 'Brain & Learning', ru: 'Мозг и обучение', ky: 'Мээ жана окуу');
const _domainSocial = L3(en: 'Social & Emotional', ru: 'Социальное и эмоциональное', ky: 'Социалдык жана эмоционалдык');
const _domainLanguage = L3(en: 'Language & Communication', ru: 'Язык и общение', ky: 'Тил жана баарлашуу');

String _pregnancyWorryBody(int week, String locale) => switch (locale) {
      'ru' => 'Это очень часто встречается на $week неделе. Твоё тело делает огромную работу!',
      'ky' => 'Бул $week-жумада абдан жайылган. Денеңиз чоң иш жасап жатат!',
      _ => 'This is very common at week $week. Your body is working hard!',
    };

String _toddlerReassurance(String locale) => switch (locale) {
      'ru' => 'Помни: каждый ребёнок развивается в своём темпе.',
      'ky' => 'Эсиңизде болсун: ар бир бала өз темпи менен өнүгөт.',
      _ => 'Remember: every child develops at their own pace.',
    };

// ─── Providers ─────────────────────────────────────────────────────

/// Provides the "This Week's Focus" card data
final todayFocusProvider = Provider<TodayFocus>((ref) {
  final profile = ref.watch(userProfileProvider);
  final locale = _resolveLocale(ref);
  final weekNum = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final weekData = PregnancyWeekData.getWeek(week);
    final dev = _pick(weekData.babyDevelopment, locale);
    return TodayFocus(
      title: _weekLabel(week, locale),
      body: _firstSentences(dev, 2),
      aiPrefill: 'What is my baby developing at week $week? What can I do to support it?',
      icon: const IconData(0xe1bc, fontFamily: 'MaterialIcons'),
    );
  }

  final age = profile.babyAgeMonths ?? 12;
  final name = profile.babyName ?? 'baby';
  final monthData = BabyMonthData.getMonth(age);
  final domains = [
    (monthData.physicalDevelopment, _domainPhysical, const IconData(0xe1e2, fontFamily: 'MaterialIcons')),
    (monthData.cognitiveDevelopment, _domainCognitive, const IconData(0xf0bf, fontFamily: 'MaterialIcons')),
    (monthData.socialEmotional, _domainSocial, const IconData(0xe25c, fontFamily: 'MaterialIcons')),
    (monthData.languageDevelopment, _domainLanguage, const IconData(0xe0c9, fontFamily: 'MaterialIcons')),
  ];
  final domainIndex = weekNum % domains.length;
  final (content, titleL3, icon) = domains[domainIndex];

  return TodayFocus(
    title: _pick(titleL3, locale),
    body: _firstSentences(_pick(content, locale), 2),
    aiPrefill: 'Tell me about ${titleL3.en.toLowerCase()} for $name at $age months. What should I focus on this week?',
    icon: icon,
  );
});

/// Provides "Today's Activity" — one activity rotated daily
final todayActivityProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider);
  final locale = _resolveLocale(ref);
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final tips = PregnancyWeekData.getWeek(week).tips;
    return _pick(tips[dayOfYear % tips.length], locale);
  }

  final age = profile.babyAgeMonths ?? 12;
  final activities = BabyMonthData.getMonth(age).activities;
  return _pick(activities[dayOfYear % activities.length], locale);
});

/// Provides "Is This Normal?" — one reassurance item rotated daily
final todayWorryProvider = Provider<(String title, String body, String aiPrefill)>((ref) {
  final profile = ref.watch(userProfileProvider);
  final locale = _resolveLocale(ref);
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  final name = profile.babyName ?? 'baby';

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final symptoms = PregnancyWeekData.getWeek(week).commonSymptoms;
    final symptom = _pick(symptoms[dayOfYear % symptoms.length], locale);
    return (
      symptom,
      _pregnancyWorryBody(week, locale),
      'Is it normal to experience "$symptom" at week $week?',
    );
  }

  final age = profile.babyAgeMonths ?? 12;
  final tips = BabyMonthData.getMonth(age).parentTips;
  final tip = _pick(tips[dayOfYear % tips.length], locale);
  return (
    tip,
    _toddlerReassurance(locale),
    'Is $name on track at $age months? What should I watch for and what is normal?',
  );
});

/// Provides the daily insight text
final todayInsightProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider);
  final locale = _resolveLocale(ref);
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final tips = PregnancyWeekData.getWeek(week).tips;
    return _pick(tips[(dayOfYear + 3) % tips.length], locale);
  }

  final age = profile.babyAgeMonths ?? 12;
  final tips = BabyMonthData.getMonth(age).parentTips;
  return _pick(tips[(dayOfYear + 2) % tips.length], locale);
});

String _firstSentences(String text, int count) {
  final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
  return sentences.take(count).join(' ');
}
