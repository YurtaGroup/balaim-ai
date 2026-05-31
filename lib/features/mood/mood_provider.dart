import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart' show isFirebaseInitialized;
import '../auth/providers/auth_provider.dart';
import 'mood_models.dart';

/// Streams the most recent mood check-ins for the signed-in user.
/// Capped at 30 — Today's Debrief only needs the recent window and
/// the mood thread screen lazy-loads more if/when we build it.
final moodCheckinsProvider =
    StreamProvider.autoDispose<List<MoodCheckin>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(const []);

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('moodCheckins')
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots();

  return stream.map(
    (snap) => snap.docs.map(MoodCheckin.fromFirestore).toList(),
  );
});

/// Streams the rolling moodState/summary doc. Returns null while it
/// doesn't exist yet (first-time user with no check-ins).
final moodSummaryProvider = StreamProvider.autoDispose<MoodSummary?>((ref) {
  if (!isFirebaseInitialized) return Stream.value(null);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .doc('users/$uid/moodState/summary')
      .snapshots()
      .map((snap) => snap.exists ? MoodSummary.fromFirestore(snap) : null);
});

/// Most recent check-in shorthand — handy for the Home card flip-side
/// that shows the AI's reply (once Wednesday lands).
final latestMoodCheckinProvider = Provider.autoDispose<MoodCheckin?>((ref) {
  final async = ref.watch(moodCheckinsProvider);
  final list = async.asData?.value ?? const <MoodCheckin>[];
  return list.isEmpty ? null : list.first;
});

/// Log a mood check-in. The trigger picks it up server-side and writes
/// `aiReply`, `flaggedCrisis`, and updates the summary aggregate.
/// Returns the new doc id, or null if Firebase isn't ready / not
/// signed in.
Future<String?> logMoodCheckin({
  required String uid,
  required MoodLevel level,
  String? note,
  String? voiceUrl,
}) async {
  if (!isFirebaseInitialized) return null;
  final trimmedNote = note?.trim();
  try {
    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('moodCheckins')
        .add({
      'level': level.value,
      if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
      if (voiceUrl != null && voiceUrl.isNotEmpty) 'voiceUrl': voiceUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  } catch (e) {
    debugPrint('[mood] logMoodCheckin failed: $e');
    return null;
  }
}

/// Delete a mood check-in. Mom should always be able to erase a
/// venting entry — no soft-delete, no audit, no judgment.
Future<void> deleteMoodCheckin(String uid, String checkinId) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('moodCheckins')
        .doc(checkinId)
        .delete();
  } catch (e) {
    debugPrint('[mood] deleteMoodCheckin failed: $e');
  }
}
