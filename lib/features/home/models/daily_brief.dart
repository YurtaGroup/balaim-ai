import 'package:cloud_firestore/cloud_firestore.dart';

enum BriefCtaType { chat, share, next, emergency }

class BriefCta {
  final String label;
  final BriefCtaType type;
  final String? prefill;
  final String? shareText;

  const BriefCta({
    required this.label,
    required this.type,
    this.prefill,
    this.shareText,
  });

  factory BriefCta.fromMap(Map<String, dynamic> map) {
    return BriefCta(
      label: (map['label'] as String?) ?? '',
      type: _parseType(map['type'] as String?),
      prefill: map['prefill'] as String?,
      shareText: map['shareText'] as String?,
    );
  }

  static BriefCtaType _parseType(String? raw) {
    switch (raw) {
      case 'chat':
        return BriefCtaType.chat;
      case 'share':
        return BriefCtaType.share;
      case 'next':
        return BriefCtaType.next;
      case 'emergency':
        return BriefCtaType.emergency;
      default:
        return BriefCtaType.chat;
    }
  }
}

class DailyBrief {
  final String memberId;
  final String memberName;
  final String date;
  final String locale;
  final String headline;
  final String body;
  final List<BriefCta> ctas;
  final String source;

  const DailyBrief({
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.locale,
    required this.headline,
    required this.body,
    required this.ctas,
    required this.source,
  });

  factory DailyBrief.fromMap(Map<String, dynamic> map) {
    final rawCtas = map['ctas'];
    final ctas = <BriefCta>[];
    if (rawCtas is List) {
      for (final c in rawCtas) {
        if (c is Map<String, dynamic>) {
          ctas.add(BriefCta.fromMap(c));
        } else if (c is Map) {
          ctas.add(BriefCta.fromMap(Map<String, dynamic>.from(c)));
        }
      }
    }
    return DailyBrief(
      memberId: (map['memberId'] as String?) ?? '',
      memberName: (map['memberName'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      locale: (map['locale'] as String?) ?? 'en',
      headline: (map['headline'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      ctas: ctas,
      source: (map['source'] as String?) ?? 'unknown',
    );
  }

  factory DailyBrief.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? <String, dynamic>{};
    return DailyBrief.fromMap(data);
  }
}
