import 'package:json_annotation/json_annotation.dart';

part 'initiate_transfer_response.g.dart';

/// Breakdown of fees associated with the off-ramp transfer.
@JsonSerializable()
class TransferFees {
  @JsonKey(name: 'platform_fee_ngn')
  final num? platformFeeNgn;

  @JsonKey(name: 'provider_fee_ngn')
  final num? providerFeeNgn;

  @JsonKey(name: 'total_fee_ngn')
  final num? totalFeeNgn;

  @JsonKey(name: 'total_fiat_amount')
  final num? totalFiatAmount;

  const TransferFees({
    this.platformFeeNgn,
    this.providerFeeNgn,
    this.totalFeeNgn,
    this.totalFiatAmount,
  });

  factory TransferFees.fromJson(Map<String, dynamic> json) =>
      _$TransferFeesFromJson(json);

  Map<String, dynamic> toJson() => _$TransferFeesToJson(this);

  @override
  String toString() =>
      'TransferFees(totalFeeNgn: $totalFeeNgn, totalFiatAmount: $totalFiatAmount)';
}

/// Recipient bank account details returned in the transfer response.
@JsonSerializable()
class TransferRecipientInfo {
  @JsonKey(name: 'account_number')
  final String? accountNumber;

  @JsonKey(name: 'bank_code')
  final String? bankCode;

  @JsonKey(name: 'bank_name')
  final String? bankName;

  @JsonKey(name: 'account_name')
  final String? accountName;

  const TransferRecipientInfo({
    this.accountNumber,
    this.bankCode,
    this.bankName,
    this.accountName,
  });

  factory TransferRecipientInfo.fromJson(Map<String, dynamic> json) =>
      _$TransferRecipientInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRecipientInfoToJson(this);

  @override
  String toString() =>
      'TransferRecipientInfo(accountNumber: $accountNumber, bankCode: $bankCode, bankName: $bankName, accountName: $accountName)';
}

/// Response payload returned by POST /api/v1/ramp/transfer.
@JsonSerializable()
class InitiateTransferResponse {
  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'quote_id')
  final String? quoteId;

  @JsonKey(name: 'idempotency_key')
  final String? idempotencyKey;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'payment_type')
  final String? paymentType;

  @JsonKey(name: 'fiat_currency')
  final String? fiatCurrency;

  @JsonKey(name: 'fiat_amount')
  final num? fiatAmount;

  @JsonKey(name: 'crypto_asset')
  final String? cryptoAsset;

  @JsonKey(name: 'crypto_amount')
  final num? cryptoAmount;

  @JsonKey(name: 'network')
  final String? network;

  @JsonKey(name: 'wallet_address')
  final String? walletAddress;

  @JsonKey(name: 'deposit_address')
  final String? depositAddress;

  @JsonKey(name: 'rate')
  final num? rate;

  @JsonKey(name: 'platform_fee')
  final num? platformFee;

  @JsonKey(name: 'provider_fee')
  final num? providerFee;

  @JsonKey(name: 'fees')
  final TransferFees? fees;

  @JsonKey(name: 'recipient')
  final TransferRecipientInfo? recipient;

  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  @JsonKey(name: 'is_expired')
  final bool? isExpired;

  @JsonKey(name: 'blockchain_metadata')
  final Map<String, dynamic>? blockchainMetadata;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'meta_data')
  final Map<String, dynamic>? metaData;

  const InitiateTransferResponse({
    this.orderId,
    this.quoteId,
    this.idempotencyKey,
    this.status,
    this.paymentType,
    this.fiatCurrency,
    this.fiatAmount,
    this.cryptoAsset,
    this.cryptoAmount,
    this.network,
    this.walletAddress,
    this.depositAddress,
    this.rate,
    this.platformFee,
    this.providerFee,
    this.fees,
    this.recipient,
    this.expiresAt,
    this.isExpired,
    this.blockchainMetadata,
    this.createdAt,
    this.metaData,
  });

  factory InitiateTransferResponse.fromJson(Map<String, dynamic> json) =>
      _$InitiateTransferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitiateTransferResponseToJson(this);

  @override
  String toString() =>
      'InitiateTransferResponse(orderId: $orderId, status: $status, fiatAmount: $fiatAmount, cryptoAmount: $cryptoAmount, depositAddress: $depositAddress)';
}
