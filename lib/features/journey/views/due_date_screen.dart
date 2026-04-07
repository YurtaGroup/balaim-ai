import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/journey_provider.dart';

class DueDateScreen extends ConsumerStatefulWidget {
  const DueDateScreen({super.key});

  @override
  ConsumerState<DueDateScreen> createState() => _DueDateScreenState();
}

class _DueDateScreenState extends ConsumerState<DueDateScreen> {
  DateTime? _selectedDate;
  bool _knowsDueDate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).dueDateAppBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L.of(context).dueDateTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              L.of(context).dueDateSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),

            // Toggle
            Row(
              children: [
                _ToggleChip(
                  label: L.of(context).iKnowMyDueDate,
                  isSelected: _knowsDueDate,
                  onTap: () => setState(() => _knowsDueDate = true),
                ),
                const SizedBox(width: 12),
                _ToggleChip(
                  label: L.of(context).calculateIt,
                  isSelected: !_knowsDueDate,
                  onTap: () => setState(() => _knowsDueDate = false),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_knowsDueDate) ...[
              // Date picker card
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 120)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 300)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: AppColors.primary,
                              ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedDate != null
                          ? AppColors.primary
                          : AppColors.divider,
                      width: _selectedDate != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _selectedDate != null
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                            : L.of(context).tapToSelectDueDate,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              _selectedDate != null ? FontWeight.w600 : FontWeight.w400,
                          color: _selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // LMP calculator
              Text(
                L.of(context).whenWasLMP,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 60)),
                    firstDate: DateTime.now().subtract(const Duration(days: 300)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    // Naegele's rule: LMP + 280 days = due date
                    setState(() {
                      _selectedDate = date.add(const Duration(days: 280));
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textHint),
                      const SizedBox(width: 14),
                      Text(
                        _selectedDate != null
                            ? L.of(context).dueDate('${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}')
                            : L.of(context).tapToSelectLMP,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_selectedDate != null) ...[
              const SizedBox(height: 24),
              // Preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.child_care, color: AppColors.primary, size: 48),
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      final lmp = _selectedDate!.subtract(const Duration(days: 280));
                      final daysSince = DateTime.now().difference(lmp).inDays;
                      final week = (daysSince / 7).ceil().clamp(1, 42);
                      final daysLeft = _selectedDate!.difference(DateTime.now()).inDays;
                      return Column(
                        children: [
                          Text(
                            L.of(context).weekN(week),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            L.of(context).daysToGo(daysLeft),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDate != null
                    ? () {
                        ref
                            .read(userProfileProvider.notifier)
                            .updateDueDate(_selectedDate!);
                        context.go('/');
                      }
                    : null,
                child: Text(L.of(context).continueButton),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
