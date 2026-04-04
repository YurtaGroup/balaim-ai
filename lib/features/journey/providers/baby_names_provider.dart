import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/baby_names_data.dart';

/// User's favorited baby names. In production: persisted to Firestore.
final favoriteNamesProvider =
    StateNotifierProvider<FavoriteNamesNotifier, Set<String>>((ref) {
  return FavoriteNamesNotifier();
});

class FavoriteNamesNotifier extends StateNotifier<Set<String>> {
  FavoriteNamesNotifier() : super({});

  void toggle(String nameId) {
    final next = {...state};
    if (next.contains(nameId)) {
      next.remove(nameId);
    } else {
      next.add(nameId);
    }
    state = next;
  }

  bool isFavorite(String nameId) => state.contains(nameId);
}

class BabyNamesFilter {
  final NameGender? gender;
  final NameOrigin? origin;
  final String search;
  final bool favoritesOnly;

  const BabyNamesFilter({
    this.gender,
    this.origin,
    this.search = '',
    this.favoritesOnly = false,
  });

  BabyNamesFilter copyWith({
    NameGender? gender,
    bool clearGender = false,
    NameOrigin? origin,
    bool clearOrigin = false,
    String? search,
    bool? favoritesOnly,
  }) {
    return BabyNamesFilter(
      gender: clearGender ? null : (gender ?? this.gender),
      origin: clearOrigin ? null : (origin ?? this.origin),
      search: search ?? this.search,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

final babyNamesFilterProvider =
    StateProvider<BabyNamesFilter>((ref) => const BabyNamesFilter());
