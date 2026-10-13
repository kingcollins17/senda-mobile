import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Request body for POST /api/v1/auth/login.
@JsonSerializable(includeIfNull: false)
class LoginRequest {
  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'password')
  final String? password;

  /// Sign-in method. Defaults to "NORMAL". Allowed: "NORMAL", "GOOGLE", "APPLE".
  @JsonKey(name: 'auth_provider')
  final String? authProvider;

  const LoginRequest({
    required this.email,
    this.password,
    this.authProvider = 'NORMAL',
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
