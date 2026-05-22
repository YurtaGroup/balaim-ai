import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../consult_provider.dart';
import '../models/consultation.dart';
import 'consult_status_chip.dart';

/// The doctor's whole world: every family's consultations, newest
/// activity first. Awaiting-reply threads float to attention via the
/// status chip. Reached only by the doctor account (router redirect).
class DoctorInboxScreen extends ConsumerWidget {
  const DoctorInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final inbox = ref.watch(doctorInboxProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(lang,
            en: 'Consultations', ru: 'Консультации', ky: 'Консультациялар')),
        actions: [
          IconButton(
            tooltip: tr(lang, en: 'Sign out', ru: 'Выйти', ky: 'Чыгуу'),
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              ref.invalidate(authStateProvider);
            },
          ),
        ],
      ),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(tr(lang,
              en: 'Could not load consultations.',
              ru: 'Не удалось загрузить консультации.',
              ky: 'Консультациялар жүктөлгөн жок.')),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  tr(lang,
                      en: 'No consultations yet. New ones from families show up here.',
                      ru: 'Пока нет консультаций. Новые от семей появятся здесь.',
                      ky: 'Азырынча консультация жок. Үй-бүлөлөрдөн жаңылары ушул жерден чыгат.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _InboxRow(consult: list[i]),
          );
        },
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  final Consultation consult;
  const _InboxRow({required this.consult});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/consult/${consult.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${consult.parentName} · ${consult.topic}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ConsultStatusChip(status: consult.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(consult.lastMessagePreview,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                DateFormat.MMMd(Localizations.localeOf(context).toString())
                    .add_jm()
                    .format(consult.lastMessageAt),
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
