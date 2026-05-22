import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/moment.dart';
import '../../family/views/add_member_sheet.dart';
import '../../journey/providers/journey_provider.dart';
import '../../vault/vault_provider.dart';
import '../providers/child_timeline_provider.dart';
import '../providers/moments_provider.dart';

/// The Child tab — one timeline of the child's whole life: medical
/// records (Claude-extracted from photos) and milestone memories,
/// merged into a single chronological feed.
class ChildScreen extends ConsumerStatefulWidget {
  const ChildScreen({super.key});

  @override
  ConsumerState<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends ConsumerState<ChildScreen> {
  bool _uploading = false;

  Future<void> _addRecord(HouseholdMember child) async {
    final file = await StorageService().showPickerSheet(context);
    if (file == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final id = await ref
          .read(vaultServiceProvider)
          .uploadFile(file: file, memberId: child.id);
      if (mounted && id == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr(currentLang(context),
              en: 'Upload failed. Try again?',
              ru: 'Загрузка не удалась. Попробовать ещё раз?',
              ky: 'Жүктөө ишке ашпады. Кайра аракет кылабызбы?')),
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _addMoment(HouseholdMember child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMomentSheet(childId: child.id),
    );
  }

  void _showAddSheet(HouseholdMember child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.medical_information_outlined,
                  color: AppColors.primary),
              title: Text(tr(currentLang(ctx),
                  en: 'Add a record',
                  ru: 'Добавить запись',
                  ky: 'Жазуу кошуу')),
              subtitle: Text(tr(currentLang(ctx),
                  en: 'Photo of a prescription, lab, or doctor note',
                  ru: 'Фото рецепта, анализа или заключения',
                  ky: 'Рецепт, анализ же дарыгер жазуусунун сүрөтү')),
              onTap: () {
                Navigator.of(ctx).pop();
                _addRecord(child);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
              title: Text(tr(currentLang(ctx),
                  en: 'Add a moment',
                  ru: 'Добавить момент',
                  ky: 'Учур кошуу')),
              subtitle: Text(tr(currentLang(ctx),
                  en: 'A photo + one line — first smile, first steps',
                  ru: 'Фото и строчка — первая улыбка, первые шаги',
                  ky: 'Сүрөт жана бир сап — алгачкы жылмаюу, кадам')),
              onTap: () {
                Navigator.of(ctx).pop();
                _addMoment(child);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final children =
        profile.members.where((m) => m.role == MemberRole.child).toList();
    final selected = profile.selectedMember;
    final activeChild =
        (selected != null && selected.role == MemberRole.child)
            ? selected
            : (children.isNotEmpty ? children.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(currentLang(context),
            en: 'Child', ru: 'Ребёнок', ky: 'Бала')),
      ),
      body: activeChild == null
          ? _NoChild(onAdd: () => AddMemberSheet.show(context))
          : _Timeline(
              child: activeChild,
              children: children,
              onSelect: (id) =>
                  ref.read(userProfileProvider.notifier).selectChild(id),
            ),
      floatingActionButton: activeChild == null
          ? null
          : FloatingActionButton.extended(
              onPressed:
                  _uploading ? null : () => _showAddSheet(activeChild),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: _uploading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add),
              label: Text(tr(currentLang(context),
                  en: 'Add', ru: 'Добавить', ky: 'Кошуу')),
            ),
    );
  }
}

class _Timeline extends ConsumerWidget {
  final HouseholdMember child;
  final List<HouseholdMember> children;
  final ValueChanged<String> onSelect;
  const _Timeline({
    required this.child,
    required this.children,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(childTimelineProvider(child.id));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: entries.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return _ChildHeader(
            child: child,
            children: children,
            onSelect: onSelect,
            isEmpty: entries.isEmpty,
          );
        }
        final entry = entries[i - 1];
        final prev = i - 2 >= 0 ? entries[i - 2] : null;
        final showYear =
            prev == null || prev.date.year != entry.date.year;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showYear)
              Padding(
                padding: EdgeInsets.only(top: i == 1 ? 4 : 18, bottom: 8),
                child: Text(
                  '${entry.date.year}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHint.withValues(alpha: 0.6),
                  ),
                ),
              ),
            switch (entry) {
              RecordEntry(:final item) => _RecordCard(item: item),
              MomentEntry(:final moment) => _MomentCard(moment: moment),
            },
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

class _ChildHeader extends StatelessWidget {
  final HouseholdMember child;
  final List<HouseholdMember> children;
  final ValueChanged<String> onSelect;
  final bool isEmpty;
  const _ChildHeader({
    required this.child,
    required this.children,
    required this.onSelect,
    required this.isEmpty,
  });

