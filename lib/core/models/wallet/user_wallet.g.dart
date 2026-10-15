// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWallet _$UserWalletFromJson(Map<String, dynamic> json) => UserWallet(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  provider: json['provider'] as String?,
  accounts: (json['accounts'] as List<dynamic>?)
      ?.map((e) => WalletAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserWalletToJson(UserWallet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'provider': instance.provider,
      'accounts': instance.accounts,
      'created_at': instance.createdAt?.toIso8601String(),
    };
