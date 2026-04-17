import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/role_switcher.dart';
import '../theme/app_colors.dart';

class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/ai')) return 1;
    if (location.startsWith('/community')) return 2;
    if (location.startsWith('/marketplace')) return 3;
    if (location.startsWith('/my-child')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    return Scaffold(
      body: Stack(
        children: [
          child,
          const RoleSwitcher(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/ai');
            case 2:
              context.go('/community');
            case 3:
              context.go('/marketplace');
            case 4:
              context.go('/my-child');
          }
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today, color: AppColors.primary),
            label: l.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            label: l.navBalamAI,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people, color: AppColors.primary),
            label: l.navCommunity,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront, color: AppColors.primary),
            label: l.navMarket,
          ),
          NavigationDestination(
            icon: const Icon(Icons.face_outlined),
            selectedIcon: const Icon(Icons.face, color: AppColors.primary),
            label: l.navMyChild,
          ),
        ],
      ),
    );
  }
}
