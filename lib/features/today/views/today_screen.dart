import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart' show localeProvider;
import '../../../shared/models/child_model.dart';
import '../../../shared/models/tracking_entry.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../journey/providers/journey_provider.dart';
import '../../journey/views/tracking_sheet.dart';
import '../../balam_box/views/box_entry_sheet.dart';
import '../../family/views/add_member_sheet.dart';
import '../../family/views/family_completeness_card.dart';
import '../../notices/notice_card.dart';
import '../providers/today_provider.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final profile = ref.watch(userProfileProvider);
    final focus = ref.watch(todayFocusProvider);
    final activity = ref.watch(todayActivityProvider);
    final worry = ref.watch(todayWorryProvider);
    final insight = ref.watch(todayInsightProvider);

    // Member-centric context — the whole screen adapts to who's selected.
    // `isChildInStage` gates the pregnancy/newborn/toddler cards so adult
    // members (self/partner/mother/father/grandparent/…) don't see
    // "Week 24 🤰" or baby-focused tips.
    final member = profile.selectedMember;
    final memberStage = member?.stage ?? profile.stage;
    final isChildInStage = member != null &&
        member.role.isChild &&
        (memberStage == ParentingStage.pregnant ||
            memberStage == ParentingStage.newborn ||
            memberStage == ParentingStage.toddler);
    final isPregnantMember = member != null &&
        member.role.isChild &&
        memberStage == ParentingStage.pregnant;
    // Age for the product-recommendation card inside the child block.
    // The greeting has its own name/age logic in _Greeting.
    final age = member?.ageMonths ?? profile.babyAgeMonths ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navToday),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: l.settings,
            onPressed: () => _showSettingsSheet(context, ref),
          ),
          const NotificationBell(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting — adapts to the selected member so switching to
            // an adult relative doesn't leave pregnancy-week copy on screen.
            _Greeting(member: member, profile: profile, l: l),
            const SizedBox(height: 12),

            // Household member switcher — horizontal avatar row
            _MemberSwitcher(
              members: profile.members,
              selectedId: profile.selectedMember?.id,
              onSelect: (id) {
                ref.read(userProfileProvider.notifier).selectChild(id);
              },
              onAdd: () => AddMemberSheet.show(context),
            ),
            const SizedBox(height: 16),

            // Quick Access row — Lab, Doctors, Moments (or Notifications if pregnant)
            Row(
              children: [
                Expanded(
                  child: _QuickAccessTile(
                    icon: Icons.folder_shared_outlined,
                    label: tr(currentLang(context),
                        en: 'Vault',
                        ru: 'Медкарта',
                        ky: 'Медкарта'),
                    gradient: const [Color(0xFF34C759), Color(0xFF1DA34F)],
                    onTap: () => context.push('/vault'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAccessTile(
                    icon: Icons.medical_services_outlined,
                    label: l.myCareTeam,
                    gradient: const [Color(0xFF5E8CF7), Color(0xFF3A6EE2)],
                    onTap: () => context.push('/professionals'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAccessTile(
                    icon: isPregnantMember ? Icons.notifications_outlined : Icons.camera_alt_outlined,
                    label: isPregnantMember ? l.notifications : l.firstMoments,
                    gradient: const [Color(0xFFE8787A), Color(0xFFBE5053)],
                    onTap: () => context.push(isPregnantMember ? '/notifications' : '/moments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Family Completeness — the viral acquisition card.
            // Self-hides once the family has 2+ members. Tapping opens
            // AddMemberSheet which immediately offers a WhatsApp invite.
            const FamilyCompletenessCard(),
            const SizedBox(height: 14),

            // Balam Box — primary CTA to log a reading (BP / glucose /
            // temperature). Server classifies Green/Yellow/Orange/Red and
            // routes to the notices engine + clinician queue as needed.
            _BalamBoxCTA(onTap: () => BoxEntrySheet.show(context)),
            const SizedBox(height: 14),

            // The App That Notices — proactive nudge card
            // Self-hides if there's nothing to show for the active member.
            const NoticeCard(),

            // ── Baby / pregnancy / toddler cards ──
            // These only render when the selected member is a child in
            // one of the parenting stages. For adult members (self /
            // partner / mother / father / grandparent / …) we skip them
            // so the screen doesn't show "Week 24" or toddler tips that
            // aren't about the person the user is looking at.
            if (isChildInStage) ...[
              _FocusCard(
                title: l.thisWeeksFocus,
                subtitle: focus.title,
                body: focus.body,
                icon: focus.icon,
                actionLabel: l.askBalamAboutThis,
                onAction: () => context.go('/ai?prefill=${Uri.encodeComponent(focus.aiPrefill)}'),
              ),
              const SizedBox(height: 14),
              _ActivityCard(
                title: l.todaysActivity,
                body: activity,
                actionLabel: l.tryThisToday,
              ),
              const SizedBox(height: 14),
              _TrackingCard(
                title: l.trackToday,
                stage: memberStage,
                onTrack: (type) => _showSheet(context, type),
              ),
              const SizedBox(height: 14),
              _WorryCard(
                title: l.isThisNormalCard,
                worryTitle: worry.$1,
                worryBody: worry.$2,
                onTap: () => context.go('/ai?prefill=${Uri.encodeComponent(worry.$3)}'),
              ),
              const SizedBox(height: 14),
            ],

            // ── Universal cards (every member, every stage) ──
            _ConsultDoctorCard(
              title: l.todayConsultDoctorTitle,
              body: l.todayConsultDoctorBody,
              cta: l.todayConsultDoctorCta,
              onTap: () => context.go('/professionals'),
            ),
            const SizedBox(height: 14),

            // Adult members get an "Ask Balam about {name}" shortcut in
            // place of the baby-focused Focus card. The AI is already
            // grounded in the member's vault (vault_retrieval.ts), so
            // tapping opens a productive conversation from zero.
            if (!isChildInStage && member != null) ...[
              _AskBalamCard(memberName: member.name),
              const SizedBox(height: 14),
            ],

            // ── Child-only footer cards (insight + recommended product) ──
            if (isChildInStage) ...[
              _InsightCard(
                title: l.dailyInsightCard,
                body: insight,
              ),
              const SizedBox(height: 14),
              Builder(builder: (context) {
                final products = isPregnantMember
                    ? SeedData.getProductsForStage(memberStage)
                    : SeedData.getProductsForAge(age);
                if (products.isEmpty) return const SizedBox.shrink();
                final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
                final product = products[dayOfYear % products.length];
                final vendor = SeedData.getVendor(product.vendorId);
                return _ProductCard(
                  title: l.recommendedForYou,
                  productName: product.name.en,
                  vendorName: vendor?.name.en ?? '',
                  price: product.priceFormatted,
                  icon: product.icon,
                  iconColor: product.iconColor,
                  onTap: () => context.go('/marketplace'),
                );
              }),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, TrackingType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TrackingSheet(type: type),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card Widgets
// ─────────────────────────────────────────────

class _FocusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  const _FocusCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultDoctorCard extends StatelessWidget {
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  const _ConsultDoctorCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        cta,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String body;
  final String actionLabel;

  const _ActivityCard({
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.extension, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.secondaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            actionLabel,
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final String title;
  final ParentingStage stage;
  final Function(TrackingType) onTrack;

  const _TrackingCard({
    required this.title,
    required this.stage,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final actions = _getTrackingActions(l);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTrack(a.type),
                  child: Container(
                    margin: EdgeInsets.only(right: a != actions.last ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(a.icon, color: a.color, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          a.label,
                          style: TextStyle(
                            color: a.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<_TrackAction> _getTrackingActions(L l) {
    if (stage == ParentingStage.pregnant || stage == ParentingStage.tryingToConceive) {
      return [
        _TrackAction(Icons.monitor_weight_outlined, l.weight, AppColors.primary, TrackingType.weight),
        _TrackAction(Icons.water_drop_outlined, l.water, AppColors.secondary, TrackingType.water),
        _TrackAction(Icons.bedtime_outlined, l.sleep, AppColors.accent, TrackingType.sleep),
        _TrackAction(Icons.baby_changing_station, l.kicks, AppColors.stagePrePregnancy, TrackingType.kicks),
      ];
    }
    if (stage == ParentingStage.newborn) {
      return [
        _TrackAction(Icons.restaurant, l.feeding, AppColors.primary, TrackingType.feeding),
        _TrackAction(Icons.bedtime_outlined, l.sleep, AppColors.accent, TrackingType.sleep),
        _TrackAction(Icons.baby_changing_station, l.diaper, AppColors.secondary, TrackingType.diaper),
      ];
    }
    // Toddler
    return [
      _TrackAction(Icons.bedtime_outlined, l.sleep, AppColors.accent, TrackingType.sleep),
      _TrackAction(Icons.restaurant, l.feeding, AppColors.primary, TrackingType.feeding),
      _TrackAction(Icons.monitor_weight_outlined, l.weight, AppColors.stagePrePregnancy, TrackingType.weight),
    ];
  }
}

class _TrackAction {
  final IconData icon;
  final String label;
  final Color color;
  final TrackingType type;
  const _TrackAction(this.icon, this.label, this.color, this.type);
}

class _WorryCard extends StatelessWidget {
  final String title;
  final String worryTitle;
  final String worryBody;
  final VoidCallback onTap;

  const _WorryCard({
    required this.title,
    required this.worryTitle,
    required this.worryBody,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline, color: AppColors.accentDark, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.accentDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textHint, size: 14),
              ],
            ),
            const SizedBox(height: 10),
            Text(worryTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
            const SizedBox(height: 4),
            Text(worryBody, style: TextStyle(fontSize: 13, color: AppColors.textHint, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String body;

  const _InsightCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String productName;
  final String vendorName;
  final String price;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProductCard({
    required this.title,
    required this.productName,
    required this.vendorName,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (vendorName.isNotEmpty)
                    Text(vendorName, style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Household member switcher — horizontal avatar row
// ─────────────────────────────────────────────

class _MemberSwitcher extends StatelessWidget {
  final List<HouseholdMember> members;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  const _MemberSwitcher({
    required this.members,
    required this.selectedId,
    required this.onSelect,
    required this.onAdd,
  });

  IconData _iconForRole(MemberRole role, ParentingStage? stage) {
    if (role == MemberRole.child) {
      if (stage == ParentingStage.pregnant) return Icons.pregnant_woman;
      if (stage == ParentingStage.newborn) return Icons.child_care;
      return Icons.child_friendly;
    }
    switch (role) {
      case MemberRole.self:
        return Icons.person;
      case MemberRole.partner:
        return Icons.favorite;
      case MemberRole.mother:
        return Icons.face_3;
      case MemberRole.father:
        return Icons.face_6;
      case MemberRole.grandmother:
      case MemberRole.grandfather:
        return Icons.elderly;
      case MemberRole.sibling:
        return Icons.people;
      case MemberRole.uncleAunt:
        return Icons.group;
      default:
        return Icons.person_outline;
    }
  }

  Color _colorForRole(MemberRole role) {
    switch (role) {
      case MemberRole.child:
        return AppColors.primary;
      case MemberRole.self:
        return AppColors.secondary;
      case MemberRole.partner:
        return AppColors.error;
      case MemberRole.mother:
      case MemberRole.grandmother:
        return AppColors.accent;
      case MemberRole.father:
      case MemberRole.grandfather:
        return AppColors.secondaryDark;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: members.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == members.length) return _AddMemberChip(onTap: onAdd);
          final m = members[i];
          final selected = m.id == selectedId;
          final color = _colorForRole(m.role);
          return GestureDetector(
            onTap: () => onSelect(m.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? color : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(_iconForRole(m.role, m.stage), color: color, size: 24),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 56,
                  child: Text(
                    m.name.split(' ').first,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? color : AppColors.textSecondary,
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
    );
  }
}

class _AddMemberChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMemberChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: const Icon(Icons.add, color: AppColors.textHint, size: 22),
          ),
          const SizedBox(height: 4),
          const SizedBox(
            width: 56,
            child: Text(
              '+',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Member-aware greeting
// ─────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  final HouseholdMember? member;
  final UserProfile profile;
  final L l;

  const _Greeting({required this.member, required this.profile, required this.l});

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _compute(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  (String, String?) _compute(BuildContext context) {
    final m = member;
    if (m == null) {
      // Legacy fallback — keep the historical copy while account has no members.
      final isPregnant = profile.stage == ParentingStage.pregnant ||
          profile.stage == ParentingStage.tryingToConceive;
      if (isPregnant) {
        return ('${l.weekN(profile.currentWeek ?? 24)} 🤰', null);
      }
      final name = profile.babyName ?? l.myBaby;
      final age = profile.babyAgeMonths ?? 0;
      return ('$name, $age ${l.months} 🐆', null);
    }

    // Self — owner viewing their own Today.
    if (m.role == MemberRole.self) {
      final firstName = m.name.split(' ').first;
      return (
        tr(currentLang(context),
            en: 'Hi, $firstName',
            ru: 'Привет, $firstName',
            ky: 'Салам, $firstName'),
        tr(currentLang(context), en: 'You', ru: 'Вы', ky: 'Сиз'),
      );
    }

    // Pregnant child (the classic week-hero).
    if (m.role.isChild && m.stage == ParentingStage.pregnant) {
      final week = m.currentWeek ?? profile.currentWeek ?? 24;
      return ('${l.weekN(week)} 🤰', m.name);
    }

    // Child under 12 months — age in months with the baby leopard.
    if (m.role.isChild) {
      final months = m.ageMonths;
      if (months != null && months < 12) {
        return ('${m.name}, $months ${l.months} 🐆', null);
      }
      final years = m.ageYears;
      if (years != null) {
        return ('${m.name}, ${years}y 🐆', null);
      }
      return ('${m.name} 🐆', null);
    }

    // Adult relative — plain name + role label.
    return (m.name, _roleLabel(m.role, context));
  }

  String _roleLabel(MemberRole r, BuildContext ctx) {
    final lang = currentLang(ctx);
    switch (r) {
      case MemberRole.mother:
        return tr(lang, en: 'Mother', ru: 'Мама', ky: 'Апа');
      case MemberRole.father:
        return tr(lang, en: 'Father', ru: 'Папа', ky: 'Ата');
      case MemberRole.partner:
        return tr(lang, en: 'Partner', ru: 'Супруг(а)', ky: 'Жубай');
      case MemberRole.grandmother:
        return tr(lang, en: 'Grandmother', ru: 'Бабушка', ky: 'Чоң эне');
      case MemberRole.grandfather:
        return tr(lang, en: 'Grandfather', ru: 'Дедушка', ky: 'Чоң ата');
      case MemberRole.sibling:
        return tr(lang, en: 'Sibling', ru: 'Брат/Сестра', ky: 'Бир тууган');
      case MemberRole.uncleAunt:
        return tr(lang, en: 'Uncle/Aunt', ru: 'Дядя/Тётя', ky: 'Таяке/Эже');
      case MemberRole.other:
        return tr(lang, en: 'Family', ru: 'Семья', ky: 'Үй-бүлө');
      case MemberRole.self:
        return tr(lang, en: 'You', ru: 'Вы', ky: 'Сиз');
      case MemberRole.child:
        return tr(lang, en: 'Child', ru: 'Ребёнок', ky: 'Бала');
    }
  }
}

// ─────────────────────────────────────────────
// Adult "Ask Balam about {name}" shortcut
// ─────────────────────────────────────────────

class _AskBalamCard extends StatelessWidget {
  final String memberName;
  const _AskBalamCard({required this.memberName});

  @override
  Widget build(BuildContext context) {
    final firstName = memberName.split(' ').first;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(
          '/ai?prefill=${Uri.encodeComponent(tr(currentLang(context), en: "Tell me what you know about $firstName from their records.", ru: "Расскажи, что ты знаешь про $firstName по её записям.", ky: "$firstName тууралуу жазууларынан эмне билесиң айтчы."))}',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(currentLang(context),
                          en: 'Ask Balam about $firstName',
                          ru: 'Спроси Balam про $firstName',
                          ky: '$firstName тууралуу Balam-дан сура'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(currentLang(context),
                          en: 'Balam knows their records and reads them before answering.',
                          ru: 'Balam знает записи и читает их перед ответом.',
                          ky: 'Balam жазууларды биле алат жана жооп берүү алдында окуйт.'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textHint, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Balam Box CTA
// ─────────────────────────────────────────────

class _BalamBoxCTA extends ConsumerWidget {
  final VoidCallback onTap;
  const _BalamBoxCTA({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8787A), Color(0xFFBE5053)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8787A).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_chart, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pick(context,
                          en: 'Balam Box',
                          ru: 'Balam Box',
                          ky: 'Balam Box'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _pick(context,
                          en: 'Log BP, glucose, or temperature — clinician-reviewed',
                          ru: 'Давление, глюкоза, температура — разбор врачом',
                          ky: 'Басым, глюкоза, температура — дарыгер карайт'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  String _pick(BuildContext context, {required String en, required String ru, required String ky}) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ru') return ru;
    if (lang == 'ky') return ky;
    return en;
  }
}

// ─────────────────────────────────────────────
// Quick Access Tile
// ─────────────────────────────────────────────

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Settings bottom sheet (accessed from AppBar gear)
// ─────────────────────────────────────────────

void _showSettingsSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) {
      final l = L.of(sheetCtx);
      final current = ref.read(localeProvider)?.languageCode;
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(l.settings, style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            Text('Language / Тил / Язык',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textHint)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LangPill(label: 'English', code: 'en', current: current),
                _LangPill(label: 'Русский', code: 'ru', current: current),
                _LangPill(label: 'Кыргызча', code: 'ky', current: current),
              ],
            ),
            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
              title: Text(l.notifications),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push('/notifications');
              },
            ),
            const Divider(height: 1),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(l.signOut, style: const TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                await AuthService().signOut();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _LangPill extends ConsumerWidget {
  final String label;
  final String code;
  final String? current;

  const _LangPill({required this.label, required this.code, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = current == code;
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
