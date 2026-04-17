import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/tracking_entry.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../journey/providers/journey_provider.dart';
import '../../journey/views/tracking_sheet.dart';
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
    final isPregnant = profile.stage == ParentingStage.pregnant ||
        profile.stage == ParentingStage.tryingToConceive;
    final name = profile.babyName ?? l.myBaby;
    final age = profile.babyAgeMonths ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navToday),
        actions: const [NotificationBell()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              isPregnant
                  ? '${l.weekN(profile.currentWeek ?? 24)} 🤰'
                  : '$name, $age ${l.months} 🐆',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 20),

            // Card 1: This Week's Focus
            _FocusCard(
              title: l.thisWeeksFocus,
              subtitle: focus.title,
              body: focus.body,
              icon: focus.icon,
              actionLabel: l.askBalamAboutThis,
              onAction: () => context.go('/ai?prefill=${Uri.encodeComponent(focus.aiPrefill)}'),
            ),
            const SizedBox(height: 14),

            // Card 2: Today's Activity
            _ActivityCard(
              title: l.todaysActivity,
              body: activity,
              actionLabel: l.tryThisToday,
            ),
            const SizedBox(height: 14),

            // Card 3: Quick Tracking
            _TrackingCard(
              title: l.trackToday,
              stage: profile.stage,
              onTrack: (type) => _showSheet(context, type),
            ),
            const SizedBox(height: 14),

            // Card 4: Is This Normal?
            _WorryCard(
              title: l.isThisNormalCard,
              worryTitle: worry.$1,
              worryBody: worry.$2,
              onTap: () => context.go('/ai?prefill=${Uri.encodeComponent(worry.$3)}'),
            ),
            const SizedBox(height: 14),

            // Card 4.5: Consult a real doctor (funnel to Professionals)
            _ConsultDoctorCard(
              title: l.todayConsultDoctorTitle,
              body: l.todayConsultDoctorBody,
              cta: l.todayConsultDoctorCta,
              onTap: () => context.go('/professionals'),
            ),
            const SizedBox(height: 14),

            // Card 5: Daily Insight
            _InsightCard(
              title: l.dailyInsightCard,
              body: insight,
            ),
            const SizedBox(height: 14),

            // Card 6: First Moments CTA (baby stages only)
            if (!isPregnant)
              GestureDetector(
                onTap: () => context.push('/moments'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary.withValues(alpha: 0.1), AppColors.accent.withValues(alpha: 0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: AppColors.secondary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.firstMoments, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(l.captureFirsts, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppColors.textHint, size: 14),
                    ],
                  ),
                ),
              ),
            if (!isPregnant) const SizedBox(height: 14),

            // Card 7: Recommended Product
            Builder(builder: (context) {
              final products = isPregnant
                  ? SeedData.getProductsForStage(profile.stage)
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
