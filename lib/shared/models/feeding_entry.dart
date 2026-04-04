/// Detailed feeding log entry for newborns/infants.
enum FeedingType {
  breastLeft('Breast (Left)'),
  breastRight('Breast (Right)'),
  bottleBreastMilk('Bottle - Breast Milk'),
  bottleFormula('Bottle - Formula'),
  solid('Solid Food');

  const FeedingType(this.label);
  final String label;
}

class FeedingEntry {
  final String id;
  final FeedingType type;
  final DateTime startTime;
  final DateTime? endTime;
  final double? amountMl;         // For bottle feeds
  final int? durationMinutes;     // For breast feeds
  final String? note;

  const FeedingEntry({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.amountMl,
    this.durationMinutes,
    this.note,
  });

  bool get isBreast =>
      type == FeedingType.breastLeft || type == FeedingType.breastRight;
  bool get isBottle =>
      type == FeedingType.bottleBreastMilk || type == FeedingType.bottleFormula;

  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get displayValue {
    if (isBottle && amountMl != null) return '${amountMl!.round()} ml';
    if (isBreast && durationMinutes != null) return '${durationMinutes!} min';
    return type.label;
  }
}
