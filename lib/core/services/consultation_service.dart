import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../../shared/models/consultation.dart';
import 'analytics_service.dart';

/// Consultation service — manages the full lifecycle of async consultations.
///
/// Lifecycle:
///   Patient creates → Doctor reviews → Doctor responds → Patient reads
///   → Patient asks follow-up → Doctor answers → Closed
///
/// In demo mode: stores in-memory. In Firebase mode: Firestore.
class ConsultationService {
  static final ConsultationService _instance = ConsultationService._();
  factory ConsultationService() => _instance;
  ConsultationService._();

  FirebaseFirestore? get _db =>
      isFirebaseInitialized ? FirebaseFirestore.instance : null;

  // In-memory store for demo mode
  final List<Consultation> _demoConsultations = [];

  // ==========================================================
  // PATIENT ACTIONS
  // ==========================================================

  /// Submit a new consultation request.
  Future<String> submitConsultation(Consultation consultation) async {
    if (_db != null) {
      final docRef = _db!.collection('consultations').doc(consultation.id);
      await docRef.set(consultation.toFirestore());

      // Also add to patient's subcollection for easy querying
      await _db!
          .collection('users')
          .doc(consultation.patientUid)
          .collection('consultations')
          .doc(consultation.id)
          .set({
        'consultationId': consultation.id,
        'doctorName': consultation.doctorName,
        'specialty': consultation.specialty.name,
        'status': consultation.status.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Notify the doctor (create a notification document)
      await _db!.collection('notifications').add({
        'recipientUid': consultation.doctorUid,
        'type': 'new_consultation',
        'consultationId': consultation.id,
        'patientName': consultation.intake.patientName,
        'mainConcern': consultation.intake.mainConcern,
        'urgency': consultation.urgency.name,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } else {
      _demoConsultations.add(consultation);
    }

    AnalyticsService().logFeatureViewed('consultation_submitted');
    debugPrint('[Consultation] Submitted: ${consultation.id}');
    return consultation.id;
  }

  /// Patient asks a follow-up question.
  Future<void> askFollowUp(String consultationId, String question) async {
    if (_db != null) {
      await _db!.collection('consultations').doc(consultationId).update({
        'followUpQuestion': question,
        'status': ConsultationStatus.followUpAsked.name,
      });

      // Get consultation to find doctor
      final doc = await _db!.collection('consultations').doc(consultationId).get();
      final data = doc.data();
      if (data != null) {
        await _db!.collection('notifications').add({
          'recipientUid': data['doctorUid'],
          'type': 'follow_up_question',
          'consultationId': consultationId,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    }
  }

  /// Get patient's consultations.
  Stream<List<Map<String, dynamic>>> watchPatientConsultations(String uid) {
    if (_db == null) return Stream.value([]);
    return _db!
        .collection('consultations')
        .where('patientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  // ==========================================================
  // DOCTOR ACTIONS
  // ==========================================================

  /// Doctor marks consultation as "in review" (they've opened it).
  Future<void> markInReview(String consultationId) async {
    if (_db != null) {
      await _db!.collection('consultations').doc(consultationId).update({
        'status': ConsultationStatus.inReview.name,
      });
    }
  }

  /// Doctor submits their response.
  Future<void> submitResponse({
    required String consultationId,
    required String patientUid,
    required DoctorResponse response,
  }) async {
    if (_db != null) {
      await _db!.collection('consultations').doc(consultationId).update({
        'response': response.toMap(),
        'status': ConsultationStatus.answered.name,
        'answeredAt': FieldValue.serverTimestamp(),
      });

      // Update patient's subcollection
      await _db!
          .collection('users')
          .doc(patientUid)
          .collection('consultations')
          .doc(consultationId)
          .update({'status': ConsultationStatus.answered.name});

      // Notify the patient
      await _db!.collection('notifications').add({
        'recipientUid': patientUid,
        'type': 'consultation_answered',
        'consultationId': consultationId,
        'title': 'Your doctor has responded',
        'body': 'Your consultation has been reviewed. Tap to read the assessment.',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }

    AnalyticsService().logFeatureViewed('consultation_answered');
  }

  /// Doctor answers a follow-up question.
  Future<void> answerFollowUp({
    required String consultationId,
    required String patientUid,
    required String answer,
  }) async {
    if (_db != null) {
      await _db!.collection('consultations').doc(consultationId).update({
        'followUpAnswer': answer,
        'status': ConsultationStatus.followUpAnswered.name,
        'closedAt': FieldValue.serverTimestamp(),
      });

      await _db!.collection('notifications').add({
        'recipientUid': patientUid,
        'type': 'follow_up_answered',
        'consultationId': consultationId,
        'title': 'Follow-up answered',
        'body': 'Your doctor has answered your follow-up question.',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }

  /// Get doctor's pending consultations (queue).
  Stream<List<Map<String, dynamic>>> watchDoctorQueue(String doctorUid) {
    if (_db == null) return Stream.value([]);
    return _db!
        .collection('consultations')
        .where('doctorUid', isEqualTo: doctorUid)
        .where('status', whereIn: [
          ConsultationStatus.submitted.name,
          ConsultationStatus.inReview.name,
          ConsultationStatus.followUpAsked.name,
        ])
        .orderBy('createdAt', descending: false) // oldest first
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Get doctor's completed consultations.
  Stream<List<Map<String, dynamic>>> watchDoctorCompleted(String doctorUid) {
    if (_db == null) return Stream.value([]);
    return _db!
        .collection('consultations')
        .where('doctorUid', isEqualTo: doctorUid)
        .where('status', whereIn: [
          ConsultationStatus.answered.name,
          ConsultationStatus.followUpAnswered.name,
          ConsultationStatus.closed.name,
        ])
        .orderBy('answeredAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Get a single consultation by ID.
  Future<Map<String, dynamic>?> getConsultation(String id) async {
    if (_db == null) return null;
    final doc = await _db!.collection('consultations').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  /// Get unread notifications for a user.
  Stream<List<Map<String, dynamic>>> watchNotifications(String uid) {
    if (_db == null) return Stream.value([]);
    return _db!
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Mark a notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    if (_db != null) {
      await _db!.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    }
  }

  /// Count unread notifications.
  Stream<int> watchUnreadCount(String uid) {
    if (_db == null) return Stream.value(0);
    return _db!
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }
}
