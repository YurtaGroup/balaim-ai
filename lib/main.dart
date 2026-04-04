import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Global flag: true when Firebase is initialized successfully
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase — if firebase_options.dart doesn't exist
  // or config is missing, we fall back to demo mode gracefully
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase initialized — running in LIVE mode');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('⚠️ Firebase not configured — running in DEMO mode');
    debugPrint('   Run: flutterfire configure --project=balam-ai');
  }

  runApp(const ProviderScope(child: BalamApp()));
}

class BalamApp extends ConsumerWidget {
  const BalamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Balam.AI',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
