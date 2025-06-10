/// 边框设计令牌
/// 
/// 定义应用中使用的所有边框样式，包括：
/// - 边框宽度
/// - 边框颜色
/// - 圆角半径
/// - 边框样式
library;

import 'package:flutter/material.dart';
import 'colors.dart';

/// 应用边框系统
class AppBorders {
  AppBorders._();

  // ==================== 边框宽度 ====================
  
  /// 无边框
  static const double none = 0.0;
  
  /// 细边框
  static const double thin = 0.5;
  
  /// 默认边框
  static const double normal = 1.0;
  
  /// 粗边框
  static const double thick = 2.0;
  
  /// 超粗边框
  static const double extraThick = 3.0;

  // ==================== 圆角半径 ====================
  
  /// 无圆角
  static const double radiusNone = 0.0;
  
  /// 小圆角
  static const double radiusXs = 2.0;
  
  /// 小圆角
  static const double radiusSm = 4.0;
  
  /// 中等圆角
  static const double radiusMd = 6.0;
  
  /// 大圆角
  static const double radiusLg = 8.0;
  
  /// 超大圆角
  static const double radiusXl = 12.0;
  
  /// 超超大圆角
  static const double radiusXxl = 16.0;
  
  /// 巨大圆角
  static const double radiusXxxl = 20.0;
  
  /// 圆形
  static const double radiusFull = 9999.0;

  // ==================== BorderRadius ====================
  
  /// 无圆角
  static const BorderRadius borderRadiusNone = BorderRadius.zero;
  
