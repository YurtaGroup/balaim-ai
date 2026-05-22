import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../consult_config.dart';
import '../consult_provider.dart';
import '../models/consultation.dart';

/// One consultation thread — shared by the parent and the doctor.
/// Whose-side a bubble sits on depends on who is viewing.
class ConsultThreadScreen extends ConsumerStatefulWidget {
  final String consultId;
  const ConsultThreadScreen({super.key, required this.consultId});

  @override
  ConsumerState<ConsultThreadScreen> createState() =>
      _ConsultThreadScreenState();
}

class _ConsultThreadScreenState extends ConsumerState<ConsultThreadScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send({File? photo}) async {
    final text = _controller.text.trim();
    if (text.isEmpty && photo == null) return;
    setState(() => _sending = true);
    _controller.clear();
    final ok = await ref.read(consultServiceProvider).sendMessage(
          widget.consultId,
          text: text,
          fromDoctor: isDoctorAccount,
          photo: photo,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(currentLang(context),
            en: 'Could not send. Try again.',
            ru: 'Не удалось отправить. Попробуй ещё раз.',
            ky: 'Жөнөтүлгөн жок. Кайра аракет кыл.')),
      ));
    }
  }

  Future<void> _attachPhoto() async {
    final file = await StorageService().showPickerSheet(context);
    if (file != null) await _send(photo: file);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(consultMessagesProvider(widget.consultId));
    final lang = currentLang(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isDoctorAccount
            ? tr(lang, en: 'Consultation', ru: 'Консультация', ky: 'Консультация')
            : kDoctorName),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(tr(lang,
                    en: 'Could not load the thread.',
                    ru: 'Не удалось загрузить переписку.',
                    ky: 'Жазышуу жүктөлгөн жок.')),
              ),
              data: (msgs) => msgs.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        final m = msgs[msgs.length - 1 - i];
                        return _Bubble(
                          message: m,
                          mine: m.fromDoctor == isDoctorAccount,
                        );
                      },
                    ),
            ),
          ),
          _Composer(
            controller: _controller,
            sending: _sending,
            onSend: () => _send(),
            onAttach: _attachPhoto,
            hint: tr(lang,
                en: 'Write a message…',
                ru: 'Напиши сообщение…',
                ky: 'Билдирүү жаз…'),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ConsultMessage message;
  final bool mine;
  const _Bubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final bg = mine ? AppColors.primary : AppColors.surface;
    final fg = mine ? Colors.white : AppColors.textPrimary;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: mine ? null : Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.photoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(message.photoUrl!,
                    width: 200, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox()),
              ),
              if (message.text.isNotEmpty) const SizedBox(height: 6),
            ],
            if (message.text.isNotEmpty)
              Text(message.text,
                  style: TextStyle(color: fg, fontSize: 14, height: 1.35)),
            const SizedBox(height: 3),
            Text(
              DateFormat.MMMd(Localizations.localeOf(context).toString())
                  .add_jm()
                  .format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: mine ? Colors.white70 : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final String hint;
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onAttach,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.primary),
              onPressed: sending ? null : onAttach,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: AppColors.divider)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.arrow_upward_rounded,
                      color: AppColors.primary),
              onPressed: sending ? null : onSend,
            ),
          ],
        ),
      ),
    );
  }
}
