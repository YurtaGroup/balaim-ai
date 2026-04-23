/// Master switch between v1 (full-surface, parenting-app-era) and v2
/// (child-first, 3-tab). Every feature that v2 hides is gated by one
/// of these constants. To revert v2 entirely: flip `v2Surface = false`
/// and rebuild. The legacy code is never deleted — just unreachable.
///
/// `main` branch expects `v2Surface = false`. `v2-child-first` branch
/// expects `v2Surface = true`. Do not merge this file between branches
/// without intent.
class FeatureFlags {
  FeatureFlags._();

  /// The one master flag. Everything else derives from it so a single
  /// edit here is the revert.
  static const bool v2Surface = true;

  // ─── v2 hides these surfaces ──────────────────────────────────
  static const bool showCommunityTab = !v2Surface;
  static const bool showMarketplaceTab = !v2Surface;
  static const bool showMyChildTab = !v2Surface;      // v2 has a "Child" tab with its own content
  static const bool showTodayTab = !v2Surface;        // v2 replaces Today with Home
  static const bool showBalamBoxEntry = !v2Surface;   // backend still deployed; just hide the UI entry
  static const bool showMoments = !v2Surface;
  static const bool showSounds = !v2Surface;
  static const bool showJourneyTools = !v2Surface;    // kick counter, hospital bag, etc.
  static const bool showNewbornTools = !v2Surface;    // feeding log, diaper log, soothing, etc.
  static const bool showDoctorDashboard = !v2Surface;
  static const bool showAdminTools = !v2Surface;
  static const bool showStageSpecificTodayCards = !v2Surface; // Focus/Activity/Worry/Insight/Product

  // ─── v2 turns these on ────────────────────────────────────────
  static const bool showHomeTab = v2Surface;          // new unified feed
  static const bool showAskTab = v2Surface;           // voice-first AI
  static const bool showChildTab = v2Surface;         // vault + member switcher + add-family

  /// v2 restricts the household model to `MemberRole.child` members
  /// at onboarding. Adult family returns in a 2-week fast-follow.
  static const bool childOnlyAtLaunch = v2Surface;
}
