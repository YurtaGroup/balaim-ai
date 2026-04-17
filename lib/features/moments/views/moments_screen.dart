import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/moment.dart';
import '../../journey/providers/journey_provider.dart';
import '../providers/moments_provider.dart';

class MomentsScreen extends ConsumerWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);
    final profile = ref.watch(userProfileProvider);
    final name = profile.babyName ?? L.of(context).myBaby;
    final l = L.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.firstMoments),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddMoment(context, ref),
          ),
        ],
      ),
      body: moments.isEmpty
          ? _EmptyState(name: name, onAdd: () => _showAddMoment(context, ref))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: moments.length,
              itemBuilder: (context, index) {
                final moment = moments[index];
                final showYear = index == 0 ||
                    moments[index - 1].date.year != moment.date.year;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showYear)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
                        child: Text(
                          '${moment.date.year}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHint.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    _MomentCard(moment: moment),
                    const SizedBox(height: 14),
                  ],
                );
              },
            ),
      floatingActionButton: moments.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddMoment(context, ref),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddMoment(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMomentSheet(ref: ref),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String name;
  final VoidCallback onAdd;

  const _EmptyState({required this.name, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              l.momentsCaptureFirstsFor(name),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l.momentsFirstsDescription,
              style: TextStyle(color: AppColors.textHint, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l.momentsAddFirstButton),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Moment Card (Timeline Item)
// ─────────────────────────────────────────────

class _MomentCard extends StatelessWidget {
  final Moment moment;

  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(moment.date);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot + line
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  moment.tag.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: AppColors.divider,
            ),
          ],
        ),
        const SizedBox(width: 14),

        // Card content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      moment.tag.label,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Photo
              if (moment.hasPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: moment.photoUrl != null
                      ? Image.network(
                          moment.photoUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _photoPlaceholder(),
                        )
                      : Image.file(
                          File(moment.localPhotoPath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _photoPlaceholder(),
                        ),
                ),
              if (moment.hasPhoto) const SizedBox(height: 8),

              // Caption
              Text(
                moment.caption,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.photo, color: AppColors.textHint, size: 40),
    );
  }

}

// ─────────────────────────────────────────────
// Add Moment Bottom Sheet
// ─────────────────────────────────────────────

class _AddMomentSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddMomentSheet({required this.ref});

  @override
  State<_AddMomentSheet> createState() => _AddMomentSheetState();
}

class _AddMomentSheetState extends State<_AddMomentSheet> {
  final _captionController = TextEditingController();
  DateTime _date = DateTime.now();
  MomentTag _tag = MomentTag.memory;
  File? _photo;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            Text(L.of(context).momentsCaptureHeading, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // Photo picker
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
                        child: Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: AppColors.primary, size: 36),
                          const SizedBox(height: 8),
                          Text(L.of(context).momentsAddPhotoHint, style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Caption
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: L.of(context).momentsCaptionHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Milestone tag
            Text(L.of(context).momentsKindQuestion, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MomentTag.values.map((tag) {
                final isSelected = _tag == tag;
                return GestureDetector(
                  onTap: () => setState(() => _tag = tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(
                      '${tag.emoji} ${tag.label}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_date),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(L.of(context).momentsSaveButton, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final file = await StorageService().showPickerSheet(context);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) return;

    widget.ref.read(momentsProvider.notifier).addMoment(
          caption: caption,
          date: _date,
          tag: _tag,
          photo: _photo,
        );

    Navigator.of(context).pop();
  }
}
