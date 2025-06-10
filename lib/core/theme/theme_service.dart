/// 主题服务
///
/// 提供主题管理功能，包括：
/// - 主题切换
/// - 主题持久化
/// - 动态主题
/// - 品牌主题定制
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import '../../ui/design_system/tokens/index.dart';

/// 主题模式枚举
enum AppThemeMode { light, dark, system }

/// 主题服务类
class ThemeService extends GetxController {
  static ThemeService? _instance;

  /// 当前主题模式
  final Rx<AppThemeMode> _themeMode = AppThemeMode.system.obs;
  AppThemeMode get themeMode => _themeMode.value;

  /// 是否为深色主题
  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  /// 当前主题数据
  final Rx<ThemeData> _currentTheme = ThemeData.light().obs;
  ThemeData get currentTheme => _currentTheme.value;

  /// 当前深色主题数据
  final Rx<ThemeData> _currentDarkTheme = ThemeData.dark().obs;
  ThemeData get currentDarkTheme => _currentDarkTheme.value;

  /// 主题颜色
  final Rx<Color> _primaryColor = Colors.blue.obs;
  Color get primaryColor => _primaryColor.value;

  ThemeService._internal();

  /// 单例模式
  static ThemeService get instance {
    _instance ??= ThemeService._internal();
    return _instance!;
  }

  /// 初始化主题服务
  Future<void> initialize() async {
    // 从存储中加载主题设置
    await _loadThemeSettings();

    // 监听系统主题变化
    _listenToSystemTheme();

    // 更新主题
    _updateTheme();
  }

  /// 从存储中加载主题设置
  Future<void> _loadThemeSettings() async {
    try {
      // 加载主题模式
      final themeModeIndex =
          StorageService.instance.getAppSetting<int>('theme_mode') ?? 2;
      _themeMode.value = AppThemeMode.values[themeModeIndex];

      // 加载主题颜色
      final colorValue = StorageService.instance.getAppSetting<int>(
        'primary_color',
      );
      if (colorValue != null) {
        _primaryColor.value = Color(colorValue);
      }
    } catch (e) {
      print('加载主题设置失败: $e');
    }
  }

  /// 保存主题设置
  Future<void> _saveThemeSettings() async {
    try {
      await StorageService.instance.setAppSetting(
        'theme_mode',
        _themeMode.value.index,
      );
      await StorageService.instance.setAppSetting(
        'primary_color',
        _primaryColor.value.value,
      );
    } catch (e) {
      // 使用调试输出，生产环境应使用日志框架
      debugPrint('保存主题设置失败: $e');
    }
  }

  /// 监听系统主题变化
  void _listenToSystemTheme() {
    // 监听系统亮度变化
    WidgetsBinding
        .instance
        .platformDispatcher
        .onPlatformBrightnessChanged = () {
      if (_themeMode.value == AppThemeMode.system) {
        _updateTheme();
      }
    };
  }

  /// 更新主题
  void _updateTheme() {
    bool isDark;

    switch (_themeMode.value) {
      case AppThemeMode.light:
        isDark = false;
        break;
      case AppThemeMode.dark:
        isDark = true;
        break;
      case AppThemeMode.system:
        isDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        break;
    }

    _isDarkMode.value = isDark;

    // 更新主题数据
    _currentTheme.value = _buildLightTheme();
    _currentDarkTheme.value = _buildDarkTheme();

    // 更新GetX主题
    Get.changeTheme(isDark ? _currentDarkTheme.value : _currentTheme.value);
  }

  /// 构建浅色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor.value,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusLg,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: AppBorders.inputBorder,
        contentPadding: AppSpacing.inputPadding,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusXl),
      ),
    );
  }

  /// 构建深色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor.value,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusLg,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: AppBorders.inputBorder,
        contentPadding: AppSpacing.inputPadding,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusXl),
      ),
    );
  }

  /// 切换主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode.value = mode;
    _updateTheme();
    await _saveThemeSettings();
  }

  /// 切换到浅色主题
  Future<void> setLightTheme() async {
    await setThemeMode(AppThemeMode.light);
  }

  /// 切换到深色主题
  Future<void> setDarkTheme() async {
    await setThemeMode(AppThemeMode.dark);
  }

  /// 切换到系统主题
  Future<void> setSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// 切换主题（浅色/深色）
  Future<void> toggleTheme() async {
    if (_themeMode.value == AppThemeMode.system) {
      // 如果当前是系统主题，根据当前显示的主题切换
      await setThemeMode(
        _isDarkMode.value ? AppThemeMode.light : AppThemeMode.dark,
      );
    } else {
      // 在浅色和深色之间切换
      await setThemeMode(
        _themeMode.value == AppThemeMode.light
            ? AppThemeMode.dark
            : AppThemeMode.light,
      );
    }
  }

  /// 设置主题颜色
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor.value = color;
    _updateTheme();
    await _saveThemeSettings();
  }

  /// 预定义的主题颜色
  static const List<Color> predefinedColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  /// 获取主题模式名称
  String getThemeModeName() {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        return '浅色主题';
      case AppThemeMode.dark:
        return '深色主题';
      case AppThemeMode.system:
        return '跟随系统';
    }
  }

  /// 获取当前主题信息
  Map<String, dynamic> getThemeInfo() {
    return {
      'mode': _themeMode.value.name,
      'isDark': _isDarkMode.value,
      'primaryColor': _primaryColor.value.value,
      'modeName': getThemeModeName(),
    };
  }

  /// 重置主题设置
  Future<void> resetTheme() async {
    _themeMode.value = AppThemeMode.system;
    _primaryColor.value = Colors.blue;
    _updateTheme();
    await _saveThemeSettings();
  }
}
