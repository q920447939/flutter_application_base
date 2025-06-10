/// 颜色设计令牌
/// 
/// 定义应用中使用的所有颜色，包括：
/// - 主色调和辅助色
/// - 语义化颜色
/// - 中性色
/// - 状态颜色
library;

import 'package:flutter/material.dart';

/// 应用颜色系统
class AppColors {
  AppColors._();

  // ==================== 主色调 ====================
  
  /// 主色调 - 蓝色系
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  /// 辅助色 - 青色系
  static const Color secondary = Color(0xFF00BCD4);
  static const Color secondaryLight = Color(0xFF4DD0E1);
  static const Color secondaryDark = Color(0xFF0097A7);

  /// 强调色 - 橙色系
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFF57C00);

  // ==================== 语义化颜色 ====================
  
  /// 成功色 - 绿色系
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  /// 警告色 - 黄色系
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  
  /// 错误色 - 红色系
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  /// 信息色 - 蓝色系
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ==================== 中性色 ====================
  
  /// 白色
  static const Color white = Color(0xFFFFFFFF);
  
  /// 黑色
  static const Color black = Color(0xFF000000);
  
  /// 灰色系
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ==================== 背景色 ====================
  
  /// 浅色主题背景
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  /// 深色主题背景
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);

  // ==================== 文本颜色 ====================
  
  /// 浅色主题文本
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  
  /// 深色主题文本
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textDisabledDark = Color(0xFF666666);

  // ==================== 边框颜色 ====================
  
  /// 浅色主题边框
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFEEEEEE);
  
  /// 深色主题边框
  static const Color borderDark = Color(0xFF424242);
  static const Color dividerDark = Color(0xFF2D2D2D);

  // ==================== 阴影颜色 ====================
  
  /// 阴影色
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // ==================== 品牌颜色 ====================
  
  /// 社交媒体品牌色
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color youtube = Color(0xFFFF0000);
  static const Color wechat = Color(0xFF07C160);
  static const Color qq = Color(0xFF12B7F5);
  static const Color weibo = Color(0xFFE6162D);

  // ==================== 渐变色 ====================
  
  /// 主色调渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 辅助色渐变
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 成功色渐变
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 错误色渐变
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== 工具方法 ====================
  
  /// 获取颜色的透明度变体
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// 获取颜色的亮度变体
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// 获取颜色的暗度变体
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// 根据主题获取对应的颜色
  static Color getColorByTheme(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.light ? lightColor : darkColor;
  }
  
  /// 获取文本颜色
  static Color getTextColor(BuildContext context, {bool isPrimary = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isPrimary) {
      return isDark ? textPrimaryDark : textPrimaryLight;
    } else {
      return isDark ? textSecondaryDark : textSecondaryLight;
    }
  }
  
  /// 获取背景颜色
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? backgroundLight 
        : backgroundDark;
  }
  
  /// 获取表面颜色
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? surfaceLight 
        : surfaceDark;
  }
  
  /// 获取边框颜色
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? borderLight 
        : borderDark;
  }

  // ==================== 颜色调色板 ====================
  
  /// 蓝色调色板
  static const Map<int, Color> bluePalette = {
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(0xFF2196F3),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  };
  
  /// 绿色调色板
  static const Map<int, Color> greenPalette = {
    50: Color(0xFFE8F5E8),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF4CAF50),
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  };
  
  /// 红色调色板
  static const Map<int, Color> redPalette = {
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFF44336),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  };
}
