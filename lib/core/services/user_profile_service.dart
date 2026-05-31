import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Saves and loads user profile data to/from Firestore.
/// No-ops in demo mode (data stays in-memory only).
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._();
  factory UserProfileService() => _instance;
  UserProfileService._();

  FirebaseFirestore? get _db =>
      isFirebaseInitialized ? FirebaseFirestore.instance : null;

  Future<void> updateProfile({
    required String uid,
    String? stage,
    DateTime? dueDate,
    DateTime? babyBirthDate,
    String? babyName,
    String? partnerName,
  }) async {
    if (_db == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (stage != null) updates['stage'] = stage;
    if (dueDate != null) updates['dueDate'] = Timestamp.fromDate(dueDate);
    if (babyBirthDate != null) {
      updates['babyBirthDate'] = Timestamp.fromDate(babyBirthDate);
    }
    if (babyName != null) updates['babyName'] = babyName;
    if (partnerName != null) updates['partnerName'] = partnerName;

    await _db!.collection('users').doc(uid).set(updates, SetOptions(merge: true));
  }

  /// Writes `lastSeenAt` + the device's current UTC offset so the Sunday
  /// Chapter cron knows when it's local Sunday 7pm for this parent.
  /// Idempotent — call freely on auth state changes / cold starts.
  Future<void> markActiveSession(String uid) async {
    if (_db == null) return;
    final now = DateTime.now();
    await _db!.collection('users').doc(uid).set({
      'lastSeenAt': FieldValue.serverTimestamp(),
      'timezoneOffsetMinutes': now.timeZoneOffset.inMinutes,
      'timezoneName': now.timeZoneName,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    if (_db == null) return null;
    final doc = await _db!.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<Map<String, dynamic>?> watchProfile(String uid) {
    if (_db == null) return const Stream.empty();
    return _db!.collection('users').doc(uid).snapshots().map((d) => d.data());
  }

  // ==========================================================
  // ADMIN — for admin dashboard metrics
  // ==========================================================

  Future<int> totalUserCount() async {
    if (_db == null) return 0;
    final snap = await _db!.collection('users').count().get();
    return snap.count ?? 0;
  }

  Future<int> usersCreatedSince(DateTime since) async {
    if (_db == null) return 0;
    final snap = await _db!
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<Map<String, int>> usersByStage() async {
    if (_db == null) return {};
    final snap = await _db!.collection('users').get();
    final result = <String, int>{};
    for (final doc in snap.docs) {
      final stage = doc.data()['stage'] as String? ?? 'unknown';
      result[stage] = (result[stage] ?? 0) + 1;
    }
    return result;
  }
}
