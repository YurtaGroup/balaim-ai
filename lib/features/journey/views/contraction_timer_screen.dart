import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/contraction.dart';
import '../providers/contraction_provider.dart';

class ContractionTimerScreen extends ConsumerStatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  ConsumerState<ContractionTimerScreen> createState() =>
      _ContractionTimerScreenState();
}

class _ContractionTimerScreenState
    extends ConsumerState<ContractionTimerScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  String _fmtShort(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(contractionsProvider.notifier);
    final contractions = ref.watch(contractionsProvider);
    final analysis = ref.watch(contractionAnalysisProvider);
    final isTiming = notifier.isTiming;
    final activeDuration = notifier.activeStartTime != null
        ? DateTime.now().difference(notifier.activeStartTime!)
        : Duration.zero;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contraction Timer'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (contractions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmClear(context, notifier),
            ),
        ],
      ),
      body: Column(
        children: [
          // Active contraction display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: isTiming
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isTiming ? null : AppColors.surface,
            ),
            child: Column(
              children: [
                Text(
                  isTiming ? 'CONTRACTION IN PROGRESS' : 'READY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isTiming
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isTiming ? _fmtDuration(activeDuration) : '--:--',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: isTiming ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Start/Stop button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  if (isTiming) {
                    notifier.stopContraction();
                  } else {
                    notifier.startContraction();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isTiming ? AppColors.error : AppColors.primary,
                ),
                child: Text(
                  isTiming ? 'Stop Contraction' : 'Start Contraction',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // Analysis
          if (analysis.count > 0) _AnalysisCard(analysis: analysis),

          // History
          Expanded(
            child: contractions.isEmpty
                ? _EmptyState()
                : _ContractionHistory(
                    contractions: contractions,
                    onDelete: notifier.removeContraction,
                    fmtDuration: _fmtShort,
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, ContractionsNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all contractions?'),
        content: const Text(
          'This will remove all recorded contractions from this session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAll();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final ContractionAnalysis analysis;

  const _AnalysisCard({required this.analysis});

  String _fmt(Duration? d) {
    if (d == null) return '--';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Stat(
                label: 'Count',
                value: '${analysis.count}',
                color: AppColors.primary,
              ),
              _Stat(
                label: 'Avg Length',
                value: _fmt(analysis.averageDuration),
                color: AppColors.secondary,
              ),
              _Stat(
                label: 'Avg Interval',
                value: _fmt(analysis.averageInterval),
                color: AppColors.accent,
              ),
            ],
          ),
          if (analysis.phase != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: analysis.meets511Rule
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    analysis.meets511Rule ? Icons.warning_amber : Icons.info_outline,
                    color: analysis.meets511Rule
                        ? AppColors.error
                        : AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.meets511Rule
                              ? '5-1-1 Rule Met — Call your doctor'
                              : analysis.phase!.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: analysis.meets511Rule
                                ? AppColors.error
                                : AppColors.secondaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          analysis.meets511Rule
                              ? 'Contractions are 5 min apart, lasting 1 min, for 1 hour. Time to go.'
                              : analysis.phase!.guidance,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'Tap Start Contraction\nwhen one begins',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractionHistory extends StatelessWidget {
  final List<Contraction> contractions;
  final void Function(String id) onDelete;
  final String Function(Duration) fmtDuration;

  const _ContractionHistory({
    required this.contractions,
    required this.onDelete,
    required this.fmtDuration,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...contractions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final c = sorted[i];
        final index = sorted.length - i;
        final previous = i < sorted.length - 1 ? sorted[i + 1] : null;
        final interval = previous != null
            ? c.startTime.difference(previous.startTime)
            : null;
        final time = '${c.startTime.hour.toString().padLeft(2, '0')}:${c.startTime.minute.toString().padLeft(2, '0')}';

        return Dismissible(
          key: Key(c.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(c.id),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Length: ${fmtDuration(c.duration)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (interval != null)
                        Text(
                          'Interval: ${fmtDuration(interval)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
