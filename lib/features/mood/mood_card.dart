import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/content_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import '../journey/providers/journey_provider.dart';
import 'mood_models.dart';
import 'mood_provider.dart';

/// "How are you?" card on Home.
///
/// Two states:
///   - **Ask** — 5 emojis, no labels. One tap logs the mood.
///   - **Reply** — Balam's 2-3 sentence response (or a "thinking…" pill
///     while the server-side reply lands).
///
/// The card lives ABOVE Today's Debrief on purpose: Mom before kid.
/// That's the whole point of the feature.
class MoodCard extends ConsumerWidget {
  const MoodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLatest = ref.watch(moodCheckinsProvider);
    final latest = asyncLatest.asData?.value.isNotEmpty == true
        ? asyncLatest.asData!.value.first
        : null;

    // Today's check-in already logged? Show the reply state, otherwise
    // the ask state. "Today" is local-time same calendar day.
    final loggedToday = latest != null && _isSameLocalDay(latest.createdAt, DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: loggedToday
          ? _MoodReplyState(checkin: latest)
          : const _MoodAskState(),
    );
  }

  static bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ─── Ask state ────────────────────────────────────────────────────

class _MoodAskState extends ConsumerWidget {
  const _MoodAskState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = _firstName(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite_outline,
                  color: AppColors.accent, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tr(currentLang(context),
                    en: 'For you',
                    ru: 'Для тебя',
                    ky: 'Сен үчүн'),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          firstName == null
              ? tr(currentLang(context),
                  en: 'How are you?',
                  ru: 'Как ты?',
                  ky: 'Кандайсың?')
              : tr(currentLang(context),
                  en: 'How are you, $firstName?',
                  ru: 'Как ты, $firstName?',
                  ky: '$firstName, кандайсың?'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: MoodLevel.values
              .map((l) => _EmojiButton(level: l))
              .toList(),
        ),
        const SizedBox(height: 8),
        Text(
          tr(currentLang(context),
              en: 'Tap one — no one else sees this.',
              ru: 'Нажми любой — это видишь только ты.',
              ky: 'Бирин басыңыз — муну сиз гана көрөсүз.'),
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  String? _firstName(WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final n = profile.displayName.trim();
    if (n.isEmpty) return null;
    return n.split(' ').first;
  }
}

class _EmojiButton extends ConsumerStatefulWidget {
  final MoodLevel level;
  const _EmojiButton({required this.level});

  @override
  ConsumerState<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends ConsumerState<_EmojiButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _busy ? null : _onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _busy ? 0.92 : 1.0,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            widget.level.emoji,
            style: const TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap() async {
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;

    setState(() => _busy = true);

    // For levels 1-3 ("drowning", "hard", "meh"), prompt for a short
    // note so the AI reply has something to ground on. Levels 4-5 are
    // a one-tap pass-through — don't make Mom type when she's fine.
    String? note;
    if (widget.level.value <= 3 && mounted) {
      note = await _askForNote(context, widget.level);
    }

    final id = await logMoodCheckin(
      uid: uid,
      level: widget.level,
      note: note,
    );
    if (id != null) {
      unawaited(Analytics.instance.moodCheckinLogged(
        level: widget.level.value,
        hasNote: note != null && note.isNotEmpty,
      ));
    }

    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<String?> _askForNote(BuildContext context, MoodLevel level) async {
    final controller = TextEditingController();
    final ctxLang = currentLang(context);
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(level.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              tr(ctxLang,
                  en: "Want to tell me more?",
                  ru: 'Хочешь рассказать больше?',
                  ky: 'Көбүрөөк айткың келеби?'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(ctxLang,
                  en: 'Optional. A sentence is plenty.',
                  ru: 'Необязательно. Хватит одного предложения.',
                  ky: 'Кааласаң. Бир сүйлөм жетиштүү.'),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 4,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: tr(ctxLang,
                    en: "I'm tired. She didn't sleep again…",
                    ru: 'Я устала. Она снова не спала…',
                    ky: 'Чарчадым. Кайра уктаган жок…'),
                hintStyle: const TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      tr(ctxLang,
                          en: 'Skip',
                          ru: 'Пропустить',
                          ky: 'Өткөрүү'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      tr(ctxLang,
                          en: 'Share',
                          ru: 'Отправить',
                          ky: 'Жөнөтүү'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    final t = result?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

// ─── Reply state ──────────────────────────────────────────────────

class _MoodReplyState extends StatelessWidget {
  final MoodCheckin checkin;
  const _MoodReplyState({required this.checkin});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(checkin.level.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              tr(lang,
                  en: 'Logged today',
                  ru: 'Записано сегодня',
                  ky: 'Бүгүн жазылды'),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/mood'),
              child: Text(
                tr(lang,
                    en: 'Open thread',
                    ru: 'Открыть',
                    ky: 'Ачуу'),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (checkin.aiReply == null)
          _ThinkingPill(lang: lang)
        else
          Text(
            checkin.aiReply!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        if (checkin.flaggedCrisis) ...[
          const SizedBox(height: 14),
          const _CrisisActions(),
        ],
      ],
    );
  }
}

class _ThinkingPill extends StatelessWidget {
  final String lang;
  const _ThinkingPill({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          tr(lang,
              en: "Balam's writing back…",
              ru: 'Balam пишет…',
              ky: 'Balam жооп жазып жатат…'),
          style: const TextStyle(color: AppColors.textHint, fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Crisis escalation buttons ───────────────────────────────────

/// Shown only when the server-side trigger flagged the check-in
/// (`flaggedCrisis: true`). The two destinations are the US national
/// crisis services Mom can reach in under 10 seconds — Crisis Text
/// Line for non-verbal contact and 988 for a voice line.
///
/// IMPORTANT: this is a first-line bridge, not a screening tool. Every
/// phrase that lights this up has been hand-curated; the seed list
/// lives in functions/src/mood/crisisKeywords.ts and is pending
/// clinical review by Jane Mone NP.
class _CrisisActions extends StatelessWidget {
  const _CrisisActions();

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(lang,
                en: 'I want to make sure you have someone now.',
                ru: 'Я хочу, чтобы рядом был кто-то живой прямо сейчас.',
                ky: 'Азыр жаныңда бирөө болсун дейм.'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr(lang,
                en: 'These are free, confidential, 24/7. Tap to start.',
                ru: 'Бесплатно, конфиденциально, круглосуточно.',
                ky: 'Бекер, купуя, 24/7.'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CrisisButton(
                  label: tr(lang,
                      en: 'Text HOME → 741741',
                      ru: 'СМС HOME на 741741',
                      ky: 'SMS HOME → 741741'),
                  icon: Icons.sms_outlined,
                  onTap: () => _openSms('741741', 'HOME'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CrisisButton(
                  label: tr(lang,
                      en: 'Call 988',
                      ru: 'Звонок 988',
                      ky: '988 чалуу'),
                  icon: Icons.call_outlined,
                  onTap: () => _openCall('988'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openSms(String number, String body) async {
    final uri = Uri(scheme: 'sms', path: number, queryParameters: {'body': body});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _CrisisButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CrisisButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
