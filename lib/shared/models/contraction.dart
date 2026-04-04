/// A single timed contraction.
class Contraction {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  const Contraction({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  /// Interval between this contraction's start and the previous one's start.
  Duration intervalFrom(Contraction? previous) {
    if (previous == null) return Duration.zero;
    return startTime.difference(previous.startTime);
  }
}

/// Labor phase guidance based on contraction pattern.
enum LaborPhase {
  early(
    'Early Labor',
    'Contractions are irregular and mild. Rest, hydrate, and time them.',
  ),
  active(
    'Active Labor',
    'Contractions are regular and stronger. Head to the hospital if this is your plan.',
  ),
  transition(
    'Transition',
    'Contractions are intense and close together. Baby is almost here!',
  );

  const LaborPhase(this.label, this.guidance);
  final String label;
  final String guidance;
}

/// 5-1-1 rule: contractions 5 minutes apart, lasting 1 minute, for 1 hour.
/// Standard guidance for when to go to the hospital for a first-time mom.
class ContractionAnalysis {
  final int count;
  final Duration? averageDuration;
  final Duration? averageInterval;
  final LaborPhase? phase;
  final bool meets511Rule;

  const ContractionAnalysis({
    required this.count,
    this.averageDuration,
    this.averageInterval,
    this.phase,
    required this.meets511Rule,
  });

  static ContractionAnalysis from(List<Contraction> contractions) {
    if (contractions.isEmpty) {
      return const ContractionAnalysis(count: 0, meets511Rule: false);
    }

    // Sort ascending by start time
    final sorted = [...contractions]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Use last 5 for analysis (more recent = more relevant)
    final recent = sorted.length > 5
        ? sorted.sublist(sorted.length - 5)
        : sorted;

    final totalDurationMs = recent.fold<int>(
      0,
      (sum, c) => sum + c.duration.inMilliseconds,
    );
    final avgDuration =
        Duration(milliseconds: (totalDurationMs / recent.length).round());

    Duration? avgInterval;
    if (recent.length >= 2) {
      var totalIntervalMs = 0;
      for (var i = 1; i < recent.length; i++) {
        totalIntervalMs +=
            recent[i].startTime.difference(recent[i - 1].startTime).inMilliseconds;
      }
      avgInterval = Duration(
        milliseconds: (totalIntervalMs / (recent.length - 1)).round(),
      );
    }

    final phase = _determinePhase(avgDuration, avgInterval);
    final meets511 = _meets511Rule(avgDuration, avgInterval, sorted);

    return ContractionAnalysis(
      count: contractions.length,
      averageDuration: avgDuration,
      averageInterval: avgInterval,
      phase: phase,
      meets511Rule: meets511,
    );
  }

  static LaborPhase? _determinePhase(Duration avgDur, Duration? avgInt) {
    if (avgInt == null) return null;
    final intMin = avgInt.inSeconds / 60;
    final durSec = avgDur.inSeconds;

    if (intMin <= 3 && durSec >= 60) return LaborPhase.transition;
    if (intMin <= 5 && durSec >= 45) return LaborPhase.active;
    return LaborPhase.early;
  }

  static bool _meets511Rule(
    Duration avgDur,
    Duration? avgInt,
    List<Contraction> all,
  ) {
    if (avgInt == null) return false;
    if (avgInt.inMinutes > 5 || avgInt.inMinutes < 4) return false;
    if (avgDur.inSeconds < 60) return false;
    // Have contractions been happening for at least 1 hour?
    if (all.length < 2) return false;
    final span = all.last.startTime.difference(all.first.startTime);
    return span.inMinutes >= 60;
  }
}
