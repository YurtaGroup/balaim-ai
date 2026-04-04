import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/tracking_entry.dart';

/// Firestore service for reading/writing user data.
/// Only used when Firebase is initialized.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  // ============================================================
  // USER PROFILES
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUserProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toFirestore());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromFirestore(doc.data()!);
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _users.doc(profile.uid).update(profile.toFirestore());
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromFirestore(doc.data()!);
    });
  }

  // ============================================================
  // TRACKING ENTRIES
  // ============================================================

  CollectionReference<Map<String, dynamic>> _tracking(String uid) =>
      _users.doc(uid).collection('tracking');

  Future<void> addTrackingEntry(String uid, TrackingEntry entry) async {
    await _tracking(uid).doc(entry.id).set(entry.toFirestore());
  }

  Future<void> deleteTrackingEntry(String uid, String entryId) async {
    await _tracking(uid).doc(entryId).delete();
  }

  Stream<List<TrackingEntry>> watchTrackingEntries(String uid, {int limit = 50}) {
    return _tracking(uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrackingEntry.fromFirestore(d.data()))
            .toList());
  }

  Future<List<TrackingEntry>> getTodayEntries(String uid) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final snap = await _tracking(uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => TrackingEntry.fromFirestore(d.data())).toList();
  }

  // ============================================================
  // INSIGHTS
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _insights =>
      _db.collection('insights');

  Stream<List<Map<String, dynamic>>> watchInsights(String uid, {int limit = 10}) {
    return _insights
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> markInsightRead(String insightId) async {
    await _insights.doc(insightId).update({'read': true});
  }

  // ============================================================
  // COMMUNITY POSTS
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');

  Future<String> createPost({
    required String uid,
    required String displayName,
    required String group,
    required String text,
    bool isAnonymous = false,
  }) async {
    final doc = await _posts.add({
      'uid': uid,
      'displayName': isAnonymous ? 'Anonymous' : displayName,
      'group': group,
      'text': text,
      'isAnonymous': isAnonymous,
      'likes': 0,
      'comments': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<Map<String, dynamic>>> watchPosts({String? group, int limit = 20}) {
    var query = _posts.orderBy('createdAt', descending: true).limit(limit);
    if (group != null) {
      query = _posts
          .where('group', isEqualTo: group)
          .orderBy('createdAt', descending: true)
          .limit(limit);
    }
    return query.snapshots().map((snap) => snap.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return data;
        }).toList());
  }

  Future<void> likePost(String postId) async {
    await _posts.doc(postId).update({'likes': FieldValue.increment(1)});
  }
}
