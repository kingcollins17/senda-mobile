import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senda/core/constants.dart';
import 'package:senda/core/enums.dart';
import 'package:senda/core/providers/ramp_providers.dart';

export 'package:senda/core/enums.dart' show SupportedNetworks;

/// Holds the state of an in-progress bank transfer session across different screens.
final class BankTransferSessionState {
  /// Currently selected bank.
  final BankModel? bank;

  /// Input account number (10 digits for Nigerian NUBAN).
  final String accountNumber;

  /// Verified account info returned by account verification endpoint.
  final VerifyAccountResponse? verifiedAccount;

  /// Human-readable error message if account verification fails.
  final String? verificationError;

  /// Input fiat amount string (e.g. "5000" or "5,000").
  final String amount;

  /// Fiat currency (defaults to "NGN").
  final String currency;

  /// Crypto token selected for off-ramp payment (defaults to "USDC").
  final String token;

  /// Blockchain network chosen to pay with. Defaults to [SupportedNetworks.solana].
  final SupportedNetworks network;

  /// Active step in multi-step transfer flows.
  final int step;

  /// Unique idempotency key generated at session initiation.
  final String idempotencyKey;

  /// Order response received after initiating the transfer.
  final InitiateTransferResponse? transferOrder;

  /// Quote response received after initiating the transfer.
  InitiateTransferResponse? get quote => transferOrder;

  /// Human-readable error message if transfer initiation fails.
  final String? transferError;

  const BankTransferSessionState({
    this.bank,
    this.accountNumber = '',
    this.verifiedAccount,
    this.verificationError,
    this.amount = '',
    this.currency = 'NGN',
    this.token = 'USDC',
    this.network = SupportedNetworks.solana,
    this.step = 0,
    required this.idempotencyKey,
    this.transferOrder,
    this.transferError,
  });

  /// Factory creating an initial transfer session with a freshly generated [idempotencyKey].
  factory BankTransferSessionState.initial() =>
      BankTransferSessionState(idempotencyKey: _generateIdempotencyKey());

  /// Whether recipient account name has been successfully verified.
  bool get isAccountVerified => verifiedAccount != null;

  /// Resolved recipient account name if verified.
  String? get resolvedAccountName =>
      verifiedAccount?.accountName ?? verifiedAccount?.fullname;

  /// Resolved bank code from bank or verified account.
  String? get bankCode =>
      bank?.code ?? bank?.bankCode ?? verifiedAccount?.bankCode;

  /// Resolved bank name from bank or verified account.
  String? get bankName => bank?.name ?? verifiedAccount?.bankName;

  /// Parsed numeric fiat amount.
  num? get numericAmount => num.tryParse(amount.replaceAll(',', '').trim());

  /// Returns whether recipient details are valid and verified to proceed to amount entry.
  bool get canProceedToAmount =>
      accountNumber.trim().length >= 10 &&
      bankCode != null &&
      isAccountVerified;

  /// Returns whether transfer details are valid to proceed to review.
  bool get canProceedToReview => canProceedToAmount && (numericAmount ?? 0) > 0;

  /// Constructs a [TransferRecipient] object from the current session.
  TransferRecipient? get transferRecipient {
    final code = bankCode;
    if (code == null || accountNumber.trim().isEmpty) return null;
    return TransferRecipient(
      accountNumber: accountNumber.trim(),
      bankCode: code,
      bankName: bankName,
      accountName: verifiedAccount?.accountName,
      fullname: verifiedAccount?.fullname,
    );
  }

  /// Constructs an [InitiateTransferRequest] ready for the transfer endpoint.
  InitiateTransferRequest? get initiateTransferRequest {
    final recipient = transferRecipient;
    final amt = numericAmount;
    if (recipient == null || amt == null || amt <= 0) return null;
    return InitiateTransferRequest(
      amount: amt,
      currency: currency,
      token: token,
      network: network.apiValue,
      recipient: recipient,
    );
  }

