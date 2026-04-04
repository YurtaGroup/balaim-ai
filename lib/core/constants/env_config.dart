/// Environment configuration for Balam.AI
///
/// Firebase config is handled by google-services.json (Android)
/// and GoogleService-Info.plist (iOS) — no manual config needed.
///
/// Cloud Functions base URL and API keys go here.
class EnvConfig {
  EnvConfig._();

  // Cloud Functions base URL (update after deploying)
  static const cloudFunctionsBaseUrl = String.fromEnvironment(
    'CLOUD_FUNCTIONS_URL',
    defaultValue: 'http://localhost:5001/balam-ai/us-central1',
  );

  // Claude API is called server-side via Cloud Functions (never from client)
  // Stripe publishable key (safe for client)
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: '',
  );

  // RevenueCat
  static const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_KEY',
    defaultValue: '',
  );
}
