// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletConnectionState _$WalletConnectionStateFromJson(
  Map<String, dynamic> json,
) => WalletConnectionState(
  provider: json['provider'] as String?,
  solanaAddress: json['solana_address'] as String?,
  ethAddress: json['eth_address'] as String?,
  polygonAddress: json['polygon_address'] as String?,
  userId: json['user_id'] as String?,
  connectedAt: json['connected_at'] == null
      ? null
      : DateTime.parse(json['connected_at'] as String),
);

Map<String, dynamic> _$WalletConnectionStateToJson(
  WalletConnectionState instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'solana_address': instance.solanaAddress,
  'eth_address': instance.ethAddress,
  'polygon_address': instance.polygonAddress,
  'user_id': instance.userId,
  'connected_at': instance.connectedAt?.toIso8601String(),
};
