// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsernamePasswordAuthRequest _$UsernamePasswordAuthRequestFromJson(
  Map<String, dynamic> json,
) => UsernamePasswordAuthRequest(
  username: json['username'] as String,
  password: json['password'] as String,
  captcha: json['captcha'] as String,
  captchaSessionId: json['captchaSessionId'] as String,
  deviceInfo: json['deviceInfo'] as String?,
  clientIp: json['clientIp'] as String?,
  context: (json['context'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as Object),
  ),
);

Map<String, dynamic> _$UsernamePasswordAuthRequestToJson(
  UsernamePasswordAuthRequest instance,
) => <String, dynamic>{
  'deviceInfo': instance.deviceInfo,
  'clientIp': instance.clientIp,
  'context': instance.context,
  'username': instance.username,
  'password': instance.password,
  'captcha': instance.captcha,
  'captchaSessionId': instance.captchaSessionId,
};

PhonePasswordAuthRequest _$PhonePasswordAuthRequestFromJson(
  Map<String, dynamic> json,
) => PhonePasswordAuthRequest(
  phone: json['phone'] as String,
  password: json['password'] as String,
  captcha: json['captcha'] as String,
  captchaSessionId: json['captchaSessionId'] as String,
  deviceInfo: json['deviceInfo'] as String?,
  clientIp: json['clientIp'] as String?,
  context: (json['context'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as Object),
  ),
);

Map<String, dynamic> _$PhonePasswordAuthRequestToJson(
  PhonePasswordAuthRequest instance,
) => <String, dynamic>{
  'deviceInfo': instance.deviceInfo,
  'clientIp': instance.clientIp,
  'context': instance.context,
  'phone': instance.phone,
  'password': instance.password,
  'captcha': instance.captcha,
  'captchaSessionId': instance.captchaSessionId,
};

EmailPasswordAuthRequest _$EmailPasswordAuthRequestFromJson(
  Map<String, dynamic> json,
) => EmailPasswordAuthRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  captcha: json['captcha'] as String,
  captchaSessionId: json['captchaSessionId'] as String,
  deviceInfo: json['deviceInfo'] as String?,
  clientIp: json['clientIp'] as String?,
  context: (json['context'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as Object),
  ),
);

Map<String, dynamic> _$EmailPasswordAuthRequestToJson(
  EmailPasswordAuthRequest instance,
) => <String, dynamic>{
  'deviceInfo': instance.deviceInfo,
  'clientIp': instance.clientIp,
  'context': instance.context,
  'email': instance.email,
  'password': instance.password,
  'captcha': instance.captcha,
  'captchaSessionId': instance.captchaSessionId,
};
