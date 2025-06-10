/// 应用列表项组件
///
/// 提供统一的列表项样式，包括：
/// - 基础列表项
/// - 带图标列表项
/// - 带头像列表项
/// - 带开关列表项
/// - 带复选框列表项
library;

import 'package:flutter/material.dart';
import '../../../design_system/tokens/index.dart';
import '../../atoms/index.dart';

/// 列表项类型枚举
enum AppListTileType {
  basic, // 基础列表项
  switch_, // 开关列表项
  checkbox, // 复选框列表项
  radio, // 单选框列表项
}

/// 应用列表项组件
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final String? titleText;
  final String? subtitleText;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isThreeLine;
  final bool dense;
  final bool enabled;
  final bool selected;
  final Color? selectedColor;
  final EdgeInsetsGeometry? contentPadding;
  final VisualDensity? visualDensity;

  const AppListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.titleText,
    this.subtitleText,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.onLongPress,
    this.isThreeLine = false,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.selectedColor,
    this.contentPadding,
    this.visualDensity,
  });

  /// 带图标列表项构造函数
  const AppListTile.icon({
    super.key,
    required this.leadingIcon,
    required this.titleText,
    this.subtitleText,
    this.trailing,
    this.trailingIcon,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.selectedColor,
    this.contentPadding,
  }) : leading = null,
       title = null,
       subtitle = null,
       isThreeLine = false,
       visualDensity = null;

  /// 带头像列表项构造函数
  const AppListTile.avatar({
    super.key,
    required Widget avatar,
    required this.titleText,
    this.subtitleText,
    this.trailing,
    this.trailingIcon,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.selectedColor,
    this.contentPadding,
  }) : leading = avatar,
       title = null,
       subtitle = null,
       leadingIcon = null,
       isThreeLine = false,
       visualDensity = null;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeading(context),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context),
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      isThreeLine: isThreeLine,
      dense: dense,
      enabled: enabled,
      selected: selected,
      selectedColor: selectedColor ?? AppColors.primary.withOpacity(0.1),
      contentPadding: contentPadding ?? AppSpacing.horizontal16,
      visualDensity: visualDensity,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (leadingIcon != null) {
      return Icon(
        leadingIcon,
        color:
            enabled
                ? AppColors.getTextColor(context, isPrimary: false)
                : AppColors.grey400,
      );
    }
    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    if (title != null) return title;
    if (titleText != null) {
      return Text(
        titleText!,
        style: AppTypography.bodyLargeStyle.copyWith(
          color: enabled ? AppColors.getTextColor(context) : AppColors.grey400,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }
    return null;
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (subtitle != null) return subtitle;
    if (subtitleText != null) {
      return Text(
        subtitleText!,
        style: AppTypography.bodyMediumStyle.copyWith(
          color:
              enabled
                  ? AppColors.getTextColor(context, isPrimary: false)
                  : AppColors.grey400,
        ),
      );
    }
    return null;
  }

  Widget? _buildTrailing(BuildContext context) {
    if (trailing != null) return trailing;
    if (trailingIcon != null) {
      return Icon(
        trailingIcon,
        color:
            enabled
                ? AppColors.getTextColor(context, isPrimary: false)
                : AppColors.grey400,
      );
    }
    return null;
  }
}

/// 开关列表项组件
class AppSwitchListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final String? titleText;
  final String? subtitleText;
  final IconData? leadingIcon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isThreeLine;
  final bool dense;
  final bool enabled;
  final bool selected;
  final Color? activeColor;
  final Color? selectedColor;
  final EdgeInsetsGeometry? contentPadding;

  const AppSwitchListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.titleText,
    this.subtitleText,
    this.leadingIcon,
    required this.value,
    this.onChanged,
    this.isThreeLine = false,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.activeColor,
    this.selectedColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: _buildLeading(context),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      value: value,
      onChanged: enabled ? onChanged : null,
      isThreeLine: isThreeLine,
      dense: dense,
      selected: selected,
      activeColor: activeColor ?? AppColors.primary,
      //selectedColor: selectedColor ?? AppColors.primary.withOpacity(0.1),
      contentPadding: contentPadding ?? AppSpacing.horizontal16,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (leadingIcon != null) {
      return Icon(
        leadingIcon,
        color:
            enabled
                ? AppColors.getTextColor(context, isPrimary: false)
                : AppColors.grey400,
      );
    }
    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    if (title != null) return title;
    if (titleText != null) {
      return Text(
        titleText!,
        style: AppTypography.bodyLargeStyle.copyWith(
          color: enabled ? AppColors.getTextColor(context) : AppColors.grey400,
        ),
      );
    }
    return null;
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (subtitle != null) return subtitle;
    if (subtitleText != null) {
      return Text(
        subtitleText!,
        style: AppTypography.bodyMediumStyle.copyWith(
          color:
              enabled
                  ? AppColors.getTextColor(context, isPrimary: false)
                  : AppColors.grey400,
        ),
      );
    }
    return null;
  }
}

