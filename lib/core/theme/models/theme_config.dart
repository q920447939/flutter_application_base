/// 主题配置数据模型
///
/// 定义主题配置的数据结构，支持：
/// - 基础主题配置
/// - 品牌主题定制
/// - 动态主题参数
/// - 主题扩展属性
library;

import 'package:flutter/material.dart';

/// 主题配置类
class ThemeConfig {
  /// 主题唯一标识
  final String id;
  
  /// 主题名称
  final String name;
  
  /// 主题描述
  final String description;
  
  /// 主题版本
  final String version;
  
  /// 是否为默认主题
  final bool isDefault;
  
  /// 主题模式（浅色/深色/自动）
  final AppThemeMode mode;
  
  /// 主色调配置
  final ColorConfig primaryColor;
  
  /// 辅助色配置
  final ColorConfig? secondaryColor;
  
  /// 字体配置
  final TypographyConfig typography;
  
  /// 间距配置
  final SpacingConfig spacing;
  
  /// 边框配置
  final BorderConfig borders;
  
  /// 阴影配置
  final ShadowConfig shadows;
  
  /// 动画配置
  final AnimationConfig animations;
  
  /// 品牌配置
  final BrandConfig? brand;
  
  /// 扩展属性
  final Map<String, dynamic> extensions;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;

  const ThemeConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    this.isDefault = false,
    required this.mode,
    required this.primaryColor,
    this.secondaryColor,
    required this.typography,
    required this.spacing,
    required this.borders,
    required this.shadows,
    required this.animations,
    this.brand,
    this.extensions = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建主题配置
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      mode: AppThemeMode.values[json['mode'] as int? ?? 2],
      primaryColor: ColorConfig.fromJson(json['primaryColor'] as Map<String, dynamic>),
      secondaryColor: json['secondaryColor'] != null 
          ? ColorConfig.fromJson(json['secondaryColor'] as Map<String, dynamic>)
          : null,
      typography: TypographyConfig.fromJson(json['typography'] as Map<String, dynamic>),
      spacing: SpacingConfig.fromJson(json['spacing'] as Map<String, dynamic>),
      borders: BorderConfig.fromJson(json['borders'] as Map<String, dynamic>),
      shadows: ShadowConfig.fromJson(json['shadows'] as Map<String, dynamic>),
      animations: AnimationConfig.fromJson(json['animations'] as Map<String, dynamic>),
      brand: json['brand'] != null 
          ? BrandConfig.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      extensions: json['extensions'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'isDefault': isDefault,
      'mode': mode.index,
      'primaryColor': primaryColor.toJson(),
      'secondaryColor': secondaryColor?.toJson(),
      'typography': typography.toJson(),
      'spacing': spacing.toJson(),
      'borders': borders.toJson(),
      'shadows': shadows.toJson(),
      'animations': animations.toJson(),
      'brand': brand?.toJson(),
      'extensions': extensions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改配置
  ThemeConfig copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    bool? isDefault,
    AppThemeMode? mode,
    ColorConfig? primaryColor,
    ColorConfig? secondaryColor,
    TypographyConfig? typography,
    SpacingConfig? spacing,
    BorderConfig? borders,
    ShadowConfig? shadows,
    AnimationConfig? animations,
    BrandConfig? brand,
    Map<String, dynamic>? extensions,
    DateTime? updatedAt,
  }) {
    return ThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      isDefault: isDefault ?? this.isDefault,
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      borders: borders ?? this.borders,
      shadows: shadows ?? this.shadows,
      animations: animations ?? this.animations,
      brand: brand ?? this.brand,
      extensions: extensions ?? this.extensions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeConfig && other.id == id && other.version == version;
  }

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() {
    return 'ThemeConfig(id: $id, name: $name, version: $version)';
  }
}

/// 主题模式枚举
enum AppThemeMode { 
  light, 
  dark, 
  system;
  
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return '浅色主题';
      case AppThemeMode.dark:
        return '深色主题';
      case AppThemeMode.system:
        return '跟随系统';
    }
  }
}

