import 'package:json_annotation/json_annotation.dart';
import 'package:senda/core/models/wallet/wallet_account.dart';

part 'user_wallet.g.dart';

/// Represents a connected external wallet object associated with a user.
@JsonSerializable()
class UserWallet {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'provider')
  final String? provider;

  @JsonKey(name: 'accounts')
  final List<WalletAccount>? accounts;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const UserWallet({
    this.id,
    this.userId,
    this.provider,
    this.accounts,
    this.createdAt,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) =>
      _$UserWalletFromJson(json);

  Map<String, dynamic> toJson() => _$UserWalletToJson(this);

  /// Address for Solana network if connected.
  String? get solanaAddress => accounts
      ?.firstWhere(
        (a) => a.network?.toUpperCase() == 'SOLANA',
        orElse: () => const WalletAccount(),
      )
      .address;

  /// Address for Ethereum network if connected.
  String? get ethAddress => accounts
      ?.firstWhere(
        (a) => a.network?.toUpperCase() == 'ETHEREUM',
        orElse: () => const WalletAccount(),
      )
      .address;

  /// Address for Polygon network if connected.
  String? get polygonAddress => accounts
      ?.firstWhere(
        (a) => a.network?.toUpperCase() == 'POLYGON',
        orElse: () => const WalletAccount(),
      )
      .address;

  bool get hasAtLeastOneAccount =>
      accounts != null &&
      accounts!.any((a) => a.address != null && a.address!.isNotEmpty);

  @override
  String toString() =>
      'UserWallet(id: $id, userId: $userId, provider: $provider, accounts: ${accounts?.length})';
}

/// Alias for [UserWallet] to support both naming styles.
typedef Wallet = UserWallet;
