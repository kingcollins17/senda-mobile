import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

/// Generic API envelope returned by every endpoint.
///
/// - [data] holds the strongly-typed response payload (nullable).
/// - [detail] carries a human-readable message or error detail from the server.
/// - [statusCode] mirrors the HTTP status code when the server echoes it.
///
/// Usage:
/// ```dart
/// BaseResponse<AuthResponse> response = ...;
/// final token = response.data?.accessToken;
/// ```
@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  /// Human-readable message / error detail from the server.
  @JsonKey(name: 'detail')
  final String? detail;

  /// The strongly-typed payload, or null when the server returns no body.
  @JsonKey(name: 'data')
  final T? data;

  /// HTTP status code echoed by the server (not always present).
  @JsonKey(name: 'status_code')
  final int? statusCode;

  const BaseResponse({
    this.detail,
    this.data,
    this.statusCode,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$BaseResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseToJson(this, toJsonT);

  @override
  String toString() =>
      'BaseResponse(statusCode: $statusCode, detail: $detail, data: $data)';
}
