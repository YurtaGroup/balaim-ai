import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../../../main.dart' show isFirebaseInitialized;
import '../../../shared/models/moment.dart';
import '../../auth/providers/auth_provider.dart';

final momentsProvider =
    StateNotifierProvider<MomentsNotifier, List<Moment>>((ref) {
  return MomentsNotifier(ref);
});

class MomentsNotifier extends StateNotifier<List<Moment>> {
  final Ref _ref;

  MomentsNotifier(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    if (!isFirebaseInitialized) {
      // Demo moments for testing
      state = _demoMoments();
      return;
    }

    try {
      final uid = _ref.read(currentUserInfoProvider).uid;
      if (uid == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('moments')
          .orderBy('date', descending: true)
          .get();

      state = snap.docs
          .map((doc) => Moment.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[Moments] Error loading: $e');
      state = _demoMoments();
    }
  }

  Future<void> addMoment({
    required String caption,
    required DateTime date,
    required MomentTag tag,
    File? photo,
  }) async {
    String? photoUrl;

    // Upload photo if provided
    if (photo != null && isFirebaseInitialized) {
      try {
        final uid = _ref.read(currentUserInfoProvider).uid ?? 'demo';
        photoUrl = await StorageService().uploadFile(
          file: photo,
          path: 'moments/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } catch (e) {
        debugPrint('[Moments] Photo upload error: $e');
      }
    }

    final moment = Moment(
      id: 'moment-${DateTime.now().millisecondsSinceEpoch}',
      caption: caption,
      date: date,
      photoUrl: photoUrl,
      localPhotoPath: photo?.path,
      tag: tag,
    );

    // Save to Firestore
    if (isFirebaseInitialized) {
      try {
        final uid = _ref.read(currentUserInfoProvider).uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('moments')
              .add(moment.toMap());
        }
      } catch (e) {
        debugPrint('[Moments] Save error: $e');
      }
    }

    // Add to local state (newest first)
    state = [moment, ...state];
  }

  Future<void> removeMoment(String id) async {
    if (isFirebaseInitialized) {
      try {
        final uid = _ref.read(currentUserInfoProvider).uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('moments')
              .doc(id)
              .delete();
        }
      } catch (e) {
        debugPrint('[Moments] Delete error: $e');
      }
    }

    state = state.where((m) => m.id != id).toList();
  }

  List<Moment> _demoMoments() {
    final now = DateTime.now();
    return [
      Moment(
        id: 'demo-1',
        caption: 'Those little eyes looking right at me',
        date: now.subtract(const Duration(days: 710)),
        tag: MomentTag.firstSmile,
      ),
      Moment(
        id: 'demo-2',
        caption: 'That belly laugh! I could listen to it forever',
        date: now.subtract(const Duration(days: 650)),
        tag: MomentTag.firstLaugh,
      ),
      Moment(
        id: 'demo-3',
        caption: 'Rolled from tummy to back during tummy time!',
        date: now.subtract(const Duration(days: 590)),
        tag: MomentTag.rolledOver,
      ),
      Moment(
        id: 'demo-4',
        caption: 'Sitting up all by himself!',
        date: now.subtract(const Duration(days: 530)),
        tag: MomentTag.satUp,
      ),
      Moment(
        id: 'demo-5',
        caption: 'Avocado was a hit! Bananas, not so much',
        date: now.subtract(const Duration(days: 500)),
        tag: MomentTag.firstFood,
      ),
      Moment(
        id: 'demo-6',
        caption: 'Army crawling across the living room to get the remote',
        date: now.subtract(const Duration(days: 450)),
        tag: MomentTag.crawled,
      ),
      Moment(
        id: 'demo-7',
        caption: '"Dada!" — of course that was first 😤😂',
        date: now.subtract(const Duration(days: 380)),
        tag: MomentTag.firstWord,
      ),
      Moment(
        id: 'demo-8',
        caption: '3 wobbly steps between the couch and papa!',
        date: now.subtract(const Duration(days: 340)),
        tag: MomentTag.firstStep,
      ),
      Moment(
        id: 'demo-9',
        caption: 'One whole year of being the best thing that ever happened to us',
        date: now.subtract(const Duration(days: 310)),
        tag: MomentTag.firstBirthday,
      ),
    ];
  }
}
