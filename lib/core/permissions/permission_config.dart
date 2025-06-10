/// 权限配置管理
///
/// 提供权限配置的定义、加载、缓存和管理功能
library;

import 'dart:convert';
import 'package:flutter/services.dart';
import '../storage/storage_service.dart';
import '../network/network_service.dart';
import 'permission_service.dart';
import 'platform_detector.dart';

/// 权限配置项
class PermissionConfig {
  /// 权限类型
  final AppPermission permission;

  /// 权限重要性级别
  final PermissionPriority priority;

  /// 触发场景列表
  final List<PermissionTrigger> triggers;

  /// 支持的平台列表
  final List<PlatformType> supportedPlatforms;

  /// 权限说明文本（可自定义）
  final String? customTitle;
  final String? customDescription;

  /// 是否允许跳过（仅对可选权限有效）
  final bool allowSkip;

  /// 权限被拒绝后的处理策略
  final PermissionDeniedStrategy deniedStrategy;

  /// 最大重试次数
  final int maxRetryCount;

  /// 权限相关的页面路由（如果有特定页面需要此权限）
  final List<String> relatedRoutes;

  const PermissionConfig({
    required this.permission,
    required this.priority,
    required this.triggers,
    required this.supportedPlatforms,
    this.customTitle,
    this.customDescription,
    this.allowSkip = true,
    this.deniedStrategy = PermissionDeniedStrategy.showDialog,
    this.maxRetryCount = 3,
    this.relatedRoutes = const [],
  });

  /// 从JSON创建配置
  factory PermissionConfig.fromJson(Map<String, dynamic> json) {
    return PermissionConfig(
      permission: AppPermission.values.firstWhere(
        (e) => e.toString().split('.').last == json['permission'],
      ),
      priority: PermissionPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      triggers:
          (json['triggers'] as List)
              .map(
                (e) => PermissionTrigger.values.firstWhere(
                  (trigger) => trigger.toString().split('.').last == e,
                ),
              )
              .toList(),
      supportedPlatforms:
          (json['supportedPlatforms'] as List)
              .map(
                (e) => PlatformType.values.firstWhere(
                  (platform) => platform.toString().split('.').last == e,
                ),
              )
              .toList(),
      customTitle: json['customTitle'],
      customDescription: json['customDescription'],
      allowSkip: json['allowSkip'] ?? true,
      deniedStrategy: PermissionDeniedStrategy.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['deniedStrategy'] ?? 'showDialog'),
      ),
      maxRetryCount: json['maxRetryCount'] ?? 3,
      relatedRoutes: List<String>.from(json['relatedRoutes'] ?? []),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'permission': permission.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'triggers': triggers.map((e) => e.toString().split('.').last).toList(),
      'supportedPlatforms':
          supportedPlatforms.map((e) => e.toString().split('.').last).toList(),
      'customTitle': customTitle,
      'customDescription': customDescription,
      'allowSkip': allowSkip,
      'deniedStrategy': deniedStrategy.toString().split('.').last,
      'maxRetryCount': maxRetryCount,
      'relatedRoutes': relatedRoutes,
    };
  }

  /// 获取权限标题（优先使用自定义标题）
  String get title => customTitle ?? permission.name;

  /// 获取权限描述（优先使用自定义描述）
  String get description => customDescription ?? permission.description;

  /// 是否为必要权限
  bool get isRequired => priority == PermissionPriority.required;

  /// 是否为可选权限
  bool get isOptional => priority == PermissionPriority.optional;

  /// 是否在当前平台支持
  bool get isSupportedOnCurrentPlatform {
    final currentPlatform = PlatformDetector.instance.currentPlatform;
    return supportedPlatforms.contains(currentPlatform);
  }

  /// 是否包含指定触发场景
  bool hasTrigger(PermissionTrigger trigger) {
    return triggers.contains(trigger);
  }

  /// 是否与指定路由相关
  bool isRelatedToRoute(String route) {
    return relatedRoutes.contains(route);
  }
}

/// 权限被拒绝后的处理策略
enum PermissionDeniedStrategy {
  showDialog, // 显示对话框
  showSnackbar, // 显示提示条
  exitApp, // 退出应用（仅限必要权限）
  disableFeature, // 禁用相关功能
  silent, // 静默处理
}

