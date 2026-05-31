import 'package:cloud_firestore/cloud_firestore.dart';

import 'montessori_taxonomy.dart';

/// One "I noticed ___" entry. Mom writes [note] (or speaks [voiceUrl]);
/// the server tag pass back-fills the rest.
class Observation {
  final String id;
  final String? childId;
  final String? note;
  final String? voiceUrl;
  final String? voiceTranscript;
  final DateTime createdAt;
  final DateTime? taggedAt;
  final ObservationTaggerStatus taggerStatus;
  final List<SensitivePeriod> sensitivePeriods;
  final MontessoriCategory montessoriCategory;
  final List<MilestoneTag> milestones;

  /// One-sentence plain-English reading from the tagger. Used in the
  /// Child timeline chip + the daily Invitation prompt context.
  final String? summary;

  const Observation({
    required this.id,
    required this.createdAt,
    this.childId,
    this.note,
    this.voiceUrl,
    this.voiceTranscript,
    this.taggedAt,
    this.taggerStatus = ObservationTaggerStatus.pending,
    this.sensitivePeriods = const [],
    this.montessoriCategory = MontessoriCategory.unknown,
    this.milestones = const [],
    this.summary,
  });

  factory Observation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const <String, dynamic>{};
    final periodIds = (d['sensitivePeriods'] as List<dynamic>?) ?? const [];
    final milestoneRaw = (d['milestones'] as List<dynamic>?) ?? const [];
    return Observation(
      id: doc.id,
      childId: (d['childId'] as String?)?.trim().isEmpty == true
          ? null
          : d['childId'] as String?,
      note: (d['note'] as String?)?.trim().isEmpty == true
          ? null
          : d['note'] as String?,
      voiceUrl: d['voiceUrl'] as String?,
      voiceTranscript: d['voiceTranscript'] as String?,
      createdAt: _date(d['createdAt']) ?? DateTime.now(),
      taggedAt: _date(d['taggedAt']),
      taggerStatus: ObservationTaggerStatus.fromString(d['taggerStatus']),
      sensitivePeriods: periodIds
          .whereType<String>()
          .map(SensitivePeriod.fromId)
          .where((p) => p != SensitivePeriod.unknown)
          .toList(),
      montessoriCategory: MontessoriCategory.fromId(
        d['montessoriCategory'] as String?,
      ),
      milestones: milestoneRaw
          .whereType<Map<String, dynamic>>()
          .map(MilestoneTag.fromMap)
          .where((m) => m.id.isNotEmpty && m.label.isNotEmpty)
          .toList(),
      summary: (d['summary'] as String?)?.trim().isEmpty == true
          ? null
          : d['summary'] as String?,
    );
  }

  /// Whether the tagger has run AND succeeded. Used by the UI to know
  /// whether to render category/milestone chips yet.
  bool get isEnriched =>
      taggerStatus == ObservationTaggerStatus.tagged && taggedAt != null;

  static DateTime? _date(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

enum ObservationTaggerStatus {
  pending,
  noTextYet,
  tagged,
  failed;

  static ObservationTaggerStatus fromString(Object? raw) {
    switch (raw) {
      case 'tagged':
        return ObservationTaggerStatus.tagged;
      case 'no_text_yet':
        return ObservationTaggerStatus.noTextYet;
      case 'failed':
        return ObservationTaggerStatus.failed;
      default:
        return ObservationTaggerStatus.pending;
    }
  }
}
