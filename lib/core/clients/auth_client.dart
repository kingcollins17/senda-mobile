import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:senda/core/models/auth/auth_response.dart';
import 'package:senda/core/models/auth/login_request.dart';
import 'package:senda/core/models/auth/otp_request.dart';
import 'package:senda/core/models/auth/register_request.dart';
import 'package:senda/core/models/base_response.dart';
import 'package:senda/core/providers/dio_provider.dart';

part 'auth_client.g.dart';

/// Retrofit client for all authentication endpoints.
///
/// Consumed via [authClientProvider]:
/// ```dart
/// final client = ref.read(authClientProvider);
/// final response = await client.login(LoginRequest(email: '...', password: '...'));
/// ```
@RestApi(baseUrl: '')
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  // ── Register ───────────────────────────────────────────────────────────────

  /// POST /api/v1/auth/register
  ///
  /// Creates a new user account. Supports NORMAL (password), GOOGLE, and
  /// APPLE sign-in methods.
  @POST('/api/v1/auth/register')
  Future<AuthResponse> register(
    @Body() RegisterRequest body,
  );

  // ── Login ──────────────────────────────────────────────────────────────────

  /// POST /api/v1/auth/login
  ///
  /// Authenticates an existing user and returns access & refresh tokens.
  @POST('/api/v1/auth/login')
  Future<AuthResponse> login(
    @Body() LoginRequest body,
  );

  // ── Send OTP ───────────────────────────────────────────────────────────────

  /// POST /api/v1/auth/send-otp
  ///
  /// Sends a mock OTP to the given email address.
  @POST('/api/v1/auth/send-otp')
  Future<BaseResponse<void>> sendOtp(
    @Body() SendOtpRequest body,
  );

  // ── Verify OTP ─────────────────────────────────────────────────────────────

  /// POST /api/v1/auth/verify-otp
  ///
  /// Verifies the OTP for an email. Mock: OTP "123456" marks the email
  /// as verified in the database.
  @POST('/api/v1/auth/verify-otp')
  Future<BaseResponse<void>> verifyOtp(
    @Body() VerifyOtpRequest body,
  );
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// Provides a scoped [AuthClient] backed by the shared [dioProvider].
final authClientProvider = Provider<AuthClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthClient(dio);
}, name: 'authClientProvider');
