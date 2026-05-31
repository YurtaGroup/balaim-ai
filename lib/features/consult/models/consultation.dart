import 'package:cloud_firestore/cloud_firestore.dart';

/// Where a consultation is in its lifecycle.
enum ConsultStatus {
  /// Parent has written; waiting on the doctor.
  awaitingDoctor,

  /// Doctor has replied; ball is with the parent.
  answered,

  /// Either side closed it.
  closed,
}

ConsultStatus _statusFrom(String? s) => ConsultStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ConsultStatus.awaitingDoctor,
    );

DateTime _date(Object? raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
  return DateTime.now();
}

/// An async consultation thread between one parent and a doctor.
/// Stored top-level at `consultations/{id}` so the doctor can query
/// across every family; messages live in the `messages` subcollection.
class Consultation {
  final String id;
  final String uid; // the parent who opened it
  final String parentName;
  final String topic;
  final ConsultStatus status;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessagePreview;
  final bool paid;

  /// The doctor this thread is with. Null on legacy (pre-multi-doctor)
  /// rows — treat null as "the anchor doctor" (Jane Mone) for back-
  /// compat. New consults always set this.
  final String? doctorId;

  /// AI bridge — set true if the new-consult pre-screen ran on this
  /// thread.
  final bool screenedByAi;

  /// Server-generated 30-second briefing for the doctor, filled by
  /// the `generateDoctorBrief` trigger shortly after consult creation.
  /// Visible only to the doctor side of the thread.
  final String? doctorBriefSummary;

  const Consultation({
    required this.id,
    required this.uid,
    required this.parentName,
    required this.topic,
    required this.status,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessagePreview,
    required this.paid,
    this.doctorId,
    this.screenedByAi = false,
    this.doctorBriefSummary,
  });

  factory Consultation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final briefRaw = d['doctorBriefSummary'] as String?;
    return Consultation(
      id: doc.id,
      uid: (d['uid'] as String?) ?? '',
      parentName: (d['parentName'] as String?) ?? '',
      topic: (d['topic'] as String?) ?? '',
      status: _statusFrom(d['status'] as String?),
      createdAt: _date(d['createdAt']),
      lastMessageAt: _date(d['lastMessageAt']),
      lastMessagePreview: (d['lastMessagePreview'] as String?) ?? '',
      paid: d['paid'] == true,
      doctorId: d['doctorId'] as String?,
      screenedByAi: d['screenedByAi'] == true,
      doctorBriefSummary: (briefRaw == null || briefRaw.isEmpty) ? null : briefRaw,
    );
  }
}

/// Kind of message inside a consult thread. `user` and `doctor` are
/// the two human sides; `aiFollowupSuggestion` is a server-appended
/// message that carries three tappable follow-up questions in
/// `suggestedFollowUps` (set by the `generateFollowUps` trigger).
enum ConsultMessageKind {
  user,
  doctor,
  aiFollowupSuggestion;

  static ConsultMessageKind fromString(String? raw) {
    switch (raw) {
      case 'doctor':
        return ConsultMessageKind.doctor;
      case 'ai_followup_suggestion':
        return ConsultMessageKind.aiFollowupSuggestion;
      case 'user':
      default:
        return ConsultMessageKind.user;
    }
  }
}

/// One message inside a consultation thread.
class ConsultMessage {
  final String id;
  final bool fromDoctor;
  final String text;
  final String? photoUrl;
  final DateTime createdAt;
  final ConsultMessageKind kind;
  final List<String> suggestedFollowUps;

  const ConsultMessage({
    required this.id,
    required this.fromDoctor,
    required this.text,
    required this.photoUrl,
    required this.createdAt,
    this.kind = ConsultMessageKind.user,
    this.suggestedFollowUps = const [],
  });

  factory ConsultMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final fromDoctor = d['fromDoctor'] == true;
    final kindRaw = d['kind'] as String?;
    // Back-compat: legacy messages don't have `kind`. Infer from
    // `fromDoctor` (doctor messages are `doctor`, parent messages are
    // `user`); the AI followup kind is always explicit.
    final kind = kindRaw == null
        ? (fromDoctor ? ConsultMessageKind.doctor : ConsultMessageKind.user)
        : ConsultMessageKind.fromString(kindRaw);
    final raw = (d['suggestedFollowUps'] as List<dynamic>?) ?? const [];
    final followUps = raw.whereType<String>().toList();
    return ConsultMessage(
      id: doc.id,
      fromDoctor: fromDoctor,
      text: (d['text'] as String?) ?? '',
      photoUrl: d['photoUrl'] as String?,
      createdAt: _date(d['createdAt']),
      kind: kind,
      suggestedFollowUps: followUps,
    );
  }
}
