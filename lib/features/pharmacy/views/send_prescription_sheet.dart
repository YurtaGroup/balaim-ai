import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/pharmacy_seed.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/pharmacy.dart';
import '../../vault/vault_provider.dart';

/// "Send this prescription to a pharmacy" — opens from a vault
/// prescription card. Picks a pharmacy, builds a WhatsApp deep-link
/// with a pre-filled message including the Rx summary + the file URL
/// from Firebase Storage. Pharmacist opens it on their phone, sees the
/// photo, confirms stock and price, replies. We never touch the order.
class SendPrescriptionSheet extends StatelessWidget {
  final VaultItem item;
  const SendPrescriptionSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, VaultItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendPrescriptionSheet(item: item),
    );
  }

  Future<void> _sendTo(BuildContext context, Pharmacy p) async {
    final lang = currentLang(context);
    final medsHeader = tr(lang, en: 'Medications:', ru: 'Препараты:', ky: 'Дары-дармектер:');
    final medsLine = item.medications.isEmpty
        ? ''
        : '\n\n$medsHeader\n- ${item.medications.join("\n- ")}';
    final summary = item.summary.isEmpty ? '' : '\n\n${item.summary}';
    final photoHeader = tr(lang, en: 'Prescription photo:', ru: 'Фото рецепта:', ky: 'Рецепттин сүрөтү:');
    final fileLine = '\n\n$photoHeader\n${item.fileUrl}';

    final msg = '${tr(lang, en: "Hi, sending a prescription via Balam. Could you confirm if this is in stock + the price?", ru: "Здравствуйте! Отправляю рецепт через Balam. Можете подтвердить наличие и цену?", ky: "Салам! Balam аркылуу рецепт жөнөтүп жатам. Бар-жогун жана бааны тактап берсеңиз?")}$medsLine$summary$fileLine';

    final clean = p.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 14),
            Text(
              tr(currentLang(context),
                  en: 'Send prescription to a pharmacy',
                  ru: 'Отправить рецепт в аптеку',
                  ky: 'Рецепти дарыканага жөнөтүү'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(currentLang(context),
                  en: 'Balam opens WhatsApp with the prescription photo + a note. The pharmacy replies with stock & price.',
                  ru: 'Balam откроет WhatsApp с фото рецепта и сообщением. Аптека ответит по наличию и цене.',
                  ky: 'Balam WhatsApp-ты рецепттин сүрөтү жана билдирүү менен ачат. Дарыкана бар-жогун жана баасын жооп берет.'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: PharmacySeed.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final p = PharmacySeed.all[i];
                  return InkWell(
                    onTap: () => _sendTo(context, p),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name.of(context),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                Text(
                                  p.neighborhood.of(context),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.textHint, size: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
