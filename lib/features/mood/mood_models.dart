import 'package:cloud_firestore/cloud_firestore.dart';

/// Mom's mood on a 1–5 scale. The Home card shows these as five emojis
/// in a single row — labels are deliberately absent in UI; we keep
/// names here only for code readability.
enum MoodLevel {
  drowning(1, '😞'),
  hard(2, '😔'),
  meh(3, '😐'),
  ok(4, '🙂'),
  great(5, '🌅');

  const MoodLevel(this.value, this.emoji);

  final int value;
  final String emoji;

  static MoodLevel? fromValue(int? v) {
    if (v == null) return null;
    for (final l in MoodLevel.values) {
      if (l.value == v) return l;
    }
    return null;
  }
}

/// A single mood check-in. Client writes only the four whitelisted
/// fields (level, note, voiceUrl, createdAt) — the rest are filled
/// server-side by the onMoodCheckinCreated trigger (aiReply lands later
/// this week, the others ship Monday).
class MoodCheckin {
  final String id;
  final MoodLevel level;
  final String? note;
  final String? voiceUrl;
  final String? voiceTranscript;
  final DateTime createdAt;
  final String? aiReply;
  final bool flaggedCrisis;
  final String? crisisLocale;

  const MoodCheckin({
    required this.id,
    required this.level,
    required this.createdAt,
    this.note,
    this.voiceUrl,
    this.voiceTranscript,
    this.aiReply,
    this.flaggedCrisis = false,
    this.crisisLocale,
  });

  factory MoodCheckin.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const <String, dynamic>{};
    final levelInt = (d['level'] as num?)?.toInt() ?? 3;
    final level = MoodLevel.fromValue(levelInt) ?? MoodLevel.meh;
    return MoodCheckin(
      id: doc.id,
      level: level,
      note: (d['note'] as String?)?.trim().isEmpty == true
          ? null
          : d['note'] as String?,
      voiceUrl: d['voiceUrl'] as String?,
      voiceTranscript: d['voiceTranscript'] as String?,
      createdAt: _parseDate(d['createdAt']),
      aiReply: d['aiReply'] as String?,
      flaggedCrisis: d['flaggedCrisis'] == true,
      crisisLocale: d['crisisLocale'] as String?,
    );
  }

  static DateTime _parseDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}

/// Aggregate mood state used by Today's Debrief (streak / silence /
/// trend prompts). Server-only writes; client reads its own.
class MoodSummary {
  final double? last7DaysAvg;
  final double? last30DaysAvg;
  final int count7;
  final int count30;

  /// Consecutive days (ending today) with at least one check-in at
  /// level ≤ 2 ("hard" or "drowning"). The Debrief surfaces a "want to
  /// talk?" prompt once this reaches 3.
  final int streakHardDays;

  final MoodTrend trend;
  final DateTime? lastCheckinAt;
  final MoodLevel? lastCheckinLevel;
  final bool hasUnacknowledgedCrisis;

  const MoodSummary({
    this.last7DaysAvg,
    this.last30DaysAvg,
    this.count7 = 0,
    this.count30 = 0,
    this.streakHardDays = 0,
    this.trend = MoodTrend.unknown,
    this.lastCheckinAt,
    this.lastCheckinLevel,
    this.hasUnacknowledgedCrisis = false,
  });

  factory MoodSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const <String, dynamic>{};
    return MoodSummary(
      last7DaysAvg: (d['last7DaysAvg'] as num?)?.toDouble(),
      last30DaysAvg: (d['last30DaysAvg'] as num?)?.toDouble(),
      count7: (d['count7'] as num?)?.toInt() ?? 0,
      count30: (d['count30'] as num?)?.toInt() ?? 0,
      streakHardDays: (d['streakHardDays'] as num?)?.toInt() ?? 0,
      trend: _trendFromString(d['trend'] as String?),
      lastCheckinAt: d['lastCheckinAt'] is Timestamp
          ? (d['lastCheckinAt'] as Timestamp).toDate()
          : null,
      lastCheckinLevel: MoodLevel.fromValue(
        (d['lastCheckinLevel'] as num?)?.toInt(),
      ),
      hasUnacknowledgedCrisis: d['hasUnacknowledgedCrisis'] == true,
    );
  }

  static MoodTrend _trendFromString(String? raw) {
    switch (raw) {
      case 'improving':
        return MoodTrend.improving;
      case 'declining':
        return MoodTrend.declining;
      case 'stable':
        return MoodTrend.stable;
      default:
        return MoodTrend.unknown;
    }
  }

  /// Has the user gone silent for at least 4 days (the threshold the
  /// Debrief uses to surface a "hey, how are you?" prompt)?
  bool get isSilent {
    if (lastCheckinAt == null) return false;
    return DateTime.now().difference(lastCheckinAt!).inDays >= 4;
  }
}

enum MoodTrend { improving, stable, declining, unknown }
