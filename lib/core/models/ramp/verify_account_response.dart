import 'package:json_annotation/json_annotation.dart';

part 'verify_account_response.g.dart';

/// Response payload for Nigerian bank account verification.
@JsonSerializable()
class VerifyAccountResponse {
  @JsonKey(name: 'fullname')
  final String? fullname;

  @JsonKey(name: 'account_name')
  final String? accountName;

  @JsonKey(name: 'bank_code')
  final String? bankCode;

  @JsonKey(name: 'bank_name')
  final String? bankName;

  @JsonKey(name: 'account_number')
  final String? accountNumber;

  const VerifyAccountResponse({
    this.fullname,
    this.accountName,
    this.bankCode,
    this.bankName,
    this.accountNumber,
  });

  factory VerifyAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyAccountResponseToJson(this);

  @override
  String toString() =>
      'VerifyAccountResponse(accountName: $accountName, accountNumber: $accountNumber, bankName: $bankName, bankCode: $bankCode)';
}

/// Helper for constructing the account verification request body map.
class VerifyAccountRequestBody {
  final String accountNumber;
  final String bankCode;

  const VerifyAccountRequestBody({
    required this.accountNumber,
    required this.bankCode,
  });

  Map<String, dynamic> toMap() => {
    'account_number': accountNumber,
    'bank_code': bankCode,
  };
}
