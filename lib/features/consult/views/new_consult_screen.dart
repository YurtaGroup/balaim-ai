import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart' show localeProvider;
import '../consult_config.dart';
import '../consult_provider.dart';
import '../doctor_picker_sheet.dart';
import '../doctors_provider.dart';
import '../models/doctor.dart';

/// Start a paid consultation with a doctor. Reads the live `doctors`
/// directory; if it's empty (pre-bootstrap), falls back to the anchor
/// doctor (Jane Mone NP) so existing single-doctor behaviour is
/// preserved.
class NewConsultScreen extends ConsumerStatefulWidget {
  const NewConsultScreen({super.key});

  @override
  ConsumerState<NewConsultScreen> createState() => _NewConsultScreenState();
}

class _NewConsultScreenState extends ConsumerState<NewConsultScreen> {
  final _topic = TextEditingController();
  final _message = TextEditingController();
  bool _busy = false;
  Doctor? _selectedDoctor;

  // AI pre-screen state
  bool _screening = false;
  _ScreenResult? _screenResult;
  String? _lastScreenedDraft;

  @override
  void dispose() {
    _topic.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _runScreen(Doctor doctor) async {
    final draft = _message.text.trim();
    final topic = _topic.text.trim();
    if (draft.length < 10) return;
    if (_screening) return;
    if (_lastScreenedDraft == draft) return;
    setState(() {
      _screening = true;
      _screenResult = null;
    });
    try {
      final locale = ref.read(localeProvider)?.languageCode ?? 'en';
      final normalized = {'en', 'ru', 'ky'}.contains(locale) ? locale : 'en';
      final callable =
          FirebaseFunctions.instance.httpsCallable('screenConsultDraft');
      final res = await callable.call(<String, dynamic>{
        'draft': draft,
        if (topic.isNotEmpty) 'topic': topic,
        'doctorId': doctor.id,
        'locale': normalized,
      });
      if (!mounted) return;
      _lastScreenedDraft = draft;
      _screenResult = _ScreenResult.fromMap(
          (res.data as Map?)?.cast<String, dynamic>() ?? const {});
      unawaited(Analytics.instance.consultDraftScreened(
        urgency: _screenResult!.urgency,
        canAiAnswerFirst: _screenResult!.canAiAnswerFirst,
        doctorRelevance: _screenResult!.doctorRelevance,
      ));
    } catch (e) {
      debugPrint('[consult] pre-screen failed: $e');
    } finally {
      if (mounted) setState(() => _screening = false);
    }
  }

  void _routeToEmergency() {
    context.go('/emergency');
  }

  void _askBalamFree() {
    final draft = _message.text.trim();
    if (draft.isEmpty) return;
    context.go('/ai?prefill=${Uri.encodeComponent(draft)}');
  }

  Doctor _resolveDoctor(List<Doctor> directory) {
    if (_selectedDoctor != null) return _selectedDoctor!;
    return defaultDoctorFrom(directory) ?? fallbackAnchorDoctor;
  }

  Future<void> _payAndSend(Doctor doctor) async {
    final topic = _topic.text.trim();
    final message = _message.text.trim();
    if (topic.isEmpty || message.isEmpty) return;
    setState(() => _busy = true);

    final pay = await PaymentService().purchaseConsult(kConsultProductId);
    if (!mounted) return;
    if (!pay.success) {
      setState(() => _busy = false);
      if (!pay.cancelled && pay.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(pay.error!)));
      }
      return;
    }

