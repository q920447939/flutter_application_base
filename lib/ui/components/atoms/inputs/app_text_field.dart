/// 应用文本输入框组件
/// 
/// 提供统一的文本输入框样式和行为，包括：
/// - 多种输入类型
/// - 验证功能
/// - 前后缀图标
/// - 清除按钮
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/tokens/index.dart';

/// 输入框类型枚举
enum AppTextFieldType {
  text,       // 普通文本
  password,   // 密码
  email,      // 邮箱
  phone,      // 手机号
  number,     // 数字
  multiline,  // 多行文本
  search,     // 搜索
}

/// 应用文本输入框组件
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final AppTextFieldType type;
  final bool isRequired;
  final bool isReadOnly;
  final bool isEnabled;
  final bool showClearButton;
  final bool showPasswordToggle;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.type = AppTextFieldType.text,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.showClearButton = false,
    this.showPasswordToggle = false,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
  });

  /// 密码输入框构造函数
  const AppTextField.password({
    super.key,
    this.label,
    this.hintText = '请输入密码',
    this.helperText,
    this.errorText,
    this.controller,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.contentPadding,
  }) : type = AppTextFieldType.password,
       initialValue = null,
       showClearButton = false,
       showPasswordToggle = true,
       prefixIcon = Icons.lock_outline,
       prefix = null,
       suffixIcon = null,
       suffix = null,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       inputFormatters = null;

  /// 邮箱输入框构造函数
  const AppTextField.email({
    super.key,
    this.label,
    this.hintText = '请输入邮箱地址',
    this.helperText,
    this.errorText,
    this.controller,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.showClearButton = true,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.contentPadding,
  }) : type = AppTextFieldType.email,
       initialValue = null,
       showPasswordToggle = false,
       prefixIcon = Icons.email_outlined,
       prefix = null,
       suffixIcon = null,
       suffix = null,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       inputFormatters = null;

  /// 手机号输入框构造函数
  const AppTextField.phone({
    super.key,
    this.label,
    this.hintText = '请输入手机号',
    this.helperText,
    this.errorText,
    this.controller,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.showClearButton = true,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.contentPadding,
  }) : type = AppTextFieldType.phone,
       initialValue = null,
       showPasswordToggle = false,
       prefixIcon = Icons.phone_outlined,
       prefix = null,
       suffixIcon = null,
       suffix = null,
       maxLines = 1,
       minLines = null,
       maxLength = 11,
       inputFormatters = null;

  /// 搜索输入框构造函数
  const AppTextField.search({
    super.key,
    this.hintText = '搜索...',
    this.controller,
    this.isEnabled = true,
    this.showClearButton = true,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.contentPadding,
  }) : type = AppTextFieldType.search,
       label = null,
       helperText = null,
       errorText = null,
       initialValue = null,
       isRequired = false,
       isReadOnly = false,
       showPasswordToggle = false,
       prefixIcon = Icons.search,
       prefix = null,
       suffixIcon = null,
       suffix = null,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       textInputAction = TextInputAction.search,
       validator = null,
       inputFormatters = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.type == AppTextFieldType.password;
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = widget.showClearButton && _controller.text.isNotEmpty;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.labelMediumStyle.copyWith(
                  color: AppColors.getTextColor(context),
                ),
              ),
              if (widget.isRequired) ...[
                AppSpacing.horizontalSpace4,
                Text(
                  '*',
                  style: AppTypography.labelMediumStyle.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.verticalSpace8,
        ],

        // 输入框
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          readOnly: widget.isReadOnly,
          enabled: widget.isEnabled,
          maxLines: widget.type == AppTextFieldType.multiline ? (widget.maxLines ?? 3) : 1,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction ?? _getDefaultTextInputAction(),
          inputFormatters: widget.inputFormatters ?? _getDefaultInputFormatters(),
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.bodyMediumStyle.copyWith(
              color: AppColors.getTextColor(context, isPrimary: false),
            ),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon, color: AppColors.getTextColor(context, isPrimary: false))
                : null,
            prefix: widget.prefix,
            suffixIcon: _buildSuffixIcon(),
            suffix: widget.suffix,
            contentPadding: widget.contentPadding ?? AppSpacing.inputPadding,
            border: AppBorders.inputBorder,
            enabledBorder: AppBorders.inputBorder,
            focusedBorder: AppBorders.inputBorderFocused,
            errorBorder: AppBorders.inputBorderError,
            focusedErrorBorder: AppBorders.inputBorderError,
            filled: true,
            fillColor: widget.isEnabled 
                ? AppColors.getSurfaceColor(context)
                : AppColors.grey100,
            counterText: widget.maxLength != null ? null : '',
          ),
        ),

        // 帮助文本或错误文本
        if (widget.helperText != null || widget.errorText != null) ...[
          AppSpacing.verticalSpace4,
          Text(
            widget.errorText ?? widget.helperText!,
            style: AppTypography.bodySmallStyle.copyWith(
              color: widget.errorText != null 
                  ? AppColors.error 
                  : AppColors.getTextColor(context, isPrimary: false),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    List<Widget> icons = [];

    // 清除按钮
    if (_showClearButton) {
      icons.add(
        IconButton(
          onPressed: _clearText,
          icon: const Icon(Icons.clear, size: 18),
          color: AppColors.getTextColor(context, isPrimary: false),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      );
    }

    // 密码可见性切换
    if (widget.showPasswordToggle && widget.type == AppTextFieldType.password) {
      icons.add(
        IconButton(
          onPressed: _togglePasswordVisibility,
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18,
          ),
          color: AppColors.getTextColor(context, isPrimary: false),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      );
    }

    // 自定义后缀图标
    if (widget.suffixIcon != null) {
      icons.add(
        Icon(
          widget.suffixIcon,
          color: AppColors.getTextColor(context, isPrimary: false),
        ),
      );
    }

    if (icons.isEmpty) return null;
    if (icons.length == 1) return icons.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.phone:
        return TextInputType.phone;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getDefaultTextInputAction() {
    switch (widget.type) {
      case AppTextFieldType.search:
        return TextInputAction.search;
      case AppTextFieldType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  List<TextInputFormatter>? _getDefaultInputFormatters() {
    switch (widget.type) {
      case AppTextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      case AppTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }
}
