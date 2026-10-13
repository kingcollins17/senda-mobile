import 'package:json_annotation/json_annotation.dart';
import 'package:senda/core/models/auth/user.dart';

part 'auth_response.g.dart';

/// Shared response envelope for Register and Login endpoints.
///
/// Wraps access token, refresh token, user details, and an optional
/// email-verification token.
@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String? accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  /// Token type — typically "bearer".
  @JsonKey(name: 'token_type')
  final String? tokenType;

  @JsonKey(name: 'user')
  final User? user;

  /// Present after registration; use to verify the user's email.
  @JsonKey(name: 'verification_token')
  final String? verificationToken;

  const AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.user,
    this.verificationToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() =>
      'AuthResponse(tokenType: $tokenType, user: ${user?.email})';
}
