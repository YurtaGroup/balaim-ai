import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/seed_data.dart';
import '../../../shared/models/baby_month_data.dart';
import '../../../shared/models/tracking_entry.dart';
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
        title: Text(profile.babyName ?? 'My Baby'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthData.ageLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$ageDays days old',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthData.title,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.child_care, color: Colors.white.withValues(alpha: 0.9), size: 56),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Growth stats
            Row(
              children: [
                _StatChip(
                  label: 'Avg Weight (Boy)',
                  value: '${monthData.avgWeightKgBoy} kg',
                  icon: Icons.monitor_weight_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Avg Weight (Girl)',
                  value: '${monthData.avgWeightKgGirl} kg',
                  icon: Icons.monitor_weight_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Avg Height',
                  value: '${monthData.avgHeightCmBoy} cm',
                  icon: Icons.straighten,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick tracking
            Text('Track Today', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _TrackAction(
                  icon: Icons.restaurant,
                  label: 'Feeding',
                  color: AppColors.primary,
                  onTap: () => _showSheet(context, TrackingType.feeding),
                ),
                const SizedBox(width: 12),
                _TrackAction(
                  icon: Icons.bedtime_outlined,
                  label: 'Sleep',
                  color: AppColors.accent,
                  onTap: () => _showSheet(context, TrackingType.sleep),
                ),
                const SizedBox(width: 12),
                _TrackAction(
                  icon: Icons.baby_changing_station,
                  label: 'Diaper',
                  color: AppColors.secondary,
                  onTap: () => _showSheet(context, TrackingType.diaper),
                ),
                const SizedBox(width: 12),
                _TrackAction(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  color: AppColors.stagePrePregnancy,
                  onTap: () => _showSheet(context, TrackingType.weight),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Development sections
            _SectionCard(
              title: 'Physical Development',
              icon: Icons.directions_run,
              color: AppColors.primary,
              content: monthData.physicalDevelopment,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Brain & Learning',
              icon: Icons.psychology,
              color: AppColors.accent,
              content: monthData.cognitiveDevelopment,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Social & Emotional',
              icon: Icons.favorite,
              color: AppColors.primary,
              content: monthData.socialEmotional,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Language & Communication',
              icon: Icons.chat_bubble_outline,
              color: AppColors.secondary,
              content: monthData.languageDevelopment,
            ),
            const SizedBox(height: 20),

            // Milestones checklist
            Text('Milestones', style: Theme.of(context).textTheme.titleLarge),
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
                            child: Text(m.description, style: const TextStyle(fontSize: 14)),
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
            Text('Activities to Try', style: Theme.of(context).textTheme.titleLarge),
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
                      Expanded(child: Text(a, style: const TextStyle(fontSize: 14, height: 1.4))),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // Sleep guide
            _GuideCard(
              title: 'Sleep Guide',
              icon: Icons.bedtime,
              color: AppColors.accent,
              header: '${monthData.sleep.totalHours} total',
              subtitle: monthData.sleep.pattern,
              tips: monthData.sleep.tips,
            ),
            const SizedBox(height: 12),

            // Feeding guide
            _GuideCard(
              title: 'Feeding Guide',
              icon: Icons.restaurant,
              color: AppColors.primary,
              header: monthData.feeding.type,
              subtitle: '${monthData.feeding.frequency}\n${monthData.feeding.amount}',
              tips: monthData.feeding.tips,
            ),
            const SizedBox(height: 20),

            // Red flags
            Text('When to Call the Doctor', style: Theme.of(context).textTheme.titleLarge),
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
                            child: Text(f, style: const TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Health checkup
            if (monthData.checkup != null) ...[
              Text('Health Checkup', style: Theme.of(context).textTheme.titleLarge),
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
                          Text(monthData.checkup!.timing,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      if (monthData.checkup!.vaccines.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Vaccines:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...monthData.checkup!.vaccines.map((v) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Row(
                                children: [
                                  const Text('💉 ', style: TextStyle(fontSize: 12)),
                                  Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                            )),
                      ],
                      if (monthData.checkup!.screenings.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Screenings:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ...monthData.checkup!.screenings.map((s) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Row(
                                children: [
                                  const Text('🔍 ', style: TextStyle(fontSize: 12)),
                                  Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
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
            Text('Tips for You', style: Theme.of(context).textTheme.titleLarge),
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
                            child: Text(t, style: const TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
              ),
            ),
            // Recommended products for baby's age
            const SizedBox(height: 20),
            Text('Recommended for ${monthData.ageLabel}', style: Theme.of(context).textTheme.titleLarge),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
