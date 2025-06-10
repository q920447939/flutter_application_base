/// 应用按钮组件
///
/// 提供统一的按钮样式和行为，包括：
/// - 多种按钮类型
/// - 不同尺寸
/// - 加载状态
/// - 禁用状态
library;

import 'package:flutter/material.dart';
import '../../../design_system/tokens/index.dart';

/// 按钮类型枚举
enum AppButtonType {
  primary, // 主要按钮
  secondary, // 次要按钮
  outline, // 轮廓按钮
  text, // 文本按钮
  icon, // 图标按钮
}

/// 按钮尺寸枚举
enum AppButtonSize {
  small, // 小按钮
  medium, // 中等按钮
  large, // 大按钮
}

/// 应用按钮组件
class AppButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : assert(
         text != null || child != null,
         'Either text or child must be provided',
       );

  /// 主要按钮构造函数
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : type = AppButtonType.primary,
       child = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null,
       padding = null,
       borderRadius = null;

  /// 次要按钮构造函数
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : type = AppButtonType.secondary,
       child = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null,
       padding = null,
       borderRadius = null;

  /// 轮廓按钮构造函数
  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : type = AppButtonType.outline,
       child = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null,
       padding = null,
       borderRadius = null;

  /// 文本按钮构造函数
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : type = AppButtonType.text,
       child = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null,
       padding = null,
       borderRadius = null;

  /// 图标按钮构造函数
  const AppButton.icon({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  }) : type = AppButtonType.icon,
       text = null,
       child = null,
       suffixIcon = null,
       borderColor = null,
       padding = null,
       borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    // 获取按钮样式配置
    final config = _getButtonConfig(context);

    // 构建按钮内容
    Widget buttonChild = _buildButtonContent(context);

    // 根据按钮类型构建不同的按钮
    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getElevatedButtonStyle(config),
          child: buttonChild,
        );
        break;
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getSecondaryButtonStyle(config),
          child: buttonChild,
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getOutlinedButtonStyle(config),
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getTextButtonStyle(config),
          child: buttonChild,
        );
        break;
      case AppButtonType.icon:
        button = IconButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getIconButtonStyle(config),
          icon: buttonChild,
        );
        break;
    }

    // 应用宽高约束
    if (width != null || height != null) {
      button = SizedBox(width: width, height: height, child: button);
    }

    return button;
  }

  /// 构建按钮内容
  Widget _buildButtonContent(BuildContext context) {
    if (child != null) {
      return child!;
    }

    if (type == AppButtonType.icon) {
      if (isLoading) {
        return SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? AppColors.getTextColor(context),
            ),
          ),
        );
      }
      return Icon(icon, size: _getIconSize());
    }

    List<Widget> children = [];

    // 添加前置图标
    if (icon != null && !isLoading) {
      children.add(Icon(icon, size: _getIconSize()));
      if (text != null) {
        children.add(AppSpacing.horizontalSpace8);
      }
    }

    // 添加加载指示器
    if (isLoading) {
      children.add(
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? AppColors.white,
            ),
          ),
        ),
      );
      if (text != null) {
        children.add(AppSpacing.horizontalSpace8);
      }
    }

    // 添加文本
    if (text != null) {
      children.add(
        Text(text!, style: _getTextStyle(context), textAlign: TextAlign.center),
      );
    }

    // 添加后置图标
    if (suffixIcon != null && !isLoading) {
      if (text != null) {
        children.add(AppSpacing.horizontalSpace8);
      }
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    if (children.length == 1) {
      return children.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  /// 获取按钮配置
  _ButtonConfig _getButtonConfig(BuildContext context) {
    switch (size) {
      case AppButtonSize.small:
        return _ButtonConfig(
          padding: padding ?? AppSpacing.buttonSmallPadding,
          textStyle: AppTypography.labelSmallStyle,
          iconSize: 16,
          borderRadius: borderRadius ?? AppBorders.borderRadiusSm,
        );
      case AppButtonSize.medium:
        return _ButtonConfig(
          padding: padding ?? AppSpacing.buttonPadding,
          textStyle: AppTypography.labelMediumStyle,
          iconSize: 18,
          borderRadius: borderRadius ?? AppBorders.borderRadiusLg,
        );
      case AppButtonSize.large:
        return _ButtonConfig(
          padding: padding ?? AppSpacing.buttonLargePadding,
          textStyle: AppTypography.labelLargeStyle,
          iconSize: 20,
          borderRadius: borderRadius ?? AppBorders.borderRadiusLg,
        );
    }
  }

  /// 获取文本样式
  TextStyle _getTextStyle(BuildContext context) {
    final config = _getButtonConfig(context);
    return config.textStyle.copyWith(color: foregroundColor);
  }

  /// 获取图标大小
  double _getIconSize() {
    //return _getButtonConfig(context).iconSize;
    return 10;
  }

  /// 获取主要按钮样式
  ButtonStyle _getElevatedButtonStyle(_ButtonConfig config) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.white,
      padding: config.padding,
      shape: RoundedRectangleBorder(borderRadius: config.borderRadius),
      elevation: 2,
    );
  }

  /// 获取次要按钮样式
  ButtonStyle _getSecondaryButtonStyle(_ButtonConfig config) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.grey200,
      foregroundColor: foregroundColor ?? AppColors.grey800,
      padding: config.padding,
      shape: RoundedRectangleBorder(borderRadius: config.borderRadius),
      elevation: 1,
    );
  }

  /// 获取轮廓按钮样式
  ButtonStyle _getOutlinedButtonStyle(_ButtonConfig config) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? AppColors.primary,
      padding: config.padding,
      shape: RoundedRectangleBorder(borderRadius: config.borderRadius),
      side: BorderSide(
        color: borderColor ?? AppColors.primary,
        width: AppBorders.normal,
      ),
    );
  }

  /// 获取文本按钮样式
  ButtonStyle _getTextButtonStyle(_ButtonConfig config) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor ?? AppColors.primary,
      padding: config.padding,
      shape: RoundedRectangleBorder(borderRadius: config.borderRadius),
    );
  }

  /// 获取图标按钮样式
  ButtonStyle _getIconButtonStyle(_ButtonConfig config) {
    return IconButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor ?? AppColors.primary,
      padding: EdgeInsets.all(AppSpacing.space8),
      shape: RoundedRectangleBorder(borderRadius: config.borderRadius),
    );
  }
}

/// 按钮配置类
class _ButtonConfig {
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final double iconSize;
  final BorderRadius borderRadius;

  const _ButtonConfig({
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.borderRadius,
  });
}
