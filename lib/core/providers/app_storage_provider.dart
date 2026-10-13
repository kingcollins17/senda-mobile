import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/models/storage_keys.dart';
import 'package:senda/core/util/local_storage_service.dart';

/// The global app storage provider — bound to [AppBox.app].
///
/// This provider is intentionally **not** declared with `keep_alive` by
/// default because the [LocalStorageService] is created before [ProviderScope]
/// mounts (see `main.dart`) and the reference is injected as an override.
///
/// Usage inside any widget or provider:
/// ```dart
/// // In a ConsumerWidget / ConsumerStatefulWidget
/// final storage = ref.read(appStorageProvider);
/// await storage.put(AppStorageKey.authToken, token);
///
/// // In a Provider / AsyncNotifier
/// final storage = ref.read(appStorageProvider);
/// ```
final appStorageProvider = Provider<LocalStorageService>(
  (ref) => throw UnimplementedError(
    'appStorageProvider must be overridden in ProviderScope. '
    'Call initAppStorage() in main() and pass the result as an override.',
  ),
  name: 'appStorageProvider',
);


LocalStorageService? _appStorage;

LocalStorageService? get appStorage => _appStorage;
/// Initialises Hive and opens the [AppBox.app] box.
///
/// Call this **once** in `main()` before `runApp`, then inject the result
/// into [ProviderScope] as an override:
///
/// ```dart
/// final appStorage = await initAppStorage();
/// runApp(
///   ProviderScope(
///     overrides: [appStorageProvider.overrideWithValue(appStorage)],
///     child: const MyApp(),
///   ),
/// );
/// ```
///
Future<LocalStorageService> initAppStorage() async {

  _appStorage=await LocalStorageService.open(AppBox.app);
  return appStorage!;
}
