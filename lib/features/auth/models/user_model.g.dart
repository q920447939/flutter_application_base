// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.active,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      if (instance.username case final value?) 'username': value,
      if (instance.email case final value?) 'email': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.nickname case final value?) 'nickname': value,
      if (instance.avatar case final value?) 'avatar': value,
      if (_$GenderEnumMap[instance.gender] case final value?) 'gender': value,
      if (instance.birthday?.toIso8601String() case final value?)
        'birthday': value,
      if (instance.address case final value?) 'address': value,
      if (instance.bio case final value?) 'bio': value,
      'status': _$UserStatusEnumMap[instance.status]!,
      'email_verified': instance.emailVerified,
      'phone_verified': instance.phoneVerified,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      if (instance.lastLoginAt?.toIso8601String() case final value?)
        'last_login_at': value,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.deleted: 'deleted',
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      identifier: json['identifier'] as String,
      password: json['password'] as String,
      rememberMe: json['remember_me'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'password': instance.password,
      'remember_me': instance.rememberMe,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
      nickname: json['nickname'] as String?,
      verificationCode: json['verification_code'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      if (instance.username case final value?) 'username': value,
      if (instance.email case final value?) 'email': value,
      if (instance.phone case final value?) 'phone': value,
      'password': instance.password,
      'confirm_password': instance.confirmPassword,
      if (instance.nickname case final value?) 'nickname': value,
      if (instance.verificationCode case final value?)
        'verification_code': value,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: (json['expires_in'] as num).toInt(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      if (instance.refreshToken case final value?) 'refresh_token': value,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'user': instance.user.toJson(),
    };
