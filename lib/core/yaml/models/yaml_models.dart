/// YAML 模块数据模型定义
///
/// 包含 YAML 处理过程中使用的各种数据模型
library;

import 'package:equatable/equatable.dart';

/// YAML 变更事件
class YamlChangeEvent extends Equatable {
  /// 文件路径
  final String filePath;

  /// 变更类型
  final YamlChangeType changeType;

  /// 变更时间
  final DateTime timestamp;

  /// 处理器名称
  final String? processorName;

  /// 额外信息
  final Map<String, dynamic>? metadata;

  const YamlChangeEvent({
    required this.filePath,
    required this.changeType,
    required this.timestamp,
    this.processorName,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    filePath,
    changeType,
    timestamp,
    processorName,
    metadata,
  ];

  @override
  String toString() {
    return 'YamlChangeEvent(filePath: $filePath, changeType: $changeType, '
        'timestamp: $timestamp, processorName: $processorName)';
  }
}

/// YAML 变更类型枚举
enum YamlChangeType {
  /// 文件创建
  created,

  /// 文件修改
  modified,

  /// 文件删除
  deleted,

  /// 文件重命名
  renamed,
}

/// 缓存条目
class CacheEntry<T> extends Equatable {
  /// 缓存值
  final T value;

  /// 过期时间
  final DateTime expireTime;

  /// 创建时间
  final DateTime createTime;

  /// 访问次数
  final int accessCount;

  /// 最后访问时间
  final DateTime lastAccessTime;

  const CacheEntry({
    required this.value,
    required this.expireTime,
    required this.createTime,
    this.accessCount = 1,
    required this.lastAccessTime,
  });

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expireTime);

  /// 创建新的访问记录
  CacheEntry<T> withAccess() {
    return CacheEntry<T>(
      value: value,
      expireTime: expireTime,
      createTime: createTime,
      accessCount: accessCount + 1,
      lastAccessTime: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    value,
    expireTime,
    createTime,
    accessCount,
    lastAccessTime,
  ];
}

/// YAML 验证结果
class YamlValidationResult extends Equatable {
  /// 是否验证成功
  final bool isValid;

  /// 错误信息列表
  final List<YamlValidationError> errors;

  /// 警告信息列表
  final List<YamlValidationWarning> warnings;

  /// 验证耗时
  final Duration duration;

  const YamlValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    required this.duration,
  });

  /// 创建成功的验证结果
  factory YamlValidationResult.success({
    List<YamlValidationWarning> warnings = const [],
    required Duration duration,
  }) {
    return YamlValidationResult(
      isValid: true,
      warnings: warnings,
      duration: duration,
    );
  }

  /// 创建失败的验证结果
  factory YamlValidationResult.failure({
    required List<YamlValidationError> errors,
    List<YamlValidationWarning> warnings = const [],
    required Duration duration,
  }) {
    return YamlValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      duration: duration,
    );
  }

  @override
  List<Object?> get props => [isValid, errors, warnings, duration];
}

/// YAML 验证错误
class YamlValidationError extends Equatable {
  /// 错误代码
  final String code;

  /// 错误消息
  final String message;

  /// 错误位置（行号）
  final int? line;

  /// 错误位置（列号）
  final int? column;

  /// 错误路径
  final String? path;

  const YamlValidationError({
    required this.code,
    required this.message,
    this.line,
    this.column,
    this.path,
  });

  @override
  List<Object?> get props => [code, message, line, column, path];

  @override
  String toString() {
    final location = line != null && column != null ? ' at $line:$column' : '';
    final pathInfo = path != null ? ' (path: $path)' : '';
    return '$code: $message$location$pathInfo';
  }
}

/// YAML 验证警告
class YamlValidationWarning extends Equatable {
  /// 警告代码
  final String code;

  /// 警告消息
  final String message;

  /// 警告位置（行号）
  final int? line;

  /// 警告位置（列号）
  final int? column;

  /// 警告路径
  final String? path;

  const YamlValidationWarning({
    required this.code,
    required this.message,
    this.line,
    this.column,
    this.path,
  });

  @override
  List<Object?> get props => [code, message, line, column, path];

  @override
  String toString() {
    final location = line != null && column != null ? ' at $line:$column' : '';
    final pathInfo = path != null ? ' (path: $path)' : '';
    return '$code: $message$location$pathInfo';
  }
}
