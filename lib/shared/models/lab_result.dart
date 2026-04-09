import '../../core/l10n/content_localizations.dart';

enum LabValueStatus { normal, borderline, outOfRange }

class LabValue {
  final L3 testName;
  final double value;
  final String unit;
  final double refLow;
  final double refHigh;
  final L3 explanation;

  const LabValue({
    required this.testName,
    required this.value,
    required this.unit,
    required this.refLow,
    required this.refHigh,
    required this.explanation,
  });

  LabValueStatus get status {
    if (value >= refLow && value <= refHigh) return LabValueStatus.normal;
    final margin = (refHigh - refLow) * 0.1;
    if (value >= refLow - margin && value <= refHigh + margin) return LabValueStatus.borderline;
    return LabValueStatus.outOfRange;
  }

  bool get isHigh => value > refHigh;
  bool get isLow => value < refLow;

  String get refRangeFormatted => '$refLow - $refHigh $unit';

  Map<String, dynamic> toFirestore() => {
    'testName': {'en': testName.en, 'ru': testName.ru, 'ky': testName.ky},
    'value': value,
    'unit': unit,
    'refLow': refLow,
    'refHigh': refHigh,
    'explanation': {'en': explanation.en, 'ru': explanation.ru, 'ky': explanation.ky},
  };

  factory LabValue.fromFirestore(Map<String, dynamic> data) {
    final tn = data['testName'] as Map<String, dynamic>;
    final ex = data['explanation'] as Map<String, dynamic>;
    return LabValue(
      testName: L3(en: tn['en'] ?? '', ru: tn['ru'] ?? '', ky: tn['ky'] ?? ''),
      value: (data['value'] as num).toDouble(),
      unit: data['unit'] as String,
      refLow: (data['refLow'] as num).toDouble(),
      refHigh: (data['refHigh'] as num).toDouble(),
      explanation: L3(en: ex['en'] ?? '', ru: ex['ru'] ?? '', ky: ex['ky'] ?? ''),
    );
  }
}

class LabResult {
  final String id;
  final String childId;
  final String childName;
  final DateTime testDate;
  final String labName;
  final List<LabValue> values;
  final L3 doctorSummary;
  final DateTime createdAt;
  final List<String> attachmentUrls; // PDFs, images, scanned lab results
  final String? sourceUrl; // Original lab result URL (e.g., IntelMed link)

  const LabResult({
    required this.id,
    required this.childId,
    required this.childName,
    required this.testDate,
    required this.labName,
    required this.values,
    required this.doctorSummary,
    required this.createdAt,
    this.attachmentUrls = const [],
    this.sourceUrl,
  });

  int get normalCount => values.where((v) => v.status == LabValueStatus.normal).length;
  int get borderlineCount => values.where((v) => v.status == LabValueStatus.borderline).length;
  int get outOfRangeCount => values.where((v) => v.status == LabValueStatus.outOfRange).length;

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'childId': childId,
    'childName': childName,
    'testDate': testDate.toIso8601String(),
    'labName': labName,
    'values': values.map((v) => v.toFirestore()).toList(),
    'doctorSummary': {'en': doctorSummary.en, 'ru': doctorSummary.ru, 'ky': doctorSummary.ky},
    'createdAt': createdAt.toIso8601String(),
    'attachmentUrls': attachmentUrls,
    'sourceUrl': sourceUrl,
  };

  factory LabResult.fromFirestore(Map<String, dynamic> data) {
    final ds = data['doctorSummary'] as Map<String, dynamic>;
    return LabResult(
      id: data['id'] as String,
      childId: data['childId'] as String,
      childName: data['childName'] as String,
      testDate: DateTime.parse(data['testDate']),
      labName: data['labName'] as String,
      values: (data['values'] as List).map((v) => LabValue.fromFirestore(v as Map<String, dynamic>)).toList(),
      doctorSummary: L3(en: ds['en'] ?? '', ru: ds['ru'] ?? '', ky: ds['ky'] ?? ''),
      createdAt: DateTime.parse(data['createdAt']),
      attachmentUrls: (data['attachmentUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      sourceUrl: data['sourceUrl'] as String?,
    );
  }
}

/// Medical disclaimer — shown on every lab screen
const labDisclaimer = L3(
  en: 'This is not medical advice. Lab result interpretation is for informational purposes only. Always consult a qualified healthcare provider for diagnosis and treatment.',
  ru: 'Это не является медицинской консультацией. Интерпретация результатов анализов носит исключительно информационный характер. Всегда обращайтесь к квалифицированному врачу для диагностики и лечения.',
  ky: 'Бул медициналык кеңеш эмес. Анализ жыйынтыктарын чечмелөө маалыматтык мүнөздө гана. Диагноз жана дарылоо үчүн дайыма квалификациялуу врачка кайрылыңыз.',
);
