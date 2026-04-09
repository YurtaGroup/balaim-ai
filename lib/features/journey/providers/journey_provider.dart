import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart' show isFirebaseInitialized;
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/tracking_entry.dart';
import '../../../shared/models/pregnancy_week_data.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

// ============================================================
// USER PROFILE — syncs to Firestore when Firebase is live
// ============================================================

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  StreamSubscription? _sub;

  UserProfileNotifier()
      : super(_initialProfile()) {
    _initFirestore();
  }

  static UserProfile _initialProfile() {
    final auth = AuthService();
    final email = auth.currentEmail ?? '';

    // Owner gets Altair pre-populated
    if (email == 'owner@balam.ai') {
      return UserProfile(
        uid: auth.currentUid ?? 'demo-owner-001',
        email: email,
        displayName: 'Timur Mone',
        stage: ParentingStage.toddler,
        babyBirthDate: DateTime(2024, 3, 16),
        babyName: 'Altair',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        children: [
          Child(
            id: 'child-altair',
            name: 'Altair',
            birthDate: DateTime(2024, 3, 16),
            stage: ParentingStage.toddler,
          ),
        ],
        selectedChildId: 'child-altair',
      );
    }

    // Other demo accounts get demo data
    if (!isFirebaseInitialized || email.endsWith('@balam.ai')) {
      return UserProfile(
        uid: auth.currentUid ?? 'demo-parent-001',
        email: email.isNotEmpty ? email : 'parent@balam.ai',
        displayName: auth.currentDisplayName ?? 'Sarah Johnson',
        stage: ParentingStage.pregnant,
        dueDate: DateTime.now().add(const Duration(days: 112)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        children: [
          Child(
            id: 'child-demo-1',
            name: 'Baby Johnson',
            dueDate: DateTime.now().add(const Duration(days: 112)),
            stage: ParentingStage.pregnant,
          ),
        ],
        selectedChildId: 'child-demo-1',
      );
    }

    // Real user — start blank, Firestore snapshot will populate
    return UserProfile(
      uid: auth.currentUid ?? '',
      email: email,
      displayName: auth.currentDisplayName ?? '',
      stage: ParentingStage.pregnant,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _initFirestore() {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null) {
        try {
          state = UserProfile.fromFirestore(doc.data()!);
        } catch (e) {
          debugPrint('[Profile] Firestore parse error: $e');
        }
      }
    });
  }

  Future<void> _save() async {
    if (!isFirebaseInitialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(state.uid)
          .set(state.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Profile] Save error: $e');
    }
  }

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
    _save();
  }

  void updateStage(ParentingStage stage) {
    state = state.copyWith(stage: stage);
    _save();
  }

  void updateBabyName(String name) {
    state = state.copyWith(babyName: name);
    _save();
  }

  void updateBabyBirthDate(DateTime date) {
    state = state.copyWith(babyBirthDate: date);
    _save();
  }

  // ── Child management ──

  void addChild(Child child) {
    final updated = [...state.children, child];
    state = state.copyWith(children: updated, selectedChildId: child.id);
    _save();
  }

  void updateChild(Child child) {
    final updated = state.children.map((c) => c.id == child.id ? child : c).toList();
    state = state.copyWith(children: updated);
    _save();
  }

  void removeChild(String childId) {
    final updated = state.children.where((c) => c.id != childId).toList();
    final newSelected = updated.isNotEmpty ? updated.first.id : null;
    state = state.copyWith(children: updated, selectedChildId: newSelected);
    _save();
  }

  void selectChild(String childId) {
    state = state.copyWith(selectedChildId: childId);
    _save();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ============================================================
// PREGNANCY WEEK DATA
// ============================================================

final currentWeekDataProvider = Provider<PregnancyWeekData>((ref) {
  final profile = ref.watch(userProfileProvider);
  final week = profile.currentWeek ?? 24;
  return PregnancyWeekData.getWeek(week);
});

// ============================================================
// TRACKING ENTRIES — syncs to Firestore when Firebase is live
// ============================================================

final trackingEntriesProvider =
    StateNotifierProvider<TrackingNotifier, List<TrackingEntry>>((ref) {
  return TrackingNotifier();
});

class TrackingNotifier extends StateNotifier<List<TrackingEntry>> {
  StreamSubscription? _sub;

  TrackingNotifier() : super(_initialData()) {
    _initFirestore();
  }

  static List<TrackingEntry> _initialData() {
    final isDemoUser = !isFirebaseInitialized || (AuthService().currentEmail?.endsWith('@balam.ai') ?? false);
    return isDemoUser ? _generateDemoData() : [];
  }

  void _initFirestore() {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tracking')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snap) {
      state = snap.docs
          .map((d) => TrackingEntry.fromFirestore(d.data()))
          .toList();
    });
  }

  void addEntry(TrackingEntry entry) {
    state = [entry, ...state];
    _writeToFirestore(entry);
  }

  void updateEntry(TrackingEntry updated) {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
    _writeToFirestore(updated);
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
    _deleteFromFirestore(id);
  }

  List<TrackingEntry> getByType(TrackingType type) {
    return state.where((e) => e.type == type).toList();
  }

  List<TrackingEntry> getToday() {
    final now = DateTime.now();
    return state.where((e) =>
      e.timestamp.year == now.year &&
      e.timestamp.month == now.month &&
      e.timestamp.day == now.day
    ).toList();
  }

  Future<void> _writeToFirestore(TrackingEntry entry) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tracking')
          .doc(entry.id)
          .set(entry.toFirestore());
    } catch (e) {
      debugPrint('[Tracking] Write error: $e');
    }
  }

  Future<void> _deleteFromFirestore(String id) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tracking')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('[Tracking] Delete error: $e');
    }
  }

  static List<TrackingEntry> _generateDemoData() {
    final now = DateTime.now();
    return [
      TrackingEntry(
        id: 'demo-w1', userId: 'demo-parent-001', type: TrackingType.weight,
        value: 68.5, unit: 'kg',
        timestamp: now.subtract(const Duration(hours: 8)),
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      TrackingEntry(
        id: 'demo-w2', userId: 'demo-parent-001', type: TrackingType.water,
        value: 6, unit: 'glasses',
        timestamp: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      TrackingEntry(
        id: 'demo-s1', userId: 'demo-parent-001', type: TrackingType.sleep,
        value: 7.5, unit: 'hours',
        timestamp: now.subtract(const Duration(hours: 10)),
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      TrackingEntry(
        id: 'demo-k1', userId: 'demo-parent-001', type: TrackingType.kicks,
        value: 12, unit: 'kicks', notes: '10 kicks in 22 minutes — very active today!',
        timestamp: now.subtract(const Duration(hours: 5)),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TrackingEntry(
        id: 'demo-m1', userId: 'demo-parent-001', type: TrackingType.mood,
        value: 4, unit: 'rating', notes: 'Feeling good, a bit tired',
        timestamp: now.subtract(const Duration(hours: 6)),
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      TrackingEntry(
        id: 'demo-w3', userId: 'demo-parent-001', type: TrackingType.weight,
        value: 68.3, unit: 'kg',
        timestamp: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TrackingEntry(
        id: 'demo-w4', userId: 'demo-parent-001', type: TrackingType.water,
        value: 8, unit: 'glasses',
        timestamp: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
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
// KICK COUNTER
// ============================================================

final kickSessionProvider =
    StateNotifierProvider<KickSessionNotifier, KickSession?>((ref) {
  return KickSessionNotifier();
});

class KickSessionNotifier extends StateNotifier<KickSession?> {
  KickSessionNotifier() : super(null);

  void startSession(String userId) {
    state = KickSession(
      id: 'kick-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      startTime: DateTime.now(),
      kicks: [],
    );
  }

  void recordKick() {
    if (state != null) {
      state = state!.addKick();
    }
  }

  KickSession? completeSession() {
    if (state != null) {
      final completed = state!.complete();
      state = null;
      return completed;
    }
    return null;
  }

  void cancelSession() {
    state = null;
  }
}
