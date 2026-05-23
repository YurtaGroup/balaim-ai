import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable red "Emergency" entry. Placed on Home (full-width row) and Ask
/// (compact pill) — tapping routes to the EmergencyScreen.
class EmergencyEntryPill extends StatelessWidget {
  final bool compact;

  const EmergencyEntryPill({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return InkWell(
      onTap: () => context.push('/emergency'),
      borderRadius: BorderRadius.circular(compact ? 999 : 14),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: compact ? 0.10 : 1.0),
          borderRadius: BorderRadius.circular(compact ? 999 : 14),
          border: compact
              ? Border.all(color: AppColors.error.withValues(alpha: 0.50))
              : null,
          boxShadow: compact
              ? null
              : [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.emergency_outlined,
              color: compact ? AppColors.error : Colors.white,
              size: compact ? 16 : 22,
            ),
            SizedBox(width: compact ? 6 : 12),
            if (compact)
              Text(
                tr(lang, en: 'Emergency', ru: 'SOS', ky: 'SOS'),
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(lang,
                          en: 'Emergency — get help fast',
                          ru: 'Экстренная помощь — быстро',
                          ky: 'Шашылыш жардам — тез'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(lang,
                          en: 'AI Pediatrician on call. Free.',
                          ru: 'AI-педиатр на связи. Бесплатно.',
                          ky: 'AI-педиатр байланышта. Акысыз.'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            if (!compact)
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}
