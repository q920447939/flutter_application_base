// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captcha_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptchaInfo _$CaptchaInfoFromJson(Map<String, dynamic> json) => CaptchaInfo(
  sessionId: json['sessionId'] as String,
  imageBase64: json['imageBase64'] as String,
  expireSeconds: (json['expireSeconds'] as num).toInt(),
  length: (json['length'] as num?)?.toInt() ?? 4,
  type:
      $enumDecodeNullable(_$CaptchaTypeEnumEnumMap, json['type']) ??
      CaptchaTypeEnum.image,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CaptchaInfoToJson(CaptchaInfo instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'imageBase64': instance.imageBase64,
      'expireSeconds': instance.expireSeconds,
      'length': instance.length,
      'type': _$CaptchaTypeEnumEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$CaptchaTypeEnumEnumMap = {
  CaptchaTypeEnum.image: 'IMAGE',
  CaptchaTypeEnum.sms: 'SMS',
  CaptchaTypeEnum.email: 'EMAIL',
  CaptchaTypeEnum.voice: 'VOICE',
};

CaptchaRequest _$CaptchaRequestFromJson(Map<String, dynamic> json) =>
    CaptchaRequest(
      type:
          $enumDecodeNullable(_$CaptchaTypeEnumEnumMap, json['type']) ??
          CaptchaTypeEnum.image,
      length: (json['length'] as num?)?.toInt() ?? 4,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$CaptchaRequestToJson(CaptchaRequest instance) =>
    <String, dynamic>{
      'type': _$CaptchaTypeEnumEnumMap[instance.type]!,
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
      'phone': instance.phone,
      'email': instance.email,
    };

CaptchaVerifyRequest _$CaptchaVerifyRequestFromJson(
  Map<String, dynamic> json,
) => CaptchaVerifyRequest(
  sessionId: json['sessionId'] as String,
  code: json['code'] as String,
  type:
      $enumDecodeNullable(_$CaptchaTypeEnumEnumMap, json['type']) ??
      CaptchaTypeEnum.image,
);

Map<String, dynamic> _$CaptchaVerifyRequestToJson(
  CaptchaVerifyRequest instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'code': instance.code,
  'type': _$CaptchaTypeEnumEnumMap[instance.type]!,
};
