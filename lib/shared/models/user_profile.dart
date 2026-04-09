import '../../core/constants/app_constants.dart';
import 'child_model.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final ParentingStage stage;
  final DateTime? dueDate;
  final DateTime? babyBirthDate;
  final String? babyName;
  final String? partnerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Child> children;
  final String? selectedChildId;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.stage,
    this.dueDate,
    this.babyBirthDate,
    this.babyName,
    this.partnerName,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
    this.selectedChildId,
  });

  /// The currently selected child, or the first child if none selected
  Child? get selectedChild {
    if (children.isEmpty) return null;
    if (selectedChildId != null) {
      final match = children.where((c) => c.id == selectedChildId);
      if (match.isNotEmpty) return match.first;
    }
    return children.first;
  }

  /// Current pregnancy week (1-42) based on due date
  int? get currentWeek {
    if (dueDate == null) return null;
    final now = DateTime.now();
    // Pregnancy is 40 weeks (280 days) from LMP
    final lmp = dueDate!.subtract(const Duration(days: 280));
    final daysSinceLmp = now.difference(lmp).inDays;
    final week = (daysSinceLmp / 7).ceil();
    return week.clamp(1, 42);
  }

  /// Days remaining until due date
  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Trimester (1, 2, or 3)
  int? get trimester {
    final week = currentWeek;
    if (week == null) return null;
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  /// Baby's age in days (for newborn/toddler stage)
  int? get babyAgeDays {
    if (babyBirthDate == null) return null;
    return DateTime.now().difference(babyBirthDate!).inDays;
  }

  /// Baby's age in months
  int? get babyAgeMonths {
    final days = babyAgeDays;
    if (days == null) return null;
    return (days / 30.44).floor();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'stage': stage.name,
      'dueDate': dueDate?.toIso8601String(),
      'babyBirthDate': babyBirthDate?.toIso8601String(),
      'babyName': babyName,
      'partnerName': partnerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'children': children.map((c) => c.toFirestore()).toList(),
      'selectedChildId': selectedChildId,
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoUrl: data['photoUrl'] as String?,
      stage: ParentingStage.values.firstWhere(
        (s) => s.name == data['stage'],
        orElse: () => ParentingStage.pregnant,
      ),
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      babyBirthDate: data['babyBirthDate'] != null
          ? DateTime.parse(data['babyBirthDate'])
          : null,
      babyName: data['babyName'] as String?,
      partnerName: data['partnerName'] as String?,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      children: (data['children'] as List<dynamic>?)
              ?.map((c) => Child.fromFirestore(c as Map<String, dynamic>))
              .toList() ??
          [],
      selectedChildId: data['selectedChildId'] as String?,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    ParentingStage? stage,
    DateTime? dueDate,
    DateTime? babyBirthDate,
    String? babyName,
    String? partnerName,
    List<Child>? children,
    String? selectedChildId,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      stage: stage ?? this.stage,
      dueDate: dueDate ?? this.dueDate,
      babyBirthDate: babyBirthDate ?? this.babyBirthDate,
      babyName: babyName ?? this.babyName,
      partnerName: partnerName ?? this.partnerName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      children: children ?? this.children,
      selectedChildId: selectedChildId ?? this.selectedChildId,
    );
  }
}
