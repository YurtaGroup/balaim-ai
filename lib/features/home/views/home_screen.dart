import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/moment.dart';
import '../../child/providers/moments_provider.dart';
import '../../care_log/quick_log_strip.dart';
import '../../emergency/widgets/emergency_entry_pill.dart';
import '../../family/views/add_member_sheet.dart';
import '../../journey/providers/journey_provider.dart';
import '../../montessori/invitation_card.dart';
import '../../mood/mood_card.dart';
import '../../mood/mood_provider.dart';
import '../../sleep_coach/sleep_help_entry.dart';
import '../../paywall/add_child_gate.dart';
import '../models/daily_brief.dart';
import '../providers/daily_brief_provider.dart';
import '../widgets/sunday_chapter_card.dart';

/// v3 Home — one card. The agent did the work overnight; mom opens
/// the app and reads the brief. Nothing else above the fold.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final children = profile.members.where((m) => m.role == MemberRole.child).toList();
    final selectedMember = profile.selectedMember;
    final activeChild = (selectedMember != null && selectedMember.role == MemberRole.child)
        ? selectedMember
        : (children.isNotEmpty ? children.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr(currentLang(context), en: 'Balam', ru: 'Balam', ky: 'Balam')),
        actions: [
          IconButton(
            tooltip: tr(currentLang(context), en: 'More', ru: 'Ещё', ky: 'Көбүрөөк'),
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showOverflow(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dailyBriefProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _ChildHeader(
              children: children,
              activeChild: activeChild,
              onSelect: (id) => ref.read(userProfileProvider.notifier).selectChild(id),
              onAdd: () {
                if (ensureCanAddChild(context, ref)) {
                  AddMemberSheet.show(context);
                }
              },
            ),
            if (activeChild != null) ...[
              const SizedBox(height: 14),
              QuickLogStrip(child: activeChild),
            ],
            if (activeChild != null) ...[
              const SizedBox(height: 14),
              const SundayChapterCard(),
            ],
            const SizedBox(height: 14),
            const _MoodNudge(),
            const MoodCard(),
            if (activeChild != null) ...[
              const SizedBox(height: 14),
              const InvitationCard(),
              const SizedBox(height: 14),
              const _DebriefHero(),
              const SizedBox(height: 14),
              _YesterdaysWin(childId: activeChild.id),
            ],
            const SizedBox(height: 18),
            if (activeChild != null) ...[
              SleepHelpEntry(child: activeChild),
              const SizedBox(height: 10),
            ],
            const EmergencyEntryPill(),
          ],
        ),
      ),
    );
  }

  void _showOverflow(BuildContext context) {
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
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            _OverflowTile(
              icon: Icons.tune_outlined,
              label: tr(currentLang(ctx), en: 'Settings', ru: 'Настройки', ky: 'Жөндөөлөр'),
              onTap: () {
                Navigator.of(ctx).pop();
                ctx.push('/settings');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── Debrief hero ──────────────────────────────────────────────────

class _DebriefHero extends ConsumerWidget {
  const _DebriefHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBrief = ref.watch(dailyBriefProvider);
    return asyncBrief.when(
      data: (brief) => brief == null
          ? const _DebriefLoading()
          : _DebriefCard(brief: brief),
      loading: () => const _DebriefLoading(),
      error: (e, _) => const _DebriefLoading(),
    );
  }
}

class _DebriefCard extends StatelessWidget {
  final DailyBrief brief;
  const _DebriefCard({required this.brief});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                child: const Icon(Icons.wb_twilight, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                tr(currentLang(context),
                    en: "Today's brief",
                    ru: 'Бриф на сегодня',
                    ky: 'Бүгүнкү маалыматтама'),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            brief.headline,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            brief.body,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (brief.ctas.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: brief.ctas.map((cta) => _CtaButton(cta: cta, brief: brief)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final BriefCta cta;
  final DailyBrief brief;
  const _CtaButton({required this.cta, required this.brief});

  @override
  Widget build(BuildContext context) {
    final isPrimary = cta.type == BriefCtaType.chat;
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            cta.label,
            style: TextStyle(
              color: isPrimary ? Colors.white : AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    switch (cta.type) {
      case BriefCtaType.chat:
        final prefill = cta.prefill;
        if (prefill != null && prefill.isNotEmpty) {
          context.go('/ask?prefill=${Uri.encodeComponent(prefill)}');
        } else {
          context.go('/ask');
        }
        break;
      case BriefCtaType.share:
        final text = cta.shareText ?? brief.headline;
        Share.share(text);
        break;
      case BriefCtaType.next:
        context.go('/child');
        break;
      case BriefCtaType.emergency:
        context.push('/emergency');
        break;
    }
  }
}

class _DebriefLoading extends StatelessWidget {
  const _DebriefLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr(currentLang(context),
                      en: 'Balam is putting today together…',
                      ru: 'Balam собирает сегодняшний бриф…',
                      ky: 'Balam бүгүнкү маалыматтаманы даярдап жатат…'),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _shimmerLine(height: 18, widthFactor: 0.7),
          const SizedBox(height: 10),
          _shimmerLine(height: 14, widthFactor: 1.0),
          const SizedBox(height: 6),
          _shimmerLine(height: 14, widthFactor: 0.85),
        ],
      ),
    );
  }

  Widget _shimmerLine({required double height, required double widthFactor}) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

// ─── Yesterday's win ──────────────────────────────────────────────

class _YesterdaysWin extends ConsumerWidget {
  final String childId;
  const _YesterdaysWin({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(momentsProvider);
    final recent = _mostRecentForChild(moments, childId);
    if (recent == null) return const SizedBox.shrink();
    final daysAgo = DateTime.now().difference(recent.date).inDays;
    if (daysAgo > 7) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.favorite, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _whenLabel(context, daysAgo),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recent.caption,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Moment? _mostRecentForChild(List<Moment> moments, String childId) {
    final relevant = moments
        .where((m) => m.childId == childId || m.childId == null)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return relevant.isEmpty ? null : relevant.first;
  }

  String _whenLabel(BuildContext context, int daysAgo) {
    if (daysAgo == 0) {
      return tr(currentLang(context), en: 'TODAY', ru: 'СЕГОДНЯ', ky: 'БҮГҮН');
    }
    if (daysAgo == 1) {
      return tr(currentLang(context), en: 'YESTERDAY', ru: 'ВЧЕРА', ky: 'КЕЧЭЭ');
    }
    return tr(currentLang(context),
        en: '$daysAgo DAYS AGO',
        ru: '$daysAgo ДНЕЙ НАЗАД',
        ky: '$daysAgo КҮН МУРДА');
  }
}

// ─── Child chip header (unchanged from v2) ────────────────────────

class _ChildHeader extends StatelessWidget {
  final List<HouseholdMember> children;
  final HouseholdMember? activeChild;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  const _ChildHeader({
    required this.children,
    required this.activeChild,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return _EmptyHeader(onAdd: onAdd);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: children.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              if (i == children.length) {
                return _AddChildChip(onTap: onAdd);
              }
              final c = children[i];
              final selected = c.id == activeChild?.id;
              return GestureDetector(
                onTap: () => onSelect(c.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.primary : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        _iconFor(c),
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 60,
                      child: Text(
                        c.name.split(' ').first,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconFor(HouseholdMember c) {
    final months = c.ageMonths ?? 0;
    if (months < 12) return Icons.child_care;
    return Icons.child_friendly;
  }
}

class _EmptyHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.child_care, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(currentLang(context),
                      en: 'Add your child to start',
                      ru: 'Добавь ребёнка, чтобы начать',
                      ky: 'Баштоо үчүн балаңызды кошуңуз'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr(currentLang(context),
                      en: "Balam needs a name + date of birth to tailor age-appropriate notices and to index your child's records.",
                      ru: 'Balam нужно имя и дата рождения, чтобы присылать уместные напоминания и разобрать медкарту.',
                      ky: 'Balam-га тиешелүү эскертүү жана медкартаны иретке салуу үчүн аты жана туулган күнү керек.'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(tr(currentLang(context),
                      en: 'Add child',
                      ru: 'Добавить ребёнка',
                      ky: 'Бала кошуу')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddChildChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChildChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: const Icon(Icons.add, color: AppColors.textHint, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            tr(currentLang(context), en: 'Add', ru: 'Добавить', ky: 'Кошуу'),
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

/// The "I see you" pill — surfaces above the MoodCard when Mom has had
/// a few hard days in a row OR has gone quiet for several days. Reads
/// the moodState/summary aggregate that the trigger maintains.
class _MoodNudge extends ConsumerWidget {
  const _MoodNudge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(moodSummaryProvider).asData?.value;
    if (summary == null) return const SizedBox.shrink();

    final lang = currentLang(context);
    String? message;

    if (summary.hasUnacknowledgedCrisis) {
      message = tr(lang,
          en: "What you wrote last time isn't something to sit with alone. Open the thread when you're ready.",
          ru: 'То, что ты написала, не стоит держать в себе. Открой переписку, когда будешь готова.',
          ky: 'Жазганың өзүң менен жалгыз отурууга арзыбайт. Даяр болгондо тизмекти ачкын.');
    } else if (summary.streakHardDays >= 3) {
      message = tr(lang,
          en: "A few hard days in a row. I'm here when you want to talk.",
          ru: 'Несколько тяжёлых дней подряд. Я рядом, когда захочешь поговорить.',
          ky: 'Бир нече күн оор болду. Сүйлөшкүң келгенде мен бармын.');
    } else if (summary.isSilent) {
      message = tr(lang,
          en: 'Hey. How are you, really?',
          ru: 'Слушай. Как ты на самом деле?',
          ky: 'Эй. Чындыгында кандайсың?');
    }

    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/mood'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.30)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.accent, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverflowTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OverflowTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
