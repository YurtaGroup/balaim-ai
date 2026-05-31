import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../main.dart' show isFirebaseInitialized;
import '../../auth/providers/auth_provider.dart';
import '../models/sunday_chapter.dart';

/// Streams the current week's chapter doc for the signed-in user.
/// Returns null while no chapter exists for this week.
final currentSundayChapterProvider =
    StreamProvider.autoDispose<SundayChapter?>((ref) {
  if (!isFirebaseInitialized) return Stream.value(null);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(null);

  final weekId = isoWeekKey(DateTime.now());
  return FirebaseFirestore.instance
      .doc('users/$uid/chapters/$weekId')
      .snapshots()
      .map((snap) => snap.exists ? SundayChapter.fromFirestore(snap) : null);
});

/// Audio player state for the Sunday Chapter — position, playing flag,
/// and "has been played at least once this week" sticky flag (drives
/// the post-play state where the share row appears).
class ChapterPlaybackState {
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final bool playedThisWeek;

  const ChapterPlaybackState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playedThisWeek,
  });

  static const initial = ChapterPlaybackState(
    isPlaying: false,
    position: Duration.zero,
    duration: null,
    playedThisWeek: false,
  );

  ChapterPlaybackState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? playedThisWeek,
  }) {
    return ChapterPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playedThisWeek: playedThisWeek ?? this.playedThisWeek,
    );
  }
}

class ChapterPlaybackNotifier extends Notifier<ChapterPlaybackState> {
  AudioPlayer? _player;
  String? _loadedUrl;

  @override
  ChapterPlaybackState build() {
    ref.onDispose(() {
      _player?.dispose();
      _player = null;
    });
    return ChapterPlaybackState.initial;
  }

  Future<void> playOrPause(String audioUrl) async {
    _player ??= AudioPlayer();
    final player = _player!;

    if (_loadedUrl != audioUrl) {
      await player.setUrl(audioUrl);
      _loadedUrl = audioUrl;
      player.positionStream.listen((pos) {
        state = state.copyWith(position: pos);
      });
      player.playerStateStream.listen((s) {
        state = state.copyWith(isPlaying: s.playing);
        if (s.processingState == ProcessingState.completed) {
          state = state.copyWith(
            isPlaying: false,
            position: Duration.zero,
            playedThisWeek: true,
          );
          player.seek(Duration.zero);
        }
      });
      final dur = player.duration;
      if (dur != null) state = state.copyWith(duration: dur);
    }

    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
      state = state.copyWith(playedThisWeek: true);
    }
  }

  Future<void> stop() async {
    await _player?.stop();
    _loadedUrl = null;
  }
}

final chapterPlaybackProvider =
    NotifierProvider<ChapterPlaybackNotifier, ChapterPlaybackState>(
  ChapterPlaybackNotifier.new,
);
