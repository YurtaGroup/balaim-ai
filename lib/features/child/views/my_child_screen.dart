import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart' show localeProvider;
import '../../../shared/models/baby_month_data.dart';
import '../../../shared/models/pregnancy_week_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/views/children_screen.dart';
import '../../journey/providers/journey_provider.dart';

class MyChildScreen extends ConsumerWidget {
  const MyChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final profile = ref.watch(userProfileProvider);
    final userInfo = ref.watch(currentUserInfoProvider);
    final demoUser = ref.watch(currentDemoUserProvider);
    final isPregnant = profile.stage == ParentingStage.pregnant ||
        profile.stage == ParentingStage.tryingToConceive;
    final age = profile.babyAgeMonths ?? 6;
    final name = profile.babyName ?? l.myBaby;

    return Scaffold(
      appBar: AppBar(title: Text(l.navMyChild)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section 1: Child Header ──
          _ChildHeader(
            name: isPregnant ? (profile.babyName ?? l.myBaby) : name,
            subtitle: isPregnant
                ? '${l.weekN(profile.currentWeek ?? 24)} — ${l.pregnant}'
                : '$age ${l.months}',
            parentName: userInfo.name ?? l.parent,
            onPhotoTap: () async {
              final file = await StorageService().showPickerSheet(context);
              if (file == null) return;
              final uid = userInfo.uid ?? 'demo';
              await StorageService().uploadProfilePhoto(file: file, userId: uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.photoUpdated), behavior: SnackBarBehavior.floating),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // ── Section 2: Development Dashboard ──
          _SectionTitle(title: l.developmentDashboard, icon: Icons.psychology),
          const SizedBox(height: 10),
          if (isPregnant) ...[
            _DevelopmentCard(
              title: l.whatsHappening,
              icon: Icons.child_care,
              color: AppColors.primary,
              content: PregnancyWeekData.getWeek(profile.currentWeek ?? 24).babyDevelopment.of(context),
            ),
          ] else ...[
            _buildDevelopmentGrid(context, age),
          ],
          const SizedBox(height: 20),

          // ── Section 3: Growth Stats (baby only) ──
          if (!isPregnant) ...[
            _buildGrowthStats(context, age),
            const SizedBox(height: 20),
          ],

          // ── Section 4: Milestones (baby only) ──
          if (!isPregnant) ...[
            _SectionTitle(title: l.milestones, icon: Icons.checklist),
            const SizedBox(height: 10),
            _buildMilestones(context, age),
            const SizedBox(height: 20),
          ],

          // ── First Moments (baby only) ──
          if (!isPregnant) ...[
            _LinkTile(
              icon: Icons.camera_alt,
              title: l.firstMoments,
              subtitle: l.captureFirsts,
              onTap: () => context.push('/moments'),
            ),
            const SizedBox(height: 20),
          ],

          // ── Section 5: Toolkit ──
          _SectionTitle(title: l.myToolkit, icon: Icons.build_outlined),
          const SizedBox(height: 10),
          if (isPregnant)
            _buildPregnancyTools(context)
          else
            _buildBabyToolkit(context, age, name),
          const SizedBox(height: 20),

          // ── Section 6: Guides (baby only) ──
          if (!isPregnant) ...[
            _SectionTitle(title: l.guidesSection, icon: Icons.menu_book),
            const SizedBox(height: 10),
            _buildGuides(context, age),
            const SizedBox(height: 20),
          ],

          // ── Section 7: Health ──
          if (!isPregnant) ...[
            _SectionTitle(title: l.healthSection, icon: Icons.health_and_safety),
            const SizedBox(height: 10),
            _buildHealth(context, age),
            const SizedBox(height: 20),
          ],

          // ── Section 8: Quick Links ──
          _SectionTitle(title: l.quickLinksSection, icon: Icons.link),
          const SizedBox(height: 10),
          _LinkTile(
            icon: Icons.family_restroom,
            title: l.myChildren,
            subtitle: l.childrenCount(profile.children.length),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChildrenScreen()),
            ),
          ),
          _LinkTile(
            icon: Icons.medical_services_outlined,
            title: l.myCareTeam,
            subtitle: l.doctorsSpecialists,
            onTap: () => context.push('/professionals'),
          ),
          _LinkTile(
            icon: Icons.science_outlined,
            title: l.labResults,
            subtitle: l.manageAlerts,
            onTap: () => context.push('/lab'),
          ),
          _LinkTile(
            icon: Icons.notifications_outlined,
            title: l.notifications,
            subtitle: l.manageAlerts,
            onTap: () => context.push('/notifications'),
          ),
          const SizedBox(height: 20),

          // ── Section 9: Stage switcher (language + sign out moved to Today gear) ──
          _buildStageSwitcher(context, ref, profile, demoUser),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Development Grid (4 domains) ──
  Widget _buildDevelopmentGrid(BuildContext context, int ageMonths) {
    final monthData = BabyMonthData.getMonth(ageMonths);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _DomainChip(
              icon: Icons.directions_run,
              label: L.of(context).physicalDevelopment,
              content: monthData.physicalDevelopment.of(context),
              color: AppColors.primary,
            )),
            const SizedBox(width: 10),
            Expanded(child: _DomainChip(
              icon: Icons.psychology,
              label: L.of(context).brainAndLearning,
              content: monthData.cognitiveDevelopment.of(context),
              color: AppColors.accent,
            )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _DomainChip(
              icon: Icons.favorite,
              label: L.of(context).socialAndEmotional,
              content: monthData.socialEmotional.of(context),
              color: AppColors.primary,
            )),
            const SizedBox(width: 10),
            Expanded(child: _DomainChip(
              icon: Icons.chat_bubble_outline,
              label: L.of(context).languageAndCommunication,
              content: monthData.languageDevelopment.of(context),
              color: AppColors.secondary,
            )),
          ],
        ),
      ],
    );
  }

  // ── Growth Stats ──
  Widget _buildGrowthStats(BuildContext context, int ageMonths) {
    final l = L.of(context);
    final monthData = BabyMonthData.getMonth(ageMonths);
    return Row(
      children: [
        _StatChip(label: l.avgWeightBoy, value: '${monthData.avgWeightKgBoy} kg', icon: Icons.monitor_weight_outlined, color: AppColors.secondary),
        const SizedBox(width: 8),
        _StatChip(label: l.avgWeightGirl, value: '${monthData.avgWeightKgGirl} kg', icon: Icons.monitor_weight_outlined, color: AppColors.primary),
        const SizedBox(width: 8),
        _StatChip(label: l.avgHeight, value: '${monthData.avgHeightCmBoy} cm', icon: Icons.straighten, color: AppColors.accent),
      ],
    );
  }

  // ── Milestones ──
  Widget _buildMilestones(BuildContext context, int ageMonths) {
    final monthData = BabyMonthData.getMonth(ageMonths);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: monthData.milestones.map((m) {
            final icon = switch (m.category) {
              MilestoneCategory.motor => Icons.directions_run,
              MilestoneCategory.cognitive => Icons.psychology,
              MilestoneCategory.language => Icons.chat_bubble_outline,
              MilestoneCategory.social => Icons.favorite,
              MilestoneCategory.sensory => Icons.visibility,
              MilestoneCategory.feeding => Icons.restaurant,
            };
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(m.description.of(context), style: const TextStyle(fontSize: 14))),
                  Checkbox(value: false, onChanged: (_) {}, activeColor: AppColors.primary),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Pregnancy Tools ──
  Widget _buildPregnancyTools(BuildContext context) {
    final l = L.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _ToolkitTile(icon: Icons.timer, label: l.contractionTimer, subtitle: '', color: AppColors.error, onTap: () => context.push('/contraction-timer')),
        _ToolkitTile(icon: Icons.luggage, label: l.hospitalBag, subtitle: '', color: AppColors.primary, onTap: () => context.push('/hospital-bag')),
        _ToolkitTile(icon: Icons.description, label: l.birthPlan, subtitle: '', color: AppColors.secondary, onTap: () => context.push('/birth-plan')),
        _ToolkitTile(icon: Icons.child_care, label: l.babyNames, subtitle: '', color: AppColors.accent, onTap: () => context.push('/baby-names')),
        _ToolkitTile(icon: Icons.menu_book, label: l.trimesterGuide, subtitle: '', color: AppColors.stagePregnancy, onTap: () => context.push('/trimester-guide')),
        _ToolkitTile(icon: Icons.auto_awesome, label: l.aiChat, subtitle: '', color: AppColors.secondaryDark, onTap: () => context.go('/ai')),
      ],
    );
  }

  // ── Baby Toolkit (age-adaptive) ──
  Widget _buildBabyToolkit(BuildContext context, int ageMonths, String name) {
    final l = L.of(context);
    final tiles = <Widget>[];

    // Toddler AI-powered tiles
    if (ageMonths >= 12) {
      tiles.add(_ToolkitTile(icon: Icons.record_voice_over, label: l.speechLanguage, subtitle: l.speechLanguageSubtitle, color: AppColors.accent,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent("Tell me about speech and language development for $name at $ageMonths months.")}')));
      tiles.add(_ToolkitTile(icon: Icons.extension, label: l.montessoriActivities, subtitle: l.montessoriActivitiesSubtitle, color: AppColors.primary,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent("What Montessori activities can I do with $name today at $ageMonths months?")}')));
      tiles.add(_ToolkitTile(icon: Icons.volunteer_activism, label: l.emotionalConnection, subtitle: l.emotionalConnectionSubtitle, color: AppColors.stagePregnancy,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent("How do I build a strong emotional bond with $name at $ageMonths months?")}')));
      tiles.add(_ToolkitTile(icon: Icons.psychology, label: l.behaviorBoundaries, subtitle: l.behaviorBoundariesSubtitle, color: AppColors.secondary,
        onTap: () => context.go('/ai?prefill=${Uri.encodeComponent("How do I handle discipline with $name at $ageMonths months the Montessori way?")}')));
    }

    // Newborn tiles
    if (ageMonths < 9) {
      tiles.add(_ToolkitTile(icon: Icons.volume_up, label: l.whiteNoise, subtitle: l.soothAndSleep, color: AppColors.stagePrePregnancy, onTap: () => context.push('/sounds')));
      tiles.add(_ToolkitTile(icon: Icons.auto_awesome, label: l.soothing, subtitle: l.fiveSsAndMore, color: AppColors.primary, onTap: () => context.push('/soothing')));
    }

    // Always shown
    tiles.addAll([
      _ToolkitTile(icon: Icons.restaurant, label: l.feedingLog, subtitle: ageMonths >= 12 ? l.mealsAndSnacks : l.breastAndBottle, color: AppColors.secondary, onTap: () => context.push('/feeding-log')),
      _ToolkitTile(icon: Icons.baby_changing_station, label: l.diaperLog, subtitle: l.wetAndDirty, color: AppColors.accent, onTap: () => context.push('/diaper-log')),
      _ToolkitTile(icon: Icons.emergency, label: l.whenToCall, subtitle: l.doctorRedFlags, color: AppColors.error, onTap: () => context.push('/emergency')),
      _ToolkitTile(icon: Icons.restaurant_menu, label: l.babyFoods, subtitle: l.whatToFeed, color: AppColors.success, onTap: () => context.push('/baby-foods')),
      _ToolkitTile(icon: Icons.science, label: l.labResults, subtitle: '', color: AppColors.success, onTap: () => context.push('/lab')),
      _ToolkitTile(icon: Icons.medical_services, label: l.pediatrician, subtitle: l.findADoctor, color: AppColors.secondaryDark, onTap: () => context.go('/professionals')),
    ]);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: tiles,
    );
  }

  // ── Guides ──
  Widget _buildGuides(BuildContext context, int ageMonths) {
    final l = L.of(context);
    final monthData = BabyMonthData.getMonth(ageMonths);
    return Column(
      children: [
        _GuideCard(
          title: l.sleepGuide,
          icon: Icons.bedtime,
          color: AppColors.accent,
          header: '${monthData.sleep.totalHours} ${l.hrs}',
          subtitle: monthData.sleep.pattern.of(context),
          tips: monthData.sleep.tips.map((t) => t.of(context)).toList(),
        ),
        const SizedBox(height: 10),
        _GuideCard(
          title: l.feedingGuide,
          icon: Icons.restaurant,
          color: AppColors.primary,
          header: monthData.feeding.type.of(context),
          subtitle: '${monthData.feeding.frequency.of(context)}\n${monthData.feeding.amount.of(context)}',
          tips: monthData.feeding.tips.map((t) => t.of(context)).toList(),
        ),
      ],
    );
  }

  // ── Health (Red Flags + Checkup) ──
  Widget _buildHealth(BuildContext context, int ageMonths) {
    final l = L.of(context);
    final monthData = BabyMonthData.getMonth(ageMonths);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.whenToCallDoctor, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              ...monthData.redFlags.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ ', style: TextStyle(fontSize: 13)),
                    Expanded(child: Text(f.of(context), style: const TextStyle(fontSize: 13, height: 1.4))),
                  ],
                ),
              )),
            ],
          ),
        ),
        if (monthData.checkup != null) ...[
          const SizedBox(height: 10),
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
                      Expanded(child: Text(monthData.checkup!.timing.of(context), style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                  if (monthData.checkup!.vaccines.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(l.vaccines, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ...monthData.checkup!.vaccines.map((v) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text('💉 ${v.of(context)}', style: const TextStyle(fontSize: 12)),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Stage Switcher (demo only) ──
  Widget _buildStageSwitcher(BuildContext context, WidgetRef ref, dynamic profile, dynamic demoUser) {
    final l = L.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: AppColors.accentDark, size: 18),
              const SizedBox(width: 6),
              Text(l.switchStageDemo, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentDark, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.previewStages, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ParentingStage.values.map((stage) {
              final isSelected = profile.stage == stage;
              final stageIcon = switch (stage) {
                ParentingStage.tryingToConceive => Icons.favorite,
                ParentingStage.pregnant => Icons.pregnant_woman,
                ParentingStage.newborn => Icons.child_care,
                ParentingStage.toddler => Icons.child_friendly,
              };
              return GestureDetector(
                onTap: () {
                  ref.read(userProfileProvider.notifier).updateStage(stage);
                  if (stage == ParentingStage.newborn) {
                    ref.read(userProfileProvider.notifier).updateBabyBirthDate(DateTime.now().subtract(const Duration(days: 180)));
                    ref.read(userProfileProvider.notifier).updateBabyName('Luna');
                  } else if (stage == ParentingStage.toddler) {
                    ref.read(userProfileProvider.notifier).updateBabyBirthDate(DateTime.now().subtract(const Duration(days: 548)));
                    ref.read(userProfileProvider.notifier).updateBabyName('Luna');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(stageIcon, color: isSelected ? Colors.white : AppColors.textPrimary, size: 16),
                      const SizedBox(width: 6),
                      Text(stage.labelFor(currentLang(context)), style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Language Switcher ──
  Widget _buildLanguageSwitcher(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text('Language / Тил / Язык', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.secondaryDark)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _langChip('English', const Locale('en'), currentLocale, () => ref.read(localeProvider.notifier).setLocale(const Locale('en'))),
              _langChip('Русский', const Locale('ru'), currentLocale, () => ref.read(localeProvider.notifier).setLocale(const Locale('ru'))),
              _langChip('Кыргызча', const Locale('ky'), currentLocale, () => ref.read(localeProvider.notifier).setLocale(const Locale('ky'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _langChip(String label, Locale locale, Locale? current, VoidCallback onTap) {
    final isSelected = current?.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.secondary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isSelected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable Widgets
// ─────────────────────────────────────────────

class _ChildHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String parentName;
  final VoidCallback onPhotoTap;

  const _ChildHeader({required this.name, required this.subtitle, required this.parentName, required this.onPhotoTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPhotoTap,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                child: const Icon(Icons.child_care, color: AppColors.secondary, size: 40),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(subtitle, style: TextStyle(fontSize: 14, color: AppColors.textHint)),
        const SizedBox(height: 4),
        Text(parentName, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String content;
  final Color color;

  const _DomainChip({required this.icon, required this.label, required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 12),
              Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _DevelopmentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _DevelopmentCard({required this.title, required this.icon, required this.color, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
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

class _ToolkitTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolkitTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

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
                    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
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

class _GuideCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String header;
  final String subtitle;
  final List<String> tips;

  const _GuideCard({required this.title, required this.icon, required this.color, required this.header, required this.subtitle, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleMedium)]),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
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

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
