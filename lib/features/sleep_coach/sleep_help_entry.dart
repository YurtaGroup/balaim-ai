import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/content_localizations.dart';
import '../../shared/models/child_model.dart';
import '../care_log/care_log_provider.dart';

/// "She won't sleep right now" Home entry.
///
/// One-tap to a Sleep Coach session, prefilled with the kid's age +
/// time since last feed + a time-of-day-appropriate framing (nap vs.
/// bedtime vs. middle-of-night). Premium gates the Sleep Coach
/// persona server-side; free users fall back to Balam (who still has
/// solid sleep advice baked into its toddler/newborn prompts).
///
/// This is the 3am button — every millisecond of friction here is a
/// defect. No menus, no confirmations, no popups. Tap → answer.
class SleepHelpEntry extends ConsumerWidget {
  final HouseholdMember child;
  const SleepHelpEntry({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    return Material(
      color: const Color(0xFF2A2D54), // calm deep-blue for "night"
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _tap(context, ref),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🌙', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(lang,
                          en: "She won't sleep",
                          ru: 'Она не спит',
                          ky: 'Уктабай жатат'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(lang,
                          en: '3 things to try in the next 20 min',
                          ru: '3 совета прямо сейчас',
                          ky: 'Азыр аракет кылууга 3 кеңеш'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.85),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tap(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final lastFeed = lastFeedingFor(ref, child.id);
    final prefill = _composePrefill(
      child: child,
      lang: lang,
      lastFeedAgoMinutes: lastFeed == null
          ? null
          : DateTime.now().difference(lastFeed.startTime).inMinutes,
    );

    Analytics.instance.sleepHelpOpened(
      ageMonths: child.ageMonths,
      lastFeedAgoMinutes: lastFeed == null
          ? null
          : DateTime.now().difference(lastFeed.startTime).inMinutes,
    );

    final uri = Uri(path: '/ai', queryParameters: {
      'persona': 'sleep_coach',
      'prefill': prefill,
    });
    context.push(uri.toString());
  }

  static String _composePrefill({
    required HouseholdMember child,
    required String lang,
    required int? lastFeedAgoMinutes,
  }) {
    final firstName = child.name.split(' ').first;
    final age = child.ageMonths;
    final ageLine = age != null
        ? tr(lang,
            en: '$firstName is $age months old.',
            ru: 'Возраст $firstName: $age мес.',
            ky: "$firstName $age айлык.")
        : '';

    final hour = DateTime.now().hour;
    final framing = (hour >= 0 && hour < 5)
        ? tr(lang,
            en: "$firstName woke in the middle of the night and won't go back to sleep.",
            ru: "$firstName проснулся ночью и не засыпает обратно.",
            ky: "$firstName түн ортосунда ойгонду, кайра уктабай жатат.")
        : (hour >= 5 && hour < 9)
            ? tr(lang,
                en: "$firstName is up too early and won't go back to sleep.",
                ru: "$firstName проснулся слишком рано и не засыпает.",
                ky: "$firstName өтө эрте ойгонду, кайра уктабайт.")
            : (hour >= 9 && hour < 19)
                ? tr(lang,
                    en: "$firstName won't go down for a nap.",
                    ru: "$firstName не идёт на дневной сон.",
                    ky: "$firstName күндүзкү уйкуга кетпейт.")
                : tr(lang,
                    en: "$firstName won't go to sleep for the night.",
                    ru: "$firstName не идёт на ночной сон.",
                    ky: "$firstName түнкү уйкуга кетпейт.");

    final feedLine = lastFeedAgoMinutes == null
        ? ''
        : tr(lang,
            en: ' Last feed was $lastFeedAgoMinutes minutes ago.',
            ru: ' Последнее кормление: $lastFeedAgoMinutes мин назад.',
            ky: ' Акыркы тамак: $lastFeedAgoMinutes мүн мурда.');

    final ask = tr(lang,
        en: ' Suggest 3 specific things I can try in the next 20 minutes.',
        ru: ' Предложи 3 конкретных шага на ближайшие 20 минут.',
        ky: ' Кийинки 20 мүнүттө кылууга 3 конкреттүү иш сун.');

    return [ageLine, framing + feedLine, ask].where((s) => s.isNotEmpty).join(' ');
  }
}
