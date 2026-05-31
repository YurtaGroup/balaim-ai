import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/content_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import 'invitation_models.dart';
import 'invitation_provider.dart';
import 'montessori_taxonomy.dart';

/// Today's Montessori Invitation.
///
/// Sits on Home, below the MoodCard and above Today's Debrief. One
/// activity, never three. Real tools, never purchases. Process, never
/// product. The "follow the child" implementation lives in the
/// generator's hard rules.
class InvitationCard extends ConsumerWidget {
  const InvitationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(invitationProvider);
    return async.when(
      data: (inv) => inv == null
          ? const _Loading()
          : _Card(invitation: inv),
      loading: () => const _Loading(),
      error: (_, _) => const _Loading(),
    );
  }
}

class _Card extends ConsumerWidget {
  final Invitation invitation;
  const _Card({required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco_outlined,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr(lang,
                      en: "Today's Invitation",
                      ru: 'Сегодняшнее приглашение',
                      ky: 'Бүгүнкү сунуш'),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                '${invitation.setupMinutes} ${tr(lang, en: 'min', ru: 'мин', ky: 'мин')}',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            invitation.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            invitation.whyOneLine,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
          if (invitation.setupSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var i = 0; i < invitation.setupSteps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 1),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        invitation.setupSteps[i],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (invitation.category != MontessoriCategory.unknown)
                _PeriodChip(
                  icon: invitation.category.icon,
                  label: invitation.category.label,
                  color: AppColors.primary,
                ),
              for (final p in invitation.sensitivePeriods)
                _PeriodChip(label: p.label, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 14),
          _ActionRow(invitation: invitation),
        ],
      ),
    );
  }
}

class _ActionRow extends ConsumerWidget {
  final Invitation invitation;
  const _ActionRow({required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = currentLang(context);
    if (invitation.feedback != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(invitation.feedback!.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _feedbackLabel(invitation.feedback!, lang),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _FeedbackButton(
            icon: InvitationFeedback.loved.icon,
            label: tr(lang,
                en: 'Loved it',
                ru: 'Зашло',
                ky: 'Жакты'),
            onTap: () => _record(ref, InvitationFeedback.loved),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _FeedbackButton(
            icon: InvitationFeedback.lostInterest.icon,
            label: tr(lang,
                en: 'Lost interest',
                ru: 'Не пошло',
                ky: 'Жакпады'),
            onTap: () => _record(ref, InvitationFeedback.lostInterest),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _FeedbackButton(
            icon: InvitationFeedback.tooEarly.icon,
            label: tr(lang,
                en: 'Too early',
                ru: 'Рано',
                ky: 'Эрте'),
            onTap: () => _record(ref, InvitationFeedback.tooEarly),
          ),
        ),
      ],
    );
  }

  Future<void> _record(WidgetRef ref, InvitationFeedback feedback) async {
    final uid = ref.read(currentUserInfoProvider).uid;
    if (uid == null) return;
    await setInvitationFeedback(
      uid: uid,
      invitationId: invitation.id,
      feedback: feedback,
    );
  }

  String _feedbackLabel(InvitationFeedback f, String lang) {
    switch (f) {
      case InvitationFeedback.loved:
        return tr(lang,
            en: "Logged — Balam will press on this thread tomorrow.",
            ru: 'Записано — Balam продолжит эту линию завтра.',
            ky: 'Жазылды — Balam эртең ушул багыт менен улантат.');
      case InvitationFeedback.lostInterest:
        return tr(lang,
            en: "Logged — tomorrow we'll try a different angle.",
            ru: 'Записано — завтра попробуем по-другому.',
            ky: 'Жазылды — эртең башка ыкма менен сынайбыз.');
      case InvitationFeedback.tooEarly:
        return tr(lang,
            en: "Logged — we'll revisit this in a few weeks.",
            ru: 'Записано — вернёмся к этому через пару недель.',
            ky: 'Жазылды — бир нече жумадан кийин кайра карайбыз.');
    }
  }
}

class _FeedbackButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String? icon;
  final Color color;
  const _PeriodChip({required this.label, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final lang = currentLang(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tr(lang,
                  en: "Balam is composing today's invitation…",
                  ru: 'Balam готовит приглашение на сегодня…',
                  ky: 'Balam бүгүнкү сунушту даярдап жатат…'),
              style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
