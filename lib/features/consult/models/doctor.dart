import 'package:cloud_firestore/cloud_firestore.dart';

/// A doctor in the Balam directory — pediatrician, NP, or specialist.
///
/// Mirrors the `doctors/{doctorId}` Firestore shape written by the
/// `setDoctorClaim` Cloud Function. Read-only on the client; writes
/// go through Admin SDK.
class Doctor {
  final String id;
  final String email;
  final String uid; // Firebase Auth UID for this doctor
  final String name;
  final String specialty;
  final List<String> languages;
  final DoctorBio bio;
  final String? photoUrl;
  final int ratePerConsult;
  final String currency; // "USD" / "KGS"
  final String region; // "KG-BISHKEK" / "US-NJ"
  final bool active;
  final bool acceptingNew;

  const Doctor({
    required this.id,
    required this.email,
    required this.uid,
    required this.name,
    required this.specialty,
    required this.languages,
    required this.bio,
    required this.ratePerConsult,
    required this.currency,
    required this.region,
    this.photoUrl,
    this.active = true,
    this.acceptingNew = true,
  });

  /// Display-ready price like "$49" or "2,500 с".
  String get formattedRate {
    switch (currency.toUpperCase()) {
      case 'KGS':
        return '${_formatThousands(ratePerConsult)} с';
      case 'USD':
      default:
        return '\$$ratePerConsult';
    }
  }

  factory Doctor.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final langsRaw = (d['languages'] as List<dynamic>?) ?? const [];
    return Doctor(
      id: doc.id,
      email: (d['email'] as String?) ?? '',
      uid: (d['uid'] as String?) ?? '',
      name: (d['name'] as String?) ?? '',
      specialty: (d['specialty'] as String?) ?? '',
      languages: langsRaw.whereType<String>().toList(),
      bio: DoctorBio.fromMap(d['bio'] as Map<String, dynamic>?),
      photoUrl: d['photoUrl'] as String?,
      ratePerConsult: (d['ratePerConsult'] as num?)?.toInt() ?? 0,
      currency: (d['currency'] as String?) ?? 'USD',
      region: (d['region'] as String?) ?? '',
      active: d['active'] == true,
      acceptingNew: d['acceptingNew'] == true,
    );
  }

  static String _formatThousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// Trilingual short bio. Picks the right language at render time.
class DoctorBio {
  final String en;
  final String ru;
  final String ky;

  const DoctorBio({this.en = '', this.ru = '', this.ky = ''});

  factory DoctorBio.fromMap(Map<String, dynamic>? raw) {
    if (raw == null) return const DoctorBio();
    return DoctorBio(
      en: (raw['en'] as String?) ?? '',
      ru: (raw['ru'] as String?) ?? '',
      ky: (raw['ky'] as String?) ?? '',
    );
  }

  String forLocale(String lang) {
    switch (lang) {
      case 'ru':
        return ru.isNotEmpty ? ru : en;
      case 'ky':
        return ky.isNotEmpty ? ky : (ru.isNotEmpty ? ru : en);
      default:
        return en;
    }
  }
}
