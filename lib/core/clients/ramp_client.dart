import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:senda/core/models/base_response.dart';
import 'package:senda/core/models/ramp/ramp.dart';
import 'package:senda/core/providers/dio_provider.dart';

part 'ramp_client.g.dart';

/// Retrofit client for off-ramp endpoints.
///
/// Consumed via [rampClientProvider]:
/// ```dart
/// final rampClient = ref.read(rampClientProvider);
/// final banks = await rampClient.getBanks();
/// ```
@RestApi(baseUrl: '')
abstract class RampClient {
  factory RampClient(Dio dio, {String baseUrl}) = _RampClient;

  // ── List Banks ─────────────────────────────────────────────────────────────

  /// GET /api/v1/ramp/banks
  ///
  /// List supported Nigerian banks with their bank code and logo URL.
  /// Optionally filter by name or code using [query].
  @GET('/api/v1/ramp/banks')
  Future<BaseResponse<List<BankModel>>> getBanks({
    @Query('q') String? query,
  });

  // ── Verify Account ─────────────────────────────────────────────────────────

  /// POST /api/v1/ramp/verify
  ///
  /// Verify a recipient's Nigerian bank account by account number and bank code.
  /// Accepts a [body] Map with `account_number` and `bank_code`.
  @POST('/api/v1/ramp/verify')
  Future<BaseResponse<VerifyAccountResponse>> verifyAccount(
    @Body() Map<String, dynamic> body,
  );

  // ── Initiate Transfer ──────────────────────────────────────────────────────

  /// POST /api/v1/ramp/transfer
  ///
  /// Initiate an off-ramp bank transfer.
  /// Accepts [body] containing amount, currency, token, network, and recipient info.
  /// Optional [idempotencyKey] or [xIdempotencyKey] can be provided in headers.
  @POST('/api/v1/ramp/transfer')
  Future<BaseResponse<InitiateTransferResponse>> initiateTransfer(
    @Body() InitiateTransferRequest body, {
    @Header('Idempotency-Key') String? idempotencyKey,
    @Header('X-Idempotency-Key') String? xIdempotencyKey,
  });
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// Provides a scoped [RampClient] backed by the shared [dioProvider].
final rampClientProvider = Provider<RampClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RampClient(dio);
}, name: 'rampClientProvider');
