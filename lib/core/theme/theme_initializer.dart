/// 主题初始化器
///
/// 负责主题系统的完整初始化流程，包括：
/// - 主题配置加载与验证
/// - 默认主题设置
/// - 远程主题配置同步
/// - 主题服务初始化
/// - 主题缓存管理
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import 'models/theme_config.dart';
import 'theme_service.dart';
import 'theme_config_manager.dart';
import 'theme_cache_service.dart';
import '../../ui/design_system/tokens/index.dart';

/// 主题初始化结果
class ThemeInitializationResult {
  final bool success;
  final String? error;
  final Duration duration;
  final ThemeConfig? appliedTheme;

  const ThemeInitializationResult({
    required this.success,
    this.error,
    required this.duration,
    this.appliedTheme,
  });

  factory ThemeInitializationResult.success({
    required Duration duration,
    ThemeConfig? appliedTheme,
  }) {
    return ThemeInitializationResult(
      success: true,
      duration: duration,
      appliedTheme: appliedTheme,
    );
  }

  factory ThemeInitializationResult.failure({
    required String error,
    required Duration duration,
  }) {
    return ThemeInitializationResult(
      success: false,
      error: error,
      duration: duration,
    );
  }
}

/// 主题初始化器
class ThemeInitializer {
  static ThemeInitializer? _instance;
  static ThemeInitializer get instance => _instance ??= ThemeInitializer._();

  ThemeInitializer._();

