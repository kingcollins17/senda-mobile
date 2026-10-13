import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

/// Request body for POST /api/v1/auth/register.
@JsonSerializable(includeIfNull: false)
class RegisterRequest {
  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'password')
  final String? password;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Sign-in method. Defaults to "NORMAL". Allowed: "NORMAL", "GOOGLE", "APPLE".
  @JsonKey(name: 'auth_provider')
  final String? authProvider;

  const RegisterRequest({
    required this.email,
    required this.name,
    this.password,
    this.phone,
    this.avatarUrl,
    this.authProvider = 'NORMAL',
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
