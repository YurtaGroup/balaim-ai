import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../journey/providers/journey_provider.dart';
import '../../pharmacy/views/send_prescription_sheet.dart';
import '../vault_provider.dart';

/// Main vault screen — a per-member timeline of medical documents.
/// "Balam never loses anything." Where the family shoebox goes.
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final profile = ref.read(userProfileProvider);
    final member = profile.selectedMember;
    if (member == null) return;

    final file = await StorageService().showPickerSheet(context);
    if (file == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final id = await ref.read(vaultServiceProvider).uploadFile(
            file: file,
            memberId: member.id,
          );
      if (!mounted) return;
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr(currentLang(context),
              en: 'Upload failed. Try again?',
              ru: 'Загрузка не удалась. Попробовать ещё раз?',
              ky: 'Жүктөө ишке ашпады. Кайрадан аракет кылабызбы?')),
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final member = profile.selectedMember;
    final memberName = member?.name ?? '—';
    final items = member == null
        ? const <VaultItem>[]
        : ref.watch(vaultItemsForMemberProvider(member.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(currentLang(context),
            en: 'Health Vault',
            ru: 'Медкарта',
            ky: 'Медкарта')),
      ),
      body: items.isEmpty
          ? _EmptyState(memberName: memberName)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _VaultItemCard(item: items[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _upload,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: _uploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add),
        label: Text(tr(currentLang(context),
            en: 'Add document',
            ru: 'Добавить документ',
            ky: 'Документ кошуу')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String memberName;
  const _EmptyState({required this.memberName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_shared_outlined,
              size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            tr(currentLang(context),
                en: 'Balam never loses anything',
                ru: 'Balam ничего не теряет',
                ky: 'Balam эч нерсе жоготпойт'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr(currentLang(context),
                en: 'Upload lab results, prescriptions, doctor notes, vaccination cards. We read them, tag them, and keep them ready for $memberName\'s entire health history.',
                ru: 'Загружай анализы, рецепты, заключения врачей, прививочные карты. Balam всё прочитает, разметит и сохранит историю здоровья $memberName.',
                ky: '$memberName үчүн анализ, рецепт, дарыгер кошумчасы, эмдөө карты жүктөй бер. Balam баарын окуйт, белгилеп, ден соолук тарыхын сактайт.'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _VaultItemCard extends StatelessWidget {
  final VaultItem item;
  const _VaultItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _typeStyle(item.docType, context);

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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.providerName ?? label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(item.dateOfService ?? item.uploadedAt, context),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _StatusBadge(item: item),
            ],
          ),
          if (item.summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.summary,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.35, fontSize: 14),
            ),
          ],
          if (item.diagnoses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.diagnoses
                  .take(5)
                  .map((d) => _Chip(text: d, color: AppColors.secondary))
                  .toList(),
            ),
          ],
          if (item.medications.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.medications
                  .take(5)
                  .map((m) => _Chip(text: m, color: AppColors.accentDark))
                  .toList(),
            ),
          ],
          if (item.flagsForReview.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.flagsForReview.join(' · '),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 12, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.followUpDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event, color: AppColors.textHint, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${tr(currentLang(context), en: "Follow-up", ru: "Повторный приём", ky: "Кайра кароо")}: ${_formatDate(item.followUpDate!, context)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
          if (item.docType == 'prescription' && item.isProcessed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => SendPrescriptionSheet.show(context, item),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: Text(tr(currentLang(context),
                    en: 'Send to a pharmacy',
                    ru: 'Отправить в аптеку',
                    ky: 'Дарыканага жөнөтүү')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  (IconData, String) _typeStyle(String? type, BuildContext context) {
    switch (type) {
      case 'lab_result':
        return (Icons.science_outlined, tr(currentLang(context), en: 'Lab result', ru: 'Анализы', ky: 'Анализ'));
      case 'prescription':
        return (Icons.medication_outlined, tr(currentLang(context), en: 'Prescription', ru: 'Рецепт', ky: 'Рецепт'));
      case 'doctor_note':
        return (Icons.note_alt_outlined, tr(currentLang(context), en: 'Doctor note', ru: 'Заключение врача', ky: 'Дарыгер жазуусу'));
      case 'discharge_summary':
        return (Icons.local_hospital_outlined, tr(currentLang(context), en: 'Discharge', ru: 'Выписка', ky: 'Чыгарылыш'));
      case 'imaging_report':
        return (Icons.camera_outdoor_outlined, tr(currentLang(context), en: 'Imaging', ru: 'Снимок', ky: 'Сүрөт'));
      case 'vaccination_card':
        return (Icons.vaccines_outlined, tr(currentLang(context), en: 'Vaccination', ru: 'Прививки', ky: 'Эмдөө'));
      case 'growth_chart':
        return (Icons.show_chart, tr(currentLang(context), en: 'Growth chart', ru: 'График роста', ky: 'Өсүү графиги'));
      case 'insurance_card':
        return (Icons.badge_outlined, tr(currentLang(context), en: 'Insurance', ru: 'Страховка', ky: 'Камсыздандыруу'));
      case 'referral':
        return (Icons.assignment_outlined, tr(currentLang(context), en: 'Referral', ru: 'Направление', ky: 'Жолдомо'));
      default:
        return (Icons.description_outlined, tr(currentLang(context), en: 'Document', ru: 'Документ', ky: 'Документ'));
    }
  }

  String _formatDate(DateTime d, BuildContext context) {
    final lang = currentLang(context);
    final mo = [
      ['Jan', 'Янв', 'Янв'],
      ['Feb', 'Фев', 'Фев'],
      ['Mar', 'Мар', 'Мар'],
      ['Apr', 'Апр', 'Апр'],
      ['May', 'Май', 'Май'],
      ['Jun', 'Июн', 'Июн'],
      ['Jul', 'Июл', 'Июл'],
      ['Aug', 'Авг', 'Авг'],
      ['Sep', 'Сен', 'Сен'],
      ['Oct', 'Окт', 'Окт'],
      ['Nov', 'Ноя', 'Ноя'],
      ['Dec', 'Дек', 'Дек'],
    ];
    final idx = lang == 'ru' ? 1 : lang == 'ky' ? 2 : 0;
    return '${mo[d.month - 1][idx]} ${d.day}, ${d.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final VaultItem item;
  const _StatusBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
              width: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.accentDark),
            ),
            const SizedBox(width: 6),
            Text(
              tr(currentLang(context), en: 'Reading…', ru: 'Читаю…', ky: 'Окуп жатам…'),
              style: const TextStyle(fontSize: 11, color: AppColors.accentDark),
            ),
          ],
        ),
      );
    }
    if (item.isFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          tr(currentLang(context), en: 'Couldn\'t read', ru: 'Не прочитал', ky: 'Окулбады'),
          style: const TextStyle(fontSize: 11, color: AppColors.error),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
