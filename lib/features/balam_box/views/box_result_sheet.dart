import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../box_service.dart';

/// Renders the tier classification that came back from `submitBoxReading`.
/// Green → quick confirmation. Yellow/Orange → coloured banner with next
/// steps. Red → full-screen emergency card with one-tap dial.
class BoxResultSheet extends StatelessWidget {
  final BoxClassification result;
  const BoxResultSheet({super.key, required this.result});

  static Future<void> show(BuildContext context, BoxClassification result) {
    if (result.tier == BoxTier.red) {
      // Emergency — hard interrupt, not a dismissable sheet.
      HapticFeedback.heavyImpact();
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _RedEmergencyDialog(result: result),
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BoxResultSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, icon, label) = _tierStyle(result.tier, context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: bgColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: bgColor,
                        ),
                      ),
                      Text(
                        result.ruleId,
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              result.reason.of(context),
              style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
            ),
            const SizedBox(height: 20),
            if (result.tier == BoxTier.green)
              _GreenFooter()
            else
              _NonGreenFooter(tier: result.tier, hasNotice: result.noticeId != null),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(tr(currentLang(context),
                    en: 'Close',
                    ru: 'Закрыть',
                    ky: 'Жабуу')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _tierStyle(BoxTier tier, BuildContext context) {
    switch (tier) {
      case BoxTier.green:
        return (
          AppColors.success,
          Icons.check_circle_outline,
          tr(currentLang(context), en: 'All clear', ru: 'Всё в порядке', ky: 'Баары жакшы'),
        );
      case BoxTier.yellow:
        return (
          AppColors.warning,
          Icons.info_outline,
          tr(currentLang(context), en: 'Keep an eye', ru: 'Следим', ky: 'Байкайбыз'),
        );
      case BoxTier.orange:
        return (
          AppColors.primary,
          Icons.medical_services_outlined,
          tr(currentLang(context),
              en: 'Clinician review in 24h',
              ru: 'Врач — в течение 24 ч',
              ky: 'Дарыгер — 24 саат ичинде'),
        );
      case BoxTier.red:
        return (AppColors.error, Icons.warning_amber_rounded, 'EMERGENCY');
    }
  }
}

class _GreenFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      tr(currentLang(context),
          en: 'Logged to your record. Balam watches the trend nightly.',
          ru: 'Сохранено в истории. Balam отслеживает динамику каждую ночь.',
          ky: 'Тарыхка сакталды. Balan динамиканы ар бир түнү көзөмөлдөйт.'),
      style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
    );
  }
}

class _NonGreenFooter extends StatelessWidget {
  final BoxTier tier;
  final bool hasNotice;
  const _NonGreenFooter({required this.tier, required this.hasNotice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            tier == BoxTier.orange
                ? tr(currentLang(context),
                    en: 'We\'ve queued this for the on-call clinician. You\'ll get a push when they respond.',
                    ru: 'Случай поставлен в очередь дежурному врачу. Придёт уведомление, когда ответит.',
                    ky: 'Окуя кезекчи дарыгерге кезекке коюлду. Жооп келгенде пуш келет.')
                : tr(currentLang(context),
                    en: 'Logged and tracked. Balam will escalate if the pattern continues.',
                    ru: 'Сохранено. Balam эскалирует, если паттерн сохранится.',
                    ky: 'Сакталды. Эгер кайталанса, Balam эскалациялайт.'),
            style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
          ),
        ),
        if (hasNotice) ...[
          const SizedBox(height: 10),
          Text(
            tr(currentLang(context),
                en: 'Added to your Today screen as a "Balam noticed…" card.',
                ru: 'Добавлено на экран Today как карточка «Balam заметил…».',
                ky: 'Today экранына «Balam байкады…» карточкасы катары кошулду.'),
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _RedEmergencyDialog extends StatelessWidget {
  final BoxClassification result;
  const _RedEmergencyDialog({required this.result});

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final instruction = result.emergency?.instruction.of(context) ??
        result.reason.of(context);
    final numbers = result.emergency?.callNumbers ?? const {};
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 32),
                const SizedBox(width: 8),
                const Text(
                  'EMERGENCY',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              instruction,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ..._dialButtons(numbers),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/emergency');
              },
              child: Text(tr(currentLang(context),
                  en: 'See emergency reference',
                  ru: 'Экстренная справка',
                  ky: 'Шашылыш маалымат')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                tr(currentLang(context),
                    en: 'I understand, close',
                    ru: 'Понятно, закрыть',
                    ky: 'Түшүндүм, жабуу'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _dialButtons(Map<String, String> numbers) {
    const labels = {
      'kg': 'Kyrgyzstan 103',
      'us': 'USA 911',
      'ru': 'Russia 103',
    };
    return numbers.entries.map((e) {
      final label = labels[e.key] ?? e.key.toUpperCase();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton.icon(
          onPressed: () => _dial(e.value),
          icon: const Icon(Icons.phone),
          label: Text('$label — ${e.value}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }).toList();
  }
}
