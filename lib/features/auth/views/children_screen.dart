import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/child_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/providers/journey_provider.dart';

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final children = profile.children;

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).myChildren),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(L.of(context).addChild),
      ),
      body: children.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    L.of(context).noChildrenYet,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L.of(context).addChildToStart,
                    style: TextStyle(color: AppColors.textHint),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, i) {
                final child = children[i];
                final isSelected = child.id == profile.selectedChildId;
                return _ChildCard(
                  child: child,
                  isSelected: isSelected,
                  onSelect: () => ref.read(userProfileProvider.notifier).selectChild(child.id),
                  onEdit: () => _showEditChildDialog(context, ref, child),
                  onDelete: () => _confirmDelete(context, ref, child),
                );
              },
            ),
    );
  }

  void _showAddChildDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var selectedStage = ParentingStage.pregnant;
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L.of(context).addChild, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: L.of(context).childName,
                  prefixIcon: const Icon(Icons.child_care),
                ),
              ),
              const SizedBox(height: 16),
              Text(L.of(context).stage, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ParentingStage.values.map((stage) {
                  final isSelected = selectedStage == stage;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedStage = stage),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                      ),
                      child: Text(
                        stage.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedStage == ParentingStage.pregnant
                        ? DateTime.now().add(const Duration(days: 120))
                        : DateTime.now().subtract(const Duration(days: 90)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2028),
                  );
                  if (picked != null) setSheetState(() => selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : selectedStage == ParentingStage.pregnant
                        ? L.of(context).selectDueDate
                        : L.of(context).selectBirthDate),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final child = Child(
                      id: 'child-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      stage: selectedStage,
                      dueDate: selectedStage == ParentingStage.pregnant ? selectedDate : null,
                      birthDate: selectedStage != ParentingStage.pregnant ? selectedDate : null,
                    );
                    ref.read(userProfileProvider.notifier).addChild(child);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(L.of(context).addChild),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditChildDialog(BuildContext context, WidgetRef ref, Child child) {
    final nameController = TextEditingController(text: child.name);
    var selectedStage = child.stage;
    DateTime? selectedDate = child.birthDate ?? child.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L.of(context).editChild, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: L.of(context).childName,
                  prefixIcon: const Icon(Icons.child_care),
                ),
              ),
              const SizedBox(height: 16),
              Text(L.of(context).stage, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ParentingStage.values.map((stage) {
                  final isSelected = selectedStage == stage;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedStage = stage),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                      ),
                      child: Text(
                        stage.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2028),
                  );
                  if (picked != null) setSheetState(() => selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : L.of(context).selectDate),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final updated = child.copyWith(
                      name: nameController.text.trim(),
                      stage: selectedStage,
                      dueDate: selectedStage == ParentingStage.pregnant ? selectedDate : child.dueDate,
                      birthDate: selectedStage != ParentingStage.pregnant ? selectedDate : child.birthDate,
                    );
                    ref.read(userProfileProvider.notifier).updateChild(updated);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(L.of(context).save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Child child) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L.of(context).removeChild),
        content: Text(L.of(context).removeChildConfirm(child.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(L.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).removeChild(child.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(L.of(context).remove),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Stage is null for adult members (self, partner, grandparents…).
    // Fall back to a generic person icon and role-based subtitle in that case.
    final stage = child.stage;
    final IconData stageIcon = stage == null
        ? Icons.person_outline
        : switch (stage) {
            ParentingStage.tryingToConceive => Icons.favorite,
            ParentingStage.pregnant => Icons.pregnant_woman,
            ParentingStage.newborn => Icons.child_care,
            ParentingStage.toddler => Icons.child_friendly,
          };

    String subtitle;
    if (stage == null) {
      // Adult: show age in years or just the name.
      final years = child.ageYears;
      subtitle = years != null ? '$years' : child.role.name;
    } else if (stage == ParentingStage.pregnant) {
      final weeks = child.currentWeek;
      subtitle = weeks != null
          ? '${L.of(context).weekN(weeks)} — ${L.of(context).daysToGo(child.daysRemaining ?? 0)}'
          : stage.label;
    } else if (child.ageMonths != null) {
      subtitle = '${child.ageMonths} ${L.of(context).months} — ${stage.label}';
    } else {
      subtitle = stage.label;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(stageIcon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(child.name, style: Theme.of(context).textTheme.titleMedium),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              L.of(context).active,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.textSecondary,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
