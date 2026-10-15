// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyAccountResponse _$VerifyAccountResponseFromJson(
  Map<String, dynamic> json,
) => VerifyAccountResponse(
  fullname: json['fullname'] as String?,
  accountName: json['account_name'] as String?,
  bankCode: json['bank_code'] as String?,
  bankName: json['bank_name'] as String?,
  accountNumber: json['account_number'] as String?,
);

Map<String, dynamic> _$VerifyAccountResponseToJson(
  VerifyAccountResponse instance,
) => <String, dynamic>{
  'fullname': instance.fullname,
  'account_name': instance.accountName,
  'bank_code': instance.bankCode,
  'bank_name': instance.bankName,
  'account_number': instance.accountNumber,
};