/// 复选框列表项组件
class AppCheckboxListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final String? titleText;
  final String? subtitleText;
  final IconData? leadingIcon;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool isThreeLine;
  final bool dense;
  final bool enabled;
  final bool selected;
  final Color? activeColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool tristate;

  const AppCheckboxListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.titleText,
    this.subtitleText,
    this.leadingIcon,
    required this.value,
    this.onChanged,
    this.isThreeLine = false,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.activeColor,
    this.contentPadding,
    this.tristate = false,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      secondary: _buildLeading(context),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      value: value,
      onChanged: enabled ? onChanged : null,
      isThreeLine: isThreeLine,
      dense: dense,
      selected: selected,
      activeColor: activeColor ?? AppColors.primary,
      contentPadding: contentPadding ?? AppSpacing.horizontal16,
      tristate: tristate,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (leadingIcon != null) {
      return Icon(
        leadingIcon,
        color:
            enabled
                ? AppColors.getTextColor(context, isPrimary: false)
                : AppColors.grey400,
      );
    }
    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    if (title != null) return title;
    if (titleText != null) {
      return Text(
        titleText!,
        style: AppTypography.bodyLargeStyle.copyWith(
          color: enabled ? AppColors.getTextColor(context) : AppColors.grey400,
        ),
      );
    }
    return null;
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (subtitle != null) return subtitle;
    if (subtitleText != null) {
      return Text(
        subtitleText!,
        style: AppTypography.bodyMediumStyle.copyWith(
          color:
              enabled
                  ? AppColors.getTextColor(context, isPrimary: false)
                  : AppColors.grey400,
        ),
      );
    }
    return null;
  }
}

/// 单选框列表项组件
class AppRadioListTile<T> extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final String? titleText;
  final String? subtitleText;
  final IconData? leadingIcon;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool isThreeLine;
  final bool dense;
  final bool enabled;
  final bool selected;
  final Color? activeColor;
  final EdgeInsetsGeometry? contentPadding;

  const AppRadioListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.titleText,
    this.subtitleText,
    this.leadingIcon,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.isThreeLine = false,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.activeColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      secondary: _buildLeading(context),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? onChanged : null,
      isThreeLine: isThreeLine,
      dense: dense,
      selected: selected,
      activeColor: activeColor ?? AppColors.primary,
      contentPadding: contentPadding ?? AppSpacing.horizontal16,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (leadingIcon != null) {
      return Icon(
        leadingIcon,
        color:
            enabled
                ? AppColors.getTextColor(context, isPrimary: false)
                : AppColors.grey400,
      );
    }
    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    if (title != null) return title;
    if (titleText != null) {
      return Text(
        titleText!,
        style: AppTypography.bodyLargeStyle.copyWith(
          color: enabled ? AppColors.getTextColor(context) : AppColors.grey400,
        ),
      );
    }
    return null;
  }

  Widget? _buildSubtitle(BuildContext context) {
    if (subtitle != null) return subtitle;
    if (subtitleText != null) {
      return Text(
        subtitleText!,
        style: AppTypography.bodyMediumStyle.copyWith(
          color:
              enabled
                  ? AppColors.getTextColor(context, isPrimary: false)
                  : AppColors.grey400,
        ),
      );
    }
    return null;
  }
}
