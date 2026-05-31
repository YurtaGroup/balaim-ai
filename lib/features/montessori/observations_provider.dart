import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart' show isFirebaseInitialized;
import '../auth/providers/auth_provider.dart';
import 'observation_models.dart';

/// Stream the most recent observations for the signed-in user. Capped
/// at 50 — the Child timeline lazy-loads more if/when we add scroll
/// pagination.
final observationsProvider =
    StreamProvider.autoDispose<List<Observation>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('observations')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map(Observation.fromFirestore).toList());
});

/// Observations filtered to the currently-selected child, if any.
final observationsForChildProvider =
    Provider.autoDispose.family<List<Observation>, String?>((ref, childId) {
  final all = ref.watch(observationsProvider).asData?.value ?? const [];
  if (childId == null) return all;
  return all.where((o) => o.childId == null || o.childId == childId).toList();
});

/// Log a new observation. Server tag pass fires async; UI watches the
/// stream and renders the chips once `taggerStatus == 'tagged'` lands.
Future<String?> logObservation({
  required String uid,
  required String childId,
  String? note,
  String? voiceUrl,
}) async {
  if (!isFirebaseInitialized) return null;
  final trimmed = note?.trim();
  if ((trimmed == null || trimmed.isEmpty) &&
      (voiceUrl == null || voiceUrl.isEmpty)) {
    return null;
  }
  try {
    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('observations')
        .add({
      'childId': childId,
      if (trimmed != null && trimmed.isNotEmpty) 'note': trimmed,
      if (voiceUrl != null && voiceUrl.isNotEmpty) 'voiceUrl': voiceUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  } catch (e) {
    debugPrint('[observation] logObservation failed: $e');
    return null;
  }
}

/// Mom may correct her own text after logging (typo, expansion). Only
/// `note` is mutable per Firestore rules.
Future<void> updateObservationNote({
  required String uid,
  required String observationId,
  required String note,
}) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('observations')
        .doc(observationId)
        .update({'note': note});
  } catch (e) {
    debugPrint('[observation] updateObservationNote failed: $e');
  }
}

Future<void> deleteObservation({
  required String uid,
  required String observationId,
}) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('observations')
        .doc(observationId)
        .delete();
  } catch (e) {
    debugPrint('[observation] deleteObservation failed: $e');
  }
}
