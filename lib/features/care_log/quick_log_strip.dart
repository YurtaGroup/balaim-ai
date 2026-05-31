import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/l10n/content_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/child_model.dart';
import '../../shared/models/diaper_entry.dart';
import '../../shared/models/feeding_entry.dart';
import '../auth/providers/auth_provider.dart';
import 'care_log_provider.dart';

/// The survival-data strip on Home. One row, three actions:
/// **Feed · Diaper · …** with a live "Last feed: 2h 14m ago" stat
/// above. Taps land in a sheet, log writes are 1-2 taps total.
///
/// This is the open-the-app-12x-a-day surface for newborn parents.
/// Treat every millisecond of friction here as a defect.
class QuickLogStrip extends ConsumerWidget {
  final HouseholdMember child;
  const QuickLogStrip({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final lastFeed = lastFeedingFor(ref, child.id);
    final wetToday = wetDiaperCountToday(ref, child.id);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: tr(lang,
                      en: 'Last feed',
                      ru: 'Покормил',
                      ky: 'Акыркы тамак'),
                  value: lastFeed == null
                      ? tr(lang, en: '—', ru: '—', ky: '—')
                      : _ago(lastFeed.startTime, lang),
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _Stat(
                  label: tr(lang,
                      en: 'Wet today',
                      ru: 'Мокрых сегодня',
                      ky: 'Бүгүн нымдуу'),
                  value: '$wetToday',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Btn(
                  emoji: '🍼',
                  label: tr(lang, en: 'Feed', ru: 'Кормить', ky: 'Тамак'),
                  onTap: () => _openFeedingSheet(context, ref, child),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Btn(
                  emoji: '💧',
                  label:
                      tr(lang, en: 'Diaper', ru: 'Подгузник', ky: 'Жөргөк'),
                  onTap: () => _openDiaperSheet(context, ref, child),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _ago(DateTime then, String lang) {
    final diff = DateTime.now().difference(then);
    if (diff.inMinutes < 1) {
      return tr(lang, en: 'just now', ru: 'только что', ky: 'азыр гана');
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return tr(lang, en: '${m}m ago', ru: '${m} мин', ky: '${m} мин');
    }
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return tr(lang,
        en: '${h}h ${m}m ago',
        ru: '${h}ч ${m}мин',
        ky: '${h}с ${m}мин');
  }

  static void _openFeedingSheet(
      BuildContext context, WidgetRef ref, HouseholdMember child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FeedingSheet(child: child),
    );
  }

  static void _openDiaperSheet(
      BuildContext context, WidgetRef ref, HouseholdMember child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DiaperSheet(child: child),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: AppColors.divider,
      );
}

class _Btn extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feeding sheet ────────────────────────────────────────────────

class _FeedingSheet extends ConsumerStatefulWidget {
  final HouseholdMember child;
  const _FeedingSheet({required this.child});

  @override
  ConsumerState<_FeedingSheet> createState() => _FeedingSheetState();
}

class _FeedingSheetState extends ConsumerState<_FeedingSheet> {
  bool _saving = false;

  Future<void> _logBreast(FeedingType side) async {
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final id = await logFeeding(
      uid: uid,
      childId: widget.child.id,
      type: side,
      startTime: DateTime.now(),
    );
    if (id != null) {
      unawaited(Analytics.instance.feedingLogged(
        type: side.name,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _logBottle(FeedingType kind, double ml) async {
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final id = await logFeeding(
      uid: uid,
      childId: widget.child.id,
      type: kind,
      startTime: DateTime.now(),
      amountMl: ml,
    );
    if (id != null) {
      unawaited(Analytics.instance.feedingLogged(
        type: kind.name,
        amountMl: ml.round(),
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Handle(),
          const SizedBox(height: 14),
          Text(
            tr(lang,
                en: 'Feeding',
                ru: 'Кормление',
                ky: 'Тамактануу'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr(lang,
                en: 'Right now. You can edit later.',
                ru: 'Сейчас. Можно отредактировать позже.',
                ky: 'Азыр. Кийин түзөтсө болот.'),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          // Breast row
          _SectionLabel(text: tr(lang, en: 'Breast', ru: 'Грудь', ky: 'Эмчек')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BigButton(
                  label: tr(lang, en: 'Left', ru: 'Левая', ky: 'Сол'),
                  disabled: _saving,
                  onTap: () => _logBreast(FeedingType.breastLeft),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BigButton(
                  label: tr(lang, en: 'Right', ru: 'Правая', ky: 'Оң'),
                  disabled: _saving,
                  onTap: () => _logBreast(FeedingType.breastRight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionLabel(text: tr(lang, en: 'Bottle', ru: 'Бутылка', ky: 'Бөтөлкө')),
          const SizedBox(height: 6),
          Text(
            tr(lang,
                en: 'Tap an amount — breast milk',
                ru: 'Выбери объём — грудное молоко',
                ky: 'Көлөмүн тандаңыз — эмчек сүтү'),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          _MlRow(
            disabled: _saving,
            onTap: (ml) => _logBottle(FeedingType.bottleBreastMilk, ml),
          ),
          const SizedBox(height: 10),
          Text(
            tr(lang,
                en: 'Tap an amount — formula',
                ru: 'Выбери объём — смесь',
                ky: 'Көлөмүн тандаңыз — аралашма'),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          _MlRow(
            disabled: _saving,
            onTap: (ml) => _logBottle(FeedingType.bottleFormula, ml),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MlRow extends StatelessWidget {
  final void Function(double ml) onTap;
  final bool disabled;
  const _MlRow({required this.onTap, required this.disabled});

  @override
  Widget build(BuildContext context) {
    const options = <double>[60, 90, 120, 150, 180];
    return Row(
      children: [
        for (final ml in options) ...[
          Expanded(
            child: _BigButton(
              label: '${ml.round()} ml',
              disabled: disabled,
              onTap: () => onTap(ml),
            ),
          ),
          if (ml != options.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ─── Diaper sheet ────────────────────────────────────────────────

class _DiaperSheet extends ConsumerStatefulWidget {
  final HouseholdMember child;
  const _DiaperSheet({required this.child});

  @override
  ConsumerState<_DiaperSheet> createState() => _DiaperSheetState();
}

class _DiaperSheetState extends ConsumerState<_DiaperSheet> {
  bool _saving = false;

  Future<void> _log(DiaperType type) async {
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final id = await logDiaper(
      uid: uid,
      childId: widget.child.id,
      type: type,
    );
    if (id != null) {
      unawaited(Analytics.instance.diaperLogged(type: type.name));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Handle(),
          const SizedBox(height: 14),
          Text(
            tr(lang,
                en: 'Diaper',
                ru: 'Подгузник',
                ky: 'Жөргөк'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BigButton(
                  label: tr(lang,
                      en: '💧 Wet',
                      ru: '💧 Мокрый',
                      ky: '💧 Нымдуу'),
                  disabled: _saving,
                  onTap: () => _log(DiaperType.wet),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BigButton(
                  label: tr(lang,
                      en: '💩 Dirty',
                      ru: '💩 Грязный',
                      ky: '💩 Кир'),
                  disabled: _saving,
                  onTap: () => _log(DiaperType.dirty),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BigButton(
                  label: tr(lang,
                      en: '💧💩 Both',
                      ru: '💧💩 Оба',
                      ky: '💧💩 Экөө'),
                  disabled: _saving,
                  onTap: () => _log(DiaperType.both),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BigButton(
                  label: tr(lang,
                      en: '⊘ Dry',
                      ru: '⊘ Сухой',
                      ky: '⊘ Кургак'),
                  disabled: _saving,
                  onTap: () => _log(DiaperType.dry),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared sheet bits ───────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      );
}

class _BigButton extends StatelessWidget {
  final String label;
  final bool disabled;
  final VoidCallback onTap;
  const _BigButton({
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
