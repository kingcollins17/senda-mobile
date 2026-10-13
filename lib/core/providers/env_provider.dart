import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/models/app_env.dart';

/// A [Provider] that exposes the fully-loaded [AppEnv] configuration.
///
/// This provider is synchronous because [dotenv] must be fully loaded before
/// [ProviderScope] / [runApp] is called (see `main.dart`).
///
/// Usage:
/// ```dart
/// final env = ref.watch(envProvider);
/// final baseUrl = env.apiBaseUrl;
/// ```
final envProvider = Provider<AppEnv>((ref) {
  return AppEnv.fromDotenv();
});

/// Convenience extension so any [Ref] can access [AppEnv] without
/// writing `ref.watch(envProvider)` everywhere.
///
/// Usage inside a provider:
/// ```dart
/// final url = ref.env.apiBaseUrl;
/// ```
extension EnvRefExtension on Ref {
  AppEnv get env => watch(envProvider);
}
