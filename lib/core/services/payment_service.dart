import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../constants/env_config.dart';
import 'auth_service.dart';

/// RevenueCat-powered subscription service.
///
/// Business model — Balam is a SaaS:
/// - Free: 1 child, the vault, proactive notices, 3 AI questions / week.
/// - Balam Premium ($9/mo or $79/yr): unlimited AI, unlimited children,
///   PDF export, partner sharing.
///
/// RevenueCat setup (dashboard + App Store Connect):
/// - Entitlement: `premium`
/// - Products: `balam_premium_monthly`, `balam_premium_yearly`
///   exposed through the "current" offering as the monthly/annual packages.
///
/// Demo mode (no RevenueCat key) stays on the free tier so the paywall
/// and the free-tier gate are testable without a store connection.
class PaymentService {
  static final PaymentService _instance = PaymentService._();
  factory PaymentService() => _instance;
  PaymentService._();

  /// RevenueCat entitlement that unlocks Balam Premium.
  static const entitlementId = 'premium';

  bool _initialized = false;
  final ValueNotifier<bool> _premium = ValueNotifier<bool>(false);

  /// Listenable premium status — the source for `isPremiumProvider`.
  ValueListenable<bool> get premiumListenable => _premium;
  bool get isPremium => _premium.value;

  // ── Init / identity ──

  Future<void> init({required String userId}) async {
    if (_initialized) return;
    if (EnvConfig.revenueCatApiKey.isEmpty) {
      debugPrint('[Payment] No RevenueCat key — free tier (demo mode)');
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(
        PurchasesConfiguration(EnvConfig.revenueCatApiKey)..appUserID = userId,
      );
      _initialized = true;
      Purchases.addCustomerInfoUpdateListener(_apply);
      await _refresh();
      debugPrint('[Payment] RevenueCat initialized for $userId');
    } catch (e) {
      debugPrint('[Payment] init failed: $e');
    }
  }

  Future<void> identify(String userId) async {
    if (!_initialized) return;
    try {
      final res = await Purchases.logIn(userId);
      _apply(res.customerInfo);
    } catch (e) {
      debugPrint('[Payment] identify failed: $e');
    }
  }

  Future<void> logOut() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('[Payment] logOut failed: $e');
    }
    _premium.value = false;
  }

  // ── Premium state ──

  void _apply(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(entitlementId);
    if (active != _premium.value) {
      _premium.value = active;
      _syncToFirestore(active);
    }
  }

  Future<void> _refresh() async {
    if (!_initialized) return;
    try {
      _apply(await Purchases.getCustomerInfo());
    } catch (e) {
      debugPrint('[Payment] refresh failed: $e');
    }
  }

  // ── Offerings / purchase ──

  /// The Balam Premium packages (monthly + yearly) from the current
  /// offering. Empty in demo mode.
  Future<List<Package>> premiumPackages() async {
    if (!_initialized) return const [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? const [];
    } catch (e) {
      debugPrint('[Payment] offerings failed: $e');
      return const [];
    }
  }

  Future<PurchaseResult> purchase(Package package) async {
    if (!_initialized) {
      return const PurchaseResult(
        success: false,
        error: 'Purchases are not available right now.',
      );
    }
    try {
      final info = await Purchases.purchasePackage(package);
      _apply(info);
      return PurchaseResult(success: _premium.value);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseResult(success: false, cancelled: true);
      }
      return const PurchaseResult(
        success: false,
        error: 'Purchase failed. Please try again.',
      );
    } catch (e) {
      debugPrint('[Payment] purchase error: $e');
      return const PurchaseResult(
        success: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Restore previous purchases (e.g. after reinstall). Returns the
  /// resulting premium status.
  Future<bool> restorePurchases() async {
    if (!_initialized) return false;
    try {
      _apply(await Purchases.restorePurchases());
    } catch (e) {
      debugPrint('[Payment] restore failed: $e');
    }
    return _premium.value;
  }

  /// Mirror premium status into `users/{uid}.premium` so the balamChat
  /// Cloud Function can enforce the free-tier gate server-side. A
  /// RevenueCat webhook should also write this field (defense in depth);
  /// Firestore rules must keep `premium` non-writable by clients except
  /// through this trusted path.
  Future<void> _syncToFirestore(bool premium) async {
    if (!isFirebaseInitialized) return;
    final uid = AuthService().currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .doc('users/$uid')
          .set({'premium': premium}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Payment] firestore sync failed: $e');
    }
  }
}

class PurchaseResult {
  final bool success;
  final bool cancelled;
  final String? error;

  const PurchaseResult({
    required this.success,
    this.cancelled = false,
    this.error,
  });
}
