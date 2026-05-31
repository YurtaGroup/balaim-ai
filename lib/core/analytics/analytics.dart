import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../main.dart' show isFirebaseInitialized;

/// Single typed entrypoint for every analytics event in Balam.
///
/// Why this exists: a YC partner cannot price the company off vibes.
/// They need to see the funnel — installs → first Ask → weekly cap hit
/// → paywall viewed → purchase → retention. The events below are the
/// minimum surface that lets us print a cohort chart inside 30 days.
///
/// Rules of the road:
/// - Use the typed methods on `Analytics`. Don't `logEvent` directly
///   from features — every event must live here so we can rename or
///   change shapes in one place.
/// - Properties are flat scalars only (no maps, no arrays). Firebase
///   silently drops nested objects on iOS.
/// - Server-trusted events (`weekly_cap_hit`, `purchase_completed`)
///   are ALSO logged from the Cloud Functions side using the Admin
///   SDK + log-to-Firestore pattern. The client-side event below is
///   the fast UI signal; the server-side log is the one the funnel
///   analysis trusts.
class Analytics {
  Analytics._();
  static final Analytics instance = Analytics._();

  FirebaseAnalytics? get _fa =>
      isFirebaseInitialized ? FirebaseAnalytics.instance : null;

  // ── Identity ────────────────────────────────────────────────────

  Future<void> setUser({required String uid, bool? premium}) async {
    final fa = _fa;
    if (fa == null) return;
    try {
      await fa.setUserId(id: uid);
      if (premium != null) {
        await fa.setUserProperty(
            name: 'premium', value: premium ? 'true' : 'false');
      }
    } catch (e) {
      _swallow('setUser', e);
    }
  }

  Future<void> clearUser() async {
    final fa = _fa;
    if (fa == null) return;
    try {
      await fa.setUserId(id: null);
    } catch (e) {
      _swallow('clearUser', e);
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────

  Future<void> appOpened() => _log('app_open');

  // ── Ask / AI ────────────────────────────────────────────────────

  Future<void> askQuestionSent({
    required int weekQuestionsUsed,
    required bool isPremium,
    String? personaId,
    bool? emergencyMode,
  }) =>
      _log('ask_question_sent', {
        'week_questions_used': weekQuestionsUsed,
        'is_premium': isPremium,
        if (personaId != null) 'persona_id': personaId,
        if (emergencyMode == true) 'emergency_mode': true,
      });

  Future<void> weeklyCapHit() => _log('weekly_cap_hit');

  // ── Paywall / purchase ─────────────────────────────────────────

  Future<void> paywallViewed({required String surface}) =>
      _log('paywall_viewed', {'surface': surface});

  Future<void> purchaseInitiated({
    required String productId,
    required String surface,
  }) =>
      _log('purchase_initiated', {
        'product_id': productId,
        'surface': surface,
      });

  Future<void> purchaseCompleted({
    required String productId,
    required String surface,
    double? priceUsd,
  }) =>
      _log('purchase_completed', {
        'product_id': productId,
        'surface': surface,
        if (priceUsd != null) 'price_usd': priceUsd,
      });

  Future<void> purchaseFailed({
    required String productId,
    required String reason,
  }) =>
      _log('purchase_failed', {
        'product_id': productId,
        'reason': reason,
      });

  // ── Care log (feeding + diaper) ─────────────────────────────────

  Future<void> feedingLogged({
    required String type, // FeedingType.name
    int? amountMl,
  }) =>
      _log('feeding_logged', {
        'type': type,
        if (amountMl != null) 'amount_ml': amountMl,
      });

  Future<void> diaperLogged({required String type}) =>
      _log('diaper_logged', {'type': type});

  // ── Mood ("Am I Okay") ──────────────────────────────────────────

  Future<void> moodCheckinLogged({
    required int level, // 1-5
    required bool hasNote,
  }) =>
      _log('mood_checkin_logged', {
        'level': level,
        'has_note': hasNote,
      });

  Future<void> moodThreadOpened() => _log('mood_thread_opened');

  // ── Montessori — Invitation + Observation ─────────────────────

  Future<void> observationLogged({String? noteLengthBucket}) => _log(
        'observation_logged',
        noteLengthBucket == null ? null : {'note_length': noteLengthBucket},
      );

  Future<void> invitationViewed({
    required String category,
    required int setupMinutes,
  }) =>
      _log('invitation_viewed', {
        'category': category,
        'setup_minutes': setupMinutes,
      });

  Future<void> invitationFeedback({
    required String feedback, // loved / lost_interest / too_early
    required String category,
  }) =>
      _log('invitation_feedback', {
        'feedback': feedback,
        'category': category,
      });

  // ── Internal ────────────────────────────────────────────────────

  Future<void> _log(String name, [Map<String, Object?>? params]) async {
    final fa = _fa;
    if (fa == null) return;
    try {
      final cleaned = <String, Object>{};
      params?.forEach((k, v) {
        if (v == null) return;
        cleaned[k] = v;
      });
      await fa.logEvent(name: name, parameters: cleaned.isEmpty ? null : cleaned);
    } catch (e) {
      _swallow(name, e);
    }
  }

  void _swallow(String label, Object e) {
    if (kDebugMode) {
      debugPrint('[analytics] $label failed: $e');
    }
  }
}
