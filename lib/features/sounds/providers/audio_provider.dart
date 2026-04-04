import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_player_service.dart';

final audioServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

/// Reactive stream of audio state — use this to rebuild UI on playback changes.
final audioStateProvider = StreamProvider<AudioState>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.stateStream;
});
