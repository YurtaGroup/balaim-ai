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
import '../../features/journey/views/contraction_timer_screen.dart';
import '../../features/journey/views/hospital_bag_screen.dart';
import '../../features/journey/views/birth_plan_screen.dart';
import '../../features/journey/views/baby_names_screen.dart';
import '../../features/sounds/views/sounds_screen.dart';
import '../../features/newborn/views/soothing_techniques_screen.dart';
import '../../features/newborn/views/feeding_log_screen.dart';
import '../../features/newborn/views/diaper_log_screen.dart';
import '../../features/newborn/views/emergency_reference_screen.dart';
import '../../features/newborn/views/postpartum_screen.dart';
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
      GoRoute(
        path: '/contraction-timer',
        builder: (context, state) => const ContractionTimerScreen(),
      ),
      GoRoute(
        path: '/hospital-bag',
        builder: (context, state) => const HospitalBagScreen(),
      ),
      GoRoute(
        path: '/birth-plan',
        builder: (context, state) => const BirthPlanScreen(),
      ),
      GoRoute(
        path: '/baby-names',
        builder: (context, state) => const BabyNamesScreen(),
      ),
      GoRoute(
        path: '/sounds',
        builder: (context, state) => const SoundsScreen(),
      ),
      GoRoute(
        path: '/soothing',
        builder: (context, state) => const SoothingTechniquesScreen(),
      ),
      GoRoute(
        path: '/feeding-log',
        builder: (context, state) => const FeedingLogScreen(),
      ),
      GoRoute(
        path: '/diaper-log',
        builder: (context, state) => const DiaperLogScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyReferenceScreen(),
      ),
      GoRoute(
        path: '/postpartum',
        builder: (context, state) => const PostpartumScreen(),
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
