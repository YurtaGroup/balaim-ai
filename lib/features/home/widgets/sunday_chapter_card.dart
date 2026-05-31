import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/sunday_chapter.dart';
import '../providers/sunday_chapter_provider.dart';

/// The Sunday Chapter card — Sprint 1's load-bearing artifact.
/// Designer spec lives at docs/roadmap/standups/2026-06-01-sprint-1-kickoff.md.
class SundayChapterCard extends ConsumerWidget {
  const SundayChapterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(currentSundayChapterProvider);
    final chapter = async.asData?.value;
    final now = DateTime.now();

    // Per Designer spec: only render in the Sun 7pm → Sat 11:59pm window,
    // AND only if a chapter doc actually exists.
    if (chapter == null || !shouldShowChapterAt(now)) {
      return const SizedBox.shrink();
    }

    return _ChapterCardSurface(chapter: chapter);
  }
}

class _ChapterCardSurface extends ConsumerWidget {
  final SundayChapter chapter;
  const _ChapterCardSurface({required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final playback = ref.watch(chapterPlaybackProvider);

    Widget body;
    switch (chapter.state) {
      case ChapterState.generating:
        body = _generating(lang);
        break;
      case ChapterState.textReady:
      case ChapterState.ready:
        if (playback.playedThisWeek) {
          body = _played(context, ref, lang);
        } else if (playback.isPlaying) {
          body = _playing(context, ref, lang, playback);
        } else {
          body = _readyToPlay(context, ref, lang);
        }
        break;
      case ChapterState.playing:
        body = _playing(context, ref, lang, playback);
        break;
      case ChapterState.played:
        body = _played(context, ref, lang);
        break;
      case ChapterState.error:
        body = _errorState(lang);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _eyebrow(lang, chapter.childName, chapter.chapterNumber),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          body,
        ],
      ),
    );
  }

  // ============================================================
  // STATES
  // ============================================================

  Widget _generating(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(lang,
              en: "Writing this week's chapter.",
              ru: 'Пишем главу этой недели.',
              ky: 'Бул жуманын бабын жазып жатабыз.'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(lang,
              en: 'Ready tonight.',
              ru: 'Будет готово сегодня вечером.',
              ky: 'Бүгүн кечинде даяр болот.'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        const _ShimmerBar(),
      ],
    );
  }

  Widget _readyToPlay(BuildContext context, WidgetRef ref, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chapter.teaser,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: [
              _PlayCircle(
                size: 64,
                icon: Icons.play_arrow,
                onTap: () => _onPlayTap(ref),
              ),
              const SizedBox(height: 8),
              Text(
                _durationLabel(lang, chapter.duration),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playing(BuildContext context, WidgetRef ref, String lang,
      ChapterPlaybackState playback) {
    final dur = playback.duration ?? chapter.duration ?? Duration.zero;
    final pos = playback.position;
    final progress = dur.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chapter.teaser,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 2,
                child: Stack(
                  children: [
                    Container(color: AppColors.divider),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_fmt(pos)} / ${_fmt(dur)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: _PlayCircle(
            size: 64,
            icon: Icons.pause,
            onTap: () => _onPlayTap(ref),
          ),
        ),
      ],
    );
  }

  Widget _played(BuildContext context, WidgetRef ref, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chapter.teaser,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(height: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              tr(lang, en: 'Played', ru: 'Прослушано', ky: 'Угулду'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _onShare(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.ios_share, size: 18, color: AppColors.textHint),
                const SizedBox(width: 8),
                Text(
                  tr(lang,
                      en: 'Save or share',
                      ru: 'Сохранить или поделиться',
                      ky: 'Сактоо же бөлүшүү'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: _PlayCircle(
            size: 48,
            icon: Icons.play_arrow,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.divider,
            iconSize: 22,
            onTap: () => _onPlayTap(ref),
          ),
        ),
      ],
    );
  }

  Widget _errorState(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(lang,
              en: "This week's chapter didn't make it.",
              ru: 'Глава этой недели не вышла.',
              ky: 'Бул жуманын бабы чыкпады.'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(lang,
              en: 'Next Sunday.',
              ru: 'До следующего воскресенья.',
              ky: 'Кийинки жекшембиде.'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: AppColors.divider),
      ],
    );
  }

  // ============================================================
  // INTERACTIONS
  // ============================================================

  void _onPlayTap(WidgetRef ref) {
    final url = chapter.audioUrl;
    if (url == null || url.isEmpty) {
      // Sprint 1: text-only chapters. Tapping play before TTS is wired
      // is a no-op — but in practice the card uses the textReady state
      // which still shows the play affordance. Once OPENAI_API_KEY is
      // wired, audioUrl will be populated and this branch goes away.
      return;
    }
    ref.read(chapterPlaybackProvider.notifier).playOrPause(url);
  }

  Future<void> _onShare(BuildContext context) async {
    final url = chapter.audioUrl;
    if (url == null || url.isEmpty) return;
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/balam_chapter_${chapter.weekId}.mp3';
      final response = await Dio().download(url, path);
      if (response.statusCode != 200) return;
      await Share.shareXFiles(
        [XFile(path)],
        text: chapter.narrative ?? '',
      );
    } catch (_) {
      // Silent — share failures should not surface as errors. The card
      // stays in played state and Mom can try again.
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _eyebrow(String lang, String childName, int n) {
    final upper = childName.toUpperCase();
    return tr(lang,
        en: "$upper'S STORY, WEEK $n",
        ru: 'ИСТОРИЯ $upper, НЕДЕЛЯ $n',
        ky: '$upper-НЫН ОКУЯСЫ, $n-АПТА');
  }

  String _durationLabel(String lang, Duration? duration) {
    final seconds = duration?.inSeconds ?? 60;
    return tr(lang,
        en: '$seconds seconds',
        ru: '$seconds секунд',
        ky: '$seconds секунд');
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ============================================================
// PRIMITIVES
// ============================================================

class _PlayCircle extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double iconSize;
  final VoidCallback onTap;

  const _PlayCircle({
    required this.size,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.backgroundColor = AppColors.primary,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatefulWidget {
  const _ShimmerBar();

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.6,
          child: Container(
            height: 3,
            color: AppColors.divider.withValues(
              alpha: 0.4 + 0.6 * _controller.value,
            ),
          ),
        );
      },
    );
  }
}
