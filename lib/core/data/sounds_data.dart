import 'package:flutter/material.dart';

/// Procedural sound categories for newborns, parents, and focus.
/// Inspired by BabyBoo — sounds are generated procedurally (no audio files).

enum SoundCategory {
  babySleep('Baby Sleep', Icons.child_care),
  nature('Nature', Icons.forest),
  parentRelax('Parent Relax', Icons.spa),
  focus('Focus', Icons.center_focus_strong);

  const SoundCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// How to procedurally generate each sound.
/// Used by the noise generator to produce waveforms on-device.
enum NoiseType {
  white,      // Flat random noise
  pink,       // 1/f filtered noise — softer, more natural
  brown,      // Deep red noise — very low frequencies
  heartbeat,  // Rhythmic low-frequency pulse
  womb,       // Low rumble + heartbeat
  shushing,   // Modulated filtered noise (shh shh)
  lullaby,    // Soft sine drone
  rain,       // High-pass filtered noise
  ocean,      // Slowly modulated noise
  thunder,    // Brown noise + occasional rumble
  forest,     // Pink noise + chirps
  wind,       // Low-pass modulated noise
  crickets,   // Rhythmic chirps
  fireplace,  // Brown noise + crackles
  cafe,       // Pink noise (simulates background chatter)
  train,      // Brown noise + rhythm
  library,    // Very soft pink noise
}

class SoundPreset {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final SoundCategory category;
  final NoiseType type;

  const SoundPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.type,
  });
}

class SoundsData {
  SoundsData._();

  static const presets = <SoundPreset>[
    // BABY SLEEP
    SoundPreset(
      id: 'white',
      name: 'White Noise',
      description: 'Gentle static',
      icon: Icons.cloud_outlined,
      color: Color(0xFFBDBDBD),
      category: SoundCategory.babySleep,
      type: NoiseType.white,
    ),
    SoundPreset(
      id: 'pink',
      name: 'Pink Noise',
      description: 'Soft & warm',
      icon: Icons.filter_vintage,
      color: Color(0xFFE8787A),
      category: SoundCategory.babySleep,
      type: NoiseType.pink,
    ),
    SoundPreset(
      id: 'heartbeat',
      name: 'Heartbeat',
      description: "Like mama's heart",
      icon: Icons.favorite,
      color: Color(0xFFE53935),
      category: SoundCategory.babySleep,
      type: NoiseType.heartbeat,
    ),
    SoundPreset(
      id: 'womb',
      name: 'Womb',
      description: 'Safe & familiar',
      icon: Icons.pregnant_woman,
      color: Color(0xFFEC407A),
      category: SoundCategory.babySleep,
      type: NoiseType.womb,
    ),
    SoundPreset(
      id: 'shushing',
      name: 'Shushing',
      description: 'Gentle shh shh',
      icon: Icons.do_not_disturb_on_outlined,
      color: Color(0xFF9575CD),
      category: SoundCategory.babySleep,
      type: NoiseType.shushing,
    ),
    SoundPreset(
      id: 'lullaby',
      name: 'Lullaby Hum',
      description: 'Soft drone',
      icon: Icons.music_note,
      color: Color(0xFFF5C15A),
      category: SoundCategory.babySleep,
      type: NoiseType.lullaby,
    ),

    // NATURE
    SoundPreset(
      id: 'rain',
      name: 'Rain',
      description: 'Gentle rainfall',
      icon: Icons.water_drop,
      color: Color(0xFF4FC3F7),
      category: SoundCategory.nature,
      type: NoiseType.rain,
    ),
    SoundPreset(
      id: 'ocean',
      name: 'Ocean',
      description: 'Calm waves',
      icon: Icons.waves,
      color: Color(0xFF5BBCB4),
      category: SoundCategory.nature,
      type: NoiseType.ocean,
    ),
    SoundPreset(
      id: 'thunder',
      name: 'Thunder',
      description: 'Distant storm',
      icon: Icons.bolt,
      color: Color(0xFF546E7A),
      category: SoundCategory.nature,
      type: NoiseType.thunder,
    ),
    SoundPreset(
      id: 'forest',
      name: 'Forest',
      description: 'Birds & breeze',
      icon: Icons.forest,
      color: Color(0xFF66BB6A),
      category: SoundCategory.nature,
      type: NoiseType.forest,
    ),
    SoundPreset(
      id: 'wind',
      name: 'Wind',
      description: 'Gentle breeze',
      icon: Icons.air,
      color: Color(0xFF80DEEA),
      category: SoundCategory.nature,
      type: NoiseType.wind,
    ),
    SoundPreset(
      id: 'crickets',
      name: 'Crickets',
      description: 'Summer night',
      icon: Icons.nightlight_round,
      color: Color(0xFF26A69A),
      category: SoundCategory.nature,
      type: NoiseType.crickets,
    ),

    // PARENT RELAX
    SoundPreset(
      id: 'fireplace',
      name: 'Fireplace',
      description: 'Crackling fire',
      icon: Icons.fireplace,
      color: Color(0xFFFF7043),
      category: SoundCategory.parentRelax,
      type: NoiseType.fireplace,
    ),
    SoundPreset(
      id: 'cafe',
      name: 'Coffee Shop',
      description: 'Cozy chatter',
      icon: Icons.local_cafe,
      color: Color(0xFFA1887F),
      category: SoundCategory.parentRelax,
      type: NoiseType.cafe,
    ),
    SoundPreset(
      id: 'train',
      name: 'Train Journey',
      description: 'Rhythmic rails',
      icon: Icons.train,
      color: Color(0xFF78909C),
      category: SoundCategory.parentRelax,
      type: NoiseType.train,
    ),

    // FOCUS
    SoundPreset(
      id: 'brown',
      name: 'Brown Noise',
      description: 'Deep & rich',
      icon: Icons.graphic_eq,
      color: Color(0xFF8D6E63),
      category: SoundCategory.focus,
      type: NoiseType.brown,
    ),
    SoundPreset(
      id: 'library',
      name: 'Library',
      description: 'Quiet study',
      icon: Icons.menu_book,
      color: Color(0xFF90A4AE),
      category: SoundCategory.focus,
      type: NoiseType.library,
    ),
  ];

  static List<SoundPreset> byCategory(SoundCategory cat) {
    return presets.where((p) => p.category == cat).toList();
  }

  static SoundPreset? byId(String id) {
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Sleep timer presets for the sound player.
class SleepTimer {
  final String label;
  final Duration? duration; // null = off / infinite

  const SleepTimer(this.label, this.duration);

  static const off = SleepTimer('Off', null);
  static const t15 = SleepTimer('15m', Duration(minutes: 15));
  static const t30 = SleepTimer('30m', Duration(minutes: 30));
  static const t60 = SleepTimer('1h', Duration(hours: 1));
  static const t120 = SleepTimer('2h', Duration(hours: 2));
  static const tAllNight = SleepTimer('All Night', Duration(hours: 8));

  static const all = <SleepTimer>[off, t15, t30, t60, t120, tAllNight];
}
