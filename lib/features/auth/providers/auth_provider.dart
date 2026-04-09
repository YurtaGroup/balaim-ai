import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/demo_auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/payment_service.dart';

/// Auth state — true when user is signed in (Firebase or demo).
/// This is what the router watches. Uses the SAME AuthService singleton.
final authStateProvider = StreamProvider<bool>((ref) {
  return AuthService().authStateChanges;
});

/// Demo user (role-specific info like admin/doctor/vendor).
/// Uses the SAME DemoAuthService instance as AuthService.
final currentDemoUserProvider = Provider<DemoUser?>((ref) {
  ref.watch(authStateProvider); // Rebuild when auth changes
  return AuthService().currentDemoUser;
});

/// Current user display info — works across Firebase and demo.
/// Also initializes push notifications when user signs in.
final currentUserInfoProvider = Provider<({String? uid, String? email, String? name})>((ref) {
  ref.watch(authStateProvider);
  final auth = AuthService();
  final uid = auth.currentUid;

  // Initialize services when signed in
  if (uid != null) {
    NotificationService().init(userId: uid);
    PaymentService().init(userId: uid);
  }

  return (
    uid: uid,
    email: auth.currentEmail,
    name: auth.currentDisplayName,
  );
});

/// Whether the current user is the app owner
final isOwnerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentDemoUserProvider);
  return user?.isOwner == true;
});

/// Role the owner is currently viewing as (null = use actual role)
final activeViewRoleProvider = StateProvider<UserRole?>((ref) => null);
