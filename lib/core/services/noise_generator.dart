import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../data/sounds_data.dart';

/// Generates procedural noise/ambient sounds as seamless-looping WAV files.
/// Files are cached in temporary directory; regenerated once per device.
///
/// Design goals:
/// - No audio files in the app bundle (keeps size tiny)
/// - Works fully offline, on-device
/// - Clean seamless loops for hours of continuous playback
class NoiseGenerator {
  NoiseGenerator._();

  static const int _sampleRate = 22050; // Mono, modest quality, small files
  static const int _loopSeconds = 10;
  static const int _numSamples = _sampleRate * _loopSeconds;

  static final _random = Random();

  /// Returns a path to a cached WAV file for the given noise type.
  /// Generates it on the first call, reuses thereafter.
  static Future<String> getOrGenerateWav(NoiseType type) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/balam_sound_${type.name}.wav');
    if (await file.exists()) {
      return file.path;
    }
    final samples = _generate(type);
    final wavBytes = _encodeWav(samples);
    await file.writeAsBytes(wavBytes, flush: true);
    return file.path;
  }

  /// Delete all cached audio files — called if user wants to regenerate.
  static Future<void> clearCache() async {
    final dir = await getTemporaryDirectory();
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.contains('balam_sound_')) {
        await entity.delete();
      }
    }
  }

  // ==========================================================
  // PROCEDURAL GENERATION
  // ==========================================================

  /// Generate `_numSamples` Float32 samples in [-1, 1] for the given type.
  /// Applies a crossfade at start/end for seamless looping.
  static Float32List _generate(NoiseType type) {
    final samples = Float32List(_numSamples);

    switch (type) {
      case NoiseType.white:
        _white(samples, gain: 0.25);
      case NoiseType.pink:
        _pink(samples, gain: 0.3);
      case NoiseType.brown:
        _brown(samples, gain: 0.4);
      case NoiseType.heartbeat:
        _heartbeat(samples);
      case NoiseType.womb:
        _womb(samples);
      case NoiseType.shushing:
        _shushing(samples);
      case NoiseType.lullaby:
        _lullaby(samples);
      case NoiseType.rain:
        _rain(samples);
      case NoiseType.ocean:
        _ocean(samples);
      case NoiseType.thunder:
        _thunder(samples);
      case NoiseType.forest:
        _forest(samples);
      case NoiseType.wind:
        _wind(samples);
      case NoiseType.crickets:
        _crickets(samples);
      case NoiseType.fireplace:
        _fireplace(samples);
      case NoiseType.cafe:
        _pink(samples, gain: 0.2);
      case NoiseType.train:
        _train(samples);
      case NoiseType.library:
        _pink(samples, gain: 0.1);
    }

    _applyFadeLoop(samples);
    return samples;
  }

  // ==========================================================
  // PRIMITIVES
  // ==========================================================

  static void _white(Float32List out, {double gain = 0.3}) {
    for (var i = 0; i < out.length; i++) {
      out[i] = (_random.nextDouble() * 2 - 1) * gain;
    }
  }

  /// Pink noise via Voss-McCartney algorithm — cheap and natural-sounding.
  static void _pink(Float32List out, {double gain = 0.3}) {
    final b = List<double>.filled(7, 0);
    for (var i = 0; i < out.length; i++) {
      final w = _random.nextDouble() * 2 - 1;
      b[0] = 0.99886 * b[0] + w * 0.0555179;
      b[1] = 0.99332 * b[1] + w * 0.0750759;
      b[2] = 0.96900 * b[2] + w * 0.1538520;
      b[3] = 0.86650 * b[3] + w * 0.3104856;
      b[4] = 0.55000 * b[4] + w * 0.5329522;
      b[5] = -0.7616 * b[5] - w * 0.0168980;
      final pink = b[0] + b[1] + b[2] + b[3] + b[4] + b[5] + b[6] + w * 0.5362;
      b[6] = w * 0.115926;
      out[i] = pink * 0.11 * gain;
    }
  }

  /// Brown noise — integrated white noise, very low-frequency dominated.
  static void _brown(Float32List out, {double gain = 0.5}) {
    var last = 0.0;
    for (var i = 0; i < out.length; i++) {
      final w = _random.nextDouble() * 2 - 1;
      last = (last + 0.02 * w).clamp(-1.0, 1.0);
      out[i] = last * 3.5 * gain;
    }
  }

  /// Heartbeat — two-thump pattern at ~60 BPM.
  static void _heartbeat(Float32List out) {
    final beatInterval = _sampleRate; // 1 sec = 60 BPM
    final thumpGap = (_sampleRate * 0.15).round();
    for (var i = 0; i < out.length; i++) {
      final posInBeat = i % beatInterval;
      double v = 0;
      // First thump (lub)
      if (posInBeat < 2000) {
        final t = posInBeat / 2000.0;
        final env = exp(-t * 8);
        v += sin(2 * pi * 60 * posInBeat / _sampleRate) * env * 0.7;
      }
      // Second thump (dub)
      if (posInBeat > thumpGap && posInBeat < thumpGap + 1500) {
        final local = posInBeat - thumpGap;
        final t = local / 1500.0;
        final env = exp(-t * 10);
        v += sin(2 * pi * 50 * local / _sampleRate) * env * 0.5;
      }
      out[i] = v;
    }
  }

  /// Womb — low rumble (filtered brown) with gentle heartbeat underneath.
  static void _womb(Float32List out) {
    _brown(out, gain: 0.4);
    // Layer heartbeat
    final beatInterval = _sampleRate;
    for (var i = 0; i < out.length; i++) {
      final posInBeat = i % beatInterval;
      if (posInBeat < 1500) {
        final t = posInBeat / 1500.0;
        final env = exp(-t * 6);
        out[i] += sin(2 * pi * 45 * posInBeat / _sampleRate) * env * 0.15;
      }
    }
  }

  /// Shushing — modulated pink noise like a parent going "shhh shhh".
  static void _shushing(Float32List out) {
    _pink(out, gain: 0.4);
    // Modulate amplitude at ~1Hz (one shush per second)
    for (var i = 0; i < out.length; i++) {
      final mod = 0.6 + 0.4 * (sin(2 * pi * 1.0 * i / _sampleRate) * 0.5 + 0.5);
      out[i] *= mod;
    }
  }

  /// Lullaby hum — soft sine drone in a minor chord, very slow modulation.
  static void _lullaby(Float32List out) {
    const freq1 = 110.0; // A2
    const freq2 = 146.8; // D3
    const freq3 = 174.6; // F3
    for (var i = 0; i < out.length; i++) {
      final t = i / _sampleRate;
      final mod = 0.5 + 0.5 * sin(2 * pi * 0.1 * t);
      final v = (sin(2 * pi * freq1 * t) * 0.4 +
              sin(2 * pi * freq2 * t) * 0.25 +
              sin(2 * pi * freq3 * t) * 0.2) *
          0.15 *
          mod;
      out[i] = v;
    }
  }

  /// Rain — high-pass filtered white noise with occasional drops.
  static void _rain(Float32List out) {
    _white(out, gain: 0.5);
    // Simple high-pass: subtract running average
    var avg = 0.0;
    const alpha = 0.2;
    for (var i = 0; i < out.length; i++) {
      avg = avg * (1 - alpha) + out[i] * alpha;
      out[i] = (out[i] - avg) * 0.7;
    }
  }

  /// Ocean — slowly modulated pink noise (wave breath).
  static void _ocean(Float32List out) {
    _pink(out, gain: 0.5);
    for (var i = 0; i < out.length; i++) {
      final wave = 0.4 + 0.6 * (sin(2 * pi * 0.15 * i / _sampleRate) * 0.5 + 0.5);
      out[i] *= wave;
    }
  }

  /// Thunder — brown base with occasional low rumbles.
  static void _thunder(Float32List out) {
    _brown(out, gain: 0.3);
    // Add 2 rumbles
    for (var rumble = 0; rumble < 2; rumble++) {
      final start = (rumble * _numSamples ~/ 2) + _random.nextInt(_sampleRate);
      final length = _sampleRate * 2;
      for (var j = 0; j < length && start + j < out.length; j++) {
        final t = j / length;
        final env = exp(-t * 3) * (1 - exp(-t * 20));
        out[start + j] += (_random.nextDouble() * 2 - 1) * env * 0.6;
      }
    }
  }

  /// Forest — pink noise base + chirps.
  static void _forest(Float32List out) {
    _pink(out, gain: 0.25);
    // Add random bird chirps
    final chirpCount = 8;
    for (var c = 0; c < chirpCount; c++) {
      final start = _random.nextInt(_numSamples - _sampleRate);
      final freq = 800.0 + _random.nextDouble() * 2000;
      final len = (_sampleRate * 0.08).round();
      for (var j = 0; j < len; j++) {
        final t = j / len;
        final env = sin(t * pi);
        out[start + j] += sin(2 * pi * freq * j / _sampleRate) * env * 0.15;
      }
    }
  }

  /// Wind — low-pass filtered modulated noise.
  static void _wind(Float32List out) {
    _brown(out, gain: 0.6);
    for (var i = 0; i < out.length; i++) {
      final gust = 0.3 + 0.7 * (sin(2 * pi * 0.3 * i / _sampleRate) * 0.5 + 0.5);
      out[i] *= gust;
    }
  }

  /// Crickets — rhythmic high chirps.
  static void _crickets(Float32List out) {
    for (var i = 0; i < out.length; i++) {
      final posInBeat = i % (_sampleRate ~/ 4); // 4 chirps/sec
      if (posInBeat < 600) {
        final t = posInBeat / 600.0;
        final env = sin(t * pi);
        out[i] = sin(2 * pi * 3500 * posInBeat / _sampleRate) * env * 0.08;
      }
    }
    // Add quiet pink base
    final base = Float32List(out.length);
    _pink(base, gain: 0.08);
    for (var i = 0; i < out.length; i++) {
      out[i] += base[i];
    }
  }

  /// Fireplace — brown noise with random crackles.
  static void _fireplace(Float32List out) {
    _brown(out, gain: 0.35);
    // Add random crackles
    for (var c = 0; c < 40; c++) {
      final start = _random.nextInt(_numSamples - 500);
      final len = 200 + _random.nextInt(300);
      for (var j = 0; j < len; j++) {
        final t = j / len;
        final env = exp(-t * 10);
        out[start + j] += (_random.nextDouble() * 2 - 1) * env * 0.4;
      }
    }
  }

  /// Train — brown noise with rhythmic clacks.
  static void _train(Float32List out) {
    _brown(out, gain: 0.3);
    final clackInterval = _sampleRate ~/ 3; // 3 clacks/sec
    for (var i = 0; i < out.length; i++) {
      final posInBeat = i % clackInterval;
      if (posInBeat < 300) {
        final t = posInBeat / 300.0;
        final env = exp(-t * 8);
        out[i] += (_random.nextDouble() * 2 - 1) * env * 0.25;
      }
    }
  }

  // ==========================================================
  // LOOP SMOOTHING
  // ==========================================================

  /// Apply a short crossfade at the loop boundary to eliminate clicks.
  static void _applyFadeLoop(Float32List s) {
    const fadeSamples = 1000;
    for (var i = 0; i < fadeSamples && i < s.length; i++) {
      final t = i / fadeSamples;
      s[i] *= t;
      s[s.length - 1 - i] *= t;
    }
  }

  // ==========================================================
  // WAV ENCODING (16-bit PCM, mono)
  // ==========================================================

  static Uint8List _encodeWav(Float32List samples) {
    final byteRate = _sampleRate * 2; // 16-bit mono
    final dataSize = samples.length * 2;
    final fileSize = 36 + dataSize;

    final bytes = BytesBuilder();

    // RIFF header
    bytes.add([0x52, 0x49, 0x46, 0x46]); // "RIFF"
    bytes.add(_u32(fileSize));
    bytes.add([0x57, 0x41, 0x56, 0x45]); // "WAVE"

    // fmt chunk
    bytes.add([0x66, 0x6D, 0x74, 0x20]); // "fmt "
    bytes.add(_u32(16));                 // chunk size
    bytes.add(_u16(1));                  // PCM
    bytes.add(_u16(1));                  // mono
    bytes.add(_u32(_sampleRate));
    bytes.add(_u32(byteRate));
    bytes.add(_u16(2));                  // block align
    bytes.add(_u16(16));                 // bits per sample

    // data chunk
    bytes.add([0x64, 0x61, 0x74, 0x61]); // "data"
    bytes.add(_u32(dataSize));

    // Convert Float32 [-1, 1] to Int16
    for (var i = 0; i < samples.length; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      final v = (clamped * 32767).round();
      bytes.add(_u16(v & 0xFFFF));
    }

    return bytes.toBytes();
  }

  static List<int> _u32(int v) => [
        v & 0xFF,
        (v >> 8) & 0xFF,
        (v >> 16) & 0xFF,
        (v >> 24) & 0xFF,
      ];

  static List<int> _u16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
}
