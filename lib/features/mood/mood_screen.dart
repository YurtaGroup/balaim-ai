import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/content_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import 'mood_models.dart';
import 'mood_provider.dart';

/// Full mood thread — the history view. Each check-in renders as a
/// little chat bubble: Mom's emoji + note on the right, Balam's reply
/// on the left. Crisis-flagged entries surface the 988 / 741741
/// shortcut directly on that bubble.
class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(moodCheckinsProvider);
    final summary = ref.watch(moodSummaryProvider).asData?.value;
    final lang = currentLang(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tr(lang,
              en: 'How you are',
              ru: 'Как ты',
              ky: 'Сенин абалың'),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: asyncList.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              tr(lang,
                  en: "I couldn't load your thread right now. Try again in a sec.",
                  ru: 'Сейчас не получилось загрузить. Попробуй ещё раз.',
                  ky: 'Азыр жүктөй албадым. Кайра аракет кылыңыз.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (checkins) {
          if (checkins.isEmpty) {
            return _Empty(lang: lang);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              if (summary != null) _SummaryStrip(summary: summary),
              const SizedBox(height: 8),
              for (final c in checkins) _CheckinBubble(checkin: c),
            ],
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String lang;
  const _Empty({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 14),
            Text(
              tr(lang,
                  en: 'Nothing here yet.',
                  ru: 'Пока пусто.',
                  ky: 'Азырынча эч нерсе жок.'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(lang,
                  en: 'Tap an emoji on Home whenever you feel like checking in. No streaks, no judgment.',
                  ru: 'Нажми эмодзи на главном, когда захочешь. Без подсчётов, без оценок.',
                  ky: 'Башкы беттеги эмодзинин бирин баса бер. Эсеп жок, баа жок.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final MoodSummary summary;
  const _SummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    final messages = <String>[];

    if (summary.streakHardDays >= 3) {
      messages.add(tr(lang,
          en: 'A few hard days in a row. I see you.',
          ru: 'Несколько тяжёлых дней подряд. Я вижу.',
          ky: 'Бир нече күн оор болду. Мен көрүп турам.'));
    } else if (summary.trend == MoodTrend.improving) {
      messages.add(tr(lang,
          en: 'Things feel a little lighter this week.',
          ru: 'На этой неделе чуть полегче.',
          ky: 'Бул жума бир аз жеңилирээк.'));
    } else if (summary.trend == MoodTrend.declining) {
      messages.add(tr(lang,
          en: 'This week has been heavier than last.',
          ru: 'Эта неделя тяжелее прошлой.',
          ky: 'Бул жума өткөн жумадан оорураак.'));
    }

    if (messages.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        messages.first,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _CheckinBubble extends ConsumerWidget {
  final MoodCheckin checkin;
  const _CheckinBubble({required this.checkin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: _UserBubble(checkin: checkin, onDelete: () => _confirmDelete(context, ref)),
              ),
            ],
          ),
          if (checkin.aiReply != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: _BalamBubble(text: checkin.aiReply!),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [_ThinkingBubble()],
            ),
          ],
          if (checkin.flaggedCrisis) ...[
            const SizedBox(height: 8),
            const _CrisisStrip(),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final lang = currentLang(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          tr(lang,
              en: 'Delete this entry?',
              ru: 'Удалить запись?',
              ky: 'Жазууну өчүрөбүзбү?'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          tr(lang,
              en: 'Gone for good. No one else has seen it.',
              ru: 'Удалим навсегда. Никто кроме тебя её не видел.',
              ky: 'Биротоло өчүрөбүз. Сизден башка эч ким көргөн жок.'),
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              tr(lang, en: 'Cancel', ru: 'Отмена', ky: 'Жокко чыгаруу'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              tr(lang, en: 'Delete', ru: 'Удалить', ky: 'Өчүрүү'),
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;
    await deleteMoodCheckin(uid, checkin.id);
  }
}

class _UserBubble extends StatelessWidget {
  final MoodCheckin checkin;
  final VoidCallback onDelete;
  const _UserBubble({required this.checkin, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(checkin.level.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  _shortWhen(context, checkin.createdAt),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (checkin.note != null) ...[
              const SizedBox(height: 6),
              Text(
                checkin.note!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _shortWhen(BuildContext context, DateTime when) {
    final lang = currentLang(context);
    final now = DateTime.now();
    final isSameDay = when.year == now.year && when.month == now.month && when.day == now.day;
    if (isSameDay) {
      final h = when.hour.toString().padLeft(2, '0');
      final m = when.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final diff = now.difference(when).inDays;
    if (diff == 1) {
      return tr(lang, en: 'Yesterday', ru: 'Вчера', ky: 'Кечээ');
    }
    return tr(lang, en: '$diff days ago', ru: '$diff дней назад', ky: '$diff күн мурда');
  }
}

class _BalamBubble extends StatelessWidget {
  final String text;
  const _BalamBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          SizedBox(width: 8),
          Text(
            '…',
            style: TextStyle(color: AppColors.textHint, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CrisisStrip extends StatelessWidget {
  const _CrisisStrip();

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                en: 'A real person, right now.',
                ru: 'С тобой может быть живой человек, прямо сейчас.',
                ky: 'Жаныңда жанду адам азыр болсун.'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MiniCrisisBtn(
                  label: tr(lang,
                      en: 'Text HOME → 741741',
                      ru: 'СМС HOME на 741741',
                      ky: 'SMS HOME → 741741'),
                  icon: Icons.sms_outlined,
                  onTap: () => _sms('741741', 'HOME'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniCrisisBtn(
                  label: tr(lang,
                      en: 'Call 988',
                      ru: 'Звонок 988',
                      ky: '988 чалуу'),
                  icon: Icons.call_outlined,
                  onTap: () => _tel('988'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sms(String number, String body) async {
    final uri = Uri(scheme: 'sms', path: number, queryParameters: {'body': body});
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _tel(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _MiniCrisisBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _MiniCrisisBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

// Re-used by GoRouter — keep this default builder thin so the router
// file stays readable.
class MoodRoute extends StatelessWidget {
  const MoodRoute({super.key});

  @override
  Widget build(BuildContext context) => const MoodScreen();
}
