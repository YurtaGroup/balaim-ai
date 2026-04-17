import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/diaper_entry.dart';
import '../providers/newborn_tracking_provider.dart';

class DiaperLogScreen extends ConsumerWidget {
  const DiaperLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(diaperEntriesProvider);
    final notifier = ref.read(diaperEntriesProvider.notifier);
    final today = notifier.todayEntries();
    final wetToday = today.where((e) =>
      e.type == DiaperType.wet || e.type == DiaperType.both).length;
    final dirtyToday = today.where((e) =>
      e.type == DiaperType.dirty || e.type == DiaperType.both).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).diaperLog),
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
                colors: [AppColors.secondary, AppColors.secondaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
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
                        L.of(context).diapersToday,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💧 $wetToday wet',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '💩 $dirtyToday dirty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.accentDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    L.of(context).wetDiapersGuidance,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick add
          Text(L.of(context).logADiaper, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickLogButton(
                  emoji: '💧',
                  label: 'Wet',
                  color: AppColors.secondary,
                  onTap: () => _log(context, ref, DiaperType.wet),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickLogButton(
                  emoji: '💩',
                  label: 'Dirty',
                  color: AppColors.accent,
                  onTap: () => _log(context, ref, DiaperType.dirty),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickLogButton(
                  emoji: '💧💩',
                  label: 'Both',
                  color: AppColors.primary,
                  onTap: () => _log(context, ref, DiaperType.both),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickLogButton(
                  emoji: '✓',
                  label: 'Dry',
                  color: AppColors.success,
                  onTap: () => _log(context, ref, DiaperType.dry),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (entries.isNotEmpty) ...[
            Text(L.of(context).history, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...entries.map(
              (e) => _DiaperTile(
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

  void _log(BuildContext context, WidgetRef ref, DiaperType type) {
    ref.read(diaperEntriesProvider.notifier).add(
          DiaperEntry(
            id: const Uuid().v4(),
            type: type,
            timestamp: DateTime.now(),
          ),
        );
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(L.of(context).diaperLoggedToast(timeStr))),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.emoji,
    required this.label,
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaperTile extends StatelessWidget {
  final DiaperEntry entry;
  final VoidCallback onDelete;

  const _DiaperTile({required this.entry, required this.onDelete});

  String get _emoji {
    switch (entry.type) {
      case DiaperType.wet:
        return '💧';
      case DiaperType.dirty:
        return '💩';
      case DiaperType.both:
        return '💧💩';
      case DiaperType.dry:
        return '✓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = entry.timestamp;
    final timeStr =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
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
            Text(_emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                entry.type.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
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
