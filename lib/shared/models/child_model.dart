import '../../core/constants/app_constants.dart';

/// Who this person is in the household. Drives AI tone, tracking types,
/// consult specialties, and UI copy.
///
/// `self` is the account owner. All other roles describe family members
/// added by the owner. `child` is the default so legacy data (pre-family-
/// expansion) continues to deserialize correctly without migration.
enum MemberRole {
  self,
  child,
  partner,
  mother,
  father,
  grandmother,
  grandfather,
  sibling,
  uncleAunt,
  other,
}

extension MemberRoleX on MemberRole {
  bool get isChild => this == MemberRole.child;
  bool get isAdult => !isChild;
}

/// A member of the user's household — baby, toddler, the account owner,
/// a partner, a parent/grandparent, or anyone else whose health the
/// account owner cares about. Previously called `Child`; the old name
/// is preserved as a typedef for backward compatibility.
class HouseholdMember {
  final String id;
  final String name;
  final DateTime? birthDate;
  final DateTime? dueDate;
  final String? gender;

  /// Optional for adult members (who don't have a pregnancy/newborn/toddler
  /// lifecycle). Required for children; defaults to newborn on legacy data.
  final ParentingStage? stage;

  final MemberRole role;

  /// Free-text tags like 'diabetes', 'hypertension', 'asthma'. Feeds the
  /// AI system prompt so Claude knows what the person is managing.
  final List<String> conditions;

  /// Free-text medication list. Feeds AI context + adult tracking ("did
  /// you take your meds today?").
  final List<String> medications;

  const HouseholdMember({
    required this.id,
    required this.name,
    this.birthDate,
    this.dueDate,
    this.gender,
    this.stage,
    this.role = MemberRole.child,
    this.conditions = const [],
    this.medications = const [],
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

  int? get ageYears {
    final days = ageDays;
    if (days == null) return null;
    return (days / 365.25).floor();
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

  HouseholdMember copyWith({
    String? name,
    DateTime? birthDate,
    DateTime? dueDate,
    String? gender,
    ParentingStage? stage,
    MemberRole? role,
    List<String>? conditions,
    List<String>? medications,
  }) {
    return HouseholdMember(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      dueDate: dueDate ?? this.dueDate,
      gender: gender ?? this.gender,
      stage: stage ?? this.stage,
      role: role ?? this.role,
      conditions: conditions ?? this.conditions,
      medications: medications ?? this.medications,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'gender': gender,
      'stage': stage?.name,
      'role': role.name,
      'conditions': conditions,
      'medications': medications,
    };
  }

  factory HouseholdMember.fromFirestore(Map<String, dynamic> data) {
    return HouseholdMember(
      id: data['id'] as String,
      name: data['name'] as String,
      birthDate: data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      gender: data['gender'] as String?,
      stage: data['stage'] == null
          ? null
          : ParentingStage.values.firstWhere(
              (s) => s.name == data['stage'],
              orElse: () => ParentingStage.newborn,
            ),
      role: MemberRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => MemberRole.child,
      ),
      conditions: (data['conditions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      medications: (data['medications'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

/// Backward-compatible alias. Old code still using `Child` continues to
/// resolve to `HouseholdMember` with zero callsite changes.
typedef Child = HouseholdMember;
