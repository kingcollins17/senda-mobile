import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/providers/env_provider.dart';

/// Provides a fully-configured [Dio] instance for the app.
///
/// The base URL is pulled from [envProvider] so it is never hard-coded.
/// Interceptors for logging, auth token injection, and error handling
/// should be added here as the project grows.
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);

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
     
      onResponse: (response, handler) {
        if(response.data is Map) {
          // pass the status code to the response body
           response.data['status_code'] = response.statusCode;
        }
       
        handler.next(response);
      },
    ),
  );

  return dio;
}, name: 'dioProvider');