/// 颜色配置
class ColorConfig {
  final int value;
  final String? name;
  final String? description;

  const ColorConfig({
    required this.value,
    this.name,
    this.description,
  });

  Color get color => Color(value);

  factory ColorConfig.fromColor(Color color, {String? name, String? description}) {
    return ColorConfig(
      value: color.value,
      name: name,
      description: description,
    );
  }

  factory ColorConfig.fromJson(Map<String, dynamic> json) {
    return ColorConfig(
      value: json['value'] as int,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
      'description': description,
    };
  }
}

/// 字体配置
class TypographyConfig {
  final String fontFamily;
  final Map<String, double> fontSizes;
  final Map<String, FontWeight> fontWeights;
  final Map<String, double> lineHeights;

  const TypographyConfig({
    required this.fontFamily,
    required this.fontSizes,
    required this.fontWeights,
    required this.lineHeights,
  });

  factory TypographyConfig.fromJson(Map<String, dynamic> json) {
    return TypographyConfig(
      fontFamily: json['fontFamily'] as String,
      fontSizes: Map<String, double>.from(json['fontSizes'] as Map),
      fontWeights: (json['fontWeights'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, FontWeight.values[value as int]),
      ),
      lineHeights: Map<String, double>.from(json['lineHeights'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSizes': fontSizes,
      'fontWeights': fontWeights.map((key, value) => MapEntry(key, value.index)),
      'lineHeights': lineHeights,
    };
  }
}

/// 间距配置
class SpacingConfig {
  final Map<String, double> values;

  const SpacingConfig({required this.values});

  factory SpacingConfig.fromJson(Map<String, dynamic> json) {
    return SpacingConfig(
      values: Map<String, double>.from(json['values'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {'values': values};
  }
}

/// 边框配置
class BorderConfig {
  final Map<String, double> radiusValues;
  final Map<String, double> widthValues;

  const BorderConfig({
    required this.radiusValues,
    required this.widthValues,
  });

  factory BorderConfig.fromJson(Map<String, dynamic> json) {
    return BorderConfig(
      radiusValues: Map<String, double>.from(json['radiusValues'] as Map),
      widthValues: Map<String, double>.from(json['widthValues'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'radiusValues': radiusValues,
      'widthValues': widthValues,
    };
  }
}

/// 阴影配置
class ShadowConfig {
  final Map<String, Map<String, dynamic>> shadows;

  const ShadowConfig({required this.shadows});

  factory ShadowConfig.fromJson(Map<String, dynamic> json) {
    return ShadowConfig(
      shadows: Map<String, Map<String, dynamic>>.from(json['shadows'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {'shadows': shadows};
  }
}

/// 动画配置
class AnimationConfig {
  final Map<String, int> durations;
  final Map<String, String> curves;

  const AnimationConfig({
    required this.durations,
    required this.curves,
  });

  factory AnimationConfig.fromJson(Map<String, dynamic> json) {
    return AnimationConfig(
      durations: Map<String, int>.from(json['durations'] as Map),
      curves: Map<String, String>.from(json['curves'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durations': durations,
      'curves': curves,
    };
  }
}

/// 品牌配置
class BrandConfig {
  final String name;
  final String logo;
  final ColorConfig brandColor;
  final Map<String, dynamic> customProperties;

  const BrandConfig({
    required this.name,
    required this.logo,
    required this.brandColor,
    this.customProperties = const {},
  });

  factory BrandConfig.fromJson(Map<String, dynamic> json) {
    return BrandConfig(
      name: json['name'] as String,
      logo: json['logo'] as String,
      brandColor: ColorConfig.fromJson(json['brandColor'] as Map<String, dynamic>),
      customProperties: json['customProperties'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'brandColor': brandColor.toJson(),
      'customProperties': customProperties,
    };
  }
}
