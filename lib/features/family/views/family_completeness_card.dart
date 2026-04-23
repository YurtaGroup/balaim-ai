import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../journey/providers/journey_provider.dart';
import 'add_member_sheet.dart';

/// Shows on Today when the account has <2 real members. This is the
/// viral-loop surface: every added member makes Balam's AI smarter
/// for that family AND triggers a WhatsApp invite to that person.
/// Self-hides once the family has 2+ members (the empty-vault problem
/// is solved).
class FamilyCompletenessCard extends ConsumerWidget {
  const FamilyCompletenessCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    if (profile.members.length >= 2) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AddMemberSheet.show(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.family_restroom, color: AppColors.secondaryDark, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(currentLang(context),
                          en: 'Balam is sharper with your whole family',
                          ru: 'Balam умнее, когда знает всю семью',
                          ky: 'Balam бүт үй-бүлөңүздү билсе акылдуу болот'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(currentLang(context),
                          en: 'Add your mother, wife, father or child — free forever.',
                          ru: 'Добавь маму, жену, отца или ребёнка — бесплатно навсегда.',
                          ky: 'Апаңды, жубайыңды, атаңды же балаңды кош — ар дайым акысыз.'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.secondaryDark, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
