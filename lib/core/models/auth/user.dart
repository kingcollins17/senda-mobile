import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Represents the authenticated user object returned by auth endpoints.
@JsonSerializable()
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
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => 'AuthUser(id: $id, email: $email, name: $name)';
}