  BankTransferSessionState copyWith({
    Object? bank = _sentinel,
    String? accountNumber,
    Object? verifiedAccount = _sentinel,
    Object? verificationError = _sentinel,
    String? amount,
    String? currency,
    String? token,
    SupportedNetworks? network,
    int? step,
    String? idempotencyKey,
    Object? transferOrder = _sentinel,
    Object? transferError = _sentinel,
  }) {
    return BankTransferSessionState(
      bank: identical(bank, _sentinel)
          ? this.bank
          : bank == NULL
          ? null
          : bank as BankModel?,
      accountNumber: accountNumber ?? this.accountNumber,
      verifiedAccount: identical(verifiedAccount, _sentinel)
          ? this.verifiedAccount
          : verifiedAccount == NULL
          ? null
          : verifiedAccount as VerifyAccountResponse?,
      verificationError: identical(verificationError, _sentinel)
          ? this.verificationError
          : verificationError == NULL
          ? null
          : verificationError as String?,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      token: token ?? this.token,
      network: network ?? this.network,
      step: step ?? this.step,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      transferOrder: identical(transferOrder, _sentinel)
          ? this.transferOrder
          : transferOrder == NULL
          ? null
          : transferOrder as InitiateTransferResponse?,
      transferError: identical(transferError, _sentinel)
          ? this.transferError
          : transferError == NULL
          ? null
          : transferError as String?,
    );
  }

  @override
  String toString() =>
      'BankTransferSessionState(bank: ${bank?.name}, accountNumber: $accountNumber, verified: $isAccountVerified, amount: $amount, network: ${network.apiValue}, idempotencyKey: $idempotencyKey, step: $step)';
}

const _sentinel = Object();

/// Generates a RFC 4122 v4 UUID for request idempotency.
String _generateIdempotencyKey() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // Version 4
  values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xx
  final buffer = StringBuffer();
  for (var i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
    buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

/// Notifier that manages the lifecycle of a bank transfer session across screens.
class BankTransferSessionNotifier extends Notifier<BankTransferSessionState> {
  @override
  BankTransferSessionState build() => BankTransferSessionState.initial();

  /// Updates the selected bank. If changed, clears any prior account verification.
  void setBank(BankModel? bank) {
    if (state.bank?.code != bank?.code) {
      state = state.copyWith(
        bank: bank ?? NULL,
        verifiedAccount: NULL,
        verificationError: NULL,
      );
    } else {
      state = state.copyWith(bank: bank ?? NULL);
    }
  }

  /// Updates the account number. If changed, clears any prior account verification.
  void setAccountNumber(String accountNumber) {
    final trimmed = accountNumber.trim();
    if (state.accountNumber != trimmed) {
      state = state.copyWith(
        accountNumber: trimmed,
        verifiedAccount: NULL,
        verificationError: NULL,
      );
    }
  }

  /// Updates the verified account directly.
  void setVerifiedAccount(VerifyAccountResponse? account) {
    state = state.copyWith(
      verifiedAccount: account ?? NULL,
      verificationError: NULL,
    );
  }

  /// Updates the transfer order directly.
  void setTransferOrder(InitiateTransferResponse? order) {
    state = state.copyWith(transferOrder: order ?? NULL, transferError: NULL);
  }

  /// Updates the transfer quote directly.
  void setQuote(InitiateTransferResponse? quote) => setTransferOrder(quote);

  /// Updates entered fiat transfer amount.
  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  /// Updates payment blockchain network.
  void setNetwork(SupportedNetworks network) {
    state = state.copyWith(network: network);
  }

  /// Updates payment token.
  void setToken(String token) {
    state = state.copyWith(token: token);
  }

  /// Updates fiat currency.
  void setCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  /// Sets current flow step index.
  void setStep(int step) {
    state = state.copyWith(step: step);
  }

  /// Advances to next step.
  void nextStep() {
    state = state.copyWith(step: state.step + 1);
  }

  /// Returns to previous step.
  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  /// Clears session state and resets all fields to their defaults with a new idempotency key.
  void reset() {
    state = BankTransferSessionState.initial();
  }
}

/// Provider for managing an active bank transfer session across screens.
final bankTransferSessionProvider =
    NotifierProvider<BankTransferSessionNotifier, BankTransferSessionState>(
      BankTransferSessionNotifier.new,
      name: 'bankTransferSessionProvider',
    );
