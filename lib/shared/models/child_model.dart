import '../../core/constants/app_constants.dart';

/// A child in the user's family.
class Child {
  final String id;
  final String name;
  final DateTime? birthDate;
  final DateTime? dueDate;
  final String? gender;
  final ParentingStage stage;

  const Child({
    required this.id,
    required this.name,
    this.birthDate,
    this.dueDate,
    this.gender,
    required this.stage,
  });

  int? get ageDays {
    if (birthDate == null) return null;
    return DateTime.now().difference(birthDate!).inDays;
  }

  int? get ageMonths {
    final days = ageDays;
    if (days == null) return null;
    return (days / 30.44).floor();
  }

  int? get currentWeek {
    if (dueDate == null) return null;
    final lmp = dueDate!.subtract(const Duration(days: 280));
    final daysSinceLmp = DateTime.now().difference(lmp).inDays;
    return (daysSinceLmp / 7).ceil().clamp(1, 42);
  }

  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  Child copyWith({
    String? name,
    DateTime? birthDate,
    DateTime? dueDate,
    String? gender,
    ParentingStage? stage,
  }) {
    return Child(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      dueDate: dueDate ?? this.dueDate,
      gender: gender ?? this.gender,
      stage: stage ?? this.stage,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'gender': gender,
      'stage': stage.name,
    };
  }

  factory Child.fromFirestore(Map<String, dynamic> data) {
    return Child(
      id: data['id'] as String,
      name: data['name'] as String,
      birthDate: data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      gender: data['gender'] as String?,
      stage: ParentingStage.values.firstWhere(
        (s) => s.name == data['stage'],
        orElse: () => ParentingStage.newborn,
      ),
    );
  }
}
