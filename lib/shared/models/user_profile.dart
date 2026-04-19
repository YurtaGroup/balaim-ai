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

  /// All members of the household (baby, self, partner, grandparents...).
  /// Previously `children: List<Child>`; legacy name preserved as a getter
  /// for backward compat.
  final List<HouseholdMember> members;

  /// Currently-active member for tracking / AI / labs.
  final String? selectedMemberId;

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
    this.members = const [],
    this.selectedMemberId,
  });

  // ── Backward-compatible aliases ────────────────────────────────────
  // Existing code referenced `children`, `selectedChildId`, `selectedChild`.
  // These keep working while we migrate callsites gradually.

  List<HouseholdMember> get children => members;
  String? get selectedChildId => selectedMemberId;

  /// The currently selected member, or the first child member if none
  /// selected. Prefers child over self so parenting UX still leads.
  HouseholdMember? get selectedMember {
    if (members.isEmpty) return null;
    if (selectedMemberId != null) {
      final match = members.where((m) => m.id == selectedMemberId);
      if (match.isNotEmpty) return match.first;
    }
    final firstChild = members.where((m) => m.role == MemberRole.child);
    if (firstChild.isNotEmpty) return firstChild.first;
    return members.first;
  }

  HouseholdMember? get selectedChild => selectedMember;

  // ── Owner-level pregnancy helpers (unchanged) ─────────────────────

  int? get currentWeek {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final lmp = dueDate!.subtract(const Duration(days: 280));
    final daysSinceLmp = now.difference(lmp).inDays;
    final week = (daysSinceLmp / 7).ceil();
    return week.clamp(1, 42);
  }

  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  int? get trimester {
    final week = currentWeek;
    if (week == null) return null;
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  int? get babyAgeDays {
    if (babyBirthDate == null) return null;
    return DateTime.now().difference(babyBirthDate!).inDays;
  }

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
      // Write to `members` going forward. Also write legacy `children` key
      // so older clients keep reading the account correctly for one release.
      'members': members.map((m) => m.toFirestore()).toList(),
      'children': members.map((m) => m.toFirestore()).toList(),
      'selectedMemberId': selectedMemberId,
      'selectedChildId': selectedMemberId,
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    // Dual-read: prefer `members`, fall back to legacy `children`.
    final rawMembers = (data['members'] as List<dynamic>?) ??
        (data['children'] as List<dynamic>?) ??
        const [];

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
      members: rawMembers
          .map((m) => HouseholdMember.fromFirestore(m as Map<String, dynamic>))
          .toList(),
      selectedMemberId: (data['selectedMemberId'] ?? data['selectedChildId']) as String?,
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
    List<HouseholdMember>? members,
    // Legacy alias — existing callers pass `children:`; accept and forward.
    List<HouseholdMember>? children,
    String? selectedMemberId,
    // Legacy alias — existing callers pass `selectedChildId:`.
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
      members: members ?? children ?? this.members,
      selectedMemberId: selectedMemberId ?? selectedChildId ?? this.selectedMemberId,
    );
  }

  /// If the household doesn't yet contain a `self` member, prepend one
  /// derived from the account owner's profile. Called lazily on app
  /// start so legacy accounts auto-gain a Self member without manual
  /// migration.
  UserProfile withSelfIfMissing() {
    if (members.any((m) => m.role == MemberRole.self)) return this;
    final self = HouseholdMember(
      id: 'self-$uid',
      name: displayName,
      role: MemberRole.self,
      stage: null,
    );
    return copyWith(members: [self, ...members]);
  }
}