/// 权限配置管理器
class PermissionConfigManager {
  static PermissionConfigManager? _instance;

  PermissionConfigManager._internal();

  /// 单例模式
  static PermissionConfigManager get instance {
    _instance ??= PermissionConfigManager._internal();
    return _instance!;
  }

  /// 权限配置列表
  List<PermissionConfig> _configs = [];

  /// 配置缓存键
  static const String _cacheKey = 'permission_configs';

  /// 远程配置URL（可配置）
  String? _remoteConfigUrl;

  /// 获取所有权限配置
  List<PermissionConfig> get configs => List.unmodifiable(_configs);

  /// 设置远程配置URL
  void setRemoteConfigUrl(String url) {
    _remoteConfigUrl = url;
  }

  /// 初始化权限配置
  Future<void> initialize({
    String? remoteConfigUrl,
    bool useCache = true,
  }) async {
    if (remoteConfigUrl != null) {
      _remoteConfigUrl = remoteConfigUrl;
    }

    // 1. 尝试从缓存加载
    if (useCache) {
      await _loadFromCache();
    }

    // 2. 如果缓存为空，从本地资源加载默认配置
    if (_configs.isEmpty) {
      await _loadDefaultConfigs();
    }

    // 3. 尝试从远程加载最新配置
    if (_remoteConfigUrl != null) {
      await _loadFromRemote();
    }

    // 4. 过滤当前平台支持的权限
    _filterSupportedConfigs();
  }

  /// 从缓存加载配置
  Future<void> _loadFromCache() async {
    try {
      final cachedData = StorageService.instance.getString(_cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        _configs =
            jsonList.map((json) => PermissionConfig.fromJson(json)).toList();
      }
    } catch (e) {
      // 缓存加载失败，忽略错误
    }
  }

  /// 加载默认配置
  Future<void> _loadDefaultConfigs() async {
    try {
      final String configString = await rootBundle.loadString(
        'assets/config/permission_config.json',
      );
      final Map<String, dynamic> configData = jsonDecode(configString);
      final List<dynamic> permissionsList = configData['permissions'];

      _configs =
          permissionsList
              .map((json) => PermissionConfig.fromJson(json))
              .toList();
    } catch (e) {
      // 如果没有配置文件，使用硬编码的默认配置
      _configs = _getHardcodedDefaultConfigs();
    }
  }

