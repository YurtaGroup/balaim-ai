import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/content_localizations.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../../shared/models/child_model.dart';

final boxServiceProvider = Provider<BoxService>((ref) => BoxService());

/// Shape the backend expects for a fallback member snapshot when
/// the user's Firestore household record hasn't been synced yet.
Map<String, Object?> _memberToJson(HouseholdMember m) => {
      'id': m.id,
      'name': m.name,
      'role': m.role.name,
      if (m.birthDate != null) 'birthDate': m.birthDate!.toIso8601String(),
      if (m.conditions.isNotEmpty) 'conditions': m.conditions,
    };

enum BoxTier { green, yellow, orange, red }

enum BoxReadingType { bloodPressure, bloodGlucose, dipstick, temperature, weight }

class BoxClassification {
  final BoxTier tier;
  final String ruleId;
  final String protocolVersion;
  final L3 reason;
  final String? noticeId;
  final String? auditId;
  final String? emergencyId;
  final BoxEmergency? emergency;

  const BoxClassification({
    required this.tier,
    required this.ruleId,
    required this.protocolVersion,
    required this.reason,
    this.noticeId,
    this.auditId,
    this.emergencyId,
    this.emergency,
  });

  static BoxTier _parseTier(String? s) {
    switch (s) {
      case 'red':
        return BoxTier.red;
      case 'orange':
        return BoxTier.orange;
      case 'yellow':
        return BoxTier.yellow;
      default:
        return BoxTier.green;
    }
  }

  static L3 _parseL3(Object? raw) {
    if (raw is Map) {
      return L3(
        en: (raw['en'] as String?) ?? '',
        ru: (raw['ru'] as String?) ?? '',
        ky: (raw['ky'] as String?) ?? '',
      );
    }
    return const L3(en: '', ru: '', ky: '');
  }

  factory BoxClassification.fromJson(Map<Object?, Object?> j) {
    final emergencyRaw = j['emergency'];
    return BoxClassification(
      tier: _parseTier(j['tier'] as String?),
      ruleId: (j['ruleId'] as String?) ?? '',
      protocolVersion: (j['protocolVersion'] as String?) ?? '',
      reason: _parseL3(j['reason']),
      noticeId: j['noticeId'] as String?,
      auditId: j['auditId'] as String?,
      emergencyId: j['emergencyId'] as String?,
      emergency: emergencyRaw is Map
          ? BoxEmergency.fromJson(emergencyRaw.cast<Object?, Object?>())
          : null,
    );
  }
}

class BoxEmergency {
  final String ruleId;
  final L3 instruction;
  final Map<String, String> callNumbers; // { kg, us, ru }

  const BoxEmergency({
    required this.ruleId,
    required this.instruction,
    required this.callNumbers,
  });

  factory BoxEmergency.fromJson(Map<Object?, Object?> j) {
    final nums = (j['callNumbers'] as Map?) ?? const {};
    return BoxEmergency(
      ruleId: (j['ruleId'] as String?) ?? '',
      instruction: BoxClassification._parseL3(j['instruction']),
      callNumbers: {
        'kg': (nums['kg'] as String?) ?? '103',
        'us': (nums['us'] as String?) ?? '911',
        'ru': (nums['ru'] as String?) ?? '103',
      },
    );
  }
}

class BoxService {
  Future<BoxClassification> submitBloodPressure({
    required HouseholdMember member,
    required int systolic,
    required int diastolic,
    int? heartRate,
    List<String> symptoms = const [],
    int? pregnancyWeek,
  }) {
    return _submit(member, {
      'memberId': member.id,
      'type': 'bloodPressure',
      'timestamp': DateTime.now().toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      if (heartRate != null) 'heartRate': heartRate,
      if (symptoms.isNotEmpty) 'symptoms': symptoms,
      if (pregnancyWeek != null) 'pregnancyWeek': pregnancyWeek,
    });
  }

  Future<BoxClassification> submitGlucose({
    required HouseholdMember member,
    required int glucoseMgDl,
    required bool fasting,
    List<String> symptoms = const [],
  }) {
    return _submit(member, {
      'memberId': member.id,
      'type': 'bloodGlucose',
      'timestamp': DateTime.now().toIso8601String(),
      'glucose': glucoseMgDl,
      'fasting': fasting,
      if (symptoms.isNotEmpty) 'symptoms': symptoms,
    });
  }

  Future<BoxClassification> submitTemperature({
    required HouseholdMember member,
    required double tempC,
    List<String> symptoms = const [],
  }) {
    return _submit(member, {
      'memberId': member.id,
      'type': 'temperature',
      'timestamp': DateTime.now().toIso8601String(),
      'tempC': tempC,
      if (symptoms.isNotEmpty) 'symptoms': symptoms,
    });
  }

  Future<BoxClassification> _submit(
    HouseholdMember member,
    Map<String, Object?> reading,
  ) async {
    if (!isFirebaseInitialized) {
      throw StateError('Firebase not initialized — Balam Box requires sign-in');
    }
    final result = await FirebaseFunctions.instance
        .httpsCallable('submitBoxReading')
        .call({
      'reading': reading,
      // Fallback snapshot — server uses this if users/{uid}.members
      // hasn't been synced with this member yet, and persists it for
      // future calls.
      'member': _memberToJson(member),
    });
    final data = (result.data as Map).cast<Object?, Object?>();
    return BoxClassification.fromJson(data);
  }
}
