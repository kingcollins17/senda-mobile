// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankModel _$BankModelFromJson(Map<String, dynamic> json) => BankModel(
  name: json['name'] as String?,
  code: json['code'] as String?,
  bankCode: json['bank_code'] as String?,
  logoUrl: json['logo_url'] as String?,
  slug: json['slug'] as String?,
);

Map<String, dynamic> _$BankModelToJson(BankModel instance) => <String, dynamic>{
  'name': instance.name,
  'code': instance.code,
  'bank_code': instance.bankCode,
  'logo_url': instance.logoUrl,
  'slug': instance.slug,
};
