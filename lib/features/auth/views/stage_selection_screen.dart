import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class StageSelectionScreen extends StatelessWidget {
  const StageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                "What stage\nare you in?",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "This personalizes your entire experience",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              _StageCard(
                stage: ParentingStage.tryingToConceive,
                icon: Icons.favorite,
                color: AppColors.stagePrePregnancy,
                onTap: () => context.go('/'),
              ),
              const SizedBox(height: 12),
              _StageCard(
                stage: ParentingStage.pregnant,
                icon: Icons.pregnant_woman,
                color: AppColors.stagePregnancy,
                onTap: () => context.go('/'),
              ),
              const SizedBox(height: 12),
              _StageCard(
                stage: ParentingStage.newborn,
                icon: Icons.child_care,
                color: AppColors.stageNewborn,
                onTap: () => context.go('/'),
              ),
              const SizedBox(height: 12),
              _StageCard(
                stage: ParentingStage.toddler,
                icon: Icons.child_friendly,
                color: AppColors.stageToddler,
                onTap: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final ParentingStage stage;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StageCard({
    required this.stage,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stage.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
