import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/stage_selection_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/journey/views/journey_screen.dart';
import '../../features/journey/views/due_date_screen.dart';
import '../../features/journey/views/kick_counter_screen.dart';
import '../../features/journey/views/baby_journey_screen.dart';
import '../../features/ai/views/ai_chat_screen.dart';
import '../../features/community/views/community_screen.dart';
import '../../features/admin/views/admin_dashboard_screen.dart';
import '../../features/professionals/views/professionals_screen.dart';
import '../../features/marketplace/views/marketplace_screen.dart';
import '../router/shell_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/login';

      if (!isLoggedIn && !isAuthRoute) {
        return '/onboarding';
      }
      if (isLoggedIn && isAuthRoute) {
        // Route admins to admin dashboard
        if (user.isAdmin) return '/admin';
        return '/';
      }
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/stage-select',
        builder: (context, state) => const StageSelectionScreen(),
      ),

      GoRoute(
        path: '/due-date',
        builder: (context, state) => const DueDateScreen(),
      ),
      GoRoute(
        path: '/kick-counter',
        builder: (context, state) => const KickCounterScreen(),
      ),
      GoRoute(
        path: '/baby-journey',
        builder: (context, state) => const BabyJourneyScreen(),
      ),

      // Admin shell
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Main parent app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JourneyScreen(),
            ),
          ),
          GoRoute(
            path: '/ai',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiChatScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityScreen(),
            ),
          ),
          GoRoute(
            path: '/professionals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfessionalsScreen(),
            ),
          ),
          GoRoute(
            path: '/marketplace',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MarketplaceScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
