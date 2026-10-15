import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:senda/core/constants.dart';
import 'package:senda/core/models/storage_keys.dart';
import 'package:senda/core/providers/app_storage_provider.dart';
import 'package:senda/core/providers/auth_provider.dart';
import 'package:senda/core/util/error_util.dart';
import 'package:senda/core/util/json_util.dart';
import 'package:senda/core/util/log_util.dart';

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
      provider: provider == kNullObject ? null : provider ?? this.provider,
      solanaAddress: solanaAddress == kNullObject
          ? null
          : solanaAddress ?? this.solanaAddress,
      ethAddress: ethAddress == kNullObject
          ? null
          : ethAddress ?? this.ethAddress,
      polygonAddress: polygonAddress == kNullObject
          ? null
          : polygonAddress ?? this.polygonAddress,
      userId: userId == kNullObject ? null : userId ?? this.userId,
      connectedAt: connectedAt == kNullObject
          ? null
          : connectedAt ?? this.connectedAt,
    );
  }

  bool get hasAtleastOneConnected =>
      ethAddress != null || solanaAddress != null || polygonAddress != null;
  Map<String, dynamic> toJson() {
    return _$WalletConnectionStateToJson(this);
  }

  factory WalletConnectionState.fromJson(json) =>
      _$WalletConnectionStateFromJson(json.cast());

  @override
  String toString() => toJsonString();
}

/// Riverpod notifier managing wallet connections mapped per user and persisted in Hive.
class WalletNotifier extends AsyncNotifier<WalletConnectionState?> {
  @override
  FutureOr<WalletConnectionState?> build() async {
    // Listen for authentication changes so the active wallet switches to the logged-in user
    final user = (await ref.watch(authProvider.future)).user;
    final currentUserId = user?.id ?? _currentUserId;

    if (currentUserId == null) throw Exception('currentUserId cannot be null');
    final initial = await _loadForUser(currentUserId);
    return initial;
  }

  String? get _currentUserId {
    final authState = ref.read(authProvider).value;
    if (authState?.user?.id != null && authState!.user!.id!.isNotEmpty) {
      return authState.user!.id!;
    }
    return null;
  }

  // ignore: unused_element
  FutureOr<String> _getKey([String? value]) async {
    final userId = value ?? (await ref.read(authProvider.future)).user?.id;
    if (userId == null) throw Exception('UserID cannot be null')..debugLog();
    return _getKeySync(userId);
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

    // Automatically migrate guest wallet connection if the user has no wallet yet
    return WalletConnectionState.fromJson(json);
  }

  /// Persists [wallet] for [userId] in Hive storage.
  Future<void> _saveForUser(String userId, WalletConnectionState wallet) async {
    final appStorage = ref.read(appStorageProvider);

    await appStorage.put(_getKeySync(userId), wallet.toJson());
  }

  /// Connects an external wallet for the active user and persists in Hive.
  Future<void> connectWallet({
    required String provider,
    String? solanaAddress,
    String? ethAddress,
    String? polygonAddress,
    String? customUserId,
    void Function()? onSuccess,
    void Function(Object)? onError,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) throw Exception('userId cannot be null');
      final newState = WalletConnectionState(
        provider: provider,
        solanaAddress: solanaAddress,
        ethAddress: ethAddress,
        polygonAddress: polygonAddress,
        userId: userId,
        connectedAt: DateTime.now(),
      );

      state = AsyncData(newState);
      await _saveForUser(userId, newState);
      onSuccess?.call();
    } catch (e) {
      e.debugLog(DebugLevel.error);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Disconnects the wallet for the current active user and updates Hive.
  Future<void> disconnectWallet({
    void Function()? onSuccess,
    void Function(Object)? onError,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId != null) {
        await _clearUserWallet(userId);
      }
      onSuccess?.call();
    } catch (e) {
      e.debugLog(DebugLevel.error);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Clears stored wallet data for a specific user ID.
  Future<void> _clearUserWallet(String userId) async {
    final appStorage = ref.read(appStorageProvider);
    await appStorage.delete(_getKeySync(userId));

    state = AsyncData(null);
  }
}

/// Global provider for managing and observing wallet connections.
final walletProvider =
    AsyncNotifierProvider<WalletNotifier, WalletConnectionState?>(
      () => WalletNotifier(),
    );

final isWalletConnectedProvider = FutureProvider<bool>((ref) async {
  final result = await ref.watch(walletProvider.future);
  return result?.hasAtleastOneConnected ?? false;
});
final isWalletConnected = Provider<bool>(
  (ref) => ref.watch(isWalletConnectedProvider).value == true,
);
