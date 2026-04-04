/// Diaper log entry — wet / dirty / both.
enum DiaperType {
  wet('Wet', 'pee'),
  dirty('Dirty', 'poop'),
  both('Wet + Dirty', 'both'),
  dry('Dry', 'no change');

  const DiaperType(this.label, this.short);
  final String label;
  final String short;
}

class DiaperEntry {
  final String id;
  final DiaperType type;
  final DateTime timestamp;
  final String? note;

  const DiaperEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    this.note,
  });
}