  String _age(BuildContext context) {
    final months = child.ageMonths;
    if (months != null && months < 24) {
      return '${child.name} · $months ${tr(currentLang(context), en: 'months', ru: 'мес.', ky: 'ай')}';
    }
    final years = child.ageYears;
    if (years != null) {
      return '${child.name} · $years ${tr(currentLang(context), en: 'years', ru: 'лет', ky: 'жаш')}';
    }
    return child.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _age(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (children.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: children.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final c = children[i];
                final on = c.id == child.id;
                return GestureDetector(
                  onTap: () => onSelect(c.id),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: on
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.name.split(' ').first,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: on ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (isEmpty) _EmptyTimeline(childName: child.name),
      ],
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  final String childName;
  const _EmptyTimeline({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined,
              size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            tr(currentLang(context),
                en: '$childName\'s timeline starts here',
                ru: 'Здесь начинается история $childName',
                ky: '$childName тарыхы ушул жерден башталат'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(currentLang(context),
                en: 'Tap Add to keep a doctor visit, a vaccine card, or a first-smile photo. Balam reads records and remembers everything.',
                ru: 'Нажми «Добавить», чтобы сохранить визит к врачу, прививку или фото первой улыбки. Balam читает записи и всё помнит.',
                ky: 'Дарыгерге барууну, эмдөөнү же алгачкы жылмаюу сүрөтүн сактоо үчүн «Кошуу» бас. Balam жазууларды окуйт жана баарын эстейт.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _NoChild extends StatelessWidget {
  final VoidCallback onAdd;
  const _NoChild({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.child_care, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              tr(currentLang(context),
                  en: 'Add your child to start',
                  ru: 'Добавь ребёнка, чтобы начать',
                  ky: 'Баштоо үчүн балаңызды кош'),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(tr(currentLang(context),
                  en: 'Add child',
                  ru: 'Добавить ребёнка',
                  ky: 'Бала кошуу')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Record card ──────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final VaultItem item;
  const _RecordCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final subtitle = item.summary.isNotEmpty
        ? item.summary
        : (item.isPending
            ? tr(currentLang(context),
                en: 'Balam is reading this…',
                ru: 'Balam читает…',
                ky: 'Balam окуп жатат…')
            : (item.isFailed
                ? tr(currentLang(context),
                    en: 'Couldn\'t read this one',
                    ru: 'Не удалось разобрать',
                    ky: 'Окуу ишке ашкан жок')
                : ''));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(item.docType),
                color: AppColors.secondary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.providerName ?? _labelFor(item.docType, context),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat.yMMMd(Localizations.localeOf(context).toString())
                      .format(item.dateOfService ?? item.uploadedAt),
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String? t) {
    switch (t) {
      case 'lab_result':
        return Icons.science_outlined;
      case 'prescription':
        return Icons.medication_outlined;
      case 'doctor_note':
        return Icons.note_alt_outlined;
      case 'discharge_summary':
        return Icons.local_hospital_outlined;
      case 'imaging_report':
        return Icons.camera_outdoor_outlined;
      case 'vaccination_card':
        return Icons.vaccines_outlined;
      case 'growth_chart':
        return Icons.show_chart;
      default:
        return Icons.description_outlined;
    }
  }

  String _labelFor(String? t, BuildContext ctx) {
    final lang = currentLang(ctx);
    switch (t) {
      case 'lab_result':
        return tr(lang, en: 'Lab result', ru: 'Анализы', ky: 'Анализ');
      case 'prescription':
        return tr(lang, en: 'Prescription', ru: 'Рецепт', ky: 'Рецепт');
      case 'doctor_note':
        return tr(lang,
            en: 'Doctor note', ru: 'Заключение врача', ky: 'Дарыгер жазуусу');
      case 'vaccination_card':
        return tr(lang,
            en: 'Vaccination', ru: 'Прививка', ky: 'Эмдөө');
      default:
        return tr(lang, en: 'Record', ru: 'Запись', ky: 'Жазуу');
    }
  }
}

// ─── Moment card ──────────────────────────────────────────────────

class _MomentCard extends StatelessWidget {
  final Moment moment;
  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Text(moment.tag.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  moment.tag.label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd(Localizations.localeOf(context).toString())
                    .format(moment.date),
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
          if (moment.hasPhoto) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: moment.photoUrl != null
                  ? Image.network(moment.photoUrl!,
                      width: double.infinity, height: 180, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _ph())
                  : Image.file(File(moment.localPhotoPath!),
                      width: double.infinity, height: 180, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _ph()),
            ),
          ],
          const SizedBox(height: 8),
          Text(moment.caption,
              style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _ph() => Container(
        width: double.infinity,
        height: 180,
        color: AppColors.primary.withValues(alpha: 0.06),
        child: const Icon(Icons.photo, color: AppColors.textHint, size: 36),
      );
}

// ─── Add-moment sheet ─────────────────────────────────────────────

class _AddMomentSheet extends ConsumerStatefulWidget {
  final String childId;
  const _AddMomentSheet({required this.childId});

  @override
  ConsumerState<_AddMomentSheet> createState() => _AddMomentSheetState();
}

class _AddMomentSheetState extends ConsumerState<_AddMomentSheet> {
  final _captionController = TextEditingController();
  DateTime _date = DateTime.now();
  MomentTag _tag = MomentTag.memory;
  File? _photo;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await StorageService().showPickerSheet(context);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) return;
    ref.read(momentsProvider.notifier).addMoment(
          caption: caption,
          date: _date,
          tag: _tag,
          childId: widget.childId,
          photo: _photo,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(l.momentsCaptureHeading,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: _photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_photo!,
                            fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo,
                              color: AppColors.primary, size: 36),
                          const SizedBox(height: 8),
                          Text(l.momentsAddPhotoHint,
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: l.momentsCaptionHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Text(l.momentsKindQuestion,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MomentTag.values.map((tag) {
                final on = _tag == tag;
                return GestureDetector(
                  onTap: () => setState(() => _tag = tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: on ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              on ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(
                      '${tag.emoji} ${tag.label}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: on ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.yMMMd(
                              Localizations.localeOf(context).toString())
                          .format(_date),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textHint, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l.momentsSaveButton,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