    final id = await ref.read(consultServiceProvider).create(
          topic: topic,
          firstMessage: message,
          doctorId: doctor.id,
          screenedByAi: _screenResult != null,
        );
    if (id != null) {
      unawaited(Analytics.instance.consultStarted(
        doctorId: doctor.id,
        screenedByAi: _screenResult != null,
      ));
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(currentLang(context),
            en: 'Could not start the consultation. Try again.',
            ru: 'Не удалось начать консультацию. Попробуй ещё раз.',
            ky: 'Консультация башталган жок. Кайра аракет кыл.')),
      ));
      return;
    }
    context.pushReplacement('/consult/$id');
  }

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    final directory = ref.watch(doctorsProvider).asData?.value ?? const [];
    final doctor = _resolveDoctor(directory);
    final canSend =
        _topic.text.trim().isNotEmpty && _message.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(lang,
            en: 'New consultation',
            ru: 'Новая консультация',
            ky: 'Жаңы консультация')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SelectedDoctorCard(
            doctor: doctor,
            lang: lang,
            multipleAvailable: directory.length > 1,
            onChange: () async {
              final picked = await DoctorPickerSheet.show(
                context,
                ref,
                current: doctor,
              );
              if (picked != null) {
                setState(() => _selectedDoctor = picked);
              }
            },
          ),
          const SizedBox(height: 20),
          Text(
            tr(lang,
                en: "What's it about?",
                ru: 'О чём вопрос?',
                ky: 'Эмне жөнүндө?'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _topic,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec(tr(lang,
                en: 'e.g. Sleep regression, feeding, rash',
                ru: 'напр. сон, кормление, сыпь',
                ky: 'мис. уйку, тамак, бөртмө')),
          ),
          const SizedBox(height: 16),
          Text(
            tr(lang,
                en: 'Describe your question',
                ru: 'Опиши свой вопрос',
                ky: 'Сурооңду жаз'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _message,
            onChanged: (_) {
              setState(() {});
              // Invalidate any stale screen result on edit.
              if (_screenResult != null &&
                  _message.text.trim() != _lastScreenedDraft) {
                setState(() => _screenResult = null);
              }
            },
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec(tr(lang,
                en: 'Symptoms, how long, what you have tried, what you want to know. You can attach photos in the next step.',
                ru: 'Симптомы, как долго, что пробовали, что хочешь узнать. Фото можно приложить дальше.',
                ky: 'Симптомдор, канча убакыт, эмне аракет кылдыңыз, эмнени билгиңиз келет. Сүрөттөрдү кийинки кадамда тиркей аласыз.')),
          ),
          const SizedBox(height: 10),
          if (_message.text.trim().length >= 10 && _screenResult == null) ...[
            OutlinedButton.icon(
              onPressed: _screening ? null : () => _runScreen(doctor),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: _screening
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                _screening
                    ? tr(lang,
                        en: 'Balam is reading…',
                        ru: 'Balam читает…',
                        ky: 'Balam окуп жатат…')
                    : tr(lang,
                        en: 'Check with Balam first (free)',
                        ru: 'Сначала спросить Balam (бесплатно)',
                        ky: 'Адегенде Balamден сура (бекер)'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (_screenResult != null) ...[
            _ScreenResultCard(
              result: _screenResult!,
              lang: lang,
              onOpenEmergency: _routeToEmergency,
              onAskFreeAi: _askBalamFree,
              onUseRephrase: () {
                final r = _screenResult!.suggestedRephrase;
                if (r != null) {
                  _message.text = r;
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr(lang,
                        en: 'A private async thread with ${doctor.name}. Usually replies within a day.',
                        ru: 'Личная переписка с ${doctor.name}. Обычно отвечает в течение дня.',
                        ky: '${doctor.name} менен жеке жазышуу. Адатта бир күндө жооп берет.'),
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_busy || !canSend) ? null : () => _payAndSend(doctor),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      tr(lang,
                          en: 'Pay ${doctor.formattedRate} & send',
                          ru: 'Оплатить ${doctor.formattedRate} и отправить',
                          ky: '${doctor.formattedRate} төлөп жөнөтүү'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        contentPadding: const EdgeInsets.all(14),
      );
}

// ─── AI pre-screen result ──────────────────────────────────────

class _ScreenResult {
  final String? suggestedRephrase;
  final bool canAiAnswerFirst;
  final String? aiAnswerPreview;
  final String urgency; // low / medium / high / emergency
  final String doctorRelevance; // low / medium / high

  const _ScreenResult({
    required this.suggestedRephrase,
    required this.canAiAnswerFirst,
    required this.aiAnswerPreview,
    required this.urgency,
    required this.doctorRelevance,
  });

  factory _ScreenResult.fromMap(Map<String, dynamic> raw) {
    String? s(Object? v) {
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }
    final urgency = (raw['urgency'] as String?)?.trim() ?? 'low';
    final rel = (raw['doctor_relevance'] as String?)?.trim() ?? 'medium';
    return _ScreenResult(
      suggestedRephrase: s(raw['suggested_rephrase']),
      canAiAnswerFirst: raw['can_ai_answer_first'] == true,
      aiAnswerPreview: s(raw['ai_answer_preview']),
      urgency: ['low', 'medium', 'high', 'emergency'].contains(urgency)
          ? urgency
          : 'low',
      doctorRelevance:
          ['low', 'medium', 'high'].contains(rel) ? rel : 'medium',
    );
  }
}

class _ScreenResultCard extends StatelessWidget {
  final _ScreenResult result;
  final String lang;
  final VoidCallback onOpenEmergency;
  final VoidCallback onAskFreeAi;
  final VoidCallback onUseRephrase;

  const _ScreenResultCard({
    required this.result,
    required this.lang,
    required this.onOpenEmergency,
    required this.onAskFreeAi,
    required this.onUseRephrase,
  });

  @override
  Widget build(BuildContext context) {
    // Emergency wins everything else: hide the rest, push hard to /emergency.
    if (result.urgency == 'emergency') {
      return _EmergencyBlock(lang: lang, onOpen: onOpenEmergency);
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                tr(lang,
                    en: "BALAM'S READ",
                    ru: 'BALAM СЧИТАЕТ',
                    ky: 'BALAM КӨРГӨН'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          if (result.canAiAnswerFirst && result.aiAnswerPreview != null) ...[
            const SizedBox(height: 8),
            Text(
              result.aiAnswerPreview!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onAskFreeAi,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 14),
                  label: Text(
                    tr(lang,
                        en: 'Ask Balam free',
                        ru: 'Спросить Balam (бесплатно)',
                        ky: 'Balamдан сура (бекер)'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr(lang,
                  en: "Or send to the doctor anyway — useful if you want a clinician's eye on it.",
                  ru: 'Или всё-таки отправь врачу — если хочешь, чтобы посмотрел специалист.',
                  ky: 'Же дарыгерге жөнөткүң келсе — адистин көзү тийсин.'),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              tr(lang,
                  en: "This is a good one for the doctor.",
                  ru: 'Это как раз случай для врача.',
                  ky: 'Бул дарыгерге арналган суроо.'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          if (result.suggestedRephrase != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(lang,
                        en: 'A clearer way to ask:',
                        ru: 'Можно сформулировать так:',
                        ky: 'Так бул түрдө суроо:'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.suggestedRephrase!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onUseRephrase,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        tr(lang,
                            en: 'Use this',
                            ru: 'Использовать',
                            ky: 'Колдонуу'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyBlock extends StatelessWidget {
  final String lang;
  final VoidCallback onOpen;
  const _EmergencyBlock({required this.lang, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(lang,
                en: "This sounds urgent — don't wait for an async reply.",
                ru: 'Это срочно — не жди ответа в переписке.',
                ky: 'Бул шашылыш — жазышуудан жоопту күтпө.'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.emergency_outlined, size: 16),
            label: Text(
              tr(lang,
                  en: 'Open Emergency Mode',
                  ru: 'Открыть экстренный режим',
                  ky: 'Шашылыш режимди ачуу'),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// The doctor picked for this consult. Shows "Change" only when the
/// directory has more than one active doctor — single-doctor v1 stays
/// frictionless.
class _SelectedDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final String lang;
  final bool multipleAvailable;
  final VoidCallback onChange;

  const _SelectedDoctorCard({
    required this.doctor,
    required this.lang,
    required this.multipleAvailable,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(doctor.specialty,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary)),
                    if (doctor.bio.forLocale(lang).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(doctor.bio.forLocale(lang),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (multipleAvailable) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: Text(
                  tr(lang,
                      en: 'Change doctor',
                      ru: 'Сменить врача',
                      ky: 'Дарыгерди алмаштыруу'),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
