// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletAccount _$WalletAccountFromJson(Map<String, dynamic> json) =>
    WalletAccount(
      network: json['network'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$WalletAccountToJson(WalletAccount instance) =>
    <String, dynamic>{'network': instance.network, 'address': instance.address};
