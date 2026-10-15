// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiate_transfer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferRecipient _$TransferRecipientFromJson(Map<String, dynamic> json) =>
    TransferRecipient(
      accountNumber: json['account_number'] as String,
      bankCode: json['bank_code'] as String,
      bankName: json['bank_name'] as String?,
      accountName: json['account_name'] as String?,
      fullname: json['fullname'] as String?,
      recipientId: json['recipient_id'] as String?,
    );

Map<String, dynamic> _$TransferRecipientToJson(TransferRecipient instance) =>
    <String, dynamic>{
      'account_number': instance.accountNumber,
      'bank_code': instance.bankCode,
      'bank_name': ?instance.bankName,
      'account_name': ?instance.accountName,
      'fullname': ?instance.fullname,
      'recipient_id': ?instance.recipientId,
    };

InitiateTransferRequest _$InitiateTransferRequestFromJson(
  Map<String, dynamic> json,
) => InitiateTransferRequest(
  amount: json['amount'] as num,
  currency: json['currency'] as String? ?? 'NGN',
  token: json['token'] as String? ?? 'USDC',
  network: json['network'] as String? ?? 'SOLANA',
  recipient: TransferRecipient.fromJson(
    json['recipient'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$InitiateTransferRequestToJson(
  InitiateTransferRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
  'token': instance.token,
  'network': instance.network,
  'recipient': instance.recipient,
};
