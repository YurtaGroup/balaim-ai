import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/lab_result.dart';
import 'lab_entry_screen.dart';

/// Beautiful, mom-friendly lab result analysis screen.
/// Color-coded, expandable explanations, 3 languages, medical disclaimer.
class LabAnalysisScreen extends StatelessWidget {
  final LabResult? result;

  const LabAnalysisScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    // Use provided result or demo data (Altair's real results)
    final data = result ?? _altairDemoResult();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).labResults),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LabEntryScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Medical Disclaimer ──
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
                const Icon(Icons.medical_information, color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    labDisclaimer.of(context),
                    style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Patient Info ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.child_care, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.childName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('${data.labName} · ${data.testDate.day}.${data.testDate.month.toString().padLeft(2, '0')}.${data.testDate.year}',
                          style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Doctor's Summary ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.outOfRangeCount > 0
                    ? [AppColors.warning.withValues(alpha: 0.08), AppColors.warning.withValues(alpha: 0.04)]
                    : [AppColors.success.withValues(alpha: 0.08), AppColors.success.withValues(alpha: 0.04)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: data.outOfRangeCount > 0
                    ? AppColors.warning.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services,
                        color: data.outOfRangeCount > 0 ? AppColors.warning : AppColors.success, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      const L3(en: 'Assessment', ru: 'Заключение', ky: 'Корутунду').of(context),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  data.doctorSummary.of(context),
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Status Overview Bar ──
          Row(
            children: [
              _StatusChip(
                count: data.normalCount,
                label: const L3(en: 'Normal', ru: 'Норма', ky: 'Нормалдуу').of(context),
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatusChip(
                count: data.borderlineCount,
                label: const L3(en: 'Borderline', ru: 'Погранично', ky: 'Чекте').of(context),
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatusChip(
                count: data.outOfRangeCount,
                label: const L3(en: 'Flagged', ru: 'Отклонение', ky: 'Белгиленген').of(context),
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Original Lab Result (URL / attachments) ──
          if (data.sourceUrl != null || data.attachmentUrls.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        const L3(en: 'Original Lab Result', ru: 'Оригинал анализа', ky: 'Анализдын оригиналы').of(context),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  if (data.sourceUrl != null) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _openUrl(data.sourceUrl!),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.open_in_new, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    const L3(en: 'View original lab result', ru: 'Открыть оригинал анализа', ky: 'Анализдын оригиналын ачуу').of(context),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.secondary),
                                  ),
                                  Text(
                                    data.sourceUrl!,
                                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (data.attachmentUrls.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.attachmentUrls.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _openUrl(data.attachmentUrls[i]),
                            child: Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: data.attachmentUrls[i].startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        data.attachmentUrls[i],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.insert_drive_file, color: AppColors.textHint, size: 32),
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.insert_drive_file, color: AppColors.textHint, size: 32),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ── Individual Test Results ──
          ...data.values.map((v) => _LabValueCard(labValue: v)),

          const SizedBox(height: 16),

          // ── Share Button ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _share(context, data),
              icon: const Icon(Icons.share),
              label: Text(const L3(en: 'Share with Doctor', ru: 'Отправить врачу', ky: 'Врачка жөнөтүү').of(context)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _share(BuildContext context, LabResult data) {
    final buffer = StringBuffer();
    buffer.writeln('Lab Results — ${data.childName}');
    buffer.writeln('${data.labName} · ${data.testDate.day}.${data.testDate.month}.${data.testDate.year}');
    buffer.writeln('');
    for (final v in data.values) {
      final flag = v.status == LabValueStatus.normal ? '✅' : v.status == LabValueStatus.borderline ? '⚠️' : '🔴';
      buffer.writeln('$flag ${v.testName.en}: ${v.value} ${v.unit} (ref: ${v.refLow}-${v.refHigh})');
    }
    buffer.writeln('');
    buffer.writeln(labDisclaimer.en);
    Share.share(buffer.toString());
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatusChip({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _LabValueCard extends StatefulWidget {
  final LabValue labValue;
  const _LabValueCard({required this.labValue});

  @override
  State<_LabValueCard> createState() => _LabValueCardState();
}

class _LabValueCardState extends State<_LabValueCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.labValue;
    final color = switch (v.status) {
      LabValueStatus.normal => AppColors.success,
      LabValueStatus.borderline => AppColors.warning,
      LabValueStatus.outOfRange => AppColors.error,
    };
    final icon = switch (v.status) {
      LabValueStatus.normal => Icons.check_circle,
      LabValueStatus.borderline => Icons.warning_amber_rounded,
      LabValueStatus.outOfRange => Icons.error,
    };
    final statusLabel = switch (v.status) {
      LabValueStatus.normal => const L3(en: 'Normal', ru: 'Норма', ky: 'Нормалдуу'),
      LabValueStatus.borderline => const L3(en: 'Borderline', ru: 'Погранично', ky: 'Чекте'),
      LabValueStatus.outOfRange => v.isHigh
          ? const L3(en: 'High', ru: 'Повышен', ky: 'Жогору')
          : const L3(en: 'Low', ru: 'Понижен', ky: 'Төмөн'),
    };

    // Visual: how far the value is within or outside the range
    final rangeWidth = v.refHigh - v.refLow;
    final valuePosition = rangeWidth > 0 ? ((v.value - v.refLow) / rangeWidth).clamp(0.0, 1.0) : 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.testName.of(context), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(
                          '${v.refRangeFormatted} · ${statusLabel.of(context)}',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${v.value} ${v.unit}',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
                    ),
                  ),
                ],
              ),

              // Range bar visualization
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      // Background (full range)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Normal range (green zone)
                      FractionallySizedBox(
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.error.withValues(alpha: 0.3),
                                AppColors.success.withValues(alpha: 0.5),
                                AppColors.success.withValues(alpha: 0.5),
                                AppColors.error.withValues(alpha: 0.3),
                              ],
                              stops: const [0, 0.15, 0.85, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      // Value marker
                      Positioned(
                        left: (MediaQuery.of(context).size.width - 64) * valuePosition - 3,
                        child: Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable explanation
              if (_expanded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          v.explanation.of(context),
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Expand hint
              Center(
                child: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18, color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ALTAIR'S REAL LAB RESULTS — 09.04.2026, Бонецкий Лаборатория
// ============================================================

LabResult _altairDemoResult() {
  return LabResult(
    id: 'altair-lab-20260409',
    childId: 'child-demo-1',
    childName: 'Altair Mone',
    testDate: DateTime(2026, 4, 9),
    labName: 'Бонецкий Лаборатория',
    doctorSummary: const L3(
      en: 'Most results are within normal range for a 2-year-old boy. Platelets are elevated (503) and ESR is slightly high (14) — this is very common after a recent viral infection and usually resolves on its own in 4-6 weeks. Iron is borderline-low but ferritin (iron stores) is adequate at 29.2. No signs of anemia. Recommend a follow-up CBC in 4-6 weeks.',
      ru: 'Большинство показателей в пределах нормы для 2-летнего мальчика. Тромбоциты повышены (503) и СОЭ немного выше нормы (14) — это очень часто после недавней вирусной инфекции и обычно нормализуется за 4-6 недель. Железо на нижней границе, но ферритин (запасы железа) адекватный — 29,2. Признаков анемии нет. Рекомендуется повторный ОАК через 4-6 недель.',
      ky: 'Көпчүлүк көрсөткүчтөр 2 жаштагы бала үчүн нормалдуу диапазондо. Тромбоциттер жогорулаган (503) жана СОЭ бир аз жогору (14) — бул жакында вирустук инфекциядан кийин абдан көп кездешет жана 4-6 жумада өзүнөн өзү нормалдашат. Темир чектик-төмөн, бирок ферритин (темир запасы) 29,2де жетиштүү. Анемиянын белгилери жок. 4-6 жумадан кийин кайталоо ОАК сунушталат.',
    ),
    sourceUrl: 'https://clientapi.intelmed.kg/Service1.svc/R?p=fsEQTyHPWKaCKTFPNJNNdg',
    createdAt: DateTime(2026, 4, 9),
    values: [
      LabValue(
        testName: const L3(en: 'Hemoglobin', ru: 'Гемоглобин', ky: 'Гемоглобин'),
        value: 118, unit: 'g/L', refLow: 110, refHigh: 140,
        explanation: const L3(
          en: 'Hemoglobin carries oxygen in the blood. Your child\'s level is normal — their blood is carrying oxygen well. No anemia.',
          ru: 'Гемоглобин переносит кислород в крови. Уровень вашего ребёнка в норме — кровь хорошо переносит кислород. Анемии нет.',
          ky: 'Гемоглобин канда кычкылтек ташыйт. Балаңыздын деңгээли нормалдуу — каны кычкылтекти жакшы ташыйт. Анемия жок.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Red Blood Cells (RBC)', ru: 'Эритроциты (RBC)', ky: 'Эритроциттер (RBC)'),
        value: 4.47, unit: 'x10¹²/L', refLow: 3.7, refHigh: 4.9,
        explanation: const L3(
          en: 'Red blood cells carry oxygen throughout the body. Your child\'s count is perfectly normal.',
          ru: 'Эритроциты переносят кислород по всему организму. Количество у вашего ребёнка в полной норме.',
          ky: 'Эритроциттер бүт организмге кычкылтек ташыйт. Балаңыздын саны толук нормада.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'MCV (Red Cell Size)', ru: 'MCV (Размер эритроцитов)', ky: 'MCV (Эритроцит өлчөмү)'),
        value: 80.2, unit: 'fL', refLow: 73, refHigh: 85,
        explanation: const L3(
          en: 'MCV measures the average size of red blood cells. Normal size means the cells are healthy and well-formed.',
          ru: 'MCV измеряет средний размер эритроцитов. Нормальный размер означает, что клетки здоровые и правильно сформированы.',
          ky: 'MCV эритроциттердин орточо өлчөмүн ченейт. Нормалдуу өлчөм клеткалар дени сак жана туура түзүлгөнүн билдирет.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Hematocrit (HCT)', ru: 'Гематокрит (HCT)', ky: 'Гематокрит (HCT)'),
        value: 35.8, unit: '%', refLow: 32, refHigh: 42,
        explanation: const L3(
          en: 'Hematocrit shows the percentage of blood that is red blood cells. Normal — good blood composition.',
          ru: 'Гематокрит показывает процент крови, занятый эритроцитами. В норме — хороший состав крови.',
          ky: 'Гематокрит кандын канча пайызы эритроциттер экенин көрсөтөт. Нормада — кандын курамы жакшы.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Platelets (PLT)', ru: 'Тромбоциты (PLT)', ky: 'Тромбоциттер (PLT)'),
        value: 503, unit: 'x10⁹/L', refLow: 220, refHigh: 422,
        explanation: const L3(
          en: 'Platelets help blood clot. Your child has more than usual (elevated). This is VERY common after a recent cold, virus, or infection. The body makes extra platelets to fight illness. It almost always goes back to normal on its own in 4-6 weeks. Not dangerous — but mention to your pediatrician.',
          ru: 'Тромбоциты помогают крови свёртываться. У вашего ребёнка их больше нормы (повышены). Это ОЧЕНЬ часто бывает после недавней простуды, вируса или инфекции. Организм вырабатывает дополнительные тромбоциты для борьбы с болезнью. Почти всегда нормализуется самостоятельно за 4-6 недель. Не опасно — но упомяните педиатру.',
          ky: 'Тромбоциттер кандын уюшуна жардам берет. Балаңызда нормадан көп (жогорулаган). Бул жакында соокку, вирус же инфекциядан кийин АБДАН көп кездешет. Организм ооруга каршы кошумча тромбоциттерди чыгарат. Дээрлик дайыма 4-6 жумада өзүнөн өзү нормалдашат. Коркунучтуу эмес — бирок педиатрыңызга айтыңыз.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'White Blood Cells (WBC)', ru: 'Лейкоциты (WBC)', ky: 'Лейкоциттер (WBC)'),
        value: 6.66, unit: 'x10⁹/L', refLow: 5.5, refHigh: 14,
        explanation: const L3(
          en: 'White blood cells fight infections. Your child\'s count is normal — their immune system is working properly.',
          ru: 'Лейкоциты борются с инфекциями. Количество у вашего ребёнка в норме — иммунная система работает правильно.',
          ky: 'Лейкоциттер инфекцияларга каршы күрөшөт. Балаңыздын саны нормада — иммундук система туура иштеп жатат.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Iron (Serum)', ru: 'Железо (сыворотка)', ky: 'Темир (сыворотка)'),
        value: 5.8, unit: 'µmol/L', refLow: 6.6, refHigh: 26,
        explanation: const L3(
          en: 'Serum iron is slightly below the reference range. However, ferritin (iron stores) is adequate at 29.2, which is more important. Your child is NOT anemic. Make sure they eat iron-rich foods: red meat, lentils, spinach, fortified cereals. Pair with vitamin C (orange juice) for better absorption.',
          ru: 'Сывороточное железо чуть ниже нормы. Однако ферритин (запасы железа) адекватный — 29,2, что важнее. У вашего ребёнка НЕТ анемии. Убедитесь, что он ест продукты, богатые железом: красное мясо, чечевица, шпинат, обогащённые каши. Сочетайте с витамином С (апельсиновый сок) для лучшего усвоения.',
          ky: 'Сыворотка темири нормадан бир аз төмөн. Бирок ферритин (темир запасы) 29,2де жетиштүү, бул маанилүүрөөк. Балаңызда анемия ЖОК. Темирге бай тамактарды жесин: кызыл эт, жасмык, шпинат, байытылган ботко. Жакшы сиңирилиши үчүн С витамини (апельсин суусу) менен айкалыштырыңыз.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Ferritin', ru: 'Ферритин', ky: 'Ферритин'),
        value: 29.20, unit: 'ng/mL', refLow: 7, refHigh: 140,
        explanation: const L3(
          en: 'Ferritin measures your child\'s iron reserves. 29.2 is a good level — well above the minimum (7). This means even though serum iron is borderline, the body has adequate iron stored. No supplements needed unless your doctor recommends them.',
          ru: 'Ферритин измеряет запасы железа. 29,2 — хороший уровень, значительно выше минимума (7). Это означает, что даже при пограничном сывороточном железе в организме достаточно запасов. Добавки не нужны, если врач не рекомендует.',
          ky: 'Ферритин темир запастарын ченейт. 29,2 — жакшы деңгээл, минимумдан (7) кыйла жогору. Бул сыворотка темири чекте болсо да, организмде жетиштүү темир запасы бар дегенди билдирет. Врач сунуштабаса, кошумчалар керек эмес.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'ESR', ru: 'СОЭ', ky: 'СОЭ'),
        value: 14, unit: 'mm/hr', refLow: 2, refHigh: 10,
        explanation: const L3(
          en: 'ESR is a general inflammation marker. Slightly elevated at 14 (normal: 2-10). Combined with the high platelets, this strongly suggests a recent viral infection — extremely common at age 2. If your child has no fever or ongoing symptoms, this will likely normalize on its own. Not urgent.',
          ru: 'СОЭ — общий маркер воспаления. Немного повышен — 14 (норма: 2-10). В сочетании с повышенными тромбоцитами это убедительно указывает на недавнюю вирусную инфекцию — крайне часто в 2 года. Если нет температуры или текущих симптомов, нормализуется самостоятельно. Не срочно.',
          ky: 'СОЭ — жалпы сезгенүү белгиси. 14дө бир аз жогорулаган (норма: 2-10). Жогорулаган тромбоциттер менен бирге бул жакында вирустук инфекция болгонун көрсөтөт — 2 жашта абдан көп кездешет. Температура же учурдагы белгилер жок болсо, өзүнөн өзү нормалдашат. Шашылыш эмес.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Lymphocytes (%)', ru: 'Лимфоциты (%)', ky: 'Лимфоциттер (%)'),
        value: 57.8, unit: '%', refLow: 33, refHigh: 55,
        explanation: const L3(
          en: 'Lymphocytes fight viral infections. Slightly elevated at 57.8%. At age 2, children naturally have higher lymphocyte percentages than adults — this is called "physiological lymphocytosis." Combined with ESR and platelets, points to a recent or resolving viral infection. Completely expected.',
          ru: 'Лимфоциты борются с вирусными инфекциями. Немного повышены — 57,8%. В 2 года у детей естественно более высокий процент лимфоцитов, чем у взрослых — это называется «физиологический лимфоцитоз». В сочетании с СОЭ и тромбоцитами указывает на недавнюю или проходящую вирусную инфекцию. Полностью ожидаемо.',
          ky: 'Лимфоциттер вирустук инфекцияларга каршы күрөшөт. 57,8% да бир аз жогорулаган. 2 жашта балдарда чоңдорго караганда лимфоциттер табигый түрдө жогору болот — бул «физиологиялык лимфоцитоз» деп аталат. СОЭ жана тромбоциттер менен бирге жакында вирустук инфекция болгонун көрсөтөт. Толугу менен күтүлгөн.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Reticulocytes', ru: 'Ретикулоциты', ky: 'Ретикулоциттер'),
        value: 0.7, unit: '%', refLow: 0.5, refHigh: 2.0,
        explanation: const L3(
          en: 'Reticulocytes are young red blood cells. Normal level means the bone marrow is producing red blood cells at a healthy rate.',
          ru: 'Ретикулоциты — молодые эритроциты. Нормальный уровень означает, что костный мозг вырабатывает эритроциты с нормальной скоростью.',
          ky: 'Ретикулоциттер — жаш эритроциттер. Нормалдуу деңгээл сөөк чучугу эритроциттерди дени сак ылдамдыкта чыгарып жатканын билдирет.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Neutrophils (%)', ru: 'Нейтрофилы (%)', ky: 'Нейтрофилдер (%)'),
        value: 31.9, unit: '%', refLow: 32, refHigh: 55,
        explanation: const L3(
          en: 'Neutrophils fight bacterial infections. At 31.9%, just barely below the range (32-55%). This is insignificant — essentially normal. The slightly lower percentage is because lymphocytes are proportionally higher (viral response).',
          ru: 'Нейтрофилы борются с бактериальными инфекциями. 31,9% — едва ниже диапазона (32-55%). Это незначительно — по сути нормально. Чуть сниженный процент объясняется пропорционально повышенными лимфоцитами (вирусный ответ).',
          ky: 'Нейтрофилдер бактериялык инфекцияларга каршы күрөшөт. 31,9% диапазондон (32-55%) араң төмөн. Бул маанисиз — негизинен нормалдуу. Бир аз төмөн пайыз лимфоциттердин пропорционалдуу жогорулашы менен түшүндүрүлөт (вирустук жооп).',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Eosinophils (%)', ru: 'Эозинофилы (%)', ky: 'Эозинофилдер (%)'),
        value: 4.4, unit: '%', refLow: 1, refHigh: 6,
        explanation: const L3(
          en: 'Eosinophils are involved in allergic responses and fighting parasites. Normal range — no concerns.',
          ru: 'Эозинофилы участвуют в аллергических реакциях и борьбе с паразитами. В пределах нормы — без опасений.',
          ky: 'Эозинофилдер аллергиялык реакцияларда жана мителерге каршы күрөштө катышат. Нормалдуу диапазондо — кооптонуунун кереги жок.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'MCH', ru: 'MCH', ky: 'MCH'),
        value: 26.3, unit: 'pg', refLow: 25, refHigh: 30,
        explanation: const L3(
          en: 'MCH measures how much hemoglobin is in each red blood cell. Normal — cells are properly loaded with oxygen-carrying hemoglobin.',
          ru: 'MCH измеряет, сколько гемоглобина в каждом эритроците. В норме — клетки правильно нагружены гемоглобином, переносящим кислород.',
          ky: 'MCH ар бир эритроцитте канча гемоглобин бар экенин ченейт. Нормада — клеткалар кычкылтек ташыган гемоглобин менен туура жүктөлгөн.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'MCHC', ru: 'MCHC', ky: 'MCHC'),
        value: 33.0, unit: 'g/dL', refLow: 32, refHigh: 37,
        explanation: const L3(
          en: 'MCHC measures the concentration of hemoglobin in red blood cells. Normal — good hemoglobin density.',
          ru: 'MCHC измеряет концентрацию гемоглобина в эритроцитах. В норме — хорошая плотность гемоглобина.',
          ky: 'MCHC эритроциттердеги гемоглобин концентрациясын ченейт. Нормада — гемоглобин тыгыздыгы жакшы.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Basophils (%)', ru: 'Базофилы (%)', ky: 'Базофилдер (%)'),
        value: 0.5, unit: '%', refLow: 0, refHigh: 1,
        explanation: const L3(
          en: 'Basophils are a rare type of white blood cell. Normal level — no concerns.',
          ru: 'Базофилы — редкий тип лейкоцитов. Нормальный уровень — без опасений.',
          ky: 'Базофилдер — сейрек кездешкен лейкоцит түрү. Нормалдуу деңгээл — кооптонуунун кереги жок.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'Monocytes (%)', ru: 'Моноциты (%)', ky: 'Моноциттер (%)'),
        value: 5.4, unit: '%', refLow: 3, refHigh: 9,
        explanation: const L3(
          en: 'Monocytes help clean up after infections. Normal level — immune system is balanced.',
          ru: 'Моноциты помогают организму восстановиться после инфекций. Нормальный уровень — иммунная система сбалансирована.',
          ky: 'Моноциттер инфекциялардан кийин организмди тазалоого жардам берет. Нормалдуу деңгээл — иммундук система тең салмактуу.',
        ),
      ),
      LabValue(
        testName: const L3(en: 'RDW', ru: 'RDW', ky: 'RDW'),
        value: 14.2, unit: '%', refLow: 11.5, refHigh: 14.5,
        explanation: const L3(
          en: 'RDW measures variation in red blood cell size. Normal — cells are uniform in size, which is healthy.',
          ru: 'RDW измеряет вариацию размеров эритроцитов. В норме — клетки однородные по размеру, что здорово.',
          ky: 'RDW эритроциттердин өлчөмүнүн вариациясын ченейт. Нормада — клеткалар өлчөмү боюнча бирдей, бул дени сак.',
        ),
      ),
    ],
  );
}
