/// 应用头像组件
/// 
/// 提供统一的头像显示，包括：
/// - 网络图片头像
/// - 本地图片头像
/// - 文字头像
/// - 图标头像
/// - 不同尺寸
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../design_system/tokens/index.dart';

/// 头像尺寸枚举
enum AppAvatarSize {
  xs,     // 24x24
  sm,     // 32x32
  md,     // 40x40
  lg,     // 56x56
  xl,     // 72x72
  xxl,    // 96x96
}

/// 头像类型枚举
enum AppAvatarType {
  network,    // 网络图片
  asset,      // 本地资源
  file,       // 本地文件
  text,       // 文字
  icon,       // 图标
}

/// 应用头像组件
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final String? filePath;
  final String? text;
  final IconData? icon;
  final AppAvatarSize size;
  final AppAvatarType? type;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;
  final String? heroTag;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.filePath,
    this.text,
    this.icon,
    this.size = AppAvatarSize.md,
    this.type,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.heroTag,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  });

  /// 网络图片头像构造函数
  const AppAvatar.network({
    super.key,
    required this.imageUrl,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.onTap,
    this.heroTag,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  }) : type = AppAvatarType.network,
       assetPath = null,
       filePath = null,
       text = null,
       icon = null,
       foregroundColor = null;

  /// 本地资源头像构造函数
  const AppAvatar.asset({
    super.key,
    required this.assetPath,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.onTap,
    this.heroTag,
    this.fit = BoxFit.cover,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  }) : type = AppAvatarType.asset,
       imageUrl = null,
       filePath = null,
       text = null,
       icon = null,
       foregroundColor = null,
       placeholder = null,
       errorWidget = null;

  /// 文字头像构造函数
  const AppAvatar.text({
    super.key,
    required this.text,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.heroTag,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  }) : type = AppAvatarType.text,
       imageUrl = null,
       assetPath = null,
       filePath = null,
       icon = null,
       fit = BoxFit.cover,
       placeholder = null,
       errorWidget = null;

  /// 图标头像构造函数
  const AppAvatar.icon({
    super.key,
    required this.icon,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.heroTag,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  }) : type = AppAvatarType.icon,
       imageUrl = null,
       assetPath = null,
       filePath = null,
       text = null,
       fit = BoxFit.cover,
       placeholder = null,
       errorWidget = null;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getAvatarSize();
    final radius = avatarSize / 2;

    Widget avatar = _buildAvatarContent(context, avatarSize);

    // 添加边框
    if (showBorder) {
      avatar = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppColors.getBorderColor(context),
            width: borderWidth ?? 2,
          ),
        ),
        child: ClipOval(child: avatar),
      );
    } else {
      avatar = ClipOval(
        child: SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: avatar,
        ),
      );
    }

    // 添加Hero动画
    if (heroTag != null) {
      avatar = Hero(
        tag: heroTag!,
        child: avatar,
      );
    }

    // 添加点击事件
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildAvatarContent(BuildContext context, double size) {
    final avatarType = type ?? _getDefaultType();

    switch (avatarType) {
      case AppAvatarType.network:
        return _buildNetworkAvatar(context, size);
      case AppAvatarType.asset:
        return _buildAssetAvatar(size);
      case AppAvatarType.file:
        return _buildFileAvatar(size);
      case AppAvatarType.text:
        return _buildTextAvatar(context, size);
      case AppAvatarType.icon:
        return _buildIconAvatar(context, size);
    }
  }

  Widget _buildNetworkAvatar(BuildContext context, double size) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(context, size),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(context, size),
    );
  }

  Widget _buildAssetAvatar(double size) {
    return Image.asset(
      assetPath!,
      width: size,
      height: size,
      fit: fit,
    );
  }

  Widget _buildFileAvatar(double size) {
    // 这里需要使用dart:io的File类，但为了避免平台依赖，暂时返回占位符
    return _buildDefaultPlaceholder(null, size);
  }

  Widget _buildTextAvatar(BuildContext context, double size) {
    final displayText = _getDisplayText();
    final textStyle = _getTextStyle(size);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? _getDefaultBackgroundColor(displayText),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayText,
          style: textStyle.copyWith(
            color: foregroundColor ?? _getContrastColor(backgroundColor ?? _getDefaultBackgroundColor(displayText)),
          ),
        ),
      ),
    );
  }

  Widget _buildIconAvatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.grey200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: foregroundColor ?? AppColors.getTextColor(context),
      ),
    );
  }

  Widget _buildDefaultPlaceholder(BuildContext? context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.grey500,
      ),
    );
  }

  Widget _buildDefaultErrorWidget(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.error_outline,
        size: size * 0.5,
        color: AppColors.error,
      ),
    );
  }

  AppAvatarType _getDefaultType() {
    if (imageUrl != null) return AppAvatarType.network;
    if (assetPath != null) return AppAvatarType.asset;
    if (filePath != null) return AppAvatarType.file;
    if (text != null) return AppAvatarType.text;
    if (icon != null) return AppAvatarType.icon;
    return AppAvatarType.icon;
  }

  double _getAvatarSize() {
    switch (size) {
      case AppAvatarSize.xs:
        return 24;
      case AppAvatarSize.sm:
        return 32;
      case AppAvatarSize.md:
        return 40;
      case AppAvatarSize.lg:
        return 56;
      case AppAvatarSize.xl:
        return 72;
      case AppAvatarSize.xxl:
        return 96;
    }
  }

  String _getDisplayText() {
    if (text == null || text!.isEmpty) return '?';
    
    // 如果是中文，取第一个字符
    if (text!.contains(RegExp(r'[\u4e00-\u9fa5]'))) {
      return text!.substring(0, 1);
    }
    
    // 如果是英文，取前两个字母的首字母
    final words = text!.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    } else {
      return words[0][0].toUpperCase();
    }
  }

  TextStyle _getTextStyle(double size) {
    final fontSize = size * 0.4;
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  Color _getDefaultBackgroundColor(String text) {
    // 根据文本生成一个固定的颜色
    final hash = text.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.accent,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getContrastColor(Color backgroundColor) {
    // 计算对比色
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.black : AppColors.white;
  }
}
