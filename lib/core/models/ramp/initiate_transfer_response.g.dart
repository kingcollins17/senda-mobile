// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiate_transfer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferFees _$TransferFeesFromJson(Map<String, dynamic> json) => TransferFees(
  platformFeeNgn: json['platform_fee_ngn'] as num?,
  providerFeeNgn: json['provider_fee_ngn'] as num?,
  totalFeeNgn: json['total_fee_ngn'] as num?,
  totalFiatAmount: json['total_fiat_amount'] as num?,
);

Map<String, dynamic> _$TransferFeesToJson(TransferFees instance) =>
    <String, dynamic>{
      'platform_fee_ngn': instance.platformFeeNgn,
      'provider_fee_ngn': instance.providerFeeNgn,
      'total_fee_ngn': instance.totalFeeNgn,
      'total_fiat_amount': instance.totalFiatAmount,
    };

TransferRecipientInfo _$TransferRecipientInfoFromJson(
  Map<String, dynamic> json,
) => TransferRecipientInfo(
  accountNumber: json['account_number'] as String?,
  bankCode: json['bank_code'] as String?,
  bankName: json['bank_name'] as String?,
  accountName: json['account_name'] as String?,
);

Map<String, dynamic> _$TransferRecipientInfoToJson(
  TransferRecipientInfo instance,
) => <String, dynamic>{
  'account_number': instance.accountNumber,
  'bank_code': instance.bankCode,
  'bank_name': instance.bankName,
  'account_name': instance.accountName,
};

InitiateTransferResponse _$InitiateTransferResponseFromJson(
  Map<String, dynamic> json,
) => InitiateTransferResponse(
  orderId: json['order_id'] as String?,
  quoteId: json['quote_id'] as String?,
  idempotencyKey: json['idempotency_key'] as String?,
  status: json['status'] as String?,
  paymentType: json['payment_type'] as String?,
  fiatCurrency: json['fiat_currency'] as String?,
  fiatAmount: json['fiat_amount'] as num?,
  cryptoAsset: json['crypto_asset'] as String?,
  cryptoAmount: json['crypto_amount'] as num?,
  network: json['network'] as String?,
  walletAddress: json['wallet_address'] as String?,
  depositAddress: json['deposit_address'] as String?,
  rate: json['rate'] as num?,
  platformFee: json['platform_fee'] as num?,
  providerFee: json['provider_fee'] as num?,
  fees: json['fees'] == null
      ? null
      : TransferFees.fromJson(json['fees'] as Map<String, dynamic>),
  recipient: json['recipient'] == null
      ? null
      : TransferRecipientInfo.fromJson(
          json['recipient'] as Map<String, dynamic>,
        ),
  expiresAt: json['expires_at'] as String?,
  isExpired: json['is_expired'] as bool?,
  blockchainMetadata: json['blockchain_metadata'] as Map<String, dynamic>?,
  createdAt: json['created_at'] as String?,
  metaData: json['meta_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$InitiateTransferResponseToJson(
  InitiateTransferResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'quote_id': instance.quoteId,
  'idempotency_key': instance.idempotencyKey,
  'status': instance.status,
  'payment_type': instance.paymentType,
  'fiat_currency': instance.fiatCurrency,
  'fiat_amount': instance.fiatAmount,
  'crypto_asset': instance.cryptoAsset,
  'crypto_amount': instance.cryptoAmount,
  'network': instance.network,
  'wallet_address': instance.walletAddress,
  'deposit_address': instance.depositAddress,
  'rate': instance.rate,
  'platform_fee': instance.platformFee,
  'provider_fee': instance.providerFee,
  'fees': instance.fees,
  'recipient': instance.recipient,
  'expires_at': instance.expiresAt,
  'is_expired': instance.isExpired,
  'blockchain_metadata': instance.blockchainMetadata,
  'created_at': instance.createdAt,
  'meta_data': instance.metaData,
};
