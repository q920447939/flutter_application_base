/// 验证结果对象
///
/// 统一的验证结果表示，包含字段级和全局级错误信息
library;

/// 验证结果类
class ValidationResult {
  /// 是否验证通过
  final bool isValid;

  /// 字段级错误信息 (字段名 -> 错误列表)
  final Map<String, List<String>> fieldErrors;

  /// 全局错误信息
  final List<String> globalErrors;

  /// 第一个错误信息（用于快速显示）
  final String? firstError;

  /// 错误总数
  int get errorCount => fieldErrors.length + globalErrors.length;

  const ValidationResult({
    required this.isValid,
    this.fieldErrors = const {},
    this.globalErrors = const [],
    this.firstError,
  });

  /// 创建成功的验证结果
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  /// 创建失败的验证结果
  factory ValidationResult.failure({
    Map<String, List<String>>? fieldErrors,
    List<String>? globalErrors,
  }) {
    final fields = fieldErrors ?? {};
    final globals = globalErrors ?? [];

    // 获取第一个错误
    String? firstError;
    if (fields.isNotEmpty) {
      firstError = fields.values.first.first;
    } else if (globals.isNotEmpty) {
      firstError = globals.first;
    }

    return ValidationResult(
      isValid: false,
      fieldErrors: fields,
      globalErrors: globals,
      firstError: firstError,
    );
  }

  /// 创建单个字段错误的验证结果
  factory ValidationResult.fieldError(String fieldName, String error) {
    return ValidationResult.failure(
      fieldErrors: {
        fieldName: [error],
      },
    );
  }

  /// 创建全局错误的验证结果
  factory ValidationResult.globalError(String error) {
    return ValidationResult.failure(globalErrors: [error]);
  }

  /// 合并多个验证结果
  ValidationResult merge(ValidationResult other) {
    if (isValid && other.isValid) {
      return ValidationResult.success();
    }

    final mergedFieldErrors = <String, List<String>>{};

    // 合并字段错误
    fieldErrors.forEach((field, errors) {
      mergedFieldErrors[field] = List.from(errors);
    });

    other.fieldErrors.forEach((field, errors) {
      if (mergedFieldErrors.containsKey(field)) {
        mergedFieldErrors[field]!.addAll(errors);
      } else {
        mergedFieldErrors[field] = List.from(errors);
      }
    });

    // 合并全局错误
    final mergedGlobalErrors = <String>[...globalErrors, ...other.globalErrors];

    return ValidationResult.failure(
      fieldErrors: mergedFieldErrors,
      globalErrors: mergedGlobalErrors,
    );
  }

  /// 获取指定字段的错误信息
  List<String> getFieldErrors(String fieldName) {
    return fieldErrors[fieldName] ?? [];
  }

  /// 检查指定字段是否有错误
  bool hasFieldError(String fieldName) {
    return fieldErrors.containsKey(fieldName) &&
        fieldErrors[fieldName]!.isNotEmpty;
  }

  /// 获取所有错误信息（字段错误 + 全局错误）
  List<String> getAllErrors() {
    final allErrors = <String>[];

    // 添加字段错误
    fieldErrors.values.forEach((errors) {
      allErrors.addAll(errors);
    });

    // 添加全局错误
    allErrors.addAll(globalErrors);

    return allErrors;
  }

  /// 获取错误摘要信息
  String getErrorSummary() {
    if (isValid) return '验证通过';

    final errors = getAllErrors();
    if (errors.isEmpty) return '未知验证错误';

    if (errors.length == 1) {
      return errors.first;
    }

    return '${errors.first}等${errors.length}个错误';
  }

  /// 转换为JSON格式（用于调试）
  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'fieldErrors': fieldErrors,
      'globalErrors': globalErrors,
      'firstError': firstError,
      'errorCount': errorCount,
    };
  }

  @override
  String toString() {
    if (isValid) return 'ValidationResult(valid)';

    return 'ValidationResult(invalid, errors: ${getAllErrors()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValidationResult &&
        other.isValid == isValid &&
        _mapEquals(other.fieldErrors, fieldErrors) &&
        _listEquals(other.globalErrors, globalErrors);
  }

  @override
  int get hashCode {
    return Object.hash(isValid, fieldErrors, globalErrors);
  }

  /// 比较两个Map是否相等
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  /// 比较两个List是否相等
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}