  /// 小圆角
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  
  /// 小圆角
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  
  /// 中等圆角
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  
  /// 大圆角
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  
  /// 超大圆角
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  
  /// 超超大圆角
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));
  
  /// 巨大圆角
  static const BorderRadius borderRadiusXxxl = BorderRadius.all(Radius.circular(radiusXxxl));
  
  /// 圆形
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ==================== 基础边框 ====================
  
  /// 无边框
  static const Border borderNone = Border();
  
  /// 细边框
  static const Border borderThin = Border.fromBorderSide(
    BorderSide(color: AppColors.borderLight, width: thin),
  );
  
  /// 默认边框
  static const Border borderNormal = Border.fromBorderSide(
    BorderSide(color: AppColors.borderLight, width: normal),
  );
  
  /// 粗边框
  static const Border borderThick = Border.fromBorderSide(
    BorderSide(color: AppColors.borderLight, width: thick),
  );

  // ==================== 深色主题边框 ====================
  
  /// 深色主题细边框
  static const Border borderThinDark = Border.fromBorderSide(
    BorderSide(color: AppColors.borderDark, width: thin),
  );
  
  /// 深色主题默认边框
  static const Border borderNormalDark = Border.fromBorderSide(
    BorderSide(color: AppColors.borderDark, width: normal),
  );
  
  /// 深色主题粗边框
  static const Border borderThickDark = Border.fromBorderSide(
    BorderSide(color: AppColors.borderDark, width: thick),
  );

  // ==================== 彩色边框 ====================
  
  /// 主色调边框
  static const Border borderPrimary = Border.fromBorderSide(
    BorderSide(color: AppColors.primary, width: normal),
  );
  
  /// 成功色边框
  static const Border borderSuccess = Border.fromBorderSide(
    BorderSide(color: AppColors.success, width: normal),
  );
  
  /// 警告色边框
  static const Border borderWarning = Border.fromBorderSide(
    BorderSide(color: AppColors.warning, width: normal),
  );
  
  /// 错误色边框
  static const Border borderError = Border.fromBorderSide(
    BorderSide(color: AppColors.error, width: normal),
  );
  
  /// 信息色边框
  static const Border borderInfo = Border.fromBorderSide(
    BorderSide(color: AppColors.info, width: normal),
  );

  // ==================== 单边边框 ====================
  
  /// 顶部边框
  static const Border borderTop = Border(
    top: BorderSide(color: AppColors.borderLight, width: normal),
  );
  
  /// 底部边框
  static const Border borderBottom = Border(
    bottom: BorderSide(color: AppColors.borderLight, width: normal),
  );
  
  /// 左侧边框
  static const Border borderLeft = Border(
    left: BorderSide(color: AppColors.borderLight, width: normal),
  );
  
  /// 右侧边框
  static const Border borderRight = Border(
    right: BorderSide(color: AppColors.borderLight, width: normal),
  );

  // ==================== 虚线边框 ====================
  
  /// 虚线边框样式（需要配合自定义画笔实现）
  static const List<double> dashPattern = [5, 3];
  static const List<double> dotPattern = [2, 2];

  // ==================== 组件专用边框 ====================
  
  /// 输入框边框
  static const OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: borderRadiusLg,
    borderSide: BorderSide(color: AppColors.borderLight, width: normal),
  );
  
  /// 输入框聚焦边框
  static const OutlineInputBorder inputBorderFocused = OutlineInputBorder(
    borderRadius: borderRadiusLg,
    borderSide: BorderSide(color: AppColors.primary, width: thick),
  );
  
  /// 输入框错误边框
  static const OutlineInputBorder inputBorderError = OutlineInputBorder(
    borderRadius: borderRadiusLg,
    borderSide: BorderSide(color: AppColors.error, width: thick),
  );
  
  /// 按钮边框
  static const RoundedRectangleBorder buttonBorder = RoundedRectangleBorder(
    borderRadius: borderRadiusLg,
  );
  
  /// 卡片边框
  static const RoundedRectangleBorder cardBorder = RoundedRectangleBorder(
    borderRadius: borderRadiusXl,
  );
  
  /// 对话框边框
  static const RoundedRectangleBorder dialogBorder = RoundedRectangleBorder(
    borderRadius: borderRadiusXl,
  );
  
  /// 底部弹窗边框
  static const RoundedRectangleBorder bottomSheetBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(radiusXl),
      topRight: Radius.circular(radiusXl),
    ),
  );

  // ==================== 工具方法 ====================
  
  /// 根据主题获取边框
  static Border getByTheme(BuildContext context, Border lightBorder, Border darkBorder) {
    return Theme.of(context).brightness == Brightness.light ? lightBorder : darkBorder;
  }
  
  /// 创建自定义边框
  static Border custom({
    Color? color,
    double? width,
    BorderStyle? style,
  }) {
    return Border.fromBorderSide(
      BorderSide(
        color: color ?? AppColors.borderLight,
        width: width ?? normal,
        style: style ?? BorderStyle.solid,
      ),
    );
  }
  
  /// 创建单边边框
  static Border side({
    BorderSide? top,
    BorderSide? bottom,
    BorderSide? left,
    BorderSide? right,
  }) {
    return Border(
      top: top ?? BorderSide.none,
      bottom: bottom ?? BorderSide.none,
      left: left ?? BorderSide.none,
      right: right ?? BorderSide.none,
    );
  }
  
  /// 创建圆角边框
  static BorderRadius radius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) {
      return BorderRadius.circular(all);
    }
    
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
    );
  }
  
  /// 创建顶部圆角
  static BorderRadius topRadius(double radius) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }
  
  /// 创建底部圆角
  static BorderRadius bottomRadius(double radius) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }
  
  /// 创建左侧圆角
  static BorderRadius leftRadius(double radius) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );
  }
  
  /// 创建右侧圆角
  static BorderRadius rightRadius(double radius) {
    return BorderRadius.only(
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }
  
  /// 创建输入框边框
  static OutlineInputBorder inputBorderCustom({
    Color? color,
    double? width,
    double? radius,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius ?? radiusLg),
      borderSide: BorderSide(
        color: color ?? AppColors.borderLight,
        width: width ?? normal,
      ),
    );
  }
  
  /// 创建形状边框
  static ShapeBorder shapeBorder({
    BorderRadius? borderRadius,
    BorderSide? side,
  }) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? borderRadiusLg,
      side: side ?? BorderSide.none,
    );
  }
}
