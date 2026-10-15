import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/clients/users_client.dart';
import 'package:senda/core/models/auth/user.dart';
import 'package:senda/core/providers/auth_provider.dart';

/// Future provider exposing the profile of the currently authenticated user (`/api/v1/users/me`).
///
/// Automatically syncs [authProvider]'s cached user when fresh data is returned.
final userProvider = FutureProvider<User?>((ref) async {
  final client = ref.watch(usersClientProvider);
  final response = await client.getMe();
  final user = response.data;
  if (user != null) {
    ref.read(authProvider.notifier).updateAuthState(user: user);
  }
  return user;
}, name: 'userProvider');

/// Future provider exposing connected wallet and blockchain accounts (`/api/v1/wallets`).
final getWalletProvider = FutureProvider<UserWallet?>((ref) async {
  final client = ref.watch(usersClientProvider);
  final response = await client.getWallet();
  return response.data;
}, name: 'getWalletProvider');

/// Alias for [getWalletProvider].
final userWalletProvider = getWalletProvider;
