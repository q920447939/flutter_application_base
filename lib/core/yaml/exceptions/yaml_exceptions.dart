/// YAML 模块异常定义
///
/// 定义了 YAML 处理过程中可能出现的各种异常类型
library;

/// YAML 异常基类
abstract class YamlException implements Exception {
  /// 错误消息
  final String message;

  /// 错误代码
  final String code;

  /// 内部异常
  final Exception? innerException;

  /// 额外信息
  final Map<String, dynamic>? metadata;

  const YamlException({
    required this.message,
    required this.code,
    this.innerException,
    this.metadata,
  });

  @override
  String toString() {
    final inner = innerException != null ? '\nInner: $innerException' : '';
    final meta = metadata != null ? '\nMetadata: $metadata' : '';
    return '$runtimeType [$code]: $message$inner$meta';
  }
}

/// YAML 解析异常
class YamlParseException extends YamlException {
  /// 文件路径
  final String? filePath;

  /// 错误行号
  final int? line;

  /// 错误列号
  final int? column;

  const YamlParseException({
    required super.message,
    super.code = 'YAML_PARSE_ERROR',
    super.innerException,
    super.metadata,
    this.filePath,
    this.line,
    this.column,
  });

  @override
  String toString() {
    final location = line != null && column != null ? ' at $line:$column' : '';
    final file = filePath != null ? ' in file: $filePath' : '';
    return 'YamlParseException [$code]: $message$location$file';
  }
}

/// YAML 验证异常
class YamlValidationException extends YamlException {
  /// 验证错误列表
  final List<String> validationErrors;

  const YamlValidationException({
    required super.message,
    super.code = 'YAML_VALIDATION_ERROR',
    super.innerException,
    super.metadata,
    this.validationErrors = const [],
  });

  @override
  String toString() {
    final errors =
        validationErrors.isNotEmpty
            ? '\nValidation errors: ${validationErrors.join(', ')}'
            : '';
    return 'YamlValidationException [$code]: $message$errors';
  }
}

/// YAML 处理器未找到异常
class YamlProcessorNotFoundException extends YamlException {
  /// 处理器名称
  final String processorName;

  const YamlProcessorNotFoundException(
    this.processorName, {
    String? message,
    super.code = 'PROCESSOR_NOT_FOUND',
    super.innerException,
    super.metadata,
  }) : super(message: message ?? '未找到名为 "$processorName" 的 YAML 处理器');
}

/// 没有合适的处理器异常
class NoSuitableProcessorException extends YamlException {
  /// 文件路径
  final String filePath;

  const NoSuitableProcessorException(
    this.filePath, {
    String? message,
    super.code = 'NO_SUITABLE_PROCESSOR',
    super.innerException,
    super.metadata,
  }) : super(message: message ?? '没有找到适合处理文件 "$filePath" 的处理器');
}

/// YAML 文件未找到异常
class YamlFileNotFoundException extends YamlException {
  /// 文件路径
  final String filePath;

  const YamlFileNotFoundException(
    this.filePath, {
    String? message,
    super.code = 'FILE_NOT_FOUND',
    super.innerException,
    super.metadata,
  }) : super(message: message ?? 'YAML 文件未找到: "$filePath"');
}

/// YAML 文件读取异常
class YamlFileReadException extends YamlException {
  /// 文件路径
  final String filePath;

  const YamlFileReadException(
    this.filePath, {
    String? message,
    super.code = 'FILE_READ_ERROR',
    super.innerException,
    super.metadata,
  }) : super(message: message ?? '读取 YAML 文件失败: "$filePath"');
}

/// YAML 缓存异常
class YamlCacheException extends YamlException {
  /// 缓存键
  final String? cacheKey;

  const YamlCacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.innerException,
    super.metadata,
    this.cacheKey,
  });

  @override
  String toString() {
    final key = cacheKey != null ? ' (key: $cacheKey)' : '';
    return 'YamlCacheException [$code]: $message$key';
  }
}

/// YAML 处理器异常
class YamlProcessorException extends YamlException {
  /// 文件路径
  final String? filePath;

  const YamlProcessorException({
    required super.message,
    super.code = 'PROCESSOR_ERROR',
    super.innerException,
    super.metadata,
    this.filePath,
  });

  @override
  String toString() {
    final file = filePath != null ? ' (file: $filePath)' : '';
    return 'YamlProcessorException [$code] in  $message$file';
  }
}

/// YAML 服务异常
class YamlServiceException extends YamlException {
  const YamlServiceException({
    required super.message,
    super.code = 'SERVICE_ERROR',
    super.innerException,
    super.metadata,
  });
}

/// YAML 配置异常
class YamlConfigException extends YamlException {
  /// 配置键
  final String? configKey;

  const YamlConfigException({
    required super.message,
    super.code = 'CONFIG_ERROR',
    super.innerException,
    super.metadata,
    this.configKey,
  });

  @override
  String toString() {
    final key = configKey != null ? ' (key: $configKey)' : '';
    return 'YamlConfigException [$code]: $message$key';
  }
}

/// YAML 类型转换异常
class YamlTypeConversionException extends YamlException {
  /// 源类型
  final Type sourceType;

  /// 目标类型
  final Type targetType;

  /// 值
  final dynamic value;

  const YamlTypeConversionException({
    required this.sourceType,
    required this.targetType,
    required this.value,
    String? message,
    super.code = 'TYPE_CONVERSION_ERROR',
    super.innerException,
    super.metadata,
  }) : super(
         message: message ?? '无法将类型 $sourceType 的值 "$value" 转换为 $targetType',
       );
}
