import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/pharmacy_seed.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/pharmacy.dart';

/// Browsable pharmacy directory. No transactions — every tile hands
/// off to a phone call or WhatsApp with a pre-filled message.
/// This is the whole pharmacy product in v1. We never process orders.
class PharmacyDirectoryScreen extends StatelessWidget {
  const PharmacyDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(currentLang(context),
            en: 'Pharmacies',
            ru: 'Аптеки',
            ky: 'Дарыканалар')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: PharmacySeed.all.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          if (i == 0) return const _HeaderNote();
          return _PharmacyCard(pharmacy: PharmacySeed.all[i - 1]);
        },
      ),
    );
  }
}

class _HeaderNote extends StatelessWidget {
  const _HeaderNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.secondaryDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(currentLang(context),
                  en: 'Balam doesn\'t sell medicine. Tap a pharmacy to call or WhatsApp them directly — most accept a prescription photo.',
                  ru: 'Balam не продаёт лекарства. Нажми аптеку, чтобы позвонить или написать в WhatsApp — большинство принимают фото рецепта.',
                  ky: 'Balam дары саткан жок. Тикелей чалуу же WhatsApp-ка жазуу үчүн дарыканага баскыла — көбү рецепттин сүрөтүн кабыл алат.'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;
  const _PharmacyCard({required this.pharmacy});

  Future<void> _dial(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(BuildContext context, String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = tr(currentLang(context),
        en: "Hi! I'm using Balam and wanted to check if you have a medication in stock. Can I send you the prescription?",
        ru: 'Здравствуйте! Я пишу через Balam — хочу уточнить, есть ли у вас в наличии нужный препарат. Могу отправить рецепт?',
        ky: 'Салам! Мен Balam аркылуу жазып жатам — кереги бар дары болобу, текшергим келет. Рецептти жөнөтө аламбы?');
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_pharmacy_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name.of(context),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pharmacy.neighborhood.of(context),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Badge(icon: Icons.schedule, text: pharmacy.hours.of(context)),
              if (pharmacy.deliversInCity)
                _Badge(
                  icon: Icons.delivery_dining_outlined,
                  text: tr(currentLang(context), en: 'Delivery', ru: 'Доставка', ky: 'Жеткирүү'),
                ),
              if (pharmacy.takesPhotoOfRx)
                _Badge(
                  icon: Icons.photo_camera_outlined,
                  text: tr(currentLang(context), en: 'Photo Rx OK', ru: 'Фото рецепта ОК', ky: 'Рецепт сүрөт жарайт'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _dial(pharmacy.phone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: Text(tr(currentLang(context), en: 'Call', ru: 'Позвонить', ky: 'Чалуу')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _whatsapp(context, pharmacy.whatsapp),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
