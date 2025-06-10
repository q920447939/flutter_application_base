/// 阴影设计令牌
/// 
/// 定义应用中使用的所有阴影效果，包括：
/// - 卡片阴影
/// - 按钮阴影
/// - 浮动阴影
/// - 深度阴影
library;

import 'package:flutter/material.dart';
import 'colors.dart';

/// 应用阴影系统
class AppShadows {
  AppShadows._();

  // ==================== 基础阴影 ====================
  
  /// 无阴影
  static const List<BoxShadow> none = [];
  
  /// 极小阴影 (elevation 1)
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  /// 小阴影 (elevation 2)
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  /// 中等阴影 (elevation 4)
  static const List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 2),
      blurRadius: 3,
      spreadRadius: -1,
    ),
  ];
  
  /// 大阴影 (elevation 6)
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 3),
      blurRadius: 5,
      spreadRadius: -1,
    ),
  ];
  
  /// 超大阴影 (elevation 8)
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];
  
  /// 超超大阴影 (elevation 12)
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: -2,
    ),
  ];
  
  /// 巨大阴影 (elevation 16)
  static const List<BoxShadow> xxxl = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 8),
      blurRadius: 14,
      spreadRadius: -2,
    ),
  ];

  // ==================== 深色主题阴影 ====================
  
  /// 深色主题小阴影
  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  /// 深色主题中等阴影
  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  /// 深色主题大阴影
  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  // ==================== 特殊用途阴影 ====================
  
  /// 卡片阴影
  static const List<BoxShadow> card = md;
  
  /// 按钮阴影
  static const List<BoxShadow> button = sm;
  
  /// 按钮悬停阴影
  static const List<BoxShadow> buttonHover = md;
  
  /// 按钮按下阴影
  static const List<BoxShadow> buttonPressed = xs;
  
  /// 浮动操作按钮阴影
  static const List<BoxShadow> fab = lg;
  
  /// 浮动操作按钮悬停阴影
  static const List<BoxShadow> fabHover = xl;
  
  /// 对话框阴影
  static const List<BoxShadow> dialog = xxl;
  
  /// 底部弹窗阴影
  static const List<BoxShadow> bottomSheet = xl;
  
  /// 导航栏阴影
  static const List<BoxShadow> appBar = sm;
  
  /// 抽屉阴影
  static const List<BoxShadow> drawer = xl;
  
  /// 菜单阴影
  static const List<BoxShadow> menu = lg;
  
  /// 工具提示阴影
  static const List<BoxShadow> tooltip = sm;
  
  /// 下拉阴影
  static const List<BoxShadow> dropdown = md;

  // ==================== 彩色阴影 ====================
  
  /// 主色调阴影
  static List<BoxShadow> primary([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.primary.withOpacity(opacity),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// 成功色阴影
  static List<BoxShadow> success([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.success.withOpacity(opacity),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// 警告色阴影
  static List<BoxShadow> warning([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.warning.withOpacity(opacity),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// 错误色阴影
  static List<BoxShadow> error([double opacity = 0.3]) => [
    BoxShadow(
      color: AppColors.error.withOpacity(opacity),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // ==================== 内阴影效果 ====================
  
  /// 内阴影（通过边框模拟）
  static BoxDecoration innerShadow({
    Color color = AppColors.shadowLight,
    double blurRadius = 4,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxDecoration(
      border: Border.all(
        color: color,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: color,
          offset: offset,
          blurRadius: blurRadius,
          spreadRadius: -blurRadius,
        ),
      ],
    );
  }

  // ==================== 工具方法 ====================
  
  /// 根据主题获取阴影
  static List<BoxShadow> getByTheme(BuildContext context, List<BoxShadow> lightShadow, List<BoxShadow> darkShadow) {
    return Theme.of(context).brightness == Brightness.light ? lightShadow : darkShadow;
  }
  
  /// 创建自定义阴影
  static List<BoxShadow> custom({
    required Color color,
    required Offset offset,
    required double blurRadius,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
  
  /// 创建多层阴影
  static List<BoxShadow> layered(List<Map<String, dynamic>> layers) {
    return layers.map((layer) {
      return BoxShadow(
        color: layer['color'] ?? AppColors.shadowLight,
        offset: layer['offset'] ?? const Offset(0, 0),
        blurRadius: layer['blurRadius'] ?? 0,
        spreadRadius: layer['spreadRadius'] ?? 0,
      );
    }).toList();
  }
  
  /// 调整阴影透明度
  static List<BoxShadow> withOpacity(List<BoxShadow> shadows, double opacity) {
    return shadows.map((shadow) {
      return shadow.copyWith(
        color: shadow.color.withOpacity(opacity),
      );
    }).toList();
  }
  
  /// 调整阴影颜色
  static List<BoxShadow> withColor(List<BoxShadow> shadows, Color color) {
    return shadows.map((shadow) {
      return shadow.copyWith(color: color);
    }).toList();
  }
  
  /// 获取Material Design elevation对应的阴影
  static List<BoxShadow> fromElevation(double elevation) {
    if (elevation <= 0) return none;
    if (elevation <= 1) return xs;
    if (elevation <= 2) return sm;
    if (elevation <= 4) return md;
    if (elevation <= 6) return lg;
    if (elevation <= 8) return xl;
    if (elevation <= 12) return xxl;
    return xxxl;
  }
}
