import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/content_localizations.dart';
import '../theme/app_colors.dart';

/// The one bottom-nav shell — three tabs: Home · Ask · Child.
class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/ask') || location.startsWith('/ai')) return 1;
    if (location.startsWith('/child')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/ask');
            case 2:
              context.go('/child');
          }
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon:
                const Icon(Icons.home_rounded, color: AppColors.primary),
            label: tr(currentLang(context),
                en: 'Home', ru: 'Главная', ky: 'Башкы'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.mic_none_rounded),
            selectedIcon:
                const Icon(Icons.mic_rounded, color: AppColors.primary),
            label: tr(currentLang(context),
                en: 'Ask', ru: 'Спросить', ky: 'Суроо'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.child_care_outlined),
            selectedIcon: const Icon(Icons.child_care, color: AppColors.primary),
            label: tr(currentLang(context),
                en: 'Child', ru: 'Ребёнок', ky: 'Бала'),
          ),
        ],
      ),
    );
  }
}
