/// 主题配置管理器
///
/// 负责主题配置的管理，包括：
/// - 本地主题配置管理
/// - 远程主题配置同步
/// - 主题配置验证
/// - 主题模板管理
/// - 品牌主题定制
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import '../network/network_service.dart';
import 'models/theme_config.dart';
import 'theme_cache_service.dart';

/// 主题配置管理器
class ThemeConfigManager extends GetxController {
  static ThemeConfigManager? _instance;
  static ThemeConfigManager get instance =>
      _instance ??= ThemeConfigManager._();

  ThemeConfigManager._();

  /// 当前主题配置
  final Rx<ThemeConfig?> _currentConfig = Rx<ThemeConfig?>(null);
  ThemeConfig? get currentConfig => _currentConfig.value;

  /// 可用主题配置列表
  final RxList<ThemeConfig> _availableConfigs = <ThemeConfig>[].obs;
  List<ThemeConfig> get availableConfigs => _availableConfigs;

  /// 是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 远程配置URL
  String? _remoteConfigUrl;

  /// 初始化配置管理器
  Future<void> initialize({String? remoteConfigUrl}) async {
    if (_isInitialized) return;

    _remoteConfigUrl = remoteConfigUrl;

    // 加载本地配置
    await _loadLocalConfigs();

    _isInitialized = true;
    debugPrint('✅ 主题配置管理器初始化完成');
  }

  /// 加载本地主题配置
  Future<void> _loadLocalConfigs() async {
    try {
      // 从存储中加载配置列表
      final configsJson = StorageService.instance.getAppSetting<List<dynamic>>(
        'theme_configs',
      );
      if (configsJson != null) {
        final configs =
            configsJson
                .map(
                  (json) => ThemeConfig.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        _availableConfigs.assignAll(configs);
      }

      // 加载当前配置
      final currentConfigJson = StorageService.instance
          .getAppSetting<Map<String, dynamic>>('current_theme_config');
      if (currentConfigJson != null) {
        _currentConfig.value = ThemeConfig.fromJson(currentConfigJson);
      }

      debugPrint('📦 已加载 ${_availableConfigs.length} 个本地主题配置');
    } catch (e) {
      debugPrint('⚠️ 加载本地主题配置失败: $e');
    }
  }

  /// 合并远程配置到本地
  Future<void> _mergeRemoteConfigs(List<ThemeConfig> remoteConfigs) async {
    final localConfigIds = _availableConfigs.map((c) => c.id).toSet();
    final newConfigs = <ThemeConfig>[];

    for (final remoteConfig in remoteConfigs) {
      if (!localConfigIds.contains(remoteConfig.id)) {
        // 新配置，直接添加
        newConfigs.add(remoteConfig);
      } else {
        // 已存在的配置，检查版本并更新
        final localConfig = _availableConfigs.firstWhere(
          (c) => c.id == remoteConfig.id,
        );
        if (_isNewerVersion(remoteConfig.version, localConfig.version)) {
          // 更新现有配置
          final index = _availableConfigs.indexWhere(
            (c) => c.id == remoteConfig.id,
          );
          _availableConfigs[index] = remoteConfig;
        }
      }
    }

    if (newConfigs.isNotEmpty) {
      _availableConfigs.addAll(newConfigs);
      await _saveLocalConfigs();
    }
  }

  /// 检查版本是否更新
  bool _isNewerVersion(String newVersion, String currentVersion) {
    // 简单的版本比较，实际项目中可能需要更复杂的版本比较逻辑
    final newParts = newVersion.split('.').map(int.parse).toList();
    final currentParts = currentVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < newParts.length && i < currentParts.length; i++) {
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }

    return newParts.length > currentParts.length;
  }

