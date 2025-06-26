// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(token: json['token'] as String);

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{'token': instance.token};

ExtendedAuthResponse _$ExtendedAuthResponseFromJson(
  Map<String, dynamic> json,
) => ExtendedAuthResponse(
  token: json['token'] as String,
  user: json['user'] as Map<String, dynamic>?,
  permissions:
      (json['permissions'] as List<dynamic>?)?.map((e) => e as String).toList(),
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ExtendedAuthResponseToJson(
  ExtendedAuthResponse instance,
) => <String, dynamic>{
  'token': instance.token,
  'user': instance.user,
  'permissions': instance.permissions,
  'roles': instance.roles,
};
