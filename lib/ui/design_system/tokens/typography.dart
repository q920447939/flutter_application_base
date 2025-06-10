/// 字体设计令牌
/// 
/// 定义应用中使用的所有字体样式，包括：
/// - 字体族
/// - 字体大小
/// - 字重
/// - 行高
/// - 字间距
library;

import 'package:flutter/material.dart';

/// 应用字体系统
class AppTypography {
  AppTypography._();

  // ==================== 字体族 ====================
  
  /// 默认字体族
  static const String defaultFontFamily = 'PingFang SC';
  
  /// 英文字体族
  static const String englishFontFamily = 'Roboto';
  
  /// 数字字体族
  static const String numberFontFamily = 'Roboto Mono';
  
  /// 代码字体族
  static const String codeFontFamily = 'Source Code Pro';

  // ==================== 字体大小 ====================
  
  /// 超大标题
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  
  /// 标题
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  
  /// 子标题
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  
  /// 标签
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  
  /// 正文
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  // ==================== 字重 ====================
  
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ==================== 行高 ====================
  
  /// 紧密行高
  static const double lineHeightTight = 1.2;
  
  /// 正常行高
  static const double lineHeightNormal = 1.4;
  
  /// 宽松行高
  static const double lineHeightLoose = 1.6;
  
  /// 超宽松行高
  static const double lineHeightExtraLoose = 1.8;

  // ==================== 字间距 ====================
  
  /// 紧密字间距
  static const double letterSpacingTight = -0.5;
  
  /// 正常字间距
  static const double letterSpacingNormal = 0.0;
  
  /// 宽松字间距
  static const double letterSpacingLoose = 0.5;
  
  /// 超宽松字间距
  static const double letterSpacingExtraLoose = 1.0;

  // ==================== 预定义文本样式 ====================
  
  /// 超大显示文本
  static const TextStyle displayLargeStyle = TextStyle(
    fontSize: displayLarge,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );
  
  /// 中等显示文本
  static const TextStyle displayMediumStyle = TextStyle(
    fontSize: displayMedium,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );
  
  /// 小显示文本
  static const TextStyle displaySmallStyle = TextStyle(
    fontSize: displaySmall,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 大标题
  static const TextStyle headlineLargeStyle = TextStyle(
    fontSize: headlineLarge,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 中等标题
  static const TextStyle headlineMediumStyle = TextStyle(
    fontSize: headlineMedium,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 小标题
  static const TextStyle headlineSmallStyle = TextStyle(
    fontSize: headlineSmall,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 大子标题
  static const TextStyle titleLargeStyle = TextStyle(
    fontSize: titleLarge,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 中等子标题
  static const TextStyle titleMediumStyle = TextStyle(
    fontSize: titleMedium,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 小子标题
  static const TextStyle titleSmallStyle = TextStyle(
    fontSize: titleSmall,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 大正文
  static const TextStyle bodyLargeStyle = TextStyle(
    fontSize: bodyLarge,
    fontWeight: regular,
    height: lineHeightLoose,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 中等正文
  static const TextStyle bodyMediumStyle = TextStyle(
    fontSize: bodyMedium,
    fontWeight: regular,
    height: lineHeightLoose,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 小正文
  static const TextStyle bodySmallStyle = TextStyle(
    fontSize: bodySmall,
    fontWeight: regular,
    height: lineHeightLoose,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 大标签
  static const TextStyle labelLargeStyle = TextStyle(
    fontSize: labelLarge,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingLoose,
  );
  
  /// 中等标签
  static const TextStyle labelMediumStyle = TextStyle(
    fontSize: labelMedium,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingLoose,
  );
  
  /// 小标签
  static const TextStyle labelSmallStyle = TextStyle(
    fontSize: labelSmall,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingLoose,
  );

  // ==================== 特殊用途文本样式 ====================
  
  /// 按钮文本
  static const TextStyle buttonStyle = TextStyle(
    fontSize: labelLarge,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingLoose,
  );
  
  /// 链接文本
  static const TextStyle linkStyle = TextStyle(
    fontSize: bodyMedium,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    decoration: TextDecoration.underline,
  );
  
  /// 代码文本
  static const TextStyle codeStyle = TextStyle(
    fontSize: bodySmall,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    fontFamily: codeFontFamily,
  );
  
  /// 数字文本
  static const TextStyle numberStyle = TextStyle(
    fontSize: bodyMedium,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    fontFamily: numberFontFamily,
  );
  
  /// 价格文本
  static const TextStyle priceStyle = TextStyle(
    fontSize: titleLarge,
    fontWeight: bold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    fontFamily: numberFontFamily,
  );
  
  /// 错误文本
  static const TextStyle errorStyle = TextStyle(
    fontSize: bodySmall,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );
  
  /// 提示文本
  static const TextStyle hintStyle = TextStyle(
    fontSize: bodyMedium,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  // ==================== 工具方法 ====================
  
  /// 获取带颜色的文本样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// 获取带字重的文本样式
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// 获取带字体大小的文本样式
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// 获取带行高的文本样式
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }
  
  /// 获取带字间距的文本样式
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }
  
  /// 获取带装饰的文本样式
  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }
  
  /// 获取响应式字体大小
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 根据屏幕宽度调整字体大小
    if (screenWidth < 360) {
      return baseFontSize * 0.9;
    } else if (screenWidth > 600) {
      return baseFontSize * 1.1;
    }
    
    return baseFontSize;
  }
  
  /// 获取主题相关的文本样式
  static TextStyle getThemeTextStyle(BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    return baseStyle.copyWith(
      color: theme.textTheme.bodyMedium?.color,
      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
    );
  }
}
