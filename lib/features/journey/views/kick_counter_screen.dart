import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/tracking_entry.dart';
import '../providers/journey_provider.dart';

class KickCounterScreen extends ConsumerStatefulWidget {
  const KickCounterScreen({super.key});

  @override
  ConsumerState<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends ConsumerState<KickCounterScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    final profile = ref.read(userProfileProvider);
    ref.read(kickSessionProvider.notifier).startSession(profile.uid);
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = ref.read(kickSessionProvider);
      if (session != null) {
        setState(() => _elapsed = session.elapsed);
      }
    });
  }

  void _recordKick() {
    ref.read(kickSessionProvider.notifier).recordKick();
    // Haptic-like visual feedback
  }

  void _finishSession() {
    _timer?.cancel();
    final completed = ref.read(kickSessionProvider.notifier).completeSession();
    if (completed != null) {
      // Save as tracking entry
      ref.read(trackingEntriesProvider.notifier).addEntry(
            TrackingEntry(
              id: completed.id,
              userId: completed.userId,
              type: TrackingType.kicks,
              value: completed.kickCount.toDouble(),
              unit: 'kicks',
              notes:
                  '${completed.kickCount} kicks in ${_formatDuration(completed.elapsed)}',
              metadata: {
                'sessionDurationSeconds': completed.elapsed.inSeconds,
                'kicks': completed.kicks.map((k) => k.toIso8601String()).toList(),
              },
              timestamp: completed.startTime,
              createdAt: DateTime.now(),
            ),
          );
    }
    setState(() {
      _isRunning = false;
      _elapsed = Duration.zero;
    });
    if (mounted) context.pop();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(kickSessionProvider);
    final kickCount = session?.kickCount ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).kickCounter),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_isRunning) {
              ref.read(kickSessionProvider.notifier).cancelSession();
              _timer?.cancel();
            }
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Timer
          Text(
            _formatDuration(_elapsed),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRunning ? L.of(context).sessionInProgress : L.of(context).tapStartToBegin,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),

          // Kick count
          Text(
            '$kickCount',
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            kickCount == 1 ? L.of(context).kickSingular : L.of(context).kickPlural,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),

          // Main action button
          if (!_isRunning)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _startSession,
                  child: Text(L.of(context).startCounting, style: const TextStyle(fontSize: 18)),
                ),
              ),
            )
          else ...[
            // Big kick button
            GestureDetector(
              onTap: _recordKick,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white, size: 48),
                    const SizedBox(height: 4),
                    Text(
                      L.of(context).tapButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Finish button
            TextButton(
              onPressed: _finishSession,
              child: Text(
                L.of(context).finishSession,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Info card
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L.of(context).kickCounterInfo,
                    style: TextStyle(
                      color: AppColors.secondaryDark,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
