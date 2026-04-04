import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/tracking_entry.dart';
import '../../../shared/models/pregnancy_week_data.dart';
import '../../../core/constants/app_constants.dart';

/// Demo user profile — replaced by Firestore when Firebase is connected
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(UserProfile(
          uid: 'demo-parent-001',
          email: 'parent@balam.ai',
          displayName: 'Sarah Johnson',
          stage: ParentingStage.pregnant,
          dueDate: DateTime.now().add(const Duration(days: 112)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void updateStage(ParentingStage stage) {
    state = state.copyWith(stage: stage);
  }

  void updateBabyName(String name) {
    state = state.copyWith(babyName: name);
  }

  void updateBabyBirthDate(DateTime date) {
    state = state.copyWith(babyBirthDate: date);
  }
}

/// Current pregnancy week data based on user's due date
final currentWeekDataProvider = Provider<PregnancyWeekData>((ref) {
  final profile = ref.watch(userProfileProvider);
  final week = profile.currentWeek ?? 24;
  return PregnancyWeekData.getWeek(week);
});

/// Tracking entries — stored locally, synced to Firestore when connected
final trackingEntriesProvider =
    StateNotifierProvider<TrackingNotifier, List<TrackingEntry>>((ref) {
  return TrackingNotifier();
});

class TrackingNotifier extends StateNotifier<List<TrackingEntry>> {
  TrackingNotifier() : super(_generateDemoData());

  void addEntry(TrackingEntry entry) {
    state = [entry, ...state];
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
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

  /// Demo data so the app feels alive on first run
  static List<TrackingEntry> _generateDemoData() {
    final now = DateTime.now();
    return [
      TrackingEntry(
        id: 'demo-w1',
        userId: 'demo-parent-001',
        type: TrackingType.weight,
        value: 68.5,
        unit: 'kg',
        timestamp: now.subtract(const Duration(hours: 8)),
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      TrackingEntry(
        id: 'demo-w2',
        userId: 'demo-parent-001',
        type: TrackingType.water,
        value: 6,
        unit: 'glasses',
        timestamp: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      TrackingEntry(
        id: 'demo-s1',
        userId: 'demo-parent-001',
        type: TrackingType.sleep,
        value: 7.5,
        unit: 'hours',
        timestamp: now.subtract(const Duration(hours: 10)),
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      TrackingEntry(
        id: 'demo-k1',
        userId: 'demo-parent-001',
        type: TrackingType.kicks,
        value: 12,
        unit: 'kicks',
        notes: '10 kicks in 22 minutes — very active today!',
        timestamp: now.subtract(const Duration(hours: 5)),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TrackingEntry(
        id: 'demo-m1',
        userId: 'demo-parent-001',
        type: TrackingType.mood,
        value: 4,
        unit: 'rating',
        notes: 'Feeling good, a bit tired',
        timestamp: now.subtract(const Duration(hours: 6)),
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      // Yesterday's data
      TrackingEntry(
        id: 'demo-w3',
        userId: 'demo-parent-001',
        type: TrackingType.weight,
        value: 68.3,
        unit: 'kg',
        timestamp: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TrackingEntry(
        id: 'demo-w4',
        userId: 'demo-parent-001',
        type: TrackingType.water,
        value: 8,
        unit: 'glasses',
        timestamp: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// Kick counter session
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
