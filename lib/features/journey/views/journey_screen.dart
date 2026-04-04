import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/seed_data.dart';
import '../../../shared/models/tracking_entry.dart';
import '../providers/journey_provider.dart';
import '../../../shared/widgets/gradient_banner.dart';
import '../../../shared/widgets/baby_size_visual.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/pattern_background.dart';
import 'kick_counter_screen.dart';
import 'tracking_sheet.dart';
import 'baby_journey_screen.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    // Auto-switch: if baby is born, show baby journey; if pregnant, show pregnancy journey
    if (profile.stage == ParentingStage.newborn || profile.stage == ParentingStage.toddler) {
      return const BabyJourneyScreen();
    }

    final weekData = ref.watch(currentWeekDataProvider);
    final todayEntries = ref.watch(trackingEntriesProvider.notifier).getToday();
    final week = profile.currentWeek ?? 24;
    final daysLeft = profile.daysRemaining ?? 112;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journey'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week banner with progress ring + decorative pattern
            GradientBanner(
              colors: const [AppColors.primary, AppColors.primaryDark],
              patternStyle: PatternStyle.circles,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week $week',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${weekData.trimester} trimester',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$daysLeft days to go',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PregnancyProgressRing(currentWeek: week, size: 84),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Your baby is the size of a ${weekData.babySize.toLowerCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizeComparisonBar(
                    lengthCm: weekData.babyLengthCm,
                    weightG: weekData.babyWeightG,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Baby development
            SectionHeader(title: "What's happening"),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  weekData.babyDevelopment,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick actions — real tracking
            const SectionHeader(title: 'Track Today', subtitle: 'Tap to log', accentColor: AppColors.primary),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  color: AppColors.primary,
                  value: _todayValue(todayEntries, TrackingType.weight),
                  unit: 'kg',
                  onTap: () => _showTrackingSheet(context, TrackingType.weight),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.water_drop_outlined,
                  label: 'Water',
                  color: AppColors.secondary,
                  value: _todayValue(todayEntries, TrackingType.water),
                  unit: 'glasses',
                  onTap: () => _showTrackingSheet(context, TrackingType.water),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.bedtime_outlined,
                  label: 'Sleep',
                  color: AppColors.accent,
                  value: _todayValue(todayEntries, TrackingType.sleep),
                  unit: 'hrs',
                  onTap: () => _showTrackingSheet(context, TrackingType.sleep),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.favorite_outline,
                  label: 'Kicks',
                  color: AppColors.stagePrePregnancy,
                  value: _todayValue(todayEntries, TrackingType.kicks),
                  unit: 'kicks',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KickCounterScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mood tracking
            _MoodRow(todayEntries: todayEntries),
            const SizedBox(height: 20),

            // Today's insights
            const SectionHeader(title: "Today's Insights", accentColor: AppColors.secondary),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balam AI Insight',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekData.tips.first,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Common symptoms
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common at Week $week',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: weekData.commonSymptoms.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Pregnancy tools
            const SizedBox(height: 20),
            const SectionHeader(title: 'Tools', subtitle: 'Everything you need', accentColor: AppColors.accent),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: [
                _ToolTile(
                  icon: Icons.timer_outlined,
                  label: 'Contraction\nTimer',
                  color: AppColors.primary,
                  onTap: () => context.push('/contraction-timer'),
                ),
                _ToolTile(
                  icon: Icons.luggage_outlined,
                  label: 'Hospital\nBag',
                  color: AppColors.secondary,
                  onTap: () => context.push('/hospital-bag'),
                ),
                _ToolTile(
                  icon: Icons.edit_note,
                  label: 'Birth\nPlan',
                  color: AppColors.accent,
                  onTap: () => context.push('/birth-plan'),
                ),
                _ToolTile(
                  icon: Icons.favorite_outline,
                  label: 'Baby\nNames',
                  color: AppColors.stagePrePregnancy,
                  onTap: () => context.push('/baby-names'),
                ),
                _ToolTile(
                  icon: Icons.menu_book,
                  label: 'Trimester\nGuide',
                  color: AppColors.success,
                  onTap: () => context.push('/trimester-guide'),
                ),
                _ToolTile(
                  icon: Icons.auto_awesome,
                  label: 'AI\nChat',
                  color: AppColors.secondaryDark,
                  onTap: () => context.go('/ai'),
                ),
              ],
            ),
            // Recommended products for pregnancy
            const SizedBox(height: 20),
            const SectionHeader(title: 'Recommended for You', accentColor: AppColors.stagePrePregnancy),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Builder(builder: (context) {
                final products = SeedData.getProductsForStage(ParentingStage.pregnant);
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
                                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                if (vendor != null) Text(vendor.name, style: TextStyle(fontSize: 10, color: AppColors.textHint)),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String? _todayValue(List<TrackingEntry> entries, TrackingType type) {
    final matching = entries.where((e) => e.type == type);
    if (matching.isEmpty) return null;
    final v = matching.first.value;
    if (v == null) return null;
    if (type == TrackingType.weight) return v.toStringAsFixed(1);
    return v.round().toString();
  }

  void _showTrackingSheet(BuildContext context, TrackingType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TrackingSheet(type: type),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? value;
  final String unit;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.value,
    required this.unit,
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
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              else
                Icon(Icons.add_circle_outline, color: color, size: 16),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodRow extends ConsumerWidget {
  final List<TrackingEntry> todayEntries;

  const _MoodRow({required this.todayEntries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMood = todayEntries
        .where((e) => e.type == TrackingType.mood)
        .toList();
    final currentMood = todayMood.isNotEmpty ? todayMood.first.value?.round() : null;

    final moods = [
      ('😢', 'Rough'),
      ('😟', 'Meh'),
      ('😐', 'Okay'),
      ('😊', 'Good'),
      ('😄', 'Great'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "How are you feeling?", accentColor: AppColors.stagePrePregnancy),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(moods.length, (i) {
            final isSelected = currentMood == i + 1;
            return GestureDetector(
              onTap: () {
                final profile = ref.read(userProfileProvider);
                ref.read(trackingEntriesProvider.notifier).addEntry(
                      TrackingEntry(
                        id: 'mood-${DateTime.now().millisecondsSinceEpoch}',
                        userId: profile.uid,
                        type: TrackingType.mood,
                        value: (i + 1).toDouble(),
                        unit: 'rating',
                        timestamp: DateTime.now(),
                        createdAt: DateTime.now(),
                      ),
                    );
              },
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(moods[i].$1, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    moods[i].$2,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppColors.primary : AppColors.textHint,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
