/// 验证器接口和基础实现
///
/// 提供统一的验证接口，支持各种数据类型的验证
library;

import 'validation_result.dart';

/// 验证器抽象接口
abstract class Validator<T> {
  /// 验证器名称
  String get name;

  /// 验证数据
  ValidationResult validate(T data);

  /// 获取错误消息映射
  Map<String, String> get errorMessages => {};

  /// 是否启用
  bool get enabled => true;
}

/// 字段验证规则
class ValidationRule {
  /// 规则类型
  final String type;

  /// 约束条件
  final dynamic constraint;

  /// 错误消息
  final String message;

  /// 是否启用
  final bool enabled;

  const ValidationRule({
    required this.type,
    required this.constraint,
    required this.message,
    this.enabled = true,
  });

  /// 常用验证规则
  static const String required = 'required';
  static const String minLength = 'minLength';
  static const String maxLength = 'maxLength';
  static const String pattern = 'pattern';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String numeric = 'numeric';
  static const String range = 'range';

  /// 创建必填规则
  factory ValidationRule.createRequired([String? message]) {
    return ValidationRule(
      type: required,
      constraint: true,
      message: message ?? '此字段为必填项',
    );
  }

  /// 创建最小长度规则
  factory ValidationRule.createMinLength(int length, [String? message]) {
    return ValidationRule(
      type: minLength,
      constraint: length,
      message: message ?? '至少需要$length个字符',
    );
  }

  /// 创建最大长度规则
  factory ValidationRule.createMaxLength(int length, [String? message]) {
    return ValidationRule(
      type: maxLength,
      constraint: length,
      message: message ?? '最多允许$length个字符',
    );
  }

  /// 创建正则表达式规则
  factory ValidationRule.createPattern(String pattern, [String? message]) {
    return ValidationRule(
      type: ValidationRule.pattern,
      constraint: pattern,
      message: message ?? '格式不正确',
    );
  }

  /// 创建邮箱规则
  factory ValidationRule.createEmail([String? message]) {
    return ValidationRule(
      type: email,
      constraint: r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      message: message ?? '请输入有效的邮箱地址',
    );
  }

  /// 创建手机号规则
  factory ValidationRule.createPhone([String? message]) {
    return ValidationRule(
      type: phone,
      constraint: r'^1[3-9]\d{9}$',
      message: message ?? '请输入有效的手机号码',
    );
  }

  /// 创建数值范围规则
  factory ValidationRule.createRange(num min, num max, [String? message]) {
    return ValidationRule(
      type: range,
      constraint: {'min': min, 'max': max},
      message: message ?? '值必须在$min到$max之间',
    );
  }
}

/// 字段验证器
class FieldValidator {
  /// 字段名称
  final String fieldName;

  /// 验证规则列表
  final List<ValidationRule> rules;

  /// 字段显示名称
  final String? displayName;

  const FieldValidator({
    required this.fieldName,
    required this.rules,
    this.displayName,
  });

  /// 验证字段值
  ValidationResult validateField(dynamic value) {
    final errors = <String>[];

    for (final rule in rules) {
      if (!rule.enabled) continue;

      final error = _validateRule(value, rule);
      if (error != null) {
        errors.add(error);
      }
    }

    if (errors.isEmpty) {
      return ValidationResult.success();
    }

    return ValidationResult.fieldError(fieldName, errors.first);
  }

  /// 验证单个规则
  String? _validateRule(dynamic value, ValidationRule rule) {
    switch (rule.type) {
      case ValidationRule.required:
        if (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty)) {
          return rule.message;
        }
        break;

      case ValidationRule.minLength:
        if (value is String && value.length < (rule.constraint as int)) {
          return rule.message;
        }
        break;

      case ValidationRule.maxLength:
        if (value is String && value.length > (rule.constraint as int)) {
          return rule.message;
        }
        break;

      case ValidationRule.pattern:
      case ValidationRule.email:
      case ValidationRule.phone:
        if (value is String && value.isNotEmpty) {
          final regex = RegExp(rule.constraint as String);
          if (!regex.hasMatch(value)) {
            return rule.message;
          }
        }
        break;

      case ValidationRule.numeric:
        if (value is String && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return rule.message;
          }
        }
        break;

      case ValidationRule.range:
        if (value is num) {
          final constraint = rule.constraint as Map<String, num>;
          final min = constraint['min']!;
          final max = constraint['max']!;
          if (value < min || value > max) {
            return rule.message;
          }
        }
        break;
    }

    return null;
  }
}

/// 复合验证器
class CompositeValidator<T> extends Validator<T> {
  final List<Validator<T>> validators;

  @override
  final String name;

  CompositeValidator({
    required this.validators,
    this.name = 'CompositeValidator',
  });

  @override
  ValidationResult validate(T data) {
    ValidationResult result = ValidationResult.success();

    for (final validator in validators) {
      if (!validator.enabled) continue;

      final validationResult = validator.validate(data);
      result = result.merge(validationResult);
    }

    return result;
  }
}

/// 条件验证器
class ConditionalValidator<T> extends Validator<T> {
  final Validator<T> validator;
  final bool Function(T data) condition;

  @override
  final String name;

  ConditionalValidator({
    required this.validator,
    required this.condition,
    this.name = 'ConditionalValidator',
  });

  @override
  ValidationResult validate(T data) {
    if (!condition(data)) {
      return ValidationResult.success();
    }

    return validator.validate(data);
  }
}
