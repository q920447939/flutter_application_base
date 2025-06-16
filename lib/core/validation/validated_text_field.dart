/// 验证文本输入框组件
/// 
/// 自动显示验证错误的文本输入框
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'validation_mixin.dart';

/// 验证文本输入框
class ValidatedTextField extends StatelessWidget {
  /// 控制器（必须混入ValidationMixin）
  final GetxController controller;
  
  /// 字段名称
  final String fieldName;
  
  /// 文本控制器
  final TextEditingController? textController;
  
  /// 输入装饰
  final InputDecoration? decoration;
  
  /// 是否密码字段
  final bool obscureText;
  
  /// 键盘类型
  final TextInputType? keyboardType;
  
  /// 文本输入动作
  final TextInputAction? textInputAction;
  
  /// 最大行数
  final int? maxLines;
  
  /// 最大长度
  final int? maxLength;
  
  /// 是否启用
  final bool enabled;
  
  /// 是否只读
  final bool readOnly;
  
  /// 输入变化回调
  final ValueChanged<String>? onChanged;
  
  /// 提交回调
  final ValueChanged<String>? onSubmitted;
  
  /// 焦点节点
  final FocusNode? focusNode;
  
  /// 验证模式
  final AutovalidateMode autovalidateMode;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.fieldName,
    this.textController,
    this.decoration,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    // 确保控制器混入了ValidationMixin
    if (controller is! ValidationMixin) {
      throw ArgumentError('控制器必须混入ValidationMixin');
    }

    final validationMixin = controller as ValidationMixin;

    return Obx(() {
      final fieldErrors = validationMixin.getFieldErrors(fieldName);
      final hasError = fieldErrors.isNotEmpty;
      final errorText = hasError ? fieldErrors.first : null;

      return TextFormField(
        controller: textController,
        decoration: _buildDecoration(errorText),
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: enabled,
        readOnly: readOnly,
        focusNode: focusNode,
        autovalidateMode: autovalidateMode,
        onChanged: (value) {
          onChanged?.call(value);
          // 实时验证可以在这里添加
        },
        onFieldSubmitted: onSubmitted,
        validator: (value) {
          // 返回错误文本用于FormField显示
          return errorText;
        },
      );
    });
  }

  /// 构建输入装饰
  InputDecoration _buildDecoration(String? errorText) {
    final baseDecoration = decoration ?? const InputDecoration();
    
    if (errorText != null) {
      return baseDecoration.copyWith(
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        border: baseDecoration.border?.copyWith(
          borderSide: const BorderSide(color: Colors.red),
        ) ?? const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        enabledBorder: baseDecoration.enabledBorder?.copyWith(
          borderSide: const BorderSide(color: Colors.red),
        ) ?? const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedBorder: baseDecoration.focusedBorder?.copyWith(
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ) ?? const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      );
    }
    
    return baseDecoration;
  }
}

/// 验证表单
class ValidatedForm extends StatelessWidget {
  /// 控制器（必须混入ValidationMixin）
  final GetxController controller;
  
  /// 表单Key
  final GlobalKey<FormState>? formKey;
  
  /// 子组件
  final Widget child;
  
  /// 自动验证模式
  final AutovalidateMode autovalidateMode;

  const ValidatedForm({
    super.key,
    required this.controller,
    required this.child,
    this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    // 确保控制器混入了ValidationMixin
    if (controller is! ValidationMixin) {
      throw ArgumentError('控制器必须混入ValidationMixin');
    }

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: child,
    );
  }
}

/// 验证错误显示组件
class ValidationErrorDisplay extends StatelessWidget {
  /// 控制器（必须混入ValidationMixin）
  final GetxController controller;
  
  /// 显示模式
  final ValidationErrorDisplayMode mode;
  
  /// 自定义样式
  final TextStyle? errorStyle;
  
  /// 最大显示错误数
  final int maxErrors;

  const ValidationErrorDisplay({
    super.key,
    required this.controller,
    this.mode = ValidationErrorDisplayMode.all,
    this.errorStyle,
    this.maxErrors = 5,
  });

  @override
  Widget build(BuildContext context) {
    // 确保控制器混入了ValidationMixin
    if (controller is! ValidationMixin) {
      throw ArgumentError('控制器必须混入ValidationMixin');
    }

    final validationMixin = controller as ValidationMixin;

    return Obx(() {
      final errors = _getErrorsToDisplay(validationMixin);
      
      if (errors.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '请修正以下错误：',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...errors.take(maxErrors).map((error) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Text(
                '• $error',
                style: errorStyle ?? TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
              ),
            )),
            if (errors.length > maxErrors)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Text(
                  '还有 ${errors.length - maxErrors} 个错误...',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// 获取要显示的错误列表
  List<String> _getErrorsToDisplay(ValidationMixin validationMixin) {
    switch (mode) {
      case ValidationErrorDisplayMode.fieldOnly:
        return validationMixin.fieldErrors.values
            .expand((errors) => errors)
            .toList();
      case ValidationErrorDisplayMode.globalOnly:
        return validationMixin.globalErrors.toList();
      case ValidationErrorDisplayMode.all:
        final allErrors = <String>[];
        allErrors.addAll(validationMixin.fieldErrors.values
            .expand((errors) => errors));
        allErrors.addAll(validationMixin.globalErrors);
        return allErrors;
    }
  }
}

/// 验证错误显示模式
enum ValidationErrorDisplayMode {
  /// 只显示字段错误
  fieldOnly,
  /// 只显示全局错误
  globalOnly,
  /// 显示所有错误
  all,
}
