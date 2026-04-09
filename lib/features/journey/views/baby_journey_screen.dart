import '../../../l10n/app_localizations.dart';
import '../../../core/l10n/content_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/seed_data.dart';
import '../../../shared/models/baby_month_data.dart';
import '../../../shared/models/tracking_entry.dart';
import '../../../shared/widgets/gradient_banner.dart';
import '../../../shared/widgets/pattern_background.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../providers/journey_provider.dart';
import 'tracking_sheet.dart';

class BabyJourneyScreen extends ConsumerWidget {
  const BabyJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final ageMonths = profile.babyAgeMonths ?? 6;
    final monthData = BabyMonthData.getMonth(ageMonths);
    final ageDays = profile.babyAgeDays ?? 180;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.babyName ?? L.of(context).myBaby),
        actions: [
          const NotificationBell(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age banner with pattern
            GradientBanner(
              colors: const [AppColors.secondary, AppColors.secondaryDark],
              patternStyle: PatternStyle.hearts,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthData.ageLabel.of(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          L.of(context).daysOld(ageDays),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            monthData.title.of(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Growth stats
            Row(
              children: [
                _StatChip(
                  label: L.of(context).avgWeightBoy,
                  value: '${monthData.avgWeightKgBoy} kg',
                  icon: Icons.monitor_weight_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: L.of(context).avgWeightGirl,
                  value: '${monthData.avgWeightKgGirl} kg',
                  icon: Icons.monitor_weight_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: L.of(context).avgHeight,
                  value: '${monthData.avgHeightCmBoy} cm',
                  icon: Icons.straighten,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick tracking
            SectionHeader(title: L.of(context).trackToday, subtitle: L.of(context).tapToLog, accentColor: AppColors.primary),
            const SizedBox(height: 12),
            Row(
              children: [
                _TrackAction(
                  icon: Icons.restaurant,
                  label: L.of(context).feeding,
                  color: AppColors.primary,
                  onTap: () => _showSheet(context, TrackingType.feeding),
                ),
                const SizedBox(width: 12),
                _TrackAction(
                  icon: Icons.bedtime_outlined,
                  label: L.of(context).sleep,
                  color: AppColors.accent,
                  onTap: () => _showSheet(context, TrackingType.sleep),
                ),
                const SizedBox(width: 12),
                _TrackAction(
                  icon: Icons.baby_changing_station,
                  label: L.of(context).diaper,
                  color: AppColors.secondary,
                  onTap: () => _showSheet(context, TrackingType.diaper),
                ),
                const SizedBox(width: 12),
                _TrackAction(
                  icon: Icons.monitor_weight_outlined,
                  label: L.of(context).weight,
                  color: AppColors.stagePrePregnancy,
                  onTap: () => _showSheet(context, TrackingType.weight),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Age-adaptive Toolkit
            SectionHeader(
              title: ageMonths >= 12
                  ? L.of(context).toddlerToolkit
                  : L.of(context).newParentToolkit,
              subtitle: L.of(context).everythingYouNeed,
              accentColor: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: _buildToolkitTiles(context, ageMonths, profile.babyName ?? L.of(context).myBaby),
            ),
            const SizedBox(height: 20),

            // Development sections
            _SectionCard(
              title: L.of(context).physicalDevelopment,
              icon: Icons.directions_run,
              color: AppColors.primary,
              content: monthData.physicalDevelopment.of(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: L.of(context).brainAndLearning,
              icon: Icons.psychology,
              color: AppColors.accent,
              content: monthData.cognitiveDevelopment.of(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: L.of(context).socialAndEmotional,
              icon: Icons.favorite,
              color: AppColors.primary,
              content: monthData.socialEmotional.of(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: L.of(context).languageAndCommunication,
              icon: Icons.chat_bubble_outline,
              color: AppColors.secondary,
              content: monthData.languageDevelopment.of(context),
            ),
            const SizedBox(height: 20),

            // Milestones checklist
            SectionHeader(title: L.of(context).milestones, accentColor: AppColors.accent),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: monthData.milestones.map((m) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(_milestoneIcon(m.category), color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(m.description.of(context), style: const TextStyle(fontSize: 14)),
                          ),
                          Checkbox(
                            value: false,
                            onChanged: (_) {},
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Activities
            SectionHeader(title: L.of(context).activitiesToTry, accentColor: AppColors.secondary),
            const SizedBox(height: 12),
            ...monthData.activities.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: AppColors.secondary, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a.of(context), style: const TextStyle(fontSize: 14, height: 1.4))),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // Sleep guide
            _GuideCard(
              title: L.of(context).sleepGuide,
              icon: Icons.bedtime,
              color: AppColors.accent,
              header: '${monthData.sleep.totalHours} ${L.of(context).hrs}',
              subtitle: monthData.sleep.pattern.of(context),
              tips: monthData.sleep.tips.map((t) => t.of(context)).toList(),
            ),
            const SizedBox(height: 12),

            // Feeding guide
            _GuideCard(
              title: L.of(context).feedingGuide,
              icon: Icons.restaurant,
              color: AppColors.primary,
              header: monthData.feeding.type.of(context),
              subtitle: '${monthData.feeding.frequency.of(context)}\n${monthData.feeding.amount.of(context)}',
              tips: monthData.feeding.tips.map((t) => t.of(context)).toList(),
            ),
            const SizedBox(height: 20),

            // Red flags
            SectionHeader(title: L.of(context).whenToCallDoctor, accentColor: AppColors.error),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: monthData.redFlags.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(f.of(context), style: const TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Health checkup
            if (monthData.checkup != null) ...[
              SectionHeader(title: L.of(context).healthCheckup, accentColor: AppColors.secondary),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Text(monthData.checkup!.timing.of(context),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      if (monthData.checkup!.vaccines.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(L.of(context).vaccines, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...monthData.checkup!.vaccines.map((v) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Row(
                                children: [
                                  const Text('💉 ', style: TextStyle(fontSize: 12)),
                                  Expanded(child: Text(v.of(context), style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                            )),
                      ],
                      if (monthData.checkup!.screenings.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(L.of(context).screenings, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...monthData.checkup!.screenings.map((s) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Row(
                                children: [
                                  const Text('🔍 ', style: TextStyle(fontSize: 12)),
                                  Expanded(child: Text(s.of(context), style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Parent tips
            SectionHeader(title: L.of(context).tipsForYou, accentColor: AppColors.stagePregnancy),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: monthData.parentTips.map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💕 ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(t.of(context), style: const TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
              ),
            ),
            // Recommended products for baby's age
            const SizedBox(height: 20),
            SectionHeader(title: L.of(context).recommendedForAge(monthData.ageLabel.of(context)), accentColor: AppColors.stagePrePregnancy),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Builder(builder: (context) {
                final products = SeedData.getProductsForAge(ageMonths);
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length.clamp(0, 8),
                  itemBuilder: (context, i) {
                    final p = products[i];
                    final vendor = SeedData.getVendor(p.vendorId);
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.06),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Center(child: Icon(p.icon, color: p.iconColor, size: 36)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name.of(context), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                if (vendor != null) Text(vendor.name.of(context), style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                                const SizedBox(height: 2),
                                Text(p.priceFormatted, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildToolkitTiles(BuildContext context, int ageMonths, String name) {
    final tiles = <Widget>[];

    // Toddler-specific AI-powered tiles (12+ months)
    if (ageMonths >= 12) {
      tiles.add(_ToolkitTile(
        icon: Icons.record_voice_over,
        label: L.of(context).speechLanguage,
        subtitle: L.of(context).speechLanguageSubtitle,
        color: AppColors.accent,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent(
            "Tell me about speech and language development for $name at $ageMonths months. "
            "What words and phrases are typical? What should I watch for? "
            "How can I support language at home?")}'),
      ));
      tiles.add(_ToolkitTile(
        icon: Icons.extension,
        label: L.of(context).montessoriActivities,
        subtitle: L.of(context).montessoriActivitiesSubtitle,
        color: AppColors.primary,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent(
            "What Montessori activities can I do with $name today at $ageMonths months? "
            "Practical things I can do at home with everyday items.")}'),
      ));
      tiles.add(_ToolkitTile(
        icon: Icons.volunteer_activism,
        label: L.of(context).emotionalConnection,
        subtitle: L.of(context).emotionalConnectionSubtitle,
        color: AppColors.stagePregnancy,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent(
            "How do I build a strong emotional bond with $name at $ageMonths months? "
            "What does connection look like at this age? How do I show love effectively?")}'),
      ));
      tiles.add(_ToolkitTile(
        icon: Icons.psychology,
        label: L.of(context).behaviorBoundaries,
        subtitle: L.of(context).behaviorBoundariesSubtitle,
        color: AppColors.secondary,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent(
            "How do I handle discipline and boundaries with $name at $ageMonths months "
            "the Montessori way? Tantrums, hitting, saying no — what's the right approach?")}'),
      ));
    }

    // Newborn-only tiles (0-8 months)
    if (ageMonths < 9) {
      tiles.add(_ToolkitTile(
        icon: Icons.volume_up,
        label: L.of(context).whiteNoise,
        subtitle: L.of(context).soothAndSleep,
        color: AppColors.stagePrePregnancy,
        onTap: () => context.push('/sounds'),
      ));
      tiles.add(_ToolkitTile(
        icon: Icons.auto_awesome,
        label: L.of(context).soothing,
        subtitle: L.of(context).fiveSsAndMore,
        color: AppColors.primary,
        onTap: () => context.push('/soothing'),
      ));
    }

    // Always shown tiles
    tiles.addAll([
      _ToolkitTile(
        icon: Icons.restaurant,
        label: L.of(context).feedingLog,
        subtitle: ageMonths >= 12 ? L.of(context).mealsAndSnacks : L.of(context).breastAndBottle,
        color: AppColors.secondary,
        onTap: () => context.push('/feeding-log'),
      ),
      _ToolkitTile(
        icon: Icons.baby_changing_station,
        label: L.of(context).diaperLog,
        subtitle: L.of(context).wetAndDirty,
        color: AppColors.accent,
        onTap: () => context.push('/diaper-log'),
      ),
      _ToolkitTile(
        icon: Icons.emergency,
        label: L.of(context).whenToCall,
        subtitle: L.of(context).doctorRedFlags,
        color: AppColors.error,
        onTap: () => context.push('/emergency'),
      ),
      _ToolkitTile(
        icon: Icons.favorite,
        label: L.of(context).forYouMom,
        subtitle: L.of(context).postpartumCare,
        color: AppColors.stagePregnancy,
        onTap: () => context.push('/postpartum'),
      ),
      _ToolkitTile(
        icon: Icons.restaurant_menu,
        label: L.of(context).babyFoods,
        subtitle: L.of(context).whatToFeed,
        color: AppColors.success,
        onTap: () => context.push('/baby-foods'),
      ),
      _ToolkitTile(
        icon: Icons.science,
        label: L.of(context).labResults,
        subtitle: const L3(en: 'Analyze blood work', ru: 'Анализ крови', ky: 'Кан анализи').of(context),
        color: AppColors.success,
        onTap: () => context.push('/lab'),
      ),
      _ToolkitTile(
        icon: Icons.medical_services,
        label: L.of(context).pediatrician,
        subtitle: L.of(context).findADoctor,
        color: AppColors.secondaryDark,
        onTap: () => context.go('/professionals'),
      ),
    ]);

    return tiles;
  }

  IconData _milestoneIcon(MilestoneCategory cat) {
    return switch (cat) {
      MilestoneCategory.motor => Icons.directions_run,
      MilestoneCategory.cognitive => Icons.psychology,
      MilestoneCategory.language => Icons.chat_bubble_outline,
      MilestoneCategory.social => Icons.favorite,
      MilestoneCategory.sensory => Icons.visibility,
      MilestoneCategory.feeding => Icons.restaurant,
    };
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
            Text(label, style: TextStyle(fontSize: 9, color: AppColors.textHint), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TrackAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TrackAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String header;
  final String subtitle;
  final List<String> tips;

  const _GuideCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.header,
    required this.subtitle,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(header, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 13, height: 1.4))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ToolkitTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolkitTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