  /// 从远程加载配置
  Future<void> _loadFromRemote() async {
    try {
      final response = await NetworkService.instance.get(_remoteConfigUrl!);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> permissionsList = response.data['permissions'];
        final remoteConfigs =
            permissionsList
                .map((json) => PermissionConfig.fromJson(json))
                .toList();

        // 合并远程配置（远程配置优先）
        _mergeConfigs(remoteConfigs);

        // 缓存最新配置
        await _saveToCache();
      }
    } catch (e) {
      // 远程加载失败，使用现有配置
    }
  }

  /// 合并配置
  void _mergeConfigs(List<PermissionConfig> remoteConfigs) {
    final Map<AppPermission, PermissionConfig> configMap = {};

    // 先添加本地配置
    for (final config in _configs) {
      configMap[config.permission] = config;
    }

    // 远程配置覆盖本地配置
    for (final config in remoteConfigs) {
      configMap[config.permission] = config;
    }

    _configs = configMap.values.toList();
  }

  /// 过滤当前平台支持的配置
  void _filterSupportedConfigs() {
    _configs =
        _configs
            .where((config) => config.isSupportedOnCurrentPlatform)
            .toList();
  }

  /// 保存到缓存
  Future<void> _saveToCache() async {
    try {
      final jsonList = _configs.map((config) => config.toJson()).toList();
      await StorageService.instance.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // 缓存保存失败，忽略错误
    }
  }

  /// 获取硬编码的默认配置
  List<PermissionConfig> _getHardcodedDefaultConfigs() {
    return [
      // 移动端必要权限
      const PermissionConfig(
        permission: AppPermission.storage,
        priority: PermissionPriority.required,
        triggers: [PermissionTrigger.appLaunch],
        supportedPlatforms: [PlatformType.mobile],
        allowSkip: false,
        deniedStrategy: PermissionDeniedStrategy.exitApp,
      ),

      // 移动端可选权限
      const PermissionConfig(
        permission: AppPermission.camera,
        priority: PermissionPriority.optional,
        triggers: [PermissionTrigger.actionTrigger],
        supportedPlatforms: [PlatformType.mobile],
        allowSkip: true,
        deniedStrategy: PermissionDeniedStrategy.disableFeature,
      ),

      const PermissionConfig(
        permission: AppPermission.location,
        priority: PermissionPriority.optional,
        triggers: [
          PermissionTrigger.pageEnter,
          PermissionTrigger.actionTrigger,
        ],
        supportedPlatforms: [PlatformType.mobile],
        allowSkip: true,
        deniedStrategy: PermissionDeniedStrategy.showDialog,
      ),

      // Web端权限
      const PermissionConfig(
        permission: AppPermission.webCamera,
        priority: PermissionPriority.optional,
        triggers: [PermissionTrigger.actionTrigger],
        supportedPlatforms: [PlatformType.web],
        allowSkip: true,
        deniedStrategy: PermissionDeniedStrategy.disableFeature,
      ),

      // 桌面端权限
      const PermissionConfig(
        permission: AppPermission.desktopFileSystem,
        priority: PermissionPriority.required,
        triggers: [PermissionTrigger.appLaunch],
        supportedPlatforms: [PlatformType.desktop],
        allowSkip: false,
        deniedStrategy: PermissionDeniedStrategy.exitApp,
      ),
    ];
  }

  /// 根据权限类型获取配置
  PermissionConfig? getConfigByPermission(AppPermission permission) {
    try {
      return _configs.firstWhere((config) => config.permission == permission);
    } catch (e) {
      return null;
    }
  }

  /// 根据触发场景获取权限配置列表
  List<PermissionConfig> getConfigsByTrigger(PermissionTrigger trigger) {
    return _configs.where((config) => config.hasTrigger(trigger)).toList();
  }

  /// 根据优先级获取权限配置列表
  List<PermissionConfig> getConfigsByPriority(PermissionPriority priority) {
    return _configs.where((config) => config.priority == priority).toList();
  }

  /// 获取必要权限配置列表
  List<PermissionConfig> getRequiredConfigs() {
    return getConfigsByPriority(PermissionPriority.required);
  }

  /// 获取可选权限配置列表
  List<PermissionConfig> getOptionalConfigs() {
    return getConfigsByPriority(PermissionPriority.optional);
  }

  /// 根据路由获取相关权限配置
  List<PermissionConfig> getConfigsByRoute(String route) {
    return _configs.where((config) => config.isRelatedToRoute(route)).toList();
  }

  /// 获取应用启动时需要的权限配置
  List<PermissionConfig> getAppLaunchConfigs() {
    return getConfigsByTrigger(PermissionTrigger.appLaunch);
  }

  /// 获取页面进入时需要的权限配置
  List<PermissionConfig> getPageEnterConfigs() {
    return getConfigsByTrigger(PermissionTrigger.pageEnter);
  }

  /// 获取操作触发时需要的权限配置
  List<PermissionConfig> getActionTriggerConfigs() {
    return getConfigsByTrigger(PermissionTrigger.actionTrigger);
  }

  /// 刷新配置（重新从远程加载）
  Future<void> refreshConfigs() async {
    if (_remoteConfigUrl != null) {
      await _loadFromRemote();
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await StorageService.instance.remove(_cacheKey);
  }

  /// 添加或更新权限配置
  void addOrUpdateConfig(PermissionConfig config) {
    final index = _configs.indexWhere((c) => c.permission == config.permission);
    if (index >= 0) {
      _configs[index] = config;
    } else {
      _configs.add(config);
    }

    // 异步保存到缓存
    _saveToCache();
  }

  /// 移除权限配置
  void removeConfig(AppPermission permission) {
    _configs.removeWhere((config) => config.permission == permission);

    // 异步保存到缓存
    _saveToCache();
  }
}
