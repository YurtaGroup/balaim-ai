import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../main.dart' show isFirebaseInitialized;
import '../analytics/analytics.dart';
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

  Future<PurchaseResult> purchase(
    Package package, {
    String surface = 'unknown',
  }) async {
    if (!_initialized) {
      return const PurchaseResult(
        success: false,
        error: 'Purchases are not available right now.',
      );
    }
    final productId = package.storeProduct.identifier;
    Analytics.instance.purchaseInitiated(
      productId: productId,
      surface: surface,
    );
    try {
      final info = await Purchases.purchasePackage(package);
      _apply(info);
      if (_premium.value) {
        Analytics.instance.purchaseCompleted(
          productId: productId,
          surface: surface,
          priceUsd: package.storeProduct.price,
        );
      }
      return PurchaseResult(success: _premium.value);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        Analytics.instance.purchaseFailed(
          productId: productId,
          reason: 'cancelled',
        );
        return const PurchaseResult(success: false, cancelled: true);
      }
      Analytics.instance.purchaseFailed(
        productId: productId,
        reason: code.toString(),
      );
      return const PurchaseResult(
        success: false,
        error: 'Purchase failed. Please try again.',
      );
    } catch (e) {
      debugPrint('[Payment] purchase error: $e');
      Analytics.instance.purchaseFailed(
        productId: productId,
        reason: 'unknown',
      );
      return const PurchaseResult(
        success: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Buy a one-off consumable — used for paid doctor consultations.
  /// In demo mode (no RevenueCat key) the purchase is simulated as
  /// successful so the consult flow is testable end-to-end.
  Future<PurchaseResult> purchaseConsult(String productId) async {
    if (!_initialized) {
      return const PurchaseResult(success: true); // demo mode
    }
    try {
      final products = await Purchases.getProducts([productId]);
      if (products.isEmpty) {
        return const PurchaseResult(
          success: false,
          error: 'Consultations are not available in your region yet.',
        );
      }
      await Purchases.purchaseStoreProduct(products.first);
      return const PurchaseResult(success: true);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseResult(success: false, cancelled: true);
      }
      return const PurchaseResult(
        success: false,
        error: 'Payment failed. Please try again.',
      );
    } catch (e) {
      debugPrint('[Payment] consult purchase error: $e');
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

  /// Tell the server to verify and persist this user's premium
  /// entitlement. The Firestore rule blocks `premium` writes from the
  /// client (otherwise free users would mint themselves Premium). The
  /// `setPremiumFromReceipt` callable verifies with the RevenueCat REST
  /// API, then writes the flag using the Admin SDK.
  ///
  /// Silent failure is fine — the AI free-tier gate is the source of
  /// truth at consumption time. If the server can't verify right now,
  /// the user simply stays on free until the next call (e.g. on app
  /// resume, restore-purchases, or webhook callback).
  Future<void> _syncToFirestore(bool premium) async {
    if (!isFirebaseInitialized) return;
    if (AuthService().currentUid == null) return;
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('setPremiumFromReceipt');
      await callable.call();
    } catch (e) {
      // Common pre-launch case: REVENUECAT_API_KEY not bound on the
      // server yet → the callable returns failed-precondition. Don't
      // spam — log once and move on.
      debugPrint('[Payment] premium sync skipped: $e');
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
