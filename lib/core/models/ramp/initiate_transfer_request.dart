import 'package:json_annotation/json_annotation.dart';

part 'initiate_transfer_request.g.dart';

/// Recipient bank account details for an off-ramp transfer.
@JsonSerializable(includeIfNull: false)
class TransferRecipient {
  @JsonKey(name: 'account_number')
  final String accountNumber;

  @JsonKey(name: 'bank_code')
  final String bankCode;

  @JsonKey(name: 'bank_name')
  final String? bankName;

  @JsonKey(name: 'account_name')
  final String? accountName;

  @JsonKey(name: 'fullname')
  final String? fullname;

  @JsonKey(name: 'recipient_id')
  final String? recipientId;

  const TransferRecipient({
    required this.accountNumber,
    required this.bankCode,
    this.bankName,
    this.accountName,
    this.fullname,
    this.recipientId,
  });

  factory TransferRecipient.fromJson(Map<String, dynamic> json) =>
      _$TransferRecipientFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRecipientToJson(this);

  @override
  String toString() =>
      'TransferRecipient(accountNumber: $accountNumber, bankCode: $bankCode, bankName: $bankName)';
}

/// Request body for initiating an off-ramp bank transfer (POST /api/v1/ramp/transfer).
@JsonSerializable(includeIfNull: false)
class InitiateTransferRequest {
  /// Amount to transfer in selected currency (> 0).
  @JsonKey(name: 'amount')
  final num amount;

  /// Currency of choice, defaults to "NGN".
  @JsonKey(name: 'currency')
  final String currency;

  /// Crypto token to pay with, defaults to "USDC".
  @JsonKey(name: 'token')
  final String token;

  /// Blockchain network (e.g. "SOLANA", "ETHEREUM", "POLYGON"). Defaults to "SOLANA".
  @JsonKey(name: 'network')
  final String network;

  /// Recipient bank account details.
  @JsonKey(name: 'recipient')
  final TransferRecipient recipient;

  const InitiateTransferRequest({
    required this.amount,
    this.currency = 'NGN',
    this.token = 'USDC',
    this.network = 'SOLANA',
    required this.recipient,
  });

  factory InitiateTransferRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateTransferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InitiateTransferRequestToJson(this);

  @override
  String toString() =>
      'InitiateTransferRequest(amount: $amount, currency: $currency, token: $token, network: $network, recipient: $recipient)';
}
