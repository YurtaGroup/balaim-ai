import 'package:flutter/material.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/consultation.dart';

/// Small status pill shown on consultation rows.
class ConsultStatusChip extends StatelessWidget {
  final ConsultStatus status;
  const ConsultStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    final (label, color) = switch (status) {
      ConsultStatus.awaitingDoctor => (
          tr(lang, en: 'Awaiting reply', ru: 'Ждёт ответа', ky: 'Жооп күтүүдө'),
          AppColors.accent,
        ),
      ConsultStatus.answered => (
          tr(lang, en: 'Answered', ru: 'Есть ответ', ky: 'Жооп берилди'),
          AppColors.primary,
        ),
      ConsultStatus.closed => (
          tr(lang, en: 'Closed', ru: 'Закрыта', ky: 'Жабылды'),
          AppColors.textHint,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
