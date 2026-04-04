enum TrackingType {
  weight,
  water,
  sleep,
  kicks,
  mood,
  symptoms,
  bloodPressure,
  feeding,
  diaper,
  medication,
  contraction,
}

class TrackingEntry {
  final String id;
  final String userId;
  final TrackingType type;
  final double? value;
  final String? unit;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final DateTime createdAt;

  const TrackingEntry({
    required this.id,
    required this.userId,
    required this.type,
    this.value,
    this.unit,
    this.notes,
    this.metadata,
    required this.timestamp,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'value': value,
      'unit': unit,
      'notes': notes,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TrackingEntry.fromFirestore(Map<String, dynamic> data) {
    return TrackingEntry(
      id: data['id'] as String,
      userId: data['userId'] as String,
      type: TrackingType.values.firstWhere(
        (t) => t.name == data['type'],
      ),
      value: (data['value'] as num?)?.toDouble(),
      unit: data['unit'] as String?,
      notes: data['notes'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(data['timestamp']),
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}

/// Kick counting session
class KickSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<DateTime> kicks;

  const KickSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.kicks,
  });

  int get kickCount => kicks.length;

  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isComplete => endTime != null;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'kicks': kicks.map((k) => k.toIso8601String()).toList(),
    };
  }

  factory KickSession.fromFirestore(Map<String, dynamic> data) {
    return KickSession(
      id: data['id'] as String,
      userId: data['userId'] as String,
      startTime: DateTime.parse(data['startTime']),
      endTime:
          data['endTime'] != null ? DateTime.parse(data['endTime']) : null,
      kicks: (data['kicks'] as List)
          .map((k) => DateTime.parse(k as String))
          .toList(),
    );
  }

  KickSession addKick() {
    return KickSession(
      id: id,
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      kicks: [...kicks, DateTime.now()],
    );
  }

  KickSession complete() {
    return KickSession(
      id: id,
      userId: userId,
      startTime: startTime,
      endTime: DateTime.now(),
      kicks: kicks,
    );
  }
}

/// Contraction timer entry
class ContractionEntry {
  final DateTime startTime;
  final DateTime? endTime;

  const ContractionEntry({required this.startTime, this.endTime});

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}
