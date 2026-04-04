import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/birth_plan_data.dart';
import '../providers/birth_plan_provider.dart';

class BirthPlanScreen extends ConsumerWidget {
  const BirthPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(birthPlanProvider);
    final notifier = ref.read(birthPlanProvider.notifier);
    final totalQuestions = BirthPlanData.questions.length;
    final answered = notifier.answeredCount;
    final progress = totalQuestions > 0 ? answered / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Birth Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (answered > 0)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _showSummary(context, plan),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Birth Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$answered of $totalQuestions questions answered',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: AppColors.accentDark, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Your birth plan is a wish list, not a contract. Share it with your care team. Be flexible — baby decides.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // Sections
          ...BirthPlanData.sections.map((section) {
            final questions = BirthPlanData.bySection(section);
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _Section(
                title: section,
                questions: questions,
                plan: plan,
                onToggle: notifier.toggleOption,
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSummary(BuildContext context, Map<String, List<String>> plan) {
    final questionsById = {
      for (var q in BirthPlanData.questions) q.id: q,
    };
    final bySection = <String, List<String>>{};
    for (final entry in plan.entries) {
      final q = questionsById[entry.key];
      if (q == null) continue;
      bySection.putIfAbsent(q.section, () => []);
      bySection[q.section]!.add('${q.question}: ${entry.value.join(', ')}');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            Text(
              'My Birth Plan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...bySection.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• $line',
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<BirthPlanQuestion> questions;
  final Map<String, List<String>> plan;
  final void Function(String questionId, String option) onToggle;

  const _Section({
    required this.title,
    required this.questions,
    required this.plan,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...questions.map((q) => _QuestionCard(
              question: q,
              selected: plan[q.id] ?? const [],
              onToggle: (opt) => onToggle(q.id, opt),
            )),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final BirthPlanQuestion question;
  final List<String> selected;
  final void Function(String option) onToggle;

  const _QuestionCard({
    required this.question,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.options.map((opt) {
              final isSelected = selected.contains(opt);
              return GestureDetector(
                onTap: () => onToggle(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
