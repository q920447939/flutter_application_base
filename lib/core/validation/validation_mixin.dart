/// 验证混入和控制器
/// 
/// 提供UI集成的验证功能，自动处理错误显示
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'validation_result.dart';
import 'validator.dart';

/// 验证混入
/// 
/// 为控制器提供统一的验证和UI提示功能
mixin ValidationMixin on GetxController {
  /// 当前验证结果
  final Rx<ValidationResult?> _validationResult = Rx<ValidationResult?>(null);
  
  /// 字段错误映射
  final RxMap<String, List<String>> fieldErrors = <String, List<String>>{}.obs;
  
  /// 全局错误列表
  final RxList<String> globalErrors = <String>[].obs;
  
  /// 是否有验证错误
  bool get hasValidationErrors => 
      fieldErrors.isNotEmpty || globalErrors.isNotEmpty;
  
  /// 获取当前验证结果
  ValidationResult? get validationResult => _validationResult.value;

  /// 验证数据并显示错误
  /// 
  /// [validator] 验证器
  /// [data] 要验证的数据
  /// [showSnackbar] 是否显示Snackbar提示
  /// [autoFocus] 是否自动聚焦到第一个错误字段
  ValidationResult validateAndShow<T>(
    Validator<T> validator,
    T data, {
    bool showSnackbar = true,
    bool autoFocus = false,
  }) {
    final result = validator.validate(data);
    _updateValidationState(result);
    
    if (!result.isValid && showSnackbar && result.firstError != null) {
      _showErrorSnackbar(result.firstError!);
    }
    
    return result;
  }

  /// 验证字段并显示错误
  /// 
  /// [fieldValidator] 字段验证器
  /// [value] 字段值
  ValidationResult validateFieldAndShow(
    FieldValidator fieldValidator,
    dynamic value,
  ) {
    final result = fieldValidator.validateField(value);
    
    if (result.isValid) {
      // 清除该字段的错误
      fieldErrors.remove(fieldValidator.fieldName);
    } else {
      // 更新该字段的错误
      fieldErrors[fieldValidator.fieldName] = 
          result.getFieldErrors(fieldValidator.fieldName);
    }
    
    return result;
  }

  /// 清除所有验证错误
  void clearValidationErrors() {
    fieldErrors.clear();
    globalErrors.clear();
    _validationResult.value = null;
  }

  /// 清除指定字段的验证错误
  void clearFieldError(String fieldName) {
    fieldErrors.remove(fieldName);
  }

  /// 添加字段错误
  void addFieldError(String fieldName, String error) {
    if (fieldErrors.containsKey(fieldName)) {
      fieldErrors[fieldName]!.add(error);
    } else {
      fieldErrors[fieldName] = [error];
    }
  }

  /// 添加全局错误
  void addGlobalError(String error) {
    globalErrors.add(error);
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

  /// 获取字段错误的第一条信息
  String? getFirstFieldError(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors.isNotEmpty ? errors.first : null;
  }

  /// 更新验证状态
  void _updateValidationState(ValidationResult result) {
    _validationResult.value = result;
    
    // 更新字段错误
    fieldErrors.clear();
    fieldErrors.addAll(result.fieldErrors);
    
    // 更新全局错误
    globalErrors.clear();
    globalErrors.addAll(result.globalErrors);
  }

  /// 显示错误Snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '验证失败',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// 显示成功Snackbar
  void showSuccessMessage(String message) {
    Get.snackbar(
      '成功',
      message,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// 显示警告Snackbar
  void showWarningMessage(String message) {
    Get.snackbar(
      '警告',
      message,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning_outlined, color: Colors.white),
    );
  }

  /// 显示信息Snackbar
  void showInfoMessage(String message) {
    Get.snackbar(
      '提示',
      message,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }
}

/// 验证控制器
/// 
/// 专门用于处理验证逻辑的控制器
class ValidationController extends GetxController with ValidationMixin {
  /// 验证器映射
  final Map<String, Validator> _validators = {};
  
  /// 注册验证器
  void registerValidator<T>(String name, Validator<T> validator) {
    _validators[name] = validator;
  }

  /// 获取验证器
  Validator<T>? getValidator<T>(String name) {
    return _validators[name] as Validator<T>?;
  }

  /// 使用注册的验证器进行验证
  ValidationResult validateWithRegistered<T>(String validatorName, T data) {
    final validator = getValidator<T>(validatorName);
    if (validator == null) {
      throw ArgumentError('验证器 "$validatorName" 未注册');
    }
    
    return validateAndShow(validator, data);
  }

  /// 批量验证
  ValidationResult validateBatch(Map<String, dynamic> validations) {
    ValidationResult result = ValidationResult.success();
    
    validations.forEach((validatorName, data) {
      final validator = _validators[validatorName];
      if (validator != null) {
        final validationResult = validator.validate(data);
        result = result.merge(validationResult);
      }
    });
    
    _updateValidationState(result);
    return result;
  }

  /// 清除指定验证器的错误
  void clearValidatorErrors(String validatorName) {
    // 这里可以根据需要实现更精细的清除逻辑
    clearValidationErrors();
  }
}
