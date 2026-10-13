// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  email: json['email'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  status: json['status'] as String?,
  authProvider: json['auth_provider'] as String?,
  emailVerified: json['email_verified'] as bool?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'phone': instance.phone,
  'avatar_url': instance.avatarUrl,
  'status': instance.status,
  'auth_provider': instance.authProvider,
  'email_verified': instance.emailVerified,
  'created_at': instance.createdAt?.toIso8601String(),
};
