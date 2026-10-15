import 'package:json_annotation/json_annotation.dart';

part 'bank_model.g.dart';

/// Represents a supported Nigerian bank.
@JsonSerializable()
class BankModel {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'code')
  final String? code;

  @JsonKey(name: 'bank_code')
  final String? bankCode;

  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  @JsonKey(name: 'slug')
  final String? slug;

  const BankModel({
    this.name,
    this.code,
    this.bankCode,
    this.logoUrl,
    this.slug,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) =>
      _$BankModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankModelToJson(this);

  @override
  String toString() =>
      'BankModel(name: $name, code: $code, bankCode: $bankCode, logoUrl: $logoUrl)';
}

typedef BankResponse = BankModel;