  /// 是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化主题系统
  Future<ThemeInitializationResult> initialize({
    bool forceReload = false,
    bool enableRemoteSync = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 如果已初始化且不强制重载，直接返回成功
      if (_isInitialized && !forceReload) {
        return ThemeInitializationResult.success(
          duration: stopwatch.elapsed,
          appliedTheme: ThemeService.instance.currentThemeConfig,
        );
      }

      debugPrint('🎨 开始初始化主题系统...');

      // 1. 初始化主题缓存服务
      await _initializeThemeCacheService();

      // 2. 初始化主题配置管理器
      await _initializeThemeConfigManager();

      // 3. 加载主题配置
      final themeConfig = await _loadThemeConfiguration();

      // 4. 验证主题配置
      final validatedConfig = await _validateThemeConfiguration(themeConfig);

      // 5. 初始化主题服务
      await _initializeThemeService(validatedConfig);

      // 6. 应用主题到系统
      await _applyThemeToSystem(validatedConfig);

      // 7. 启动后台同步（如果启用）
      if (enableRemoteSync) {
        _startBackgroundSync();
      }

      // 8. 注册主题变化监听器
      _registerThemeChangeListeners();

      _isInitialized = true;
      stopwatch.stop();

      debugPrint('✅ 主题系统初始化完成，耗时: ${stopwatch.elapsedMilliseconds}ms');

      return ThemeInitializationResult.success(
        duration: stopwatch.elapsed,
        appliedTheme: validatedConfig,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('❌ 主题系统初始化失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');

      // 使用默认主题作为降级方案
      await _applyFallbackTheme();

      return ThemeInitializationResult.failure(
        error: e.toString(),
        duration: stopwatch.elapsed,
      );
    }
  }

  /// 初始化主题缓存服务
  Future<void> _initializeThemeCacheService() async {
    if (!Get.isRegistered<ThemeCacheService>()) {
      Get.put<ThemeCacheService>(ThemeCacheService.instance);
    }
    await ThemeCacheService.instance.initialize();
  }

  /// 初始化主题配置管理器
  Future<void> _initializeThemeConfigManager() async {
    if (!Get.isRegistered<ThemeConfigManager>()) {
      Get.put<ThemeConfigManager>(ThemeConfigManager.instance);
    }
    await ThemeConfigManager.instance.initialize();
  }

  /// 加载主题配置
  Future<ThemeConfig> _loadThemeConfiguration() async {
    // 1. 尝试从缓存加载
    final cachedConfig = await ThemeCacheService.instance.getCachedThemeAsync();
    if (cachedConfig != null) {
      debugPrint('📦 从缓存加载主题配置: ${cachedConfig.name}');
      return cachedConfig;
    }

    // 2. 尝试从本地存储加载
    final localConfig = await _loadLocalThemeConfig();
    if (localConfig != null) {
      debugPrint('💾 从本地存储加载主题配置: ${localConfig.name}');
      return localConfig;
    }

    // 3. 使用默认主题配置
    debugPrint('🔧 使用默认主题配置');
    return _createDefaultThemeConfig();
  }

  /// 从本地存储加载主题配置
  Future<ThemeConfig?> _loadLocalThemeConfig() async {
    try {
      final configJson = StorageService.instance
          .getAppSetting<Map<String, dynamic>>('theme_config');
      if (configJson != null) {
        return ThemeConfig.fromJson(configJson);
      }
    } catch (e) {
      debugPrint('⚠️ 加载本地主题配置失败: $e');
    }
    return null;
  }

  /// 创建默认主题配置
  ThemeConfig _createDefaultThemeConfig() {
    final now = DateTime.now();
    return ThemeConfig(
      id: 'default',
      name: '默认主题',
      description: '系统默认主题配置',
      version: '1.0.0',
      isDefault: true,
      mode: AppThemeMode.system,
      primaryColor: ColorConfig.fromColor(AppColors.primary, name: '主色调'),
      secondaryColor: ColorConfig.fromColor(AppColors.secondary, name: '辅助色'),
      typography: TypographyConfig(
        fontFamily: 'System',
        fontSizes: {
          'xs': 12.0,
          'sm': 14.0,
          'base': 16.0,
          'lg': 18.0,
          'xl': 20.0,
          '2xl': 24.0,
          '3xl': 30.0,
        },
        fontWeights: {
          'light': FontWeight.w300,
          'normal': FontWeight.w400,
          'medium': FontWeight.w500,
          'semibold': FontWeight.w600,
          'bold': FontWeight.w700,
        },
        lineHeights: {'tight': 1.2, 'normal': 1.5, 'relaxed': 1.8},
      ),
      spacing: SpacingConfig(
        values: {
          'xs': 4.0,
          'sm': 8.0,
          'md': 16.0,
          'lg': 24.0,
          'xl': 32.0,
          '2xl': 48.0,
        },
      ),
      borders: BorderConfig(
        radiusValues: {'sm': 4.0, 'md': 8.0, 'lg': 12.0, 'xl': 16.0},
        widthValues: {'thin': 1.0, 'medium': 2.0, 'thick': 4.0},
      ),
      shadows: const ShadowConfig(shadows: {}),
      animations: AnimationConfig(
        durations: {'fast': 150, 'normal': 300, 'slow': 500},
        curves: {'ease': 'easeInOut', 'bounce': 'bounceOut'},
      ),
      extensions: {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 验证主题配置
  Future<ThemeConfig> _validateThemeConfiguration(ThemeConfig config) async {
    // 这里可以添加主题配置的验证逻辑
    // 例如：检查必需字段、验证颜色值、检查版本兼容性等

    // 简单验证示例
    if (config.name.isEmpty) {
      throw Exception('主题名称不能为空');
    }

    if (config.primaryColor.value == 0) {
      throw Exception('主色调不能为空');
    }

    return config;
  }

  /// 初始化主题服务
  Future<void> _initializeThemeService(ThemeConfig config) async {
    if (!Get.isRegistered<ThemeService>()) {
      Get.put<ThemeService>(ThemeService.instance);
    }

    await ThemeService.instance.initializeWithConfig(config);
  }

  /// 应用主题到系统
  Future<void> _applyThemeToSystem(ThemeConfig config) async {
    await ThemeService.instance.applyThemeConfig(config);
  }

  /// 启动后台同步
  void _startBackgroundSync() {
    // 这里可以启动后台任务来同步远程主题配置
    debugPrint('🔄 启动主题配置后台同步');
  }

  /// 注册主题变化监听器
  void _registerThemeChangeListeners() {
    // 监听系统主题变化
    WidgetsBinding
        .instance
        .platformDispatcher
        .onPlatformBrightnessChanged = () {
      ThemeService.instance.handleSystemThemeChange();
    };
  }

  /// 应用降级主题
  Future<void> _applyFallbackTheme() async {
    try {
      final fallbackConfig = _createDefaultThemeConfig();
      await _initializeThemeService(fallbackConfig);
      await _applyThemeToSystem(fallbackConfig);
      debugPrint('🛡️ 已应用降级主题');
    } catch (e) {
      debugPrint('❌ 应用降级主题失败: $e');
    }
  }

  /// 重新初始化主题系统
  Future<ThemeInitializationResult> reinitialize() async {
    _isInitialized = false;
    return initialize(forceReload: true);
  }

  /// 获取初始化状态信息
  Map<String, dynamic> getInitializationInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentTheme': ThemeService.instance.currentThemeConfig?.name,
      'themeMode': ThemeService.instance.themeMode.displayName,
    };
  }
}
