import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:senda/core/models/auth/user.dart';
import 'package:senda/core/models/base_response.dart';
import 'package:senda/core/models/wallet/wallet.dart';
import 'package:senda/core/providers/dio_provider.dart';

part 'users_client.g.dart';

/// Retrofit client for user profile and wallet management endpoints.
///
/// Consumed via [usersClientProvider]:
/// ```dart
/// final usersClient = ref.read(usersClientProvider);
/// final me = await usersClient.getMe();
/// final wallet = await usersClient.getWallet();
/// ```
@RestApi(baseUrl: '')
abstract class UsersClient {
  factory UsersClient(Dio dio, {String baseUrl}) = _UsersClient;

  // ── Get User Me ────────────────────────────────────────────────────────────

  /// GET /api/v1/users/me
  ///
  /// Returns the profile and connected wallet of the currently authenticated user.
  @GET('/api/v1/users/me')
  Future<BaseResponse<User>> getMe();

  // ── Connect Wallet ─────────────────────────────────────────────────────────

  /// POST /api/v1/wallets/connect
  ///
  /// Attach a wallet (e.g. Phantom, MetaMask) and its associated accounts/addresses to the user.
  @POST('/api/v1/wallets/connect')
  Future<BaseResponse<UserWallet>> connectWallet(
    @Body() ConnectWalletRequest body,
  );

  // ── Get Wallet ─────────────────────────────────────────────────────────────

  /// GET /api/v1/wallets
  ///
  /// Retrieve connected wallet and their blockchain accounts for the current user.
  @GET('/api/v1/wallets')
  Future<BaseResponse<UserWallet>> getWallet();

  // ── Disconnect Wallet ──────────────────────────────────────────────────────

  /// DELETE /api/v1/wallets
  ///
  /// Disconnect a wallet from the user account and remove its associated accounts.
  @DELETE('/api/v1/wallets')
  Future<BaseResponse<void>> disconnectWallet();
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// Provides a scoped [UsersClient] backed by the shared [dioProvider].
final usersClientProvider = Provider<UsersClient>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersClient(dio);
}, name: 'usersClientProvider');
