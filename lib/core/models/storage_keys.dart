/// All Hive box names used in the application.
///
/// Each enum value corresponds to exactly one Hive box.
/// Add new boxes here as features grow.
enum AppBox {
  /// General app-wide persistent storage (auth tokens, preferences, etc.).
  app;

  /// The string key used to open/identify the Hive box.
  String get name {
    switch (this) {
      case AppBox.app:
        return 'app_storage';
    }
  }
}

/// All keys used across Hive boxes.
///
/// Nest keys inside their owning box using inner classes or a flat class with
/// a naming convention. A flat class is used here for simplicity — prefix
/// each key with its box name to make ownership obvious.
abstract final class AppStorageKey {
  AppStorageKey._();

  // ── AppBox.app ─────────────────────────────────────────────────────────────

  /// JWT / session token for the authenticated user.
  static const String authToken = 'authToken';

  /// Refresh token used to renew [authToken].
  static const String refreshToken = 'refreshToken';

  /// The raw JSON string of the cached current user profile.
  static const String currentUser = 'currentUser';

  /// Whether the user has completed the onboarding flow.
  static const String onboardingComplete = 'onboardingComplete';

  /// ISO-8601 string of when the local cache was last refreshed.
  static const String lastCacheRefresh = 'lastCacheRefresh';

  /// The JSON string mapping user IDs to their connected wallet connection state.
  static const String connectedWallet = 'connectedWallet';
}
