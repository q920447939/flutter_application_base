/// 动态路由服务
///
/// 负责从后端获取路由配置，提供：
/// - 路由配置获取
/// - 本地缓存管理
/// - 版本控制
/// - 增量更新
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../network/network_service.dart';
import '../storage/storage_service.dart';
import 'models/route_config.dart';

/// 动态路由服务
class DynamicRouteService extends GetxService {
  static DynamicRouteService get instance => Get.find<DynamicRouteService>();

  /// 路由配置缓存键
  static const String _routeConfigCacheKey = 'dynamic_route_config';
  static const String _routeVersionCacheKey = 'dynamic_route_version';

  /// 当前路由配置
  final Rx<RouteConfigResponse?> _currentConfig = Rx<RouteConfigResponse?>(
    null,
  );

  /// 路由配置获取状态
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  /// Getters
  RouteConfigResponse? get currentConfig => _currentConfig.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<RouteConfig> get routes => _currentConfig.value?.routes ?? [];

  @override
  Future<void> onInit() async {
    super.onInit();
    //await _loadCachedConfig();
  }

  /// 获取路由配置
  Future<bool> fetchRouteConfig({bool forceRefresh = false}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // 检查是否需要更新
      if (!forceRefresh && await _isConfigUpToDate()) {
        debugPrint('路由配置已是最新版本，无需更新');
        return true;
      }

      // 从服务器获取配置
      final response = await NetworkService.instance.get('/api/config/routes');

      if (response.statusCode == 200) {
        final configResponse = RouteConfigResponse.fromJson(response.data);
        await _saveConfig(configResponse);
        _currentConfig.value = configResponse;

        debugPrint('路由配置更新成功，版本: ${configResponse.version}');
        return true;
      } else {
        _error.value = '获取路由配置失败: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error.value = '获取路由配置异常: $e';
      debugPrint('获取路由配置异常: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 根据路径获取路由配置
  RouteConfig? getRouteByPath(String path) {
    return routes.firstWhereOrNull((route) => route.path == path);
  }

  /// 根据名称获取路由配置
  RouteConfig? getRouteByName(String name) {
    return routes.firstWhereOrNull((route) => route.name == name);
  }

  /// 获取启用的路由列表
  List<RouteConfig> getEnabledRoutes() {
    return routes.where((route) => route.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取需要认证的路由列表
  List<RouteConfig> getAuthRequiredRoutes() {
    return routes.where((route) => route.requiresAuth).toList();
  }

  /// 检查路由是否需要特定权限
  bool checkRoutePermission(String path, List<String> userPermissions) {
    final route = getRouteByPath(path);
    if (route == null || route.permissions == null) {
      return true;
    }

    return route.permissions!.every(
      (permission) => userPermissions.contains(permission),
    );
  }

  /// 检查配置是否为最新版本
  Future<bool> _isConfigUpToDate() async {
    try {
      final cachedVersion = await StorageService.instance.getString(
        _routeVersionCacheKey,
      );
      if (cachedVersion == null) return false;

      // 向服务器查询最新版本
      final response = await NetworkService.instance.get(
        '/api/config/routes/version',
      );
      if (response.statusCode == 200) {
        final serverVersion = response.data['version'] as String;
        return cachedVersion == serverVersion;
      }
      return false;
    } catch (e) {
      debugPrint('检查路由配置版本失败: $e');
      return false;
    }
  }

  /// 加载缓存的配置
  Future<void> _loadCachedConfig() async {
    try {
      final cachedConfigJson = await StorageService.instance.getString(
        _routeConfigCacheKey,
      );
      if (cachedConfigJson != null) {
        final configMap = jsonDecode(cachedConfigJson) as Map<String, dynamic>;
        _currentConfig.value = RouteConfigResponse.fromJson(configMap);
        debugPrint('加载缓存的路由配置成功');
      }
    } catch (e) {
      debugPrint('加载缓存的路由配置失败: $e');
    }
  }

  /// 保存配置到缓存
  Future<void> _saveConfig(RouteConfigResponse config) async {
    try {
      final configJson = jsonEncode(config.toJson());
      await StorageService.instance.setString(_routeConfigCacheKey, configJson);
      await StorageService.instance.setString(
        _routeVersionCacheKey,
        config.version,
      );
      debugPrint('路由配置缓存保存成功');
    } catch (e) {
      debugPrint('保存路由配置缓存失败: $e');
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      await StorageService.instance.remove(_routeConfigCacheKey);
      await StorageService.instance.remove(_routeVersionCacheKey);
      _currentConfig.value = null;
      debugPrint('路由配置缓存已清除');
    } catch (e) {
      debugPrint('清除路由配置缓存失败: $e');
    }
  }

  /// 重新加载配置
  Future<bool> reloadConfig() async {
    await clearCache();
    return await fetchRouteConfig(forceRefresh: true);
  }

  /// 获取路由统计信息
  Map<String, dynamic> getRouteStats() {
    final allRoutes = routes;
    final enabledRoutes = getEnabledRoutes();
    final authRequiredRoutes = getAuthRequiredRoutes();

    final typeStats = <String, int>{};
    for (final route in allRoutes) {
      final type = route.pageType.toString().split('.').last;
      typeStats[type] = (typeStats[type] ?? 0) + 1;
    }

    return {
      'total': allRoutes.length,
      'enabled': enabledRoutes.length,
      'disabled': allRoutes.length - enabledRoutes.length,
      'authRequired': authRequiredRoutes.length,
      'typeStats': typeStats,
      'version': _currentConfig.value?.version ?? 'unknown',
      'lastUpdated': _currentConfig.value?.updatedAt?.toIso8601String(),
    };
  }

  /// 验证路由配置
  List<String> validateRouteConfig() {
    final errors = <String>[];
    final routes = this.routes;
    final paths = <String>{};
    final names = <String>{};

    for (final route in routes) {
      // 检查路径重复
      if (paths.contains(route.path)) {
        errors.add('重复的路由路径: ${route.path}');
      } else {
        paths.add(route.path);
      }

      // 检查名称重复
      if (names.contains(route.name)) {
        errors.add('重复的路由名称: ${route.name}');
      } else {
        names.add(route.name);
      }

      // 检查路径格式
      if (!route.path.startsWith('/')) {
        errors.add('路由路径必须以/开头: ${route.path}');
      }

      // 检查页面配置
      if (route.pageType == PageType.dynamic &&
          route.pageConfig?.layout == null) {
        errors.add('动态页面必须配置layout: ${route.path}');
      }

      if (route.pageType == PageType.webview &&
          route.pageConfig?.webView == null) {
        errors.add('WebView页面必须配置webView: ${route.path}');
      }

      if (route.pageType == PageType.form && route.pageConfig?.form == null) {
        errors.add('表单页面必须配置form: ${route.path}');
      }
    }

    return errors;
  }
}
