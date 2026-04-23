import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/role_switcher.dart';
import '../feature_flags.dart';
import '../l10n/content_localizations.dart';
import '../theme/app_colors.dart';

/// Bottom-nav shell. v2 ships three tabs (Home / Ask / Child); v1
/// shell ships five (Today / Balam AI / Community / Market / My Child).
/// Toggle `FeatureFlags.v2Surface` to switch between the two surfaces
/// — every navigation affordance in this file adapts at compile time.
class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (FeatureFlags.v2Surface) {
      return _V2Shell(child: child);
    }
    return _V1Shell(child: child);
  }
}

// ─── v2 — three tabs: Home · Ask · Child ──────────────────────────

class _V2Shell extends StatelessWidget {
  final Widget child;
  const _V2Shell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/ask') || location.startsWith('/ai')) return 1;
    if (location.startsWith('/child') || location.startsWith('/my-child') || location.startsWith('/vault')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
            label: tr(currentLang(context),
                en: 'Home', ru: 'Главная', ky: 'Башкы'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.mic_none_rounded),
            selectedIcon: const Icon(Icons.mic_rounded, color: AppColors.primary),
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

// ─── v1 — legacy five-tab shell (kept for revert) ─────────────────

class _V1Shell extends StatelessWidget {
  final Widget child;
  const _V1Shell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/ai')) return 1;
    if (location.startsWith('/community')) return 2;
    if (location.startsWith('/marketplace')) return 3;
    if (location.startsWith('/my-child')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
