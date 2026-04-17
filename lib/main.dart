import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Global flag: true when Firebase is initialized successfully
bool isFirebaseInitialized = false;

/// Persisted language choice. Survives cold starts via SharedPreferences.
class LocaleNotifier extends Notifier<Locale?> {
  static const _key = 'app_language_code';
  static const _supported = {'en', 'ru', 'ky'};

  @override
  Locale? build() => _initial;

  /// Set by main() after reading SharedPreferences.
  static Locale? _initial;

  static Future<void> loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && _supported.contains(code)) {
      _initial = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved locale BEFORE runApp so first frame is in correct language
  await LocaleNotifier.loadInitial();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint('[Balam] Firebase initialized — running in LIVE mode');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('[Balam] Firebase not configured — running in DEMO mode');
  }

  runApp(const ProviderScope(child: BalamApp()));
}

class BalamApp extends ConsumerWidget {
  const BalamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Balam.AI',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L.supportedLocales,
    );
  }
}
