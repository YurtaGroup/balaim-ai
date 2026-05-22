import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/content_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart' show localeProvider;
import '../providers/auth_provider.dart';
import '../../journey/providers/journey_provider.dart';
import '../../paywall/providers/premium_provider.dart';
import 'children_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L.of(context).featureComingSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(currentUserInfoProvider);
    final demoUser = ref.watch(currentDemoUserProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).profile)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar — tap to change photo
          Center(
            child: GestureDetector(
              onTap: () async {
                final file = await StorageService().showPickerSheet(context);
                if (file == null) return;
                final uid = userInfo.uid ?? 'demo';
                final url = await StorageService().uploadProfilePhoto(
                  file: file,
                  userId: uid,
                );
                if (url != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(L.of(context).photoUpdated), behavior: SnackBarBehavior.floating),
                  );
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      (userInfo.name != null && userInfo.name!.isNotEmpty)
                          ? userInfo.name![0].toUpperCase()
                          : '👋',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              userInfo.name ?? L.of(context).parent,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: Text(
              userInfo.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (demoUser != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  demoUser.role.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),


          _ProfileTile(
            icon: ref.watch(isPremiumProvider)
                ? Icons.verified
                : Icons.auto_awesome,
            title: ref.watch(isPremiumProvider)
                ? tr(currentLang(context),
                    en: 'Balam Premium',
                    ru: 'Balam Premium',
                    ky: 'Balam Premium')
                : tr(currentLang(context),
                    en: 'Upgrade to Premium',
                    ru: 'Подключить Premium',
                    ky: 'Premium\'ду алуу'),
            subtitle: ref.watch(isPremiumProvider)
                ? tr(currentLang(context),
                    en: 'Active — unlimited everything',
                    ru: 'Активна — всё без лимитов',
                    ky: 'Активдүү — баары чексиз')
                : tr(currentLang(context),
                    en: 'Unlimited AI, all your children, export',
                    ru: 'Безлимитный AI, все дети, экспорт',
                    ky: 'Чексиз AI, бардык балдар, экспорт'),
            onTap: () => context.push('/paywall'),
          ),
          _ProfileTile(
            icon: Icons.family_restroom,
            title: L.of(context).myChildren,
            subtitle: L.of(context).childrenCount(profile.children.length),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChildrenScreen()),
            ),
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            title: L.of(context).notifications,
            subtitle: L.of(context).manageAlerts,
            onTap: () => context.push('/notifications'),
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            title: L.of(context).settings,
            subtitle: L.of(context).appPreferences,
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 16),

          // Language switcher
          Container(
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
                    Text(
                      'Language / Тил / Язык', // intentionally trilingual
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _LanguageChip(
                      label: 'English',
                      locale: const Locale('en'),
                      currentLocale: ref.watch(localeProvider),
                      onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                    ),
                    _LanguageChip(
                      label: 'Русский',
                      locale: const Locale('ru'),
                      currentLocale: ref.watch(localeProvider),
                      onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ru')),
                    ),
                    _LanguageChip(
                      label: 'Кыргызча',
                      locale: const Locale('ky'),
                      currentLocale: ref.watch(localeProvider),
                      onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ky')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => AuthService().signOut(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: Text(L.of(context).signOut),
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

class _LanguageChip extends StatelessWidget {
  final String label;
  final Locale locale;
  final Locale? currentLocale;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.locale,
    required this.currentLocale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale?.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
