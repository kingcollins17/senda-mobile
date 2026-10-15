import 'package:json_annotation/json_annotation.dart';
import 'package:senda/core/models/wallet/user_wallet.dart';

export 'package:senda/core/models/wallet/user_wallet.dart';

part 'user.g.dart';

/// Represents the authenticated user object returned by auth endpoints and profile queries.
@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Account status — e.g. "ACTIVE", "SUSPENDED".
  @JsonKey(name: 'status')
  final String? status;

  /// Sign-in method — "NORMAL", "GOOGLE", or "APPLE".
  @JsonKey(name: 'auth_provider')
  final String? authProvider;

  @JsonKey(name: 'email_verified')
  final bool? emailVerified;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Attached external wallet object.
  @JsonKey(name: 'wallet')
  final UserWallet? wallet;

  const User({
    this.id,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.status,
    this.authProvider,
    this.emailVerified,
    this.createdAt,
    this.wallet,
  });

  /// Whether the user has a connected external wallet attached.
  bool get hasWallet => wallet != null;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    String? status,
    String? authProvider,
    bool? emailVerified,
    DateTime? createdAt,
    UserWallet? wallet,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      authProvider: authProvider ?? this.authProvider,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      wallet: wallet ?? this.wallet,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => 'User(id: $id, email: $email, name: $name, wallet: $wallet)';
}
