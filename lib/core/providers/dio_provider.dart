import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/models/storage_keys.dart';
import 'package:senda/core/providers/app_storage_provider.dart';
import 'package:senda/core/providers/env_provider.dart';

/// Provides a fully-configured [Dio] instance for the app.
///
/// The base URL is pulled from [envProvider] so it is never hard-coded.
/// The current access token is attached to requests when one is stored.
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final appStorage = ref.watch(appStorageProvider);

  final options = BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  final dio = Dio(options);

  // ── Interceptors ───────────────────────────────────────────────────────────
  // Add a logging interceptor in debug builds.
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ),
    );
    return true;
  }());

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = appStorage.get<String>(AppStorageKey.authToken);
        if (accessToken != null && accessToken.trim().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${accessToken.trim()}';
        }
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.data is Map) {
          // pass the status code to the response body
          response.data['status_code'] = response.statusCode;
        }
        handler.next(response);
      },
    ),
  );

  return dio;
}, name: 'dioProvider');
