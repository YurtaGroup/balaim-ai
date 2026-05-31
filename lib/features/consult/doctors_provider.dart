import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart' show isFirebaseInitialized;
import '../auth/providers/auth_provider.dart';
import 'consult_config.dart';
import 'models/doctor.dart';

/// All active doctors that are currently accepting new threads.
/// Public-read once signed in; backed by the Firestore `doctors`
/// collection. Empty stream when Firebase isn't ready or not signed
/// in (the doctor picker simply hides itself).
final doctorsProvider = StreamProvider.autoDispose<List<Doctor>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('doctors')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snap) {
    final list = snap.docs.map(Doctor.fromFirestore).toList();
    // Surface accepting-new doctors first so the picker leads with
    // who's actually available right now.
    list.sort((a, b) {
      if (a.acceptingNew != b.acceptingNew) {
        return a.acceptingNew ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });
    return list;
  });
});

/// The single anchor doctor (Jane Mone NP) — used when the picker
/// can't be shown yet (e.g., directory still empty pre-bootstrap) so
/// the existing single-doctor consult flow keeps working uninterrupted.
Doctor get fallbackAnchorDoctor => Doctor(
      id: 'jane-mone',
      email: kDoctorEmail,
      uid: '',
      name: kDoctorName,
      specialty: kDoctorSpecialty,
      languages: const ['en', 'ru'],
      bio: DoctorBio(en: kDoctorBlurb),
      ratePerConsult: kConsultPriceUsd,
      currency: 'USD',
      region: 'US-NJ',
      active: true,
      acceptingNew: true,
    );

/// Picks the doctor a new consult should be created against. Reads the
/// directory; if empty (no `doctors` records written yet), falls back
/// to the anchor doctor so v1 single-doctor behaviour is preserved.
Doctor? defaultDoctorFrom(List<Doctor> list) {
  if (list.isEmpty) return fallbackAnchorDoctor;
  final accepting = list.where((d) => d.acceptingNew).toList();
  return (accepting.isNotEmpty ? accepting : list).first;
}
