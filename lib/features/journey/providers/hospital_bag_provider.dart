import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which items are packed. In production: persisted to Firestore.
final hospitalBagPackedProvider =
    StateNotifierProvider<HospitalBagPackedNotifier, Set<String>>((ref) {
  return HospitalBagPackedNotifier();
});

class HospitalBagPackedNotifier extends StateNotifier<Set<String>> {
  HospitalBagPackedNotifier() : super({});

  void toggle(String itemId) {
    final next = {...state};
    if (next.contains(itemId)) {
      next.remove(itemId);
    } else {
      next.add(itemId);
    }
    state = next;
  }

  bool isPacked(String itemId) => state.contains(itemId);
}
