import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../data/sounds_data.dart';
import 'noise_generator.dart';

/// Singleton audio service that plays procedurally-generated sounds
/// with seamless looping and background playback.
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._();

  final _player = AudioPlayer();
  SoundPreset? _currentPreset;
  Timer? _sleepTimer;
  DateTime? _sleepTimerEnd;

  final _stateController = StreamController<AudioState>.broadcast();
  Stream<AudioState> get stateStream => _stateController.stream;

  AudioState _state = const AudioState();
  AudioState get state => _state;

  void _emit() {
    _stateController.add(_state);
  }

  /// Start playing the given preset. Replaces any currently playing sound.
  Future<void> play(SoundPreset preset) async {
    _currentPreset = preset;
    _state = _state.copyWith(
      isLoading: true,
      currentPresetId: preset.id,
    );
    _emit();

    try {
      final path = await NoiseGenerator.getOrGenerateWav(preset.type);
      await _player.setLoopMode(LoopMode.one);
      await _player.setFilePath(path);
      await _player.play();
      _state = _state.copyWith(isLoading: false, isPlaying: true);
      _emit();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: e.toString(),
      );
      _emit();
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _state = _state.copyWith(isPlaying: false);
    _emit();
  }

  Future<void> resume() async {
    if (_currentPreset == null) return;
    await _player.play();
    _state = _state.copyWith(isPlaying: true);
    _emit();
  }

  Future<void> stop() async {
    await _player.stop();
    _cancelSleepTimer();
    _currentPreset = null;
    _state = const AudioState();
    _emit();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
    _state = _state.copyWith(volume: volume);
    _emit();
  }

  /// Set a sleep timer. When duration expires, playback stops.
  void setSleepTimer(SleepTimer timer) {
    _cancelSleepTimer();
    if (timer.duration == null) {
      _state = _state.copyWith(clearSleepTimer: true);
      _emit();
      return;
    }
    _sleepTimerEnd = DateTime.now().add(timer.duration!);
    _state = _state.copyWith(
      sleepTimerLabel: timer.label,
      sleepTimerEnd: _sleepTimerEnd,
    );
    _emit();
    _sleepTimer = Timer(timer.duration!, () async {
      await stop();
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEnd = null;
  }

  SoundPreset? get currentPreset => _currentPreset;

  Future<void> dispose() async {
    _cancelSleepTimer();
    await _player.dispose();
    await _stateController.close();
  }
}

class AudioState {
  final String? currentPresetId;
  final bool isPlaying;
  final bool isLoading;
  final double volume;
  final String? sleepTimerLabel;
  final DateTime? sleepTimerEnd;
  final String? error;

  const AudioState({
    this.currentPresetId,
    this.isPlaying = false,
    this.isLoading = false,
    this.volume = 0.7,
    this.sleepTimerLabel,
    this.sleepTimerEnd,
    this.error,
  });

  AudioState copyWith({
    String? currentPresetId,
    bool? isPlaying,
    bool? isLoading,
    double? volume,
    String? sleepTimerLabel,
    DateTime? sleepTimerEnd,
    bool clearSleepTimer = false,
    String? error,
  }) {
    return AudioState(
      currentPresetId: currentPresetId ?? this.currentPresetId,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      volume: volume ?? this.volume,
      sleepTimerLabel: clearSleepTimer ? null : (sleepTimerLabel ?? this.sleepTimerLabel),
      sleepTimerEnd: clearSleepTimer ? null : (sleepTimerEnd ?? this.sleepTimerEnd),
      error: error,
    );
  }
}
