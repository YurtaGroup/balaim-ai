import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart' show isFirebaseInitialized;
import '../../shared/models/diaper_entry.dart';
import '../../shared/models/feeding_entry.dart';
import '../auth/providers/auth_provider.dart';

/// The newborn survival data: feedings and diapers. Streamed live from
/// the user's nested subcollections. Capped to 60 entries each — enough
/// for a couple of days for a newborn who feeds 8-12x and pees 6-8x
/// per day. The Child timeline lazy-loads older entries when needed.

final feedingsProvider =
    StreamProvider.autoDispose<List<FeedingEntry>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('feeding')
      .orderBy('startTime', descending: true)
      .limit(60)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => FeedingEntry.fromFirestore({...d.data(), 'id': d.id}))
          .toList());
});

final diapersProvider =
    StreamProvider.autoDispose<List<DiaperEntry>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = ref.watch(currentUserInfoProvider).uid;
  if (uid == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('diapers')
      .orderBy('timestamp', descending: true)
      .limit(60)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => DiaperEntry.fromFirestore({...d.data(), 'id': d.id}))
          .toList());
});

/// Most recent feeding for the active child — drives the "Last feed:
/// 2h 14m ago" stat on the Quick Log strip. Returns null if no feeds
/// have been logged yet.
FeedingEntry? lastFeedingFor(WidgetRef ref, String? childId) {
  final list = ref.watch(feedingsProvider).asData?.value ?? const [];
  for (final f in list) {
    if (childId == null || f.childId == null || f.childId == childId) {
      return f;
    }
  }
  return null;
}

/// Today's wet-diaper count for the active child — the survival
/// metric pediatricians ask about. Counts wet + both as wet events.
int wetDiaperCountToday(WidgetRef ref, String? childId) {
  final list = ref.watch(diapersProvider).asData?.value ?? const [];
  final start = DateTime.now();
  final dayStart = DateTime(start.year, start.month, start.day);
  int count = 0;
  for (final d in list) {
    if (d.timestamp.isBefore(dayStart)) break; // list is desc-sorted
    if (childId != null && d.childId != null && d.childId != childId) continue;
    if (d.type == DiaperType.wet || d.type == DiaperType.both) count += 1;
  }
  return count;
}

// ── Write paths ──────────────────────────────────────────────────

Future<String?> logFeeding({
  required String uid,
  required String childId,
  required FeedingType type,
  required DateTime startTime,
  DateTime? endTime,
  double? amountMl,
  int? durationMinutes,
  String? note,
}) async {
  if (!isFirebaseInitialized) return null;
  try {
    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('feeding')
        .add({
      'childId': childId,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime.toIso8601String(),
      if (amountMl != null) 'amountMl': amountMl,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return ref.id;
  } catch (e) {
    debugPrint('[care_log] logFeeding failed: $e');
    return null;
  }
}

Future<String?> logDiaper({
  required String uid,
  required String childId,
  required DiaperType type,
  DateTime? at,
  String? note,
}) async {
  if (!isFirebaseInitialized) return null;
  try {
    final ts = at ?? DateTime.now();
    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diapers')
        .add({
      'childId': childId,
      'type': type.name,
      'timestamp': ts.toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return ref.id;
  } catch (e) {
    debugPrint('[care_log] logDiaper failed: $e');
    return null;
  }
}

Future<void> deleteFeeding(String uid, String id) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('feeding')
        .doc(id)
        .delete();
  } catch (e) {
    debugPrint('[care_log] deleteFeeding failed: $e');
  }
}

Future<void> deleteDiaper(String uid, String id) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diapers')
        .doc(id)
        .delete();
  } catch (e) {
    debugPrint('[care_log] deleteDiaper failed: $e');
  }
}
