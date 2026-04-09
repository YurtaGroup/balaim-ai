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

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };

  factory DiaperEntry.fromFirestore(Map<String, dynamic> data) => DiaperEntry(
    id: data['id'] as String,
    type: DiaperType.values.firstWhere((t) => t.name == data['type']),
    timestamp: DateTime.parse(data['timestamp']),
    note: data['note'] as String?,
  );
}
