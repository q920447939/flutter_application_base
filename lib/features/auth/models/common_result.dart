/// 通用响应结果模型
/// 
/// 匹配后端Spring Boot的CommonResult响应格式
library;

import 'package:json_annotation/json_annotation.dart';

part 'common_result.g.dart';

/// 通用响应结果
@JsonSerializable(genericArgumentFactories: true)
class CommonResult<T> {
  /// 错误码 (0表示成功)
  final int code;
  
  /// 返回数据
  final T? data;
  
  /// 错误提示消息，用户可阅读
  final String msg;

  const CommonResult({
    required this.code,
    this.data,
    required this.msg,
  });

  /// 是否成功
  bool get isSuccess => code == 0;
  
  /// 是否失败
  bool get isFailure => !isSuccess;
  
  /// 是否有数据
  bool get hasData => data != null;

  /// 创建成功结果
  factory CommonResult.success({
    T? data,
    String msg = '操作成功',
  }) {
    return CommonResult<T>(
      code: 0,
      data: data,
      msg: msg,
    );
  }

  /// 创建失败结果
  factory CommonResult.failure({
    required int code,
    required String msg,
    T? data,
  }) {
    return CommonResult<T>(
      code: code,
      data: data,
      msg: msg,
    );
  }

  /// 创建网络错误结果
  factory CommonResult.networkError({
    String msg = '网络连接失败',
  }) {
    return CommonResult<T>(
      code: -1,
      data: null,
      msg: msg,
    );
  }

  /// 创建参数错误结果
  factory CommonResult.parameterError({
    String msg = '参数错误',
  }) {
    return CommonResult<T>(
      code: -2,
      data: null,
      msg: msg,
    );
  }

  /// 从JSON创建
  factory CommonResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$CommonResultFromJson(json, fromJsonT);

  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$CommonResultToJson(this, toJsonT);

  /// 复制并更新部分字段
  CommonResult<T> copyWith({
    int? code,
    T? data,
    String? msg,
  }) {
    return CommonResult<T>(
      code: code ?? this.code,
      data: data ?? this.data,
      msg: msg ?? this.msg,
    );
  }

  /// 转换数据类型
  CommonResult<R> map<R>(R Function(T) mapper) {
    return CommonResult<R>(
      code: code,
      data: data != null ? mapper(data as T) : null,
      msg: msg,
    );
  }

  /// 异步转换数据类型
  Future<CommonResult<R>> mapAsync<R>(Future<R> Function(T) mapper) async {
    return CommonResult<R>(
      code: code,
      data: data != null ? await mapper(data as T) : null,
      msg: msg,
    );
  }

  @override
  String toString() {
    return 'CommonResult(code: $code, msg: $msg, hasData: $hasData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommonResult<T> &&
        other.code == code &&
        other.data == data &&
        other.msg == msg;
  }

  @override
  int get hashCode => Object.hash(code, data, msg);
}

/// 分页响应结果
@JsonSerializable(genericArgumentFactories: true)
class PageResult<T> {
  /// 数据列表
  final List<T> records;
  
  /// 总记录数
  final int total;
  
  /// 当前页码
  final int current;
  
  /// 每页大小
  final int size;
  
  /// 总页数
  final int pages;

  const PageResult({
    required this.records,
    required this.total,
    required this.current,
    required this.size,
    required this.pages,
  });

  /// 是否有数据
  bool get hasData => records.isNotEmpty;
  
  /// 是否为空
  bool get isEmpty => records.isEmpty;
  
  /// 是否有下一页
  bool get hasNext => current < pages;
  
  /// 是否有上一页
  bool get hasPrevious => current > 1;

  /// 从JSON创建
  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResultFromJson(json, fromJsonT);

  /// 转换为JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageResultToJson(this, toJsonT);

  @override
  String toString() {
    return 'PageResult(total: $total, current: $current, size: $size, pages: $pages)';
  }
}
