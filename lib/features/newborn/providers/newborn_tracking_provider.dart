import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart' show isFirebaseInitialized;
import '../../../core/services/auth_service.dart';
import '../../../shared/models/feeding_entry.dart';
import '../../../shared/models/diaper_entry.dart';

// ============================================================
// FEEDING LOG — syncs to Firestore when Firebase is live
// ============================================================

final feedingEntriesProvider =
    StateNotifierProvider<FeedingEntriesNotifier, List<FeedingEntry>>((ref) {
  return FeedingEntriesNotifier();
});

class FeedingEntriesNotifier extends StateNotifier<List<FeedingEntry>> {
  StreamSubscription? _sub;

  FeedingEntriesNotifier() : super(_isDemoUser() ? _demoData() : []) {
    _initFirestore();
  }

  static bool _isDemoUser() =>
      !isFirebaseInitialized || (AuthService().currentEmail?.endsWith('@balam.ai') ?? false);

  void _initFirestore() {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('feeding')
        .orderBy('startTime', descending: true)
        .limit(100)
        .snapshots()
        .listen((snap) {
      state = snap.docs
          .map((d) => FeedingEntry.fromFirestore(d.data()))
          .toList();
    });
  }

  void add(FeedingEntry entry) {
    state = [entry, ...state];
    _write(entry);
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _delete(id);
  }

  List<FeedingEntry> todayEntries() {
    final now = DateTime.now();
    return state.where((e) =>
      e.startTime.year == now.year &&
      e.startTime.month == now.month &&
      e.startTime.day == now.day
    ).toList();
  }

  Duration? timeSinceLastFeed() {
    if (state.isEmpty) return null;
    return DateTime.now().difference(state.first.startTime);
  }

  Future<void> _write(FeedingEntry entry) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('feeding').doc(entry.id)
          .set(entry.toFirestore());
    } catch (e) {
      debugPrint('[Feeding] Write error: $e');
    }
  }

  Future<void> _delete(String id) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('feeding').doc(id)
          .delete();
    } catch (e) {
      debugPrint('[Feeding] Delete error: $e');
    }
  }

  static List<FeedingEntry> _demoData() {
    final now = DateTime.now();
    return [
      FeedingEntry(
        id: 'demo-f1', type: FeedingType.breastLeft,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2, minutes: -15)),
        durationMinutes: 15,
      ),
      FeedingEntry(
        id: 'demo-f2', type: FeedingType.bottleBreastMilk,
        startTime: now.subtract(const Duration(hours: 5)),
        amountMl: 90,
      ),
      FeedingEntry(
        id: 'demo-f3', type: FeedingType.breastRight,
        startTime: now.subtract(const Duration(hours: 8)),
        durationMinutes: 20,
      ),
    ];
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ============================================================
// DIAPER LOG — syncs to Firestore when Firebase is live
// ============================================================

final diaperEntriesProvider =
    StateNotifierProvider<DiaperEntriesNotifier, List<DiaperEntry>>((ref) {
  return DiaperEntriesNotifier();
});

class DiaperEntriesNotifier extends StateNotifier<List<DiaperEntry>> {
  StreamSubscription? _sub;

  DiaperEntriesNotifier() : super(_isDemoUser() ? _demoData() : []) {
    _initFirestore();
  }

  static bool _isDemoUser() =>
      !isFirebaseInitialized || (AuthService().currentEmail?.endsWith('@balam.ai') ?? false);

  void _initFirestore() {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diapers')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snap) {
      state = snap.docs
          .map((d) => DiaperEntry.fromFirestore(d.data()))
          .toList();
    });
  }

  void add(DiaperEntry entry) {
    state = [entry, ...state];
    _write(entry);
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _delete(id);
  }

  List<DiaperEntry> todayEntries() {
    final now = DateTime.now();
    return state.where((e) =>
      e.timestamp.year == now.year &&
      e.timestamp.month == now.month &&
      e.timestamp.day == now.day
    ).toList();
  }

  Future<void> _write(DiaperEntry entry) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('diapers').doc(entry.id)
          .set(entry.toFirestore());
    } catch (e) {
      debugPrint('[Diaper] Write error: $e');
    }
  }

  Future<void> _delete(String id) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('diapers').doc(id)
          .delete();
    } catch (e) {
      debugPrint('[Diaper] Delete error: $e');
    }
  }

  static List<DiaperEntry> _demoData() {
    final now = DateTime.now();
    return [
      DiaperEntry(id: 'demo-d1', type: DiaperType.wet, timestamp: now.subtract(const Duration(hours: 1))),
      DiaperEntry(id: 'demo-d2', type: DiaperType.both, timestamp: now.subtract(const Duration(hours: 3))),
      DiaperEntry(id: 'demo-d3', type: DiaperType.wet, timestamp: now.subtract(const Duration(hours: 5))),
      DiaperEntry(id: 'demo-d4', type: DiaperType.dirty, timestamp: now.subtract(const Duration(hours: 7))),
    ];
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