  /// 保存本地配置
  Future<void> _saveLocalConfigs() async {
    try {
      final configsJson = _availableConfigs.map((c) => c.toJson()).toList();
      await StorageService.instance.setAppSetting('theme_configs', configsJson);

      if (_currentConfig.value != null) {
        await StorageService.instance.setAppSetting(
          'current_theme_config',
          _currentConfig.value!.toJson(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ 保存本地主题配置失败: $e');
    }
  }

  /// 设置当前主题配置
  Future<void> setCurrentConfig(ThemeConfig config) async {
    _currentConfig.value = config;
    await _saveLocalConfigs();

    // 缓存当前配置
    await ThemeCacheService.instance.cacheTheme(config);

    debugPrint('🎨 已设置当前主题: ${config.name}');
  }

  /// 添加主题配置
  Future<void> addConfig(ThemeConfig config) async {
    // 检查是否已存在
    final existingIndex = _availableConfigs.indexWhere(
      (c) => c.id == config.id,
    );
    if (existingIndex != -1) {
      // 更新现有配置
      _availableConfigs[existingIndex] = config;
    } else {
      // 添加新配置
      _availableConfigs.add(config);
    }

    await _saveLocalConfigs();
    debugPrint('➕ 已添加主题配置: ${config.name}');
  }

  /// 删除主题配置
  Future<void> removeConfig(String configId) async {
    _availableConfigs.removeWhere((c) => c.id == configId);

    // 如果删除的是当前配置，重置为默认配置
    if (_currentConfig.value?.id == configId) {
      final defaultConfig = _availableConfigs.firstWhereOrNull(
        (c) => c.isDefault,
      );
      _currentConfig.value = defaultConfig;
    }

    await _saveLocalConfigs();
    debugPrint('🗑️ 已删除主题配置: $configId');
  }

  /// 获取主题配置
  ThemeConfig? getConfig(String configId) {
    return _availableConfigs.firstWhereOrNull((c) => c.id == configId);
  }

  /// 获取默认主题配置
  ThemeConfig? getDefaultConfig() {
    return _availableConfigs.firstWhereOrNull((c) => c.isDefault);
  }

  /// 创建自定义主题配置
  ThemeConfig createCustomConfig({
    required String name,
    required String description,
    required Color primaryColor,
    Color? secondaryColor,
    AppThemeMode mode = AppThemeMode.system,
    Map<String, dynamic> extensions = const {},
  }) {
    final now = DateTime.now();
    final id = 'custom_${now.millisecondsSinceEpoch}';

    return ThemeConfig(
      id: id,
      name: name,
      description: description,
      version: '1.0.0',
      isDefault: false,
      mode: mode,
      primaryColor: ColorConfig.fromColor(primaryColor),
      secondaryColor:
          secondaryColor != null ? ColorConfig.fromColor(secondaryColor) : null,
      typography: _createDefaultTypography(),
      spacing: _createDefaultSpacing(),
      borders: _createDefaultBorders(),
      shadows: _createDefaultShadows(),
      animations: _createDefaultAnimations(),
      extensions: extensions,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建默认字体配置
  TypographyConfig _createDefaultTypography() {
    return TypographyConfig(
      fontFamily: 'System',
      fontSizes: {
        'xs': 12.0,
        'sm': 14.0,
        'base': 16.0,
        'lg': 18.0,
        'xl': 20.0,
        '2xl': 24.0,
      },
      fontWeights: {
        'light': FontWeight.w300,
        'normal': FontWeight.w400,
        'medium': FontWeight.w500,
        'bold': FontWeight.w700,
      },
      lineHeights: {'tight': 1.2, 'normal': 1.5, 'relaxed': 1.8},
    );
  }

  /// 创建默认间距配置
  SpacingConfig _createDefaultSpacing() {
    return SpacingConfig(
      values: {'xs': 4.0, 'sm': 8.0, 'md': 16.0, 'lg': 24.0, 'xl': 32.0},
    );
  }

  /// 创建默认边框配置
  BorderConfig _createDefaultBorders() {
    return BorderConfig(
      radiusValues: {'sm': 4.0, 'md': 8.0, 'lg': 12.0, 'xl': 16.0},
      widthValues: {'thin': 1.0, 'medium': 2.0, 'thick': 4.0},
    );
  }

  /// 创建默认阴影配置
  ShadowConfig _createDefaultShadows() {
    return const ShadowConfig(shadows: {});
  }

  /// 创建默认动画配置
  AnimationConfig _createDefaultAnimations() {
    return AnimationConfig(
      durations: {'fast': 150, 'normal': 300, 'slow': 500},
      curves: {'ease': 'easeInOut', 'bounce': 'bounceOut'},
    );
  }

  /// 导出主题配置
  Map<String, dynamic> exportConfig(String configId) {
    final config = getConfig(configId);
    if (config == null) {
      throw Exception('主题配置不存在: $configId');
    }
    return config.toJson();
  }

  /// 导入主题配置
  Future<void> importConfig(Map<String, dynamic> configJson) async {
    final config = ThemeConfig.fromJson(configJson);
    await addConfig(config);
  }

  /// 获取配置统计信息
  Map<String, dynamic> getConfigStats() {
    return {
      'totalConfigs': _availableConfigs.length,
      'customConfigs': _availableConfigs.where((c) => !c.isDefault).length,
      'defaultConfigs': _availableConfigs.where((c) => c.isDefault).length,
      'currentConfig': _currentConfig.value?.name,
    };
  }
}
