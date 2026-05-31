import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../main.dart' show isFirebaseInitialized;
import 'models/consultation.dart';

CollectionReference<Map<String, dynamic>> get _consults =>
    FirebaseFirestore.instance.collection('consultations');

/// The signed-in parent's own consultations, newest activity first.
/// Sorted client-side so the `where` query needs no composite index.
final myConsultationsProvider =
    StreamProvider.autoDispose<List<Consultation>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  final uid = AuthService().currentUid;
  if (uid == null) return Stream.value(const []);
  return _consults.where('uid', isEqualTo: uid).snapshots().map((s) {
    final list = s.docs.map(Consultation.fromDoc).toList();
    list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  });
});

/// Every consultation, for the doctor inbox. Access is enforced by
/// Firestore rules (only the doctor account may read across families).
final doctorInboxProvider =
    StreamProvider.autoDispose<List<Consultation>>((ref) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  return _consults
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Consultation.fromDoc).toList());
});

/// Messages in one consultation thread, oldest first.
final consultMessagesProvider = StreamProvider.autoDispose
    .family<List<ConsultMessage>, String>((ref, consultId) {
  if (!isFirebaseInitialized) return Stream.value(const []);
  return _consults
      .doc(consultId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(ConsultMessage.fromDoc).toList());
});

/// Live stream of a single consultation document — used by the thread
/// screen to react to server-side enrichment (doctorBriefSummary,
/// status changes, etc.).
final consultationProvider = StreamProvider.autoDispose
    .family<Consultation?, String>((ref, consultId) {
  if (!isFirebaseInitialized) return Stream.value(null);
  return _consults.doc(consultId).snapshots().map(
      (snap) => snap.exists ? Consultation.fromDoc(snap) : null);
});

final consultServiceProvider = Provider<ConsultService>((ref) => ConsultService());

class ConsultService {
  /// Open a new consultation against a specific doctor. Returns the
  /// new doc id, or null on failure. Call only after payment has
  /// succeeded.
  Future<String?> create({
    required String topic,
    required String firstMessage,
    String? doctorId,
    bool screenedByAi = false,
  }) async {
    if (!isFirebaseInitialized) return null;
    final uid = AuthService().currentUid;
    if (uid == null) return null;
    try {
      final doc = await _consults.add({
        'uid': uid,
        'parentName': AuthService().currentDisplayName ?? 'Parent',
        'topic': topic,
        'status': ConsultStatus.awaitingDoctor.name,
        'paid': true,
        if (doctorId != null) 'doctorId': doctorId,
        if (screenedByAi) 'screenedByAi': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview': firstMessage,
      });
      await doc.collection('messages').add({
        'fromDoctor': false,
        'kind': 'user',
        'text': firstMessage,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('[Consult] create failed: $e');
      return null;
    }
  }

  /// Post a message to a thread. [fromDoctor] flips the status so each
  /// side sees whose turn it is.
  Future<bool> sendMessage(
    String consultId, {
    required String text,
    required bool fromDoctor,
    File? photo,
  }) async {
    if (!isFirebaseInitialized) return false;
    try {
      String? photoUrl;
      if (photo != null) {
        final uid = AuthService().currentUid ?? 'unknown';
        photoUrl = await StorageService().uploadFile(
          file: photo,
          path: 'consults/$consultId/$uid-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      await _consults.doc(consultId).collection('messages').add({
        'fromDoctor': fromDoctor,
        'text': text,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _consults.doc(consultId).update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview': text.isNotEmpty ? text : '📎 Photo',
        'status': (fromDoctor
                ? ConsultStatus.answered
                : ConsultStatus.awaitingDoctor)
            .name,
      });
      return true;
    } catch (e) {
      debugPrint('[Consult] sendMessage failed: $e');
      return false;
    }
  }

  Future<void> close(String consultId) async {
    if (!isFirebaseInitialized) return;
    try {
      await _consults
          .doc(consultId)
          .update({'status': ConsultStatus.closed.name});
    } catch (e) {
      debugPrint('[Consult] close failed: $e');
    }
  }
}
