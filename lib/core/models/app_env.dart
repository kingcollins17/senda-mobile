import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Strongly-typed model for all environment variables loaded from `.env`.
///
/// Add new variables here as the project grows — keep one source of truth
/// instead of sprinkling raw [dotenv.get] calls throughout the codebase.
class AppEnv {
  // ─── Fields ────────────────────────────────────────────────────────────────

  /// Base URL for the Senda REST API.
  final String apiBaseUrl;

  // ─── Constructor ───────────────────────────────────────────────────────────

  const AppEnv({
    required this.apiBaseUrl,
  });

  // ─── Factory ───────────────────────────────────────────────────────────────

  /// Reads every variable from [dotenv] and constructs the model.
  ///
  /// Throws a [StateError] if any required variable is missing or empty,
  /// so misconfigured environments are caught at startup rather than at runtime.
  factory AppEnv.fromDotenv() {
    return AppEnv(
      apiBaseUrl: _require('API_BASE_URL'),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the value of [key] from dotenv, or throws a [StateError] if
  /// the key is absent or blank.
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Missing required environment variable: "$key". '
        'Make sure it is set in your .env file and that the file is loaded '
        'before accessing AppEnv.',
      );
    }
    return value.trim();
  }

  /// Returns the value of [key], or [fallback] when the key is absent/blank.
  // ignore: unused_element
  static String _optional(String key, String fallback) =>
      dotenv.env[key]?.trim().isEmpty == false
          ? dotenv.env[key]!.trim()
          : fallback;

  // ─── Debug ─────────────────────────────────────────────────────────────────

  @override
  String toString() => 'AppEnv(apiBaseUrl: $apiBaseUrl)';
}
