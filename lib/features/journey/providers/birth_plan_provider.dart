import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the user's birth plan preferences.
/// Map of questionId -> list of selected option strings.
final birthPlanProvider =
    StateNotifierProvider<BirthPlanNotifier, Map<String, List<String>>>((ref) {
  return BirthPlanNotifier();
});

class BirthPlanNotifier extends StateNotifier<Map<String, List<String>>> {
  BirthPlanNotifier() : super({});

  void toggleOption(String questionId, String option) {
    final current = List<String>.from(state[questionId] ?? []);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    final next = Map<String, List<String>>.from(state);
    if (current.isEmpty) {
      next.remove(questionId);
    } else {
      next[questionId] = current;
    }
    state = next;
  }

  void setSingle(String questionId, String option) {
    final next = Map<String, List<String>>.from(state);
    next[questionId] = [option];
    state = next;
  }

  List<String> getAnswers(String questionId) => state[questionId] ?? const [];

  int get answeredCount => state.length;
}
