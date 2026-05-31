import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../../shared/models/child_model.dart';
import '../../shared/models/user_profile.dart';
import '../journey/providers/journey_provider.dart';
import 'invitation_models.dart';

/// Streams today's Montessori Invitation for the active child. Mirrors
/// the dailyBriefProvider pattern: if today's doc doesn't exist yet,
/// kick off a generation call and let the stream emit it as soon as
/// Firestore reflects the write.
///
/// Returns null while loading, while no child is selected, or while
/// Firebase isn't ready.
final invitationProvider = StreamProvider<Invitation?>((ref) async* {
  final profile = ref.watch(userProfileProvider);
  final activeChild = _activeChild(profile);
  if (activeChild == null || !isFirebaseInitialized) {
    yield null;
    return;
  }
  final uid = AuthService().currentUid;
  if (uid == null) {
    yield null;
    return;
  }

  final today = _todayLocal();
  final docId = '${activeChild.id}__$today';
  final docRef =
      FirebaseFirestore.instance.doc('users/$uid/invitations/$docId');

  _ensureGenerated(uid, activeChild.id, docId);

  final stream = docRef.snapshots().handleError((Object e, StackTrace _) {
    debugPrint('[invitation] stream error: $e');
  });
  await for (final snap in stream) {
    if (!snap.exists) {
      yield null;
      continue;
    }
    yield Invitation.fromFirestore(snap);
  }
});

HouseholdMember? _activeChild(UserProfile profile) {
  final children = profile.members.where((m) => m.role == MemberRole.child).toList();
  final selected = profile.selectedMember;
  if (selected != null && selected.role == MemberRole.child) return selected;
  if (children.isNotEmpty) return children.first;
  return null;
}

String _todayLocal() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

final Set<String> _inflight = <String>{};

Future<void> _ensureGenerated(
  String uid,
  String memberId,
  String docId,
) async {
  if (_inflight.contains(docId)) return;
  _inflight.add(docId);
  try {
    final docRef =
        FirebaseFirestore.instance.doc('users/$uid/invitations/$docId');
    final existing = await docRef.get();
    if (existing.exists) return;

    final callable =
        FirebaseFunctions.instance.httpsCallable('generateDailyInvitation');
    final payload = <String, dynamic>{'memberId': memberId};
    try {
      await callable.call(payload);
    } catch (firstErr) {
      // Cold-launch race: the cloud_functions plugin can fire the call
      // before Firebase Auth's restored token has propagated, returning
      // UNAUTHENTICATED. One short retry lets the token settle.
      debugPrint(
          '[invitation] first kickoff attempt failed ($firstErr) — retrying once');
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        await callable.call(payload);
      } catch (secondErr) {
        debugPrint('[invitation] retry failed: $secondErr');
      }
    }
  } catch (e) {
    debugPrint('[invitation] generation kickoff failed: $e');
  } finally {
    _inflight.remove(docId);
  }
}

/// Mark today's Invitation as tried (sets `triedAt` server-time).
Future<void> markInvitationTried({
  required String uid,
  required String invitationId,
}) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .doc('users/$uid/invitations/$invitationId')
        .update({'triedAt': FieldValue.serverTimestamp()});
  } catch (e) {
    debugPrint('[invitation] markInvitationTried failed: $e');
  }
}

/// Mom records how the Invitation landed. Rules only allow updating
/// `triedAt`, `feedback`, `feedbackAt` from the client.
Future<void> setInvitationFeedback({
  required String uid,
  required String invitationId,
  required InvitationFeedback feedback,
}) async {
  if (!isFirebaseInitialized) return;
  try {
    await FirebaseFirestore.instance
        .doc('users/$uid/invitations/$invitationId')
        .update({
      'feedback': feedback.id,
      'feedbackAt': FieldValue.serverTimestamp(),
      'triedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint('[invitation] setInvitationFeedback failed: $e');
  }
}
