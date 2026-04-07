import '../../../l10n/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/sounds_data.dart';
import '../../../core/services/audio_player_service.dart';
import '../providers/audio_provider.dart';

class SoundsScreen extends ConsumerStatefulWidget {
  const SoundsScreen({super.key});

  @override
  ConsumerState<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends ConsumerState<SoundsScreen> {
  @override
  Widget build(BuildContext context) {
    final service = ref.watch(audioServiceProvider);
    final stateAsync = ref.watch(audioStateProvider);
    final state = stateAsync.valueOrNull ?? service.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).sounds),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                state.currentPresetId != null ? 180 : 16,
              ),
              children: [
                _HeroBanner(),
                const SizedBox(height: 20),
                ...SoundCategory.values.map(
                  (cat) => _CategorySection(
                    category: cat,
                    playingId: state.currentPresetId,
                    onSelect: (preset) => service.play(preset),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: state.currentPresetId != null
          ? _NowPlayingBar(state: state, service: service)
          : null,
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.stagePrePregnancy, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Colors.white, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'White Noise & Sounds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Soothe baby. Relax yourself. Plays in background.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final SoundCategory category;
  final String? playingId;
  final void Function(SoundPreset) onSelect;

  const _CategorySection({
    required this.category,
    required this.playingId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = SoundsData.byCategory(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Row(
            children: [
              Icon(category.icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: items.map((p) {
            final isPlaying = p.id == playingId;
            return _SoundTile(
              preset: p,
              isPlaying: isPlaying,
              onTap: () => onSelect(p),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SoundTile extends StatelessWidget {
  final SoundPreset preset;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SoundTile({
    required this.preset,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPlaying
          ? preset.color.withValues(alpha: 0.15)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying ? preset.color : AppColors.divider,
              width: isPlaying ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: preset.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(preset.icon, color: preset.color, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        preset.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isPlaying)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: preset.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      size: 14,
                      color: Colors.white,
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

class _NowPlayingBar extends StatefulWidget {
  final AudioState state;
  final AudioPlayerService service;

  const _NowPlayingBar({required this.state, required this.service});

  @override
  State<_NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<_NowPlayingBar> {
  Timer? _timerTick;

  @override
  void initState() {
    super.initState();
    _timerTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.state.sleepTimerEnd != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timerTick?.cancel();
    super.dispose();
  }

  String? _remainingTimerLabel() {
    final end = widget.state.sleepTimerEnd;
    if (end == null) return null;
    final remaining = end.difference(DateTime.now());
    if (remaining.isNegative) return null;
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final preset = SoundsData.byId(widget.state.currentPresetId ?? '');
    if (preset == null) return const SizedBox.shrink();
    final remaining = _remainingTimerLabel();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: preset.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(preset.icon, color: preset.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      preset.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (remaining != null)
                      Text(
                        'Sleep timer: $remaining',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.state.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 42,
                  color: preset.color,
                ),
                onPressed: widget.state.isLoading
                    ? null
                    : () => widget.state.isPlaying
                        ? widget.service.pause()
                        : widget.service.resume(),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textHint),
                onPressed: () => widget.service.stop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Volume
          Row(
            children: [
              const Icon(Icons.volume_down, size: 18, color: AppColors.textHint),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: preset.color,
                    inactiveTrackColor: preset.color.withValues(alpha: 0.2),
                    thumbColor: preset.color,
                    overlayColor: preset.color.withValues(alpha: 0.1),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: widget.state.volume,
                    onChanged: (v) => widget.service.setVolume(v),
                  ),
                ),
              ),
              const Icon(Icons.volume_up, size: 18, color: AppColors.textHint),
              const SizedBox(width: 8),
              // Timer menu
              PopupMenuButton<SleepTimer>(
                icon: Icon(
                  Icons.timer_outlined,
                  color: widget.state.sleepTimerEnd != null
                      ? preset.color
                      : AppColors.textHint,
                ),
                onSelected: (t) => widget.service.setSleepTimer(t),
                itemBuilder: (_) => SleepTimer.all
                    .map((t) => PopupMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
