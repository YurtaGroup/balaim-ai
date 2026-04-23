import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../journey/providers/journey_provider.dart';
import '../box_service.dart';
import 'box_result_sheet.dart';

/// Bottom sheet that lets the user log a single Balam Box reading
/// (BP, glucose, or temperature) for the active household member.
/// Submits to the `submitBoxReading` Cloud Function and then opens the
/// result sheet with the server-side tier classification.
class BoxEntrySheet extends ConsumerStatefulWidget {
  const BoxEntrySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BoxEntrySheet(),
    );
  }

  @override
  ConsumerState<BoxEntrySheet> createState() => _BoxEntrySheetState();
}

enum _Kind { bp, glucose, temperature }

class _BoxEntrySheetState extends ConsumerState<BoxEntrySheet> {
  _Kind _kind = _Kind.bp;

  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _pulse = TextEditingController();
  final _glucose = TextEditingController();
  bool _fasting = true;
  final _tempC = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _systolic.dispose();
    _diastolic.dispose();
    _pulse.dispose();
    _glucose.dispose();
    _tempC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final profile = ref.read(userProfileProvider);
    final member = profile.selectedMember;
    if (member == null) {
      setState(() => _error = 'No active member selected.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final svc = ref.read(boxServiceProvider);
      late final BoxClassification result;
      switch (_kind) {
        case _Kind.bp:
          final sys = int.tryParse(_systolic.text.trim());
          final dia = int.tryParse(_diastolic.text.trim());
          if (sys == null || dia == null || sys < 60 || dia < 30) {
            setState(() {
              _submitting = false;
              _error = 'Enter valid systolic and diastolic numbers.';
            });
            return;
          }
          result = await svc.submitBloodPressure(
            member: member,
            systolic: sys,
            diastolic: dia,
            heartRate: int.tryParse(_pulse.text.trim()),
          );
          break;
        case _Kind.glucose:
          final g = int.tryParse(_glucose.text.trim());
          if (g == null || g < 20 || g > 800) {
            setState(() {
              _submitting = false;
              _error = 'Enter a valid glucose value in mg/dL.';
            });
            return;
          }
          result = await svc.submitGlucose(
            member: member,
            glucoseMgDl: g,
            fasting: _fasting,
          );
          break;
        case _Kind.temperature:
          final t = double.tryParse(_tempC.text.trim().replaceAll(',', '.'));
          if (t == null || t < 30 || t > 45) {
            setState(() {
              _submitting = false;
              _error = 'Enter a valid temperature in °C.';
            });
            return;
          }
          result = await svc.submitTemperature(member: member, tempC: t);
          break;
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      await BoxResultSheet.show(context, result);
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Submit failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final member = profile.selectedMember;
    final memberName = member?.name ?? '—';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(currentLang(context),
                    en: 'Balam Box — new reading',
                    ru: 'Balam Box — новое измерение',
                    ky: 'Balam Box — жаңы өлчөө'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(currentLang(context),
                    en: 'For: $memberName',
                    ru: 'Для: $memberName',
                    ky: 'Үчүн: $memberName'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SegmentedButton<_Kind>(
                segments: [
                  ButtonSegment(
                    value: _Kind.bp,
                    label: Text(tr(currentLang(context), en: 'BP', ru: 'Давление', ky: 'Басым')),
                    icon: const Icon(Icons.favorite_outline),
                  ),
                  ButtonSegment(
                    value: _Kind.glucose,
                    label: Text(tr(currentLang(context), en: 'Glucose', ru: 'Глюкоза', ky: 'Глюкоза')),
                    icon: const Icon(Icons.water_drop_outlined),
                  ),
                  ButtonSegment(
                    value: _Kind.temperature,
                    label: Text(tr(currentLang(context), en: 'Temp', ru: 'Темп.', ky: 'Темп.')),
                    icon: const Icon(Icons.thermostat_outlined),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
              const SizedBox(height: 20),
              if (_kind == _Kind.bp) _bpFields(context),
              if (_kind == _Kind.glucose) _glucoseFields(context),
              if (_kind == _Kind.temperature) _tempFields(context),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          tr(currentLang(context),
                              en: 'Analyze reading',
                              ru: 'Проанализировать',
                              ky: 'Талдоо'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(currentLang(context),
                    en: 'A licensed clinician reviews every Orange/Red reading within 24 hours.',
                    ru: 'Каждое Orange/Red измерение просматривает лицензированный врач в течение 24 часов.',
                    ky: 'Ар бир Orange/Red көрсөткүчтү лицензиялуу дарыгер 24 саат ичинде карайт.'),
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bpFields(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _numberField(
                controller: _systolic,
                label: tr(currentLang(context),
                    en: 'Systolic (top)',
                    ru: 'Систол. (верх)',
                    ky: 'Систол. (жогорку)'),
                hint: '120',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _numberField(
                controller: _diastolic,
                label: tr(currentLang(context),
                    en: 'Diastolic (bottom)',
                    ru: 'Диастол. (низ)',
                    ky: 'Диастол. (ылдый)'),
                hint: '80',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _numberField(
          controller: _pulse,
          label: tr(currentLang(context),
              en: 'Pulse (optional)',
              ru: 'Пульс (опц.)',
              ky: 'Пульс (тандамал)'),
          hint: '72',
        ),
      ],
    );
  }

  Widget _glucoseFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _numberField(
          controller: _glucose,
          label: tr(currentLang(context),
              en: 'Glucose (mg/dL)',
              ru: 'Глюкоза (мг/дл)',
              ky: 'Глюкоза (мг/дл)'),
          hint: '95',
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(currentLang(context),
              en: 'Fasting reading',
              ru: 'Натощак',
              ky: 'Ачкарын')),
          subtitle: Text(tr(currentLang(context),
              en: 'No food or drink for 8+ hours',
              ru: 'Без еды и напитков 8+ часов',
              ky: 'Тамак-ашсыз 8+ саат')),
          value: _fasting,
          onChanged: (v) => setState(() => _fasting = v),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _tempFields(BuildContext context) {
    return _numberField(
      controller: _tempC,
      label: tr(currentLang(context),
          en: 'Temperature (°C)',
          ru: 'Температура (°C)',
          ky: 'Температура (°C)'),
      hint: '37.0',
      decimal: true,
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: decimal, signed: false),
      inputFormatters: decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
