import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/content_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'doctors_provider.dart';
import 'models/doctor.dart';

/// Bottom sheet that lists active doctors and returns the one the
/// parent picks. Returns null if the sheet is dismissed.
///
/// Read-only — doctors only land in this picker via the `setDoctorClaim`
/// Cloud Function (Admin SDK write).
class DoctorPickerSheet extends ConsumerWidget {
  final Doctor? current;

  const DoctorPickerSheet({super.key, this.current});

  static Future<Doctor?> show(
    BuildContext context,
    WidgetRef ref, {
    Doctor? current,
  }) {
    return showModalBottomSheet<Doctor>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DoctorPickerSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final list = ref.watch(doctorsProvider).asData?.value ?? const [];

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
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
              const SizedBox(height: 14),
              Text(
                tr(lang,
                    en: 'Pick a doctor',
                    ru: 'Выбери врача',
                    ky: 'Дарыгерди тандаңыз'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(lang,
                    en: 'Async consult — they reply within a day.',
                    ru: 'Заочная консультация — ответ в течение дня.',
                    ky: 'Сырттан консультация — бир күндө жооп.'),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: list.isEmpty
                    ? _Empty(lang: lang)
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final d = list[i];
                          final isCurrent = current?.id == d.id;
                          return _DoctorTile(
                            doctor: d,
                            lang: lang,
                            isCurrent: isCurrent,
                            onTap: () => Navigator.of(context).pop(d),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final String lang;
  final bool isCurrent;
  final VoidCallback onTap;

  const _DoctorTile({
    required this.doctor,
    required this.lang,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canAccept = doctor.acceptingNew;
    return Material(
      color: isCurrent
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: canAccept ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? AppColors.primary : AppColors.divider,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: canAccept
                      ? AppColors.primary
                      : AppColors.textHint.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.medical_services,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          doctor.formattedRate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary),
                    ),
                    if (doctor.bio.forLocale(lang).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctor.bio.forLocale(lang),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (!canAccept) ...[
                      const SizedBox(height: 6),
                      Text(
                        tr(lang,
                            en: 'Not accepting new threads right now',
                            ru: 'Сейчас не принимает новых',
                            ky: 'Азыр жаңы кабылдабайт'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services_outlined,
                size: 40, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              tr(lang,
                  en: 'No doctors available right now.',
                  ru: 'Сейчас нет доступных врачей.',
                  ky: 'Азыр жеткиликтүү дарыгер жок.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(lang,
                  en: 'We are onboarding more pediatricians this week.',
                  ru: 'На этой неделе подключаем больше педиатров.',
                  ky: 'Бул жума көбүрөөк педиатр кошобуз.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
