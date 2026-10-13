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
/// Nest keys inside their owning box using inner enums or a flat enum with
/// a naming convention. A flat enum is used here for simplicity — prefix
/// each key with its box name to make ownership obvious.
enum AppStorageKey {
  // ── AppBox.app ─────────────────────────────────────────────────────────────

  /// JWT / session token for the authenticated user.
  authToken,

  /// Refresh token used to renew [authToken].
  refreshToken,

  /// The raw JSON string of the cached current user profile.
  currentUser,

  /// Whether the user has completed the onboarding flow.
  onboardingComplete,

  /// ISO-8601 string of when the local cache was last refreshed.
  lastCacheRefresh;

  /// The string key written to the Hive box.
  String get key => name; // uses the enum member name as the box key
}
