// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonResult<T> _$CommonResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    CommonResult<T>(
      code: (json['code'] as num).toInt(),
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$CommonResultToJson<T>(
  CommonResult<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'code': instance.code,
      if (_$nullableGenericToJson(instance.data, toJsonT) case final value?)
        'data': value,
      'msg': instance.msg,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

PageResult<T> _$PageResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PageResult<T>(
      records: (json['records'] as List<dynamic>).map(fromJsonT).toList(),
      total: (json['total'] as num).toInt(),
      current: (json['current'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );

Map<String, dynamic> _$PageResultToJson<T>(
  PageResult<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'records': instance.records.map(toJsonT).toList(),
      'total': instance.total,
      'current': instance.current,
      'size': instance.size,
      'pages': instance.pages,
    };
