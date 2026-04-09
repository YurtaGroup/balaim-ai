import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/env_config.dart';

/// RevenueCat-powered payment service.
///
/// Business model:
/// - App is 100% free (tools, AI, community, marketplace browsing)
/// - Consultations are per-purchase (consumable IAP)
/// - Doctor gets 80%, Balam gets 20% (minus Apple/Google's cut)
///
/// RevenueCat product IDs (configure in RevenueCat dashboard):
/// - balam_consult_50   → $50 consultation (Kyrgyzstan market)
/// - balam_consult_100  → $100 consultation
/// - balam_consult_150  → $150 consultation
/// - balam_consult_200  → $200 consultation
///
/// Each maps to a consumable IAP in App Store Connect / Google Play Console.
class PaymentService {
  static final PaymentService _instance = PaymentService._();
  factory PaymentService() => _instance;
  PaymentService._();

  bool _initialized = false;

  // ── Init ──

  Future<void> init({required String userId}) async {
    if (_initialized) return;
    if (EnvConfig.revenueCatApiKey.isEmpty) {
      debugPrint('[Payment] No RevenueCat key — running in demo mode');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.warn);
      final config = PurchasesConfiguration(EnvConfig.revenueCatApiKey)
        ..appUserID = userId;
      await Purchases.configure(config);
      _initialized = true;
      debugPrint('[Payment] RevenueCat initialized for user $userId');
    } catch (e) {
      debugPrint('[Payment] RevenueCat init failed: $e');
    }
  }

  /// Update RevenueCat user ID after sign-in.
  Future<void> identify(String userId) async {
    if (!_initialized) return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('[Payment] identify failed: $e');
    }
  }

  /// Log out from RevenueCat on sign-out.
  Future<void> logOut() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('[Payment] logOut failed: $e');
    }
  }

  // ── Purchase consultation ──

  /// Purchase a consultation. Returns true if successful.
  ///
  /// [priceUsd] is the doctor's consultation price.
  /// We map it to the nearest available IAP product.
  Future<PurchaseResult> purchaseConsultation({required double priceUsd}) async {
    if (!_initialized) {
      // Demo mode — simulate a successful purchase
      debugPrint('[Payment] Demo mode — simulating purchase of \$$priceUsd');
      await Future.delayed(const Duration(milliseconds: 500));
      return PurchaseResult(
        success: true,
        transactionId: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    try {
      // Get available packages
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        return PurchaseResult(success: false, error: 'No offerings available. Please try again later.');
      }

      // Find the package matching this consultation price
      final productId = _productIdForPrice(priceUsd);
      final package = offering.availablePackages.where(
        (p) => p.storeProduct.identifier == productId,
      );

      if (package.isEmpty) {
        // Fallback: show all available packages and buy the first consumable
        final consumables = offering.availablePackages.where(
          (p) => p.packageType == PackageType.custom,
        );
        if (consumables.isEmpty) {
          return PurchaseResult(success: false, error: 'Consultation purchases are not available in your region yet.');
        }
        // Purchase the closest match
        final customerInfo = await Purchases.purchasePackage(consumables.first);
        return PurchaseResult(
          success: true,
          transactionId: customerInfo.originalAppUserId,
        );
      }

      final customerInfo = await Purchases.purchasePackage(package.first);
      return PurchaseResult(
        success: true,
        transactionId: customerInfo.originalAppUserId,
      );
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult(success: false, error: 'Purchase cancelled.');
      }
      return PurchaseResult(success: false, error: 'Purchase failed. Please try again.');
    } catch (e) {
      debugPrint('[Payment] Purchase error: $e');
      return PurchaseResult(success: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Map doctor price to RevenueCat product ID.
  String _productIdForPrice(double price) {
    if (price <= 50) return 'balam_consult_50';
    if (price <= 100) return 'balam_consult_100';
    if (price <= 150) return 'balam_consult_150';
    return 'balam_consult_200';
  }

  // ── Restore ──

  /// Restore previous purchases (e.g., after reinstall).
  Future<void> restorePurchases() async {
    if (!_initialized) return;
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('[Payment] Restore failed: $e');
    }
  }
}

class PurchaseResult {
  final bool success;
  final String? transactionId;
  final String? error;

  const PurchaseResult({
    required this.success,
    this.transactionId,
    this.error,
  });
}
