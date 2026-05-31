import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
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

  @override
  void dispose() {
    _topic.dispose();
    _message.dispose();
    super.dispose();
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
        );
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
            onChanged: (_) => setState(() {}),
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec(tr(lang,
                en: 'Symptoms, how long, what you have tried, what you want to know. You can attach photos in the next step.',
                ru: 'Симптомы, как долго, что пробовали, что хочешь узнать. Фото можно приложить дальше.',
                ky: 'Симптомдор, канча убакыт, эмне аракет кылдыңыз, эмнени билгиңиз келет. Сүрөттөрдү кийинки кадамда тиркей аласыз.')),
          ),
          const SizedBox(height: 20),
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
