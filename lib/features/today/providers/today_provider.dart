import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
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

/// Provides the "This Week's Focus" card data
final todayFocusProvider = Provider<TodayFocus>((ref) {
  final profile = ref.read(userProfileProvider);
  final weekNum = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000); // changes weekly

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final weekData = PregnancyWeekData.getWeek(week);
    final dev = weekData.babyDevelopment.en;
    final firstTwoSentences = _firstSentences(dev, 2);
    return TodayFocus(
      title: 'Week $week',
      body: firstTwoSentences,
      aiPrefill: 'What is my baby developing at week $week? What can I do to support it?',
      icon: const IconData(0xe1bc, fontFamily: 'MaterialIcons'), // pregnant_woman
    );
  }

  // Baby stage — rotate through 4 domains
  final age = profile.babyAgeMonths ?? 12;
  final name = profile.babyName ?? 'baby';
  final monthData = BabyMonthData.getMonth(age);
  final domains = [
    (monthData.physicalDevelopment, 'Physical Development', const IconData(0xe1e2, fontFamily: 'MaterialIcons')),
    (monthData.cognitiveDevelopment, 'Brain & Learning', const IconData(0xf0bf, fontFamily: 'MaterialIcons')),
    (monthData.socialEmotional, 'Social & Emotional', const IconData(0xe25c, fontFamily: 'MaterialIcons')),
    (monthData.languageDevelopment, 'Language & Communication', const IconData(0xe0c9, fontFamily: 'MaterialIcons')),
  ];
  final domainIndex = weekNum % domains.length;
  final (content, title, icon) = domains[domainIndex];

  return TodayFocus(
    title: title,
    body: _firstSentences(content.en, 2),
    aiPrefill: 'Tell me about ${title.toLowerCase()} for $name at $age months. What should I focus on this week?',
    icon: icon,
  );
});

/// Provides "Today's Activity" — one activity rotated daily
final todayActivityProvider = Provider<String>((ref) {
  final profile = ref.read(userProfileProvider);
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final weekData = PregnancyWeekData.getWeek(week);
    final tips = weekData.tips;
    return tips[dayOfYear % tips.length].en;
  }

  final age = profile.babyAgeMonths ?? 12;
  final monthData = BabyMonthData.getMonth(age);
  final activities = monthData.activities;
  return activities[dayOfYear % activities.length].en;
});

/// Provides "Is This Normal?" — one reassurance item rotated daily
final todayWorryProvider = Provider<(String title, String body, String aiPrefill)>((ref) {
  final profile = ref.read(userProfileProvider);
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  final name = profile.babyName ?? 'baby';

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final weekData = PregnancyWeekData.getWeek(week);
    final symptoms = weekData.commonSymptoms;
    final symptom = symptoms[dayOfYear % symptoms.length].en;
    return (
      symptom,
      'This is very common at week $week. Your body is working hard!',
      'Is it normal to experience "$symptom" at week $week?',
    );
  }

  final age = profile.babyAgeMonths ?? 12;
  final monthData = BabyMonthData.getMonth(age);
  final tips = monthData.parentTips;
  final tip = tips[dayOfYear % tips.length].en;
  return (
    tip,
    'Remember: every child develops at their own pace.',
    'Is $name on track at $age months? What should I watch for and what is normal?',
  );
});

/// Provides the daily insight text
final todayInsightProvider = Provider<String>((ref) {
  final profile = ref.read(userProfileProvider);
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;

  if (profile.stage == ParentingStage.pregnant ||
      profile.stage == ParentingStage.tryingToConceive) {
    final week = profile.currentWeek ?? 24;
    final weekData = PregnancyWeekData.getWeek(week);
    final tips = weekData.tips;
    // Use a different offset than todayActivityProvider
    return tips[(dayOfYear + 3) % tips.length].en;
  }

  final age = profile.babyAgeMonths ?? 12;
  final monthData = BabyMonthData.getMonth(age);
  final tips = monthData.parentTips;
  return tips[(dayOfYear + 2) % tips.length].en;
});

String _firstSentences(String text, int count) {
  final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
  return sentences.take(count).join(' ');
}
