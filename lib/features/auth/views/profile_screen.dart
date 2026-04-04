import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../../journey/providers/journey_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                user?.displayName.isNotEmpty == true
                    ? user!.displayName[0].toUpperCase()
                    : '👋',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.displayName ?? 'Parent',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (user != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Stage switcher — demo mode lets you preview all stages
          Container(
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
                    Text(
                      'Switch Stage (Demo)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Preview the app at different parenting stages',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
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
                          ref.read(userProfileProvider.notifier).updateBabyBirthDate(
                            DateTime.now().subtract(const Duration(days: 180)),
                          );
                          ref.read(userProfileProvider.notifier).updateBabyName('Luna');
                        } else if (stage == ParentingStage.toddler) {
                          ref.read(userProfileProvider.notifier).updateBabyBirthDate(
                            DateTime.now().subtract(const Duration(days: 548)),
                          );
                          ref.read(userProfileProvider.notifier).updateBabyName('Luna');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(stageIcon, color: isSelected ? Colors.white : AppColors.textPrimary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              stage.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _ProfileTile(
            icon: Icons.child_care,
            title: 'My Journey Stage',
            subtitle: '${profile.stage.label} — ${profile.stage == ParentingStage.pregnant ? "Week ${profile.currentWeek ?? 24}" : profile.babyName ?? "My Baby"}',
            onTap: () => context.push('/stage-select'),
          ),
          _ProfileTile(
            icon: Icons.family_restroom,
            title: 'My Children',
            subtitle: 'Manage your family',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.medical_services_outlined,
            title: 'My Care Team',
            subtitle: 'Doctors & specialists',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage alerts',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(demoAuthServiceProvider).signOut(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
