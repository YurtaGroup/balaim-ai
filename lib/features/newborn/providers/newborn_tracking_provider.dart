import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/feeding_entry.dart';
import '../../../shared/models/diaper_entry.dart';

/// Feeding log state. In production: persisted to Firestore.
final feedingEntriesProvider =
    StateNotifierProvider<FeedingEntriesNotifier, List<FeedingEntry>>((ref) {
  return FeedingEntriesNotifier();
});

class FeedingEntriesNotifier extends StateNotifier<List<FeedingEntry>> {
  FeedingEntriesNotifier() : super(_demoData());

  void add(FeedingEntry entry) {
    state = [entry, ...state];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  List<FeedingEntry> todayEntries() {
    final now = DateTime.now();
    return state.where((e) =>
      e.startTime.year == now.year &&
      e.startTime.month == now.month &&
      e.startTime.day == now.day
    ).toList();
  }

  /// How long since the last feeding. Null if never fed.
  Duration? timeSinceLastFeed() {
    if (state.isEmpty) return null;
    return DateTime.now().difference(state.first.startTime);
  }

  static List<FeedingEntry> _demoData() {
    final now = DateTime.now();
    return [
      FeedingEntry(
        id: 'demo-f1',
        type: FeedingType.breastLeft,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2, minutes: -15)),
        durationMinutes: 15,
      ),
      FeedingEntry(
        id: 'demo-f2',
        type: FeedingType.bottleBreastMilk,
        startTime: now.subtract(const Duration(hours: 5)),
        amountMl: 90,
      ),
      FeedingEntry(
        id: 'demo-f3',
        type: FeedingType.breastRight,
        startTime: now.subtract(const Duration(hours: 8)),
        durationMinutes: 20,
      ),
    ];
  }
}

/// Diaper log state.
final diaperEntriesProvider =
    StateNotifierProvider<DiaperEntriesNotifier, List<DiaperEntry>>((ref) {
  return DiaperEntriesNotifier();
});

class DiaperEntriesNotifier extends StateNotifier<List<DiaperEntry>> {
  DiaperEntriesNotifier() : super(_demoData());

  void add(DiaperEntry entry) {
    state = [entry, ...state];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  List<DiaperEntry> todayEntries() {
    final now = DateTime.now();
    return state.where((e) =>
      e.timestamp.year == now.year &&
      e.timestamp.month == now.month &&
      e.timestamp.day == now.day
    ).toList();
  }

  static List<DiaperEntry> _demoData() {
    final now = DateTime.now();
    return [
      DiaperEntry(
        id: 'demo-d1',
        type: DiaperType.wet,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      DiaperEntry(
        id: 'demo-d2',
        type: DiaperType.both,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      DiaperEntry(
        id: 'demo-d3',
        type: DiaperType.wet,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      DiaperEntry(
        id: 'demo-d4',
        type: DiaperType.dirty,
        timestamp: now.subtract(const Duration(hours: 7)),
      ),
    ];
  }
}
