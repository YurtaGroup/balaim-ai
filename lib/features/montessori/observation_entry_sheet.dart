import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/content_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import 'observations_provider.dart';

/// 30-second capture sheet for "I noticed ___" Montessori observations.
///
/// Deliberately bare. The point of the observation log is that it
/// takes less than 30 seconds — every UI hesitation here costs us a
/// real observation. No tags to pick, no category dropdown, no photo
/// attach. Mom writes one line; the server tag pass figures out the
/// Montessori reading.
class ObservationEntrySheet extends ConsumerStatefulWidget {
  final String childId;
  final String? childFirstName;

  const ObservationEntrySheet({
    super.key,
    required this.childId,
    this.childFirstName,
  });

  static Future<void> show(
    BuildContext context, {
    required String childId,
    String? childFirstName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ObservationEntrySheet(
        childId: childId,
        childFirstName: childFirstName,
      ),
    );
  }

  @override
  ConsumerState<ObservationEntrySheet> createState() =>
      _ObservationEntrySheetState();
}

class _ObservationEntrySheetState
    extends ConsumerState<ObservationEntrySheet> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _controller.text.trim();
    if (note.isEmpty) return;
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final id = await logObservation(
      uid: uid,
      childId: widget.childId,
      note: note,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (id != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    final placeholder = widget.childFirstName != null
        ? tr(lang,
            en: '${widget.childFirstName} pulled all the pots out of the cabinet again…',
            ru: '${widget.childFirstName} снова вытащил(а) все кастрюли из шкафчика…',
            ky: '${widget.childFirstName} дагы бардык казандарды шкафтан чыгарды…')
        : tr(lang,
            en: 'She pulled all the pots out of the cabinet again…',
            ru: 'Она снова вытащила все кастрюли из шкафчика…',
            ky: 'Ал дагы бардык казандарды шкафтан чыгарды…');

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.visibility_outlined,
                    color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr(lang,
                      en: 'I noticed…',
                      ru: 'Я заметила…',
                      ky: 'Мен байкадым…'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tr(lang,
                en: 'One line is plenty. Balam reads what your child is showing you and adjusts tomorrow.',
                ru: 'Одной строки достаточно. Balam поймёт, что показывает ребёнок, и подстроит завтрашнее задание.',
                ky: 'Бир сап жетиштүү. Balam балаңыз эмнени көрсөтүп жатканын окуйт жана эртеңки сунушту ыңгайлайт.'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
                height: 1.4,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    tr(lang,
                        en: 'Cancel',
                        ru: 'Отмена',
                        ky: 'Жокко чыгаруу'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          tr(lang,
                              en: 'Save observation',
                              ru: 'Сохранить',
                              ky: 'Сактоо'),
                          style:
                              const TextStyle(fontWeight: FontWeight.w700),
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
