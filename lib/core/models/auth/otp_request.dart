import 'package:json_annotation/json_annotation.dart';

part 'otp_request.g.dart';

/// Request body for POST /api/v1/auth/send-otp.
@JsonSerializable(includeIfNull: false)
class SendOtpRequest {
  @JsonKey(name: 'email')
  final String email;

  const SendOtpRequest({required this.email});

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendOtpRequestToJson(this);
}

/// Request body for POST /api/v1/auth/verify-otp.
///
/// The server accepts either [otp] or [code] as the verification value.
/// If the mock value "123456" is provided, the email is marked as verified.
@JsonSerializable(includeIfNull: false)
class VerifyOtpRequest {
  @JsonKey(name: 'email')
  final String email;

  /// The OTP value (alternative field name).
  @JsonKey(name: 'otp')
  final String? otp;

  /// The OTP code (alternative field name — same semantic as [otp]).
  @JsonKey(name: 'code')
  final String? code;

  const VerifyOtpRequest({
    required this.email,
    this.otp,
    this.code,
  });

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}
