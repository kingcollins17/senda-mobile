import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:senda/core/clients/users_client.dart';
import 'package:senda/core/constants.dart';
import 'package:senda/core/models/storage_keys.dart';
import 'package:senda/core/models/wallet/wallet.dart';
import 'package:senda/core/providers/app_storage_provider.dart';
import 'package:senda/core/providers/auth_provider.dart';
import 'package:senda/core/providers/user_provider.dart';
import 'package:senda/core/util/error_util.dart';
import 'package:senda/core/util/json_util.dart';
import 'package:senda/core/util/log_util.dart';

export 'package:senda/core/models/wallet/wallet.dart';
export 'package:senda/core/providers/user_provider.dart';

part 'wallet_provider.g.dart';

/// Represents the connection state and addresses of an external wallet mapped to a user.
@JsonSerializable(fieldRename: FieldRename.snake)
final class WalletConnectionState {
  final String? provider;
  final String? solanaAddress;
  final String? ethAddress;
  final String? polygonAddress;
  final String? userId;
  final DateTime? connectedAt;

  const WalletConnectionState({
    this.provider,
    this.solanaAddress,
    this.ethAddress,
    this.polygonAddress,
    this.userId,
    this.connectedAt,
  });

  WalletConnectionState copyWith({
    bool? isConnected,
    String? provider,
    String? solanaAddress,
    String? ethAddress,
    String? polygonAddress,
    String? userId,
    DateTime? connectedAt,
  }) {
    return WalletConnectionState(
      provider: provider == NULL ? null : provider ?? this.provider,
      solanaAddress: solanaAddress == NULL
          ? null
          : solanaAddress ?? this.solanaAddress,
      ethAddress: ethAddress == NULL ? null : ethAddress ?? this.ethAddress,
      polygonAddress: polygonAddress == NULL
          ? null
          : polygonAddress ?? this.polygonAddress,
      userId: userId == NULL ? null : userId ?? this.userId,
      connectedAt: connectedAt == NULL ? null : connectedAt ?? this.connectedAt,
    );
  }

  bool get hasAtleastOneConnected =>
      ethAddress != null || solanaAddress != null || polygonAddress != null;

  Map<String, dynamic> toJson() {
    return _$WalletConnectionStateToJson(this);
  }

  factory WalletConnectionState.fromJson(Map<String, dynamic> json) =>
      _$WalletConnectionStateFromJson(json);

  @override
  String toString() => toJsonString();
}

/// Riverpod notifier managing wallet connections mapped per user and persisted in Hive.
class WalletNotifier extends AsyncNotifier<WalletConnectionState?> {
  @override
  FutureOr<WalletConnectionState?> build() async {
    final authState = ref.watch(authProvider).valueOrNull;
    final currentUserId = authState?.user?.id ?? _currentUserId;

    if (currentUserId == null) return null;
    return _loadForUser(currentUserId);
  }

  String? get _currentUserId {
    final authState = ref.read(authProvider).value;
    if (authState?.user?.id != null && authState!.user!.id!.isNotEmpty) {
      return authState.user!.id!;
    }
    return null;
  }

  String _getKeySync(String userId) =>
      '${userId}_${AppStorageKey.connectedWallet}';

  /// Loads wallet state for [userId] from Hive storage.
  Future<WalletConnectionState?> _loadForUser(String userId) async {
    final appStorage = ref.read(appStorageProvider);
    final raw = await appStorage.get(_getKeySync(userId));
    if (raw == null) return null;
    dynamic decoded = raw;
    if (raw is String) {
      decoded = jsonDecode(decoded);
    }
    if (decoded is Map) {
      return WalletConnectionState.fromJson(Map<String, dynamic>.from(decoded));
    }
    return null;
  }

  /// Persists [wallet] for [userId] in Hive storage.
  Future<void> _saveForUser(String userId, WalletConnectionState wallet) async {
    final appStorage = ref.read(appStorageProvider);
    await appStorage.put(_getKeySync(userId), wallet.toJson());
  }

