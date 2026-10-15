// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_wallet_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectWalletRequest _$ConnectWalletRequestFromJson(
  Map<String, dynamic> json,
) => ConnectWalletRequest(
  provider: json['provider'] as String,
  accounts: (json['accounts'] as List<dynamic>)
      .map((e) => WalletAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ConnectWalletRequestToJson(
  ConnectWalletRequest instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'accounts': instance.accounts.map((e) => e.toJson()).toList(),
};
