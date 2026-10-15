import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/clients/ramp_client.dart';
import 'package:senda/core/models/ramp/ramp.dart';
import 'package:senda/core/util/error_util.dart';

export 'package:senda/core/clients/ramp_client.dart'
    show rampClientProvider, RampClient;
export 'package:senda/core/models/ramp/ramp.dart';

// ─── 1. Bank Providers ───────────────────────────────────────────────────────

/// Fetches supported Nigerian banks, optionally filtered by search query [query].
final banksProvider = FutureProvider.family<List<BankModel>, String?>((
  ref,
  query,
) async {
  final client = ref.watch(rampClientProvider);
  final response = await client.getBanks(query: query);
  return response.data ?? const <BankModel>[];
}, name: 'banksProvider');

/// Convenience provider for fetching all supported Nigerian banks without query filter.
final allBanksProvider = FutureProvider<List<BankModel>>((ref) async {
  return ref.watch(banksProvider(null).future);
}, name: 'allBanksProvider');

/// Active search query for filtering banks in UI bottom sheets or lists.
final bankSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
  name: 'bankSearchQueryProvider',
);

/// Returns banks filtered by the current [bankSearchQueryProvider] value.
final searchedBanksProvider = FutureProvider.autoDispose<List<BankModel>>((
  ref,
) async {
  final query = ref.watch(bankSearchQueryProvider).trim();
  return ref.watch(banksProvider(query.isEmpty ? null : query).future);
}, name: 'searchedBanksProvider');

// ─── 2. Account Verification ─────────────────────────────────────────────────

/// Parameters required to verify a Nigerian bank account.
class VerifyAccountParams {
  final String accountNumber;
  final String bankCode;

  const VerifyAccountParams({
    required this.accountNumber,
    required this.bankCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyAccountParams &&
          runtimeType == other.runtimeType &&
          accountNumber == other.accountNumber &&
          bankCode == other.bankCode;

  @override
  int get hashCode => Object.hash(accountNumber, bankCode);

  @override
  String toString() =>
      'VerifyAccountParams(accountNumber: $accountNumber, bankCode: $bankCode)';
}

/// Declarative family provider for verifying a bank account by [VerifyAccountParams].
final verifyAccountFutureProvider = FutureProvider.autoDispose
    .family<VerifyAccountResponse, VerifyAccountParams>((ref, params) async {
      final client = ref.watch(rampClientProvider);
      final response = await client.verifyAccount({
        'account_number': params.accountNumber,
        'bank_code': params.bankCode,
      });

      final data = response.data;
      if (data != null) {
        return data;
      }
      throw response.detail ?? 'Unable to verify account details';
    }, name: 'verifyAccountFutureProvider');

/// Manages account verification state with imperatively callable methods.
class AccountVerificationNotifier
    extends AutoDisposeAsyncNotifier<VerifyAccountResponse?> {
  @override
  FutureOr<VerifyAccountResponse?> build() => null;

  /// Verifies a recipient's bank account by [accountNumber] and [bankCode].
  Future<VerifyAccountResponse?> verify({
    required String accountNumber,
    required String bankCode,
    void Function(VerifyAccountResponse account)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(rampClientProvider);
      final response = await client.verifyAccount({
        'account_number': accountNumber,
        'bank_code': bankCode,
      });

      final data = response.data;
      if (data != null) {
        state = AsyncValue.data(data);
        onSuccess?.call(data);
        return data;
      } else {
        final error = response.detail ?? 'Account verification failed';
        state = AsyncValue.error(error, StackTrace.current);
        onError?.call(error);
        return null;
      }
    } catch (e, st) {
      final message = e.toFriendlyMessage();
      state = AsyncValue.error(message, st);
      onError?.call(message);
      return null;
    }
  }

  /// Clears the current verification state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Notifier provider for imperative account verification actions and state inspection.
final accountVerificationProvider =
    AsyncNotifierProvider.autoDispose<
      AccountVerificationNotifier,
      VerifyAccountResponse?
    >(AccountVerificationNotifier.new, name: 'accountVerificationProvider');

// ─── 3. Initiate Transfer ────────────────────────────────────────────────────

/// Manages off-ramp transfer initiation lifecycle and payment details.
class InitiateTransferNotifier
    extends AutoDisposeAsyncNotifier<InitiateTransferResponse?> {
  @override
  FutureOr<InitiateTransferResponse?> build() => null;

  /// Initiates an off-ramp transfer order.
  Future<InitiateTransferResponse?> initiateTransfer(
    InitiateTransferRequest request, {
    String? idempotencyKey,
    String? xIdempotencyKey,
    void Function(InitiateTransferResponse response)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(rampClientProvider);
      final response = await client.initiateTransfer(
        request,
        idempotencyKey: idempotencyKey,
        xIdempotencyKey: xIdempotencyKey,
      );

      final data = response.data;
      if (data != null) {
        state = AsyncValue.data(data);
        onSuccess?.call(data);
        return data;
      } else {
        final error = response.detail ?? 'Failed to initiate transfer';
        state = AsyncValue.error(error, StackTrace.current);
        onError?.call(error);
        return null;
      }
    } catch (e, st) {
      final message = e.toFriendlyMessage();
      state = AsyncValue.error(message, st);
      onError?.call(message);
      return null;
    }
  }

  /// Clears the current transfer state.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Notifier provider for initiating off-ramp bank transfers.
final initiateTransferProvider =
    AsyncNotifierProvider.autoDispose<
      InitiateTransferNotifier,
      InitiateTransferResponse?
    >(InitiateTransferNotifier.new, name: 'initiateTransferProvider');
