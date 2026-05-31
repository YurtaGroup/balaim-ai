import 'package:cloud_firestore/cloud_firestore.dart';

import 'montessori_taxonomy.dart';

/// How Mom marks how today's Invitation landed for her child. The
/// generator reads the most recent non-null feedback as context for
/// tomorrow's invitation — that's the flywheel.
enum InvitationFeedback {
  loved('loved', '🌱'),
  lostInterest('lost_interest', '🌀'),
  tooEarly('too_early', '🚫');

  const InvitationFeedback(this.id, this.icon);

  final String id;
  final String icon;

  static InvitationFeedback? fromId(String? id) {
    if (id == null) return null;
    for (final f in InvitationFeedback.values) {
      if (f.id == id) return f;
    }
    return null;
  }
}

class Invitation {
  final String id;
  final String memberId;
  final String date; // YYYY-MM-DD
  final String title;
  final String whyOneLine;
  final List<String> setupSteps;
  final MontessoriCategory category;
  final List<SensitivePeriod> sensitivePeriods;
  final int? ageMonthsAtComposition;
  final int setupMinutes;
  final DateTime? generatedAt;
  final DateTime? triedAt;
  final InvitationFeedback? feedback;
  final DateTime? feedbackAt;

  const Invitation({
    required this.id,
    required this.memberId,
    required this.date,
    required this.title,
    required this.whyOneLine,
    required this.setupSteps,
    required this.category,
    required this.sensitivePeriods,
    required this.setupMinutes,
    this.ageMonthsAtComposition,
    this.generatedAt,
    this.triedAt,
    this.feedback,
    this.feedbackAt,
  });

  bool get isTried => triedAt != null;

  factory Invitation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Invitation._fromMap(doc.id, doc.data() ?? const {});
  }

  factory Invitation.fromCallablePayload(Map<String, dynamic> raw) {
    final id = (raw['id'] as String?) ?? '';
    return Invitation._fromMap(id, raw);
  }

  factory Invitation._fromMap(String id, Map<String, dynamic> d) {
    final stepsRaw = (d['setupSteps'] as List<dynamic>?) ?? const [];
    final periodsRaw = (d['sensitivePeriods'] as List<dynamic>?) ?? const [];
    return Invitation(
      id: id,
      memberId: (d['memberId'] as String?) ?? '',
      date: (d['date'] as String?) ?? '',
      title: (d['title'] as String?) ?? '',
      whyOneLine: (d['whyOneLine'] as String?) ?? '',
      setupSteps: stepsRaw.whereType<String>().toList(),
      category: MontessoriCategory.fromId(d['category'] as String?),
      sensitivePeriods: periodsRaw
          .whereType<String>()
          .map(SensitivePeriod.fromId)
          .where((p) => p != SensitivePeriod.unknown)
          .toList(),
      ageMonthsAtComposition: (d['ageMonthsAtComposition'] as num?)?.toInt(),
      setupMinutes: (d['setupMinutes'] as num?)?.toInt() ?? 5,
      generatedAt: _date(d['generatedAt']),
      triedAt: _date(d['triedAt']),
      feedback: InvitationFeedback.fromId(d['feedback'] as String?),
      feedbackAt: _date(d['feedbackAt']),
    );
  }

  static DateTime? _date(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
