import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:senda/core/providers/wallet_provider.dart';

import 'package:senda/core/providers/app_storage_provider.dart';
import 'theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load environment variables from .env.
  await dotenv.load(fileName: '.env');

  // 2. Initialise Hive (sets up the app-documents directory on device).
  await Hive.initFlutter();

  // 3. Open the app storage box before the widget tree builds.
  final appStorage = await initAppStorage();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the fully-initialised storage service into the provider tree.
        appStorageProvider.overrideWithValue(appStorage),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch syncWalletProvider to keep walletConnectionState in sync with backend API
    ref.watch(syncWalletProvider);

    return MaterialApp.router(
      title: 'Senda MVP',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
