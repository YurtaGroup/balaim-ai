import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/views/onboarding_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/signup_screen.dart';
import '../../features/auth/views/children_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/notifications/views/notifications_screen.dart';
import '../../features/child/views/child_screen.dart';
import '../../features/ask/views/ask_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/ai/views/ai_chat_screen.dart';
import '../../features/ai/views/demo_conversations_screen.dart';
import '../../features/paywall/views/paywall_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../router/shell_screen.dart';

/// v3 router — the hyper-focused, child-first surface.
///
/// Three tabs (Home · Ask · Child) inside one shell, plus a handful of
/// pushed routes (auth, add-a-child, settings, notifications). Every
/// pregnancy / community / marketplace / professionals route from the
/// super-app era has been deleted, not flag-hidden.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull == true;
      final loc = state.matchedLocation;
      final isAuthRoute =
          loc == '/onboarding' || loc == '/login' || loc == '/signup';

      if (!isLoggedIn && !isAuthRoute) return '/onboarding';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // ─── Auth ───────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ─── Pushed routes ──────────────────────────────────────
      GoRoute(
        path: '/children',
        builder: (context, state) => const ChildrenScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/ai/examples',
        builder: (context, state) => const DemoConversationsScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),

      // ─── The three-tab shell ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          // Ask — voice-first AI entry (mic + starter chips).
          GoRoute(
            path: '/ask',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AskScreen()),
          ),
          // Child — the unified child timeline (vault + moments).
          GoRoute(
            path: '/child',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ChildScreen()),
          ),
          // Chat surface. /ask and the Home hero forward here; the
          // ?prefill= query seeds the first message.
          GoRoute(
            path: '/ai',
            pageBuilder: (context, state) => NoTransitionPage(
              child: AiChatScreen(
                prefill: state.uri.queryParameters['prefill'],
              ),
            ),
          ),
        ],
      ),
    ],
  );
});
