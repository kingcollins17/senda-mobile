import 'package:json_annotation/json_annotation.dart';

part 'wallet_account.g.dart';

/// Represents a blockchain account associated with a user's wallet.
@JsonSerializable()
class WalletAccount {
  @JsonKey(name: 'network')
  final String? network;

  @JsonKey(name: 'address')
  final String? address;

  const WalletAccount({
    this.network,
    this.address,
  });

  factory WalletAccount.fromJson(Map<String, dynamic> json) =>
      _$WalletAccountFromJson(json);

  Map<String, dynamic> toJson() => _$WalletAccountToJson(this);

  @override
  String toString() => 'WalletAccount(network: $network, address: $address)';
}
