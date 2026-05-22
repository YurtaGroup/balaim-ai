import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../consult_config.dart';
import '../consult_provider.dart';
import '../models/consultation.dart';
import 'consult_status_chip.dart';

/// The parent's consultation home — start a consult, see past threads.
class ConsultListScreen extends ConsumerWidget {
  const ConsultListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    final consults = ref.watch(myConsultationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(lang,
            en: 'Talk to a doctor',
            ru: 'Врач-консультант',
            ky: 'Дарыгер менен кеңеш')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/consult/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(tr(lang,
            en: 'New consultation',
            ru: 'Новая консультация',
            ky: 'Жаңы консультация')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          // Doctor intro.
          Container(
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
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.medical_services,
                      color: Colors.white, size: 22),
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
                      Text(
                        tr(lang,
                            en: 'A private, paid consultation for you, mom & dad — your own health, answered by a real specialist.',
                            ru: 'Личная платная консультация для мамы и папы — твоё здоровье, ответ настоящего специалиста.',
                            ky: 'Апа жана ата үчүн жеке акылуу консультация — өз ден соолугуң, чыныгы адистин жообу.'),
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr(lang,
                en: 'Your consultations',
                ru: 'Твои консультации',
                ky: 'Сенин консультацияларың'),
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          consults.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(tr(lang,
                en: 'Could not load your consultations.',
                ru: 'Не удалось загрузить консультации.',
                ky: 'Консультациялар жүктөлгөн жок.')),
            data: (list) => list.isEmpty
                ? _Empty(lang: lang)
                : Column(
                    children: list
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ConsultRow(consult: c),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String lang;
  const _Empty({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        tr(lang,
            en: 'No consultations yet. Tap "New consultation" to ask $kDoctorName your first question.',
            ru: 'Пока нет консультаций. Нажми «Новая консультация», чтобы задать $kDoctorName первый вопрос.',
            ky: 'Азырынча консультация жок. «Жаңы консультация» басып, $kDoctorName-га биринчи сурооңду бер.'),
        style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}

class _ConsultRow extends StatelessWidget {
  final Consultation consult;
  const _ConsultRow({required this.consult});

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
                    child: Text(consult.topic,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  ConsultStatusChip(status: consult.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(consult.lastMessagePreview,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
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
