import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../models/persona.dart';
import '../providers/active_persona_provider.dart';
import '../services/prompt_library.dart';

/// Horizontal carousel of age-bucketed prompts for the active persona.
/// Tapping a card invokes [onPick] with the question text in the user's
/// current language. The active child's age (months) determines which
/// bucket we pull from; the active persona determines whose voice the
/// questions are framed for.
class PromptLibraryCarousel extends ConsumerWidget {
  final HouseholdMember? activeChild;
  final ValueChanged<String> onPick;
  final EdgeInsetsGeometry padding;

  const PromptLibraryCarousel({
    super.key,
    required this.activeChild,
    required this.onPick,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activePersonaProvider);
    final persona = personaById(activeId);
    final libAsync = ref.watch(promptLibraryProvider);
    final lang = currentLang(context);

    return libAsync.when(
      data: (lib) {
        final questions = lib.questionsFor(activeId, activeChild?.ageMonths);
        if (questions.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: padding,
          child: Row(
            children: questions
                .map((q) => _PromptCard(
                      text: q.forLang(lang),
                      color: persona.color,
                      onTap: () => onPick(q.forLang(lang)),
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _PromptCard({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: color, size: 16),
              const SizedBox(height: 6),
              Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
