/// 应用卡片组件
///
/// 提供统一的卡片样式，包括：
/// - 基础卡片
/// - 带标题卡片
/// - 带操作按钮卡片
/// - 图片卡片
library;

import 'package:flutter/material.dart';
import '../../../design_system/tokens/index.dart';
import '../../atoms/index.dart';

/// 卡片类型枚举
enum AppCardType {
  basic, // 基础卡片
  elevated, // 带阴影卡片
  outlined, // 轮廓卡片
  filled, // 填充卡片
}

/// 应用卡片组件
class AppCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AppCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? width;
  final double? height;
  final bool showDivider;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.onLongPress,
    this.type = AppCardType.elevated,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.showDivider = false,
  });

  /// 基础卡片构造函数
  const AppCard.basic({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.width,
    this.height,
  }) : type = AppCardType.basic,
       title = null,
       subtitle = null,
       leading = null,
       trailing = null,
       actions = null,
       shadowColor = null,
       elevation = null,
       border = null,
       showDivider = false;

  /// 带标题卡片构造函数
  const AppCard.titled({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.onLongPress,
    this.type = AppCardType.elevated,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.showDivider = true,
  });

  /// 轮廓卡片构造函数
  const AppCard.outlined({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.actions,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.showDivider = false,
  }) : type = AppCardType.outlined,
       shadowColor = null,
       elevation = null;

  @override
  Widget build(BuildContext context) {
    Widget card = _buildCardContent(context);

    // 应用宽高约束
    if (width != null || height != null) {
      card = SizedBox(width: width, height: height, child: card);
    }

    // 应用外边距
    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }

  Widget _buildCardContent(BuildContext context) {
    final cardPadding = padding ?? AppSpacing.cardPadding;
    final cardBorderRadius = borderRadius ?? AppBorders.borderRadiusXl;

    // 构建卡片内容
    List<Widget> children = [];

    // 添加标题区域
    if (title != null || leading != null || trailing != null) {
      children.add(_buildHeader(context));

      if (showDivider && child != null) {
        children.add(
          Divider(
            height: AppSpacing.space16,
            color: AppColors.getBorderColor(context),
          ),
        );
      } else if (child != null) {
        children.add(AppSpacing.verticalSpace12);
      }
    }

    // 添加主要内容
    if (child != null) {
      children.add(child!);
    }

    // 添加操作按钮
    if (actions != null && actions!.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(AppSpacing.verticalSpace16);
      }
      children.add(_buildActions());
    }

    Widget content =
        children.length == 1
            ? children.first
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            );

    // 根据卡片类型构建不同样式的卡片
    /* switch (type) {
      case AppCardType.basic:
        return _buildBasicCard(context, content, cardPadding, cardBorderRadius);
      case AppCardType.elevated:
        return _buildElevatedCard(context, content, cardPadding, cardBorderRadius);
      case AppCardType.outlined:
        return _buildOutlinedCard(context, content, cardPadding, cardBorderRadius);
      case AppCardType.filled:
        return _buildFilledCard(context, content, cardPadding, cardBorderRadius);
    } */
    return Container();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 前置组件
        if (leading != null) ...[leading!, AppSpacing.horizontalSpace12],

        // 标题和副标题
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTypography.titleMediumStyle.copyWith(
                    color: AppColors.getTextColor(context),
                  ),
                ),
              if (subtitle != null) ...[
                AppSpacing.verticalSpace4,
                Text(
                  subtitle!,
                  style: AppTypography.bodySmallStyle.copyWith(
                    color: AppColors.getTextColor(context, isPrimary: false),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 后置组件
        if (trailing != null) ...[AppSpacing.horizontalSpace12, trailing!],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children:
          actions!
              .map(
                (action) => Padding(padding: AppSpacing.left8, child: action),
              )
              .toList(),
    );
  }

  Widget _buildBasicCard(
    BuildContext context,
    Widget content,
    EdgeInsetsGeometry padding,
    BorderRadius borderRadius,
  ) {
    return Material(
      color: backgroundColor ?? AppColors.getSurfaceColor(context),
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: content),
      ),
    );
  }

  Widget _buildElevatedCard(
    BuildContext context,
    Widget content,
    EdgeInsetsGeometry padding,
    BorderRadius borderRadius,
  ) {
    return Card(
      color: backgroundColor ?? AppColors.getSurfaceColor(context),
      shadowColor: shadowColor,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: content),
      ),
    );
  }

  Widget _buildOutlinedCard(
    BuildContext context,
    Widget content,
    EdgeInsetsGeometry padding,
    BorderRadius borderRadius,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.getSurfaceColor(context),
        borderRadius: borderRadius,
        border:
            border ??
            Border.all(
              color: AppColors.getBorderColor(context),
              width: AppBorders.normal,
            ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: content),
        ),
      ),
    );
  }

  Widget _buildFilledCard(
    BuildContext context,
    Widget content,
    EdgeInsetsGeometry padding,
    BorderRadius borderRadius,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.grey100,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: content),
        ),
      ),
    );
  }
}

/// 图片卡片组件
class AppImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final String? title;
  final String? subtitle;
  final String? description;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final VoidCallback? onImageTap;
  final double? imageHeight;
  final BoxFit imageFit;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const AppImageCard({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.title,
    this.subtitle,
    this.description,
    this.actions,
    this.onTap,
    this.onImageTap,
    this.imageHeight = 200,
    this.imageFit = BoxFit.cover,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = borderRadius ?? AppBorders.borderRadiusXl;

    return AppCard(
      type: AppCardType.elevated,
      padding: EdgeInsets.zero,
      margin: margin,
      borderRadius: cardBorderRadius,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          if (imageUrl != null || assetPath != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: cardBorderRadius.topLeft,
                topRight: cardBorderRadius.topRight,
              ),
              child: GestureDetector(onTap: onImageTap, child: _buildImage()),
            ),

          // 内容区域
          if (title != null ||
              subtitle != null ||
              description != null ||
              actions != null)
            Padding(
              padding: padding ?? AppSpacing.all16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: AppTypography.titleMediumStyle.copyWith(
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  if (subtitle != null) ...[
                    AppSpacing.verticalSpace4,
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmallStyle.copyWith(
                        color: AppColors.getTextColor(
                          context,
                          isPrimary: false,
                        ),
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    AppSpacing.verticalSpace8,
                    Text(
                      description!,
                      style: AppTypography.bodyMediumStyle.copyWith(
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ],
                  if (actions != null && actions!.isNotEmpty) ...[
                    AppSpacing.verticalSpace16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:
                          actions!
                              .map(
                                (action) => Padding(
                                  padding: AppSpacing.left8,
                                  child: action,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        height: imageHeight,
        width: double.infinity,
        fit: imageFit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: imageHeight,
            width: double.infinity,
            color: AppColors.grey200,
            child: const Icon(
              Icons.broken_image,
              color: AppColors.grey500,
              size: 48,
            ),
          );
        },
      );
    } else if (assetPath != null) {
      return Image.asset(
        assetPath!,
        height: imageHeight,
        width: double.infinity,
        fit: imageFit,
      );
    }
    return const SizedBox.shrink();
  }
}
