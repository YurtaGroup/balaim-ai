import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/payment_service.dart';

/// Premium entitlement status, driven by RevenueCat via [PaymentService].
///
/// Watch this anywhere the UI gates a premium feature. Demo mode (no
/// RevenueCat key) reports `false`, so the free-tier paywall and the
/// add-second-child gate stay exercisable without a store connection.
final isPremiumProvider =
    StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<bool> {
  final ValueListenable<bool> _listenable = PaymentService().premiumListenable;

  PremiumNotifier() : super(PaymentService().isPremium) {
    _listenable.addListener(_sync);
  }

  void _sync() => state = _listenable.value;

  @override
  void dispose() {
    _listenable.removeListener(_sync);
    super.dispose();
  }
}
