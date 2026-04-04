import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/contraction.dart';

/// Holds the list of timed contractions for the current session.
/// In production, these would be persisted to Firestore.
final contractionsProvider =
    StateNotifierProvider<ContractionsNotifier, List<Contraction>>((ref) {
  return ContractionsNotifier();
});

class ContractionsNotifier extends StateNotifier<List<Contraction>> {
  ContractionsNotifier() : super([]);

  DateTime? _activeStart;

  bool get isTiming => _activeStart != null;
  DateTime? get activeStartTime => _activeStart;

  /// Start timing a new contraction.
  void startContraction() {
    _activeStart = DateTime.now();
    // Trigger a rebuild so UI reflects the active state
    state = [...state];
  }

  /// Stop timing the active contraction and persist it.
  void stopContraction() {
    if (_activeStart == null) return;
    final contraction = Contraction(
      id: const Uuid().v4(),
      startTime: _activeStart!,
      endTime: DateTime.now(),
    );
    _activeStart = null;
    state = [...state, contraction];
  }

  void cancelActive() {
    _activeStart = null;
    state = [...state];
  }

  void removeContraction(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void clearAll() {
    _activeStart = null;
    state = [];
  }
}

/// Derived analysis — recomputed whenever contractions change.
final contractionAnalysisProvider = Provider<ContractionAnalysis>((ref) {
  final contractions = ref.watch(contractionsProvider);
  return ContractionAnalysis.from(contractions);
});
