import 'package:json_annotation/json_annotation.dart';
import 'package:senda/core/models/wallet/wallet_account.dart';
import 'package:senda/core/util/json_util.dart';

part 'connect_wallet_request.g.dart';

/// Request body for connecting an external wallet to the user.
@JsonSerializable(explicitToJson: true)
class ConnectWalletRequest {
  @JsonKey(name: 'provider')
  final String provider;

  @JsonKey(name: 'accounts')
  final List<WalletAccount> accounts;

  const ConnectWalletRequest({required this.provider, required this.accounts});

  factory ConnectWalletRequest.fromJson(Map<String, dynamic> json) =>
      _$ConnectWalletRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectWalletRequestToJson(this);

  @override
  String toString() => toJsonString();
}