  /// Connects an external wallet to the user account, immediately updating local state and
  /// Hive storage, and asynchronously syncing with the [UsersClient] backend as a backup cache.
  Future<UserWallet?> connect({
    required String provider,
    String? solanaAddress,
    String? ethAddress,
    String? polygonAddress,
    List<WalletAccount>? accounts,
    bool syncBackend = true,
    void Function(UserWallet wallet)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    try {
      final accountList = accounts ??
          [
            if (solanaAddress != null && solanaAddress.isNotEmpty)
              WalletAccount(network: 'SOLANA', address: solanaAddress),
            if (ethAddress != null && ethAddress.isNotEmpty)
              WalletAccount(network: 'ETHEREUM', address: ethAddress),
            if (polygonAddress != null && polygonAddress.isNotEmpty)
              WalletAccount(network: 'POLYGON', address: polygonAddress),
          ];

      final solana = accountList
          .firstWhere(
            (a) => a.network?.toUpperCase() == 'SOLANA',
            orElse: () => const WalletAccount(),
          )
          .address;
      final eth = accountList
          .firstWhere(
            (a) => a.network?.toUpperCase() == 'ETHEREUM',
            orElse: () => const WalletAccount(),
          )
          .address;
      final polygon = accountList
          .firstWhere(
            (a) => a.network?.toUpperCase() == 'POLYGON',
            orElse: () => const WalletAccount(),
          )
          .address;

      final userId = _currentUserId;
      final now = DateTime.now();

      // 1. Immediately update local state and Hive storage (optimistic / primary cache)
      final localState = WalletConnectionState(
        provider: provider,
        solanaAddress: solana,
        ethAddress: eth,
        polygonAddress: polygon,
        userId: userId,
        connectedAt: now,
      );

      state = AsyncData(localState);
      if (userId != null) {
        await _saveForUser(userId, localState);
      }

      var userWallet = UserWallet(
        userId: userId,
        provider: provider,
        accounts: accountList,
        createdAt: now,
      );

      // Trigger caller callback immediately so the UI proceeds without waiting for network
      onSuccess?.call(userWallet);

      // 2. Synchronize with backend API as a backup cache if requested
      if (syncBackend) {
        try {
          final req = ConnectWalletRequest(
            provider: provider,
            accounts: accountList,
          );
          final client = ref.read(usersClientProvider);
          final response = await client.connectWallet(req);
          if (response.data != null) {
            userWallet = response.data!;
            final updatedState = WalletConnectionState(
              provider: userWallet.provider ?? provider,
              solanaAddress: userWallet.solanaAddress ?? solana,
              ethAddress: userWallet.ethAddress ?? eth,
              polygonAddress: userWallet.polygonAddress ?? polygon,
              userId: userWallet.userId ?? userId,
              connectedAt: userWallet.createdAt ?? now,
            );
            state = AsyncData(updatedState);
            if (userId != null) {
              await _saveForUser(userId, updatedState);
            }
          }
        } catch (apiError) {
          // Backend failure must not prevent local wallet connection from working
          apiError.debugLog(DebugLevel.warn);
        }
      }

      return userWallet;
    } catch (e) {
      e.debugLog(DebugLevel.error);
      onError?.call(e.toFriendlyMessage());
      return null;
    }
  }

  /// Disconnects the wallet, immediately clearing local storage and state,
  /// then synchronizing with the [UsersClient] backend as a backup cache.
  Future<void> disconnect({
    void Function()? onSuccess,
    void Function(Object error)? onError,
  }) async {
    try {
      // 1. Immediately clear local storage and reset state
      final userId = _currentUserId;
      if (userId != null) {
        await _clearUserWallet(userId);
      } else {
        state = const AsyncData(null);
      }

      onSuccess?.call();

      // 2. Synchronize with backend API as a backup cache
      try {
        final client = ref.read(usersClientProvider);
        await client.disconnectWallet();
      } catch (apiError) {
        // Backend failure must not prevent local disconnection from working
        apiError.debugLog(DebugLevel.warn);
      }
    } catch (e) {
      e.debugLog(DebugLevel.error);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Clears stored wallet data for a specific user ID.
  Future<void> _clearUserWallet(String userId) async {
    final appStorage = ref.read(appStorageProvider);
    await appStorage.delete(_getKeySync(userId));
    state = const AsyncData(null);
  }
}

/// Global provider for managing and observing wallet connections.
final walletProvider =
    AsyncNotifierProvider<WalletNotifier, WalletConnectionState?>(
  () => WalletNotifier(),
  name: 'walletProvider',
);

final isWalletConnectedProvider = FutureProvider<bool>((ref) async {
  final result = await ref.watch(walletProvider.future);
  return result?.hasAtleastOneConnected ?? false;
});

final isWalletConnected = Provider<bool>(
  (ref) => ref.watch(isWalletConnectedProvider).value == true,
);

/// Provider that watches [getWalletProvider] and updates the local [walletProvider]
/// by invoking its [WalletNotifier.connect] method whenever a wallet is loaded.
final syncWalletProvider = Provider<AsyncValue<UserWallet?>>((ref) {
  final walletAsync = ref.watch(getWalletProvider);
  final wallet = walletAsync.valueOrNull;

  if (wallet != null) {
    final current = ref.read(walletProvider).valueOrNull;
    final isAlreadySynced = current?.provider == wallet.provider &&
        current?.solanaAddress == wallet.solanaAddress &&
        current?.ethAddress == wallet.ethAddress &&
        current?.polygonAddress == wallet.polygonAddress;

    if (!isAlreadySynced) {
      Future.microtask(() {
        ref.read(walletProvider.notifier).connect(
              provider: wallet.provider ?? 'external',
              accounts: wallet.accounts,
              solanaAddress: wallet.solanaAddress,
              ethAddress: wallet.ethAddress,
              polygonAddress: wallet.polygonAddress,
              syncBackend: false,
            );
      });
    }
  }

  return walletAsync;
}, name: 'syncWalletProvider');

/// Alias for [syncWalletProvider] matching user prompt spelling.
final syncWallletProvider = syncWalletProvider;

