import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../main.dart' show isFirebaseInitialized;
import '../../../shared/models/child_model.dart';
import '../../../shared/models/user_profile.dart';
import '../../journey/providers/journey_provider.dart';
import '../models/daily_brief.dart';

/// Streams the daily brief for the active child. Returns null while
/// loading, while no child is selected, or when Firebase isn't ready.
/// If today's brief doesn't exist yet, kicks off a generation call.
final dailyBriefProvider = StreamProvider<DailyBrief?>((ref) async* {
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
  final docRef = FirebaseFirestore.instance.doc('users/$uid/dailyBriefs/$docId');

  // Kick off generation in the background — only one in-flight per child/day.
  _ensureGenerated(uid, activeChild.id, docId);

  await for (final snap in docRef.snapshots()) {
    if (!snap.exists) {
      yield null;
      continue;
    }
    final data = snap.data();
    if (data == null) {
      yield null;
      continue;
    }
    yield DailyBrief.fromMap(Map<String, dynamic>.from(data));
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

final Set<String> _inflightBriefs = <String>{};

Future<void> _ensureGenerated(String uid, String memberId, String docId) async {
  if (_inflightBriefs.contains(docId)) return;
  _inflightBriefs.add(docId);
  try {
    final docRef = FirebaseFirestore.instance.doc('users/$uid/dailyBriefs/$docId');
    final existing = await docRef.get();
    if (existing.exists) return;
    final callable = FirebaseFunctions.instance.httpsCallable('dailyBriefGenerate');
    await callable.call(<String, dynamic>{
      'memberId': memberId,
      'locale': _currentLocale(),
    });
  } catch (e) {
    debugPrint('[dailyBrief] generation kickoff failed: $e');
  } finally {
    _inflightBriefs.remove(docId);
  }
}

String _currentLocale() {
  final code = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
  if (code == 'ru') return 'ru';
  if (code == 'ky') return 'ky';
  return 'en';
}
