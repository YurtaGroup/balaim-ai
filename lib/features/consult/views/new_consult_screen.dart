import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../consult_config.dart';
import '../consult_provider.dart';

/// Start a paid consultation with the doctor.
class NewConsultScreen extends ConsumerStatefulWidget {
  const NewConsultScreen({super.key});

  @override
  ConsumerState<NewConsultScreen> createState() => _NewConsultScreenState();
}

class _NewConsultScreenState extends ConsumerState<NewConsultScreen> {
  final _topic = TextEditingController();
  final _message = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _topic.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _payAndSend() async {
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

    final id = await ref
        .read(consultServiceProvider)
        .create(topic: topic, firstMessage: message);
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
          _DoctorCard(lang: lang),
          const SizedBox(height: 20),
          Text(
            tr(lang,
                en: 'What\'s it about?',
                ru: 'О чём вопрос?',
                ky: 'Эмне жөнүндө?'),
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _topic,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec(tr(lang,
                en: 'e.g. Thyroid results, fatigue',
                ru: 'напр. Щитовидка, усталость',
                ky: 'мис. Калкан без, чарчоо')),
          ),
          const SizedBox(height: 16),
          Text(
            tr(lang,
                en: 'Describe your question',
                ru: 'Опиши свой вопрос',
                ky: 'Сурооңду жаз'),
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _message,
            onChanged: (_) => setState(() {}),
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dec(tr(lang,
                en: 'Symptoms, how long, any test results, what you want to know. You can attach lab photos in the next step.',
                ru: 'Симптомы, как долго, результаты анализов, что хочешь узнать. Фото анализов можно приложить дальше.',
                ky: 'Симптомдор, канча убакыт, анализдер, эмнени билгиң келет. Анализ сүрөттөрүн кийинки кадамда тиркей аласың.')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr(lang,
                        en: 'One consultation — a private async thread with $kDoctorName. She usually replies within a day.',
                        ru: 'Одна консультация — личная переписка с $kDoctorName. Обычно отвечает в течение дня.',
                        ky: 'Бир консультация — $kDoctorName менен жеке жазышуу. Адатта бир күндө жооп берет.'),
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
              onPressed: (_busy || !canSend) ? null : _payAndSend,
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
                          en: 'Pay \$$kConsultPriceUsd & send',
                          ru: 'Оплатить \$$kConsultPriceUsd и отправить',
                          ky: '\$$kConsultPriceUsd төлөп жөнөтүү'),
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

class _DoctorCard extends StatelessWidget {
  final String lang;
  const _DoctorCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
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
                Text(kDoctorName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(kDoctorSpecialty,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(kDoctorBlurb,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
