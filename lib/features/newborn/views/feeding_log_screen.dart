import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/feeding_entry.dart';
import '../providers/newborn_tracking_provider.dart';

class FeedingLogScreen extends ConsumerWidget {
  const FeedingLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(feedingEntriesProvider);
    final notifier = ref.read(feedingEntriesProvider.notifier);
    final today = notifier.todayEntries();
    final sinceLast = notifier.timeSinceLastFeed();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).feedingLog),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${today.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'feeds today',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sinceLast != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDuration(sinceLast),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'since last feed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick add buttons
          Text('Log a feeding', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAddButton(
                  label: 'Breast\nLeft',
                  icon: Icons.chevron_left,
                  color: AppColors.primary,
                  onTap: () => _logBreast(context, ref, FeedingType.breastLeft),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAddButton(
                  label: 'Breast\nRight',
                  icon: Icons.chevron_right,
                  color: AppColors.primary,
                  onTap: () =>
                      _logBreast(context, ref, FeedingType.breastRight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickAddButton(
                  label: 'Bottle\nBreast Milk',
                  icon: Icons.local_drink,
                  color: AppColors.secondary,
                  onTap: () =>
                      _logBottle(context, ref, FeedingType.bottleBreastMilk),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAddButton(
                  label: 'Bottle\nFormula',
                  icon: Icons.local_drink_outlined,
                  color: AppColors.accent,
                  onTap: () =>
                      _logBottle(context, ref, FeedingType.bottleFormula),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // History
          if (entries.isNotEmpty) ...[
            Text('History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...entries.map(
              (e) => _FeedingTile(
                entry: e,
                onDelete: () => notifier.remove(e.id),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Future<void> _logBreast(
    BuildContext context,
    WidgetRef ref,
    FeedingType type,
  ) async {
    final duration = await showDialog<int>(
      context: context,
      builder: (_) => _BreastDurationDialog(side: type),
    );
    if (duration == null) return;
    ref.read(feedingEntriesProvider.notifier).add(
          FeedingEntry(
            id: const Uuid().v4(),
            type: type,
            startTime: DateTime.now().subtract(Duration(minutes: duration)),
            endTime: DateTime.now(),
            durationMinutes: duration,
          ),
        );
  }

  Future<void> _logBottle(
    BuildContext context,
    WidgetRef ref,
    FeedingType type,
  ) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _BottleAmountDialog(type: type),
    );
    if (amount == null) return;
    ref.read(feedingEntriesProvider.notifier).add(
          FeedingEntry(
            id: const Uuid().v4(),
            type: type,
            startTime: DateTime.now(),
            amountMl: amount,
          ),
        );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedingTile extends StatelessWidget {
  final FeedingEntry entry;
  final VoidCallback onDelete;

  const _FeedingTile({required this.entry, required this.onDelete});

  IconData get _icon {
    switch (entry.type) {
      case FeedingType.breastLeft:
      case FeedingType.breastRight:
        return Icons.favorite;
      case FeedingType.bottleBreastMilk:
        return Icons.local_drink;
      case FeedingType.bottleFormula:
        return Icons.local_drink_outlined;
      case FeedingType.solid:
        return Icons.restaurant;
    }
  }

  Color get _color {
    switch (entry.type) {
      case FeedingType.breastLeft:
      case FeedingType.breastRight:
        return AppColors.primary;
      case FeedingType.bottleBreastMilk:
        return AppColors.secondary;
      case FeedingType.bottleFormula:
        return AppColors.accent;
      case FeedingType.solid:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = entry.startTime;
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.type.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    entry.displayValue,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// DIALOGS
// =========================================================

class _BreastDurationDialog extends StatefulWidget {
  final FeedingType side;
  const _BreastDurationDialog({required this.side});

  @override
  State<_BreastDurationDialog> createState() => _BreastDurationDialogState();
}

class _BreastDurationDialogState extends State<_BreastDurationDialog> {
  double minutes = 15;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.side.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${minutes.round()} min',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Slider(
            value: minutes,
            min: 1,
            max: 45,
            divisions: 44,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => minutes = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(minutes.round()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _BottleAmountDialog extends StatefulWidget {
  final FeedingType type;
  const _BottleAmountDialog({required this.type});

  @override
  State<_BottleAmountDialog> createState() => _BottleAmountDialogState();
}

class _BottleAmountDialogState extends State<_BottleAmountDialog> {
  double ml = 90;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.type.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${ml.round()} ml',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          Slider(
            value: ml,
            min: 10,
            max: 300,
            divisions: 29,
            activeColor: AppColors.secondary,
            onChanged: (v) => setState(() => ml = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(ml),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
