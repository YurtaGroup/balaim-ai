import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/demo_auth_service.dart';

final demoAuthServiceProvider = Provider<DemoAuthService>((ref) {
  return DemoAuthService();
});

final authStateProvider = StreamProvider<DemoUser?>((ref) {
  return ref.watch(demoAuthServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<DemoUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
