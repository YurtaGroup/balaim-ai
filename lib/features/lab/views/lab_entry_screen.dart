import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/lab_result.dart';
import '../../journey/providers/journey_provider.dart';
import 'lab_analysis_screen.dart';

/// Lab result entry screen — parent manually enters test values.
/// Pre-filled dropdown with common pediatric blood tests + reference ranges for toddlers (1-3 years).
class LabEntryScreen extends ConsumerStatefulWidget {
  const LabEntryScreen({super.key});

  @override
  ConsumerState<LabEntryScreen> createState() => _LabEntryScreenState();
}

class _LabEntryScreenState extends ConsumerState<LabEntryScreen> {
  final _labNameController = TextEditingController(text: 'Бонецкий Лаборатория');
  final _sourceUrlController = TextEditingController();
  DateTime _testDate = DateTime.now();
  final List<_EntryRow> _entries = [_EntryRow()];
  final List<File> _attachedFiles = [];
  final List<String> _uploadedUrls = [];

  @override
  void dispose() {
    _labNameController.dispose();
    _sourceUrlController.dispose();
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final childName = profile.selectedChild?.name ?? profile.babyName ?? 'Child';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(const L3(en: 'Enter Lab Results', ru: 'Ввести анализы', ky: 'Анализ киргизүү').of(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Disclaimer ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_information, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    labDisclaimer.of(context),
                    style: const TextStyle(fontSize: 11, height: 1.4, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Patient & Lab info ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.child_care, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(childName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _labNameController,
                  decoration: InputDecoration(
                    labelText: const L3(en: 'Lab name', ru: 'Название лаборатории', ky: 'Лаборатория аты').of(context),
                    prefixIcon: const Icon(Icons.local_hospital_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _testDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _testDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text('${_testDate.day}.${_testDate.month.toString().padLeft(2, '0')}.${_testDate.year}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Attachments: Original lab result files ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_file, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      const L3(en: 'Attach Original Results', ru: 'Прикрепить оригинал', ky: 'Оригиналды тиркөө').of(context),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  const L3(en: 'Photo, PDF, or link to your lab results', ru: 'Фото, PDF или ссылка на результаты', ky: 'Сүрөт, PDF же анализ шилтемеси').of(context),
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const SizedBox(height: 12),

                // Source URL input
                TextField(
                  controller: _sourceUrlController,
                  decoration: InputDecoration(
                    labelText: const L3(en: 'Lab result URL (optional)', ru: 'Ссылка на анализ (опционально)', ky: 'Анализ шилтемеси (кошумча)').of(context),
                    hintText: 'https://...',
                    prefixIcon: const Icon(Icons.link, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),

                // File upload buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final file = await StorageService().pickFromCamera();
                          if (file != null) setState(() => _attachedFiles.add(file));
                        },
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text(const L3(en: 'Camera', ru: 'Камера', ky: 'Камера').of(context)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final file = await StorageService().pickFromGallery();
                          if (file != null) setState(() => _attachedFiles.add(file));
                        },
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: Text(const L3(en: 'Gallery', ru: 'Галерея', ky: 'Галерея').of(context)),
                      ),
                    ),
                  ],
                ),

                // Show attached files
                if (_attachedFiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachedFiles.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(_attachedFiles[i], fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2, right: 2,
                              child: GestureDetector(
                                onTap: () => setState(() => _attachedFiles.removeAt(i)),
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Test entries ──
          Text(
            const L3(en: 'Test Results', ru: 'Результаты', ky: 'Жыйынтыктар').of(context),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...List.generate(_entries.length, (i) => _buildEntryRow(i)),

          // Add test button
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _entries.add(_EntryRow())),
            icon: const Icon(Icons.add, size: 18),
            label: Text(const L3(en: 'Add another test', ru: 'Добавить анализ', ky: 'Анализ кошуу').of(context)),
          ),
          const SizedBox(height: 24),

          // Analyze button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _analyze,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                const L3(en: 'Analyze Results', ru: 'Анализировать', ky: 'Анализдөө').of(context),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEntryRow(int index) {
    final entry = _entries[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<_TestTemplate>(
                    value: entry.selectedTest,
                    decoration: InputDecoration(
                      labelText: const L3(en: 'Test', ru: 'Тест', ky: 'Тест').of(context),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isExpanded: true,
                    items: _testTemplates.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name.of(context), style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    onChanged: (t) {
                      if (t != null) {
                        setState(() {
                          entry.selectedTest = t;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: entry.valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: const L3(en: 'Value', ru: 'Значение', ky: 'Маани').of(context),
                      suffixText: entry.selectedTest?.unit ?? '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                if (_entries.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                    onPressed: () => setState(() {
                      _entries[index].dispose();
                      _entries.removeAt(index);
                    }),
                  ),
              ],
            ),
            if (entry.selectedTest != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${const L3(en: 'Reference', ru: 'Норма', ky: 'Норма').of(context)}: ${entry.selectedTest!.refLow} - ${entry.selectedTest!.refHigh} ${entry.selectedTest!.unit}',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _analyze() async {
    final profile = ref.read(userProfileProvider);
    final child = profile.selectedChild;
    final childName = child?.name ?? profile.babyName ?? 'Child';
    final childId = child?.id ?? 'unknown';
    final labId = 'lab-${DateTime.now().millisecondsSinceEpoch}';

    // Upload attached files
    final uploadedAttachments = <String>[];
    for (var i = 0; i < _attachedFiles.length; i++) {
      final url = await StorageService().uploadFile(
        file: _attachedFiles[i],
        path: 'lab-results/$labId/attachment_$i.jpg',
      );
      if (url != null) uploadedAttachments.add(url);
    }

    if (!mounted) return;

    final values = <LabValue>[];
    for (final entry in _entries) {
      if (entry.selectedTest == null || entry.valueController.text.isEmpty) continue;
      final val = double.tryParse(entry.valueController.text);
      if (val == null) continue;
      final t = entry.selectedTest!;
      values.add(LabValue(
        testName: t.name,
        value: val,
        unit: t.unit,
        refLow: t.refLow,
        refHigh: t.refHigh,
        explanation: t.explanation,
      ));
    }

    if (values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(const L3(en: 'Please enter at least one test result', ru: 'Введите хотя бы один результат', ky: 'Кеминде бир жыйынтык киргизиңиз').of(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Generate summary
    final outOfRange = values.where((v) => v.status == LabValueStatus.outOfRange).length;
    final borderline = values.where((v) => v.status == LabValueStatus.borderline).length;
    final L3 summary;
    if (outOfRange == 0 && borderline == 0) {
      summary = const L3(
        en: 'All results are within normal range. Your child\'s blood work looks healthy.',
        ru: 'Все результаты в пределах нормы. Анализы вашего ребёнка выглядят здоровыми.',
        ky: 'Бардык жыйынтыктар нормалдуу диапазондо. Балаңыздын анализдери дени сак көрүнөт.',
      );
    } else if (outOfRange == 0) {
      summary = const L3(
        en: 'Most results are normal with some borderline values. Discuss with your pediatrician at your next visit.',
        ru: 'Большинство результатов в норме, некоторые пограничные. Обсудите с педиатром на следующем визите.',
        ky: 'Көпчүлүк жыйынтыктар нормалдуу, кээ бирлери чекте. Кийинки визитте педиатрыңыз менен талкуулаңыз.',
      );
    } else {
      summary = L3(
        en: '$outOfRange value(s) are outside normal range. Please show these results to your pediatrician.',
        ru: '$outOfRange показатель(ей) вне нормы. Пожалуйста, покажите эти результаты педиатру.',
        ky: '$outOfRange көрсөткүч нормадан тышкары. Бул жыйынтыктарды педиатрыңызга көрсөтүңүз.',
      );
    }

    final sourceUrl = _sourceUrlController.text.trim();
    final result = LabResult(
      id: labId,
      childId: childId,
      childName: childName,
      testDate: _testDate,
      labName: _labNameController.text,
      values: values,
      doctorSummary: summary,
      createdAt: DateTime.now(),
      attachmentUrls: uploadedAttachments,
      sourceUrl: sourceUrl.isNotEmpty ? sourceUrl : null,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LabAnalysisScreen(result: result)),
    );
  }
}

class _EntryRow {
  _TestTemplate? selectedTest;
  final valueController = TextEditingController();

  void dispose() {
    valueController.dispose();
  }
}

// ============================================================
// PEDIATRIC TEST TEMPLATES — Reference ranges for age 1-3 years
// ============================================================

class _TestTemplate {
  final L3 name;
  final String unit;
  final double refLow;
  final double refHigh;
  final L3 explanation;

  const _TestTemplate({
    required this.name,
    required this.unit,
    required this.refLow,
    required this.refHigh,
    required this.explanation,
  });
}

final _testTemplates = <_TestTemplate>[
  _TestTemplate(
    name: const L3(en: 'Hemoglobin', ru: 'Гемоглобин', ky: 'Гемоглобин'),
    unit: 'g/L', refLow: 110, refHigh: 140,
    explanation: const L3(en: 'Carries oxygen in the blood. Low = possible anemia.', ru: 'Переносит кислород. Низкий = возможна анемия.', ky: 'Канда кычкылтек ташыйт. Төмөн = анемия мүмкүн.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Red Blood Cells (RBC)', ru: 'Эритроциты (RBC)', ky: 'Эритроциттер (RBC)'),
    unit: 'x10¹²/L', refLow: 3.7, refHigh: 4.9,
    explanation: const L3(en: 'Cells that carry oxygen. Normal = healthy oxygen delivery.', ru: 'Клетки, переносящие кислород. Норма = здоровая доставка кислорода.', ky: 'Кычкылтек ташыган клеткалар. Нормада = дени сак кычкылтек жеткирүү.'),
  ),
  _TestTemplate(
    name: const L3(en: 'White Blood Cells (WBC)', ru: 'Лейкоциты (WBC)', ky: 'Лейкоциттер (WBC)'),
    unit: 'x10⁹/L', refLow: 5.5, refHigh: 14,
    explanation: const L3(en: 'Immune cells. High = fighting infection. Low = weakened immunity.', ru: 'Иммунные клетки. Высокие = борьба с инфекцией. Низкие = ослабленный иммунитет.', ky: 'Иммундук клеткалар. Жогору = инфекцияга каршы күрөш. Төмөн = алсыз иммунитет.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Platelets (PLT)', ru: 'Тромбоциты (PLT)', ky: 'Тромбоциттер (PLT)'),
    unit: 'x10⁹/L', refLow: 220, refHigh: 422,
    explanation: const L3(en: 'Help blood clot. High after illness is common in toddlers.', ru: 'Помогают свёртываться крови. Повышение после болезни частое у малышей.', ky: 'Кандын уюшуна жардам берет. Оорудан кийин жогорулашы балдарда көп кездешет.'),
  ),
  _TestTemplate(
    name: const L3(en: 'MCV', ru: 'MCV (Объём эритроцитов)', ky: 'MCV (Эритроцит өлчөмү)'),
    unit: 'fL', refLow: 73, refHigh: 85,
    explanation: const L3(en: 'Average red cell size. Abnormal may indicate iron deficiency or vitamin B12 issues.', ru: 'Средний размер эритроцита. Отклонение может указывать на дефицит железа или B12.', ky: 'Орточо эритроцит өлчөмү. Четтөө темир же B12 жетишсиздигин көрсөтүшү мүмкүн.'),
  ),
  _TestTemplate(
    name: const L3(en: 'MCH', ru: 'MCH', ky: 'MCH'),
    unit: 'pg', refLow: 25, refHigh: 30,
    explanation: const L3(en: 'Hemoglobin per red cell. Normal = cells carrying enough oxygen.', ru: 'Гемоглобин на эритроцит. Норма = клетки несут достаточно кислорода.', ky: 'Эритроциттеги гемоглобин. Нормада = клеткалар жетиштүү кычкылтек ташыйт.'),
  ),
  _TestTemplate(
    name: const L3(en: 'MCHC', ru: 'MCHC', ky: 'MCHC'),
    unit: 'g/dL', refLow: 32, refHigh: 37,
    explanation: const L3(en: 'Hemoglobin concentration in red cells.', ru: 'Концентрация гемоглобина в эритроцитах.', ky: 'Эритроциттердеги гемоглобин концентрациясы.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Hematocrit (HCT)', ru: 'Гематокрит (HCT)', ky: 'Гематокрит (HCT)'),
    unit: '%', refLow: 32, refHigh: 42,
    explanation: const L3(en: 'Percentage of blood that is red cells.', ru: 'Процент крови, занятый эритроцитами.', ky: 'Кандын эритроциттер ээлеген пайызы.'),
  ),
  _TestTemplate(
    name: const L3(en: 'RDW', ru: 'RDW', ky: 'RDW'),
    unit: '%', refLow: 11.5, refHigh: 14.5,
    explanation: const L3(en: 'Red cell size variation. High may suggest iron deficiency.', ru: 'Вариация размеров эритроцитов. Высокий может указывать на дефицит железа.', ky: 'Эритроцит өлчөмүнүн вариациясы. Жогору темир жетишсиздигин көрсөтүшү мүмкүн.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Iron (Serum)', ru: 'Железо (сыворотка)', ky: 'Темир (сыворотка)'),
    unit: 'µmol/L', refLow: 6.6, refHigh: 26,
    explanation: const L3(en: 'Iron level in blood. Low may indicate iron deficiency.', ru: 'Уровень железа в крови. Низкий может указывать на дефицит.', ky: 'Кандагы темир деңгээли. Төмөн темир жетишсиздигин көрсөтүшү мүмкүн.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Ferritin', ru: 'Ферритин', ky: 'Ферритин'),
    unit: 'ng/mL', refLow: 7, refHigh: 140,
    explanation: const L3(en: 'Iron reserves. Better indicator of iron status than serum iron.', ru: 'Запасы железа. Лучший показатель статуса железа, чем сывороточное.', ky: 'Темир запасы. Сыворотка темирине караганда жакшыраак көрсөткүч.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Reticulocytes', ru: 'Ретикулоциты', ky: 'Ретикулоциттер'),
    unit: '%', refLow: 0.5, refHigh: 2.0,
    explanation: const L3(en: 'Young red blood cells. Shows bone marrow activity.', ru: 'Молодые эритроциты. Показывает активность костного мозга.', ky: 'Жаш эритроциттер. Сөөк чучугу активдүүлүгүн көрсөтөт.'),
  ),
  _TestTemplate(
    name: const L3(en: 'ESR', ru: 'СОЭ', ky: 'СОЭ'),
    unit: 'mm/hr', refLow: 2, refHigh: 10,
    explanation: const L3(en: 'General inflammation marker. High = body is fighting something.', ru: 'Общий маркер воспаления. Высокий = организм с чем-то борется.', ky: 'Жалпы сезгенүү белгиси. Жогору = организм бир нерсе менен күрөшүүдө.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Neutrophils (%)', ru: 'Нейтрофилы (%)', ky: 'Нейтрофилдер (%)'),
    unit: '%', refLow: 32, refHigh: 55,
    explanation: const L3(en: 'Fight bacterial infections. Low in viral infections (lymphocytes take over).', ru: 'Борются с бактериями. Снижены при вирусных инфекциях.', ky: 'Бактерияларга каршы күрөшөт. Вирустук инфекцияларда төмөндөйт.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Lymphocytes (%)', ru: 'Лимфоциты (%)', ky: 'Лимфоциттер (%)'),
    unit: '%', refLow: 33, refHigh: 55,
    explanation: const L3(en: 'Fight viral infections. Naturally higher in toddlers.', ru: 'Борются с вирусами. Естественно повышены у малышей.', ky: 'Вирустарга каршы күрөшөт. Балдарда табигый түрдө жогору.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Eosinophils (%)', ru: 'Эозинофилы (%)', ky: 'Эозинофилдер (%)'),
    unit: '%', refLow: 1, refHigh: 6,
    explanation: const L3(en: 'Related to allergies and parasites.', ru: 'Связаны с аллергиями и паразитами.', ky: 'Аллергия жана мителер менен байланыштуу.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Basophils (%)', ru: 'Базофилы (%)', ky: 'Базофилдер (%)'),
    unit: '%', refLow: 0, refHigh: 1,
    explanation: const L3(en: 'Rare white blood cell. Usually not significant.', ru: 'Редкий лейкоцит. Обычно не имеет значения.', ky: 'Сейрек лейкоцит. Көбүнчө маанилүү эмес.'),
  ),
  _TestTemplate(
    name: const L3(en: 'Monocytes (%)', ru: 'Моноциты (%)', ky: 'Моноциттер (%)'),
    unit: '%', refLow: 3, refHigh: 9,
    explanation: const L3(en: 'Help clean up after infections.', ru: 'Помогают восстановиться после инфекций.', ky: 'Инфекциялардан кийин тазалоого жардам берет.'),
  ),
];
