/// 路由构建器
///
/// 提供链式API来构建路由配置，简化路由定义过程
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_config.dart';
import 'route_feature.dart';
import 'features/permission_route_feature.dart';
import 'features/analytics_route_feature.dart';
import 'features/loading_route_feature.dart';
import 'declarative_permissions.dart';
import '../permissions/permission_service.dart';

/// 路由构建器
///
/// 使用构建器模式提供链式API来配置路由
class RouteBuilder {
  String? _path;
  Widget Function()? _pageBuilder;
  String? _title;
  final List<IRouteFeature> _features = [];
  bool Function(Map<String, String> parameters)? _parameterValidator;
  Transition? _transition;
  Duration? _transitionDuration;
  bool _fullscreenDialog = false;
  bool _maintainState = true;
  final Map<String, dynamic> _metadata = {};

  /// 设置路由路径
  RouteBuilder path(String path) {
    _path = path;
    return this;
  }

  /// 设置页面构建器
  RouteBuilder page(Widget Function() pageBuilder) {
    _pageBuilder = pageBuilder;
    return this;
  }

  /// 设置页面标题
  RouteBuilder title(String? title) {
    _title = title;
    return this;
  }

  /// 添加功能特性
  RouteBuilder feature(IRouteFeature feature) {
    _features.add(feature);
    return this;
  }

  /// 批量添加功能特性
  RouteBuilder features(List<IRouteFeature> features) {
    _features.addAll(features);
    return this;
  }

  /// 添加权限功能特性
  RouteBuilder withPermissions({
    List<AppPermission> required = const [],
    List<AppPermission> optional = const [],
    bool showGuide = true,
    bool allowSkipOptional = true,
    String? deniedRedirectRoute,
    Future<bool> Function(List<AppPermission>)? onDenied,
    void Function(List<AppPermission>)? onGranted,
  }) {
    _features.add(
      PermissionRouteFeature(
        requiredPermissions: required,
        optionalPermissions: optional,
        showGuide: showGuide,
        allowSkipOptional: allowSkipOptional,
        deniedRedirectRoute: deniedRedirectRoute,
        onPermissionDenied: onDenied,
        onPermissionGranted: onGranted,
      ),
    );
    return this;
  }

  /// 使用声明式权限配置
  RouteBuilder withDeclarativePermissions(RequiresPermissions permissions) {
    _features.add(permissions.toRouteFeature());
    return this;
  }

  /// 添加分析功能特性
  RouteBuilder withAnalytics({
    String? pageName,
    bool enablePageView = true,
    bool enableDuration = true,
    Map<String, dynamic> customParameters = const {},
    void Function(String, Map<String, dynamic>)? onPageEnter,
    void Function(String, Duration)? onPageExit,
    void Function(String, Map<String, dynamic>)? onPageView,
  }) {
    _features.add(
      AnalyticsRouteFeature(
        pageName: pageName,
        enablePageView: enablePageView,
        enableDuration: enableDuration,
        customParameters: customParameters,
        onPageEnter: onPageEnter,
        onPageExit: onPageExit,
        onPageView: onPageView,
      ),
    );
    return this;
  }

  /// 添加加载功能特性
  RouteBuilder withLoading({
    bool enableGlobalLoading = true,
    bool enableNetworkCheck = true,
    int minLoadingDuration = 500,
    int loadingTimeout = 30000,
    Future<bool> Function()? onPreloadData,
    void Function(bool)? onNetworkStatusChanged,
    void Function(String)? onLoadingStart,
    void Function(String, Duration)? onLoadingComplete,
    void Function(String, String)? onLoadingError,
  }) {
    _features.add(
      LoadingRouteFeature(
        enableGlobalLoading: enableGlobalLoading,
        enableNetworkCheck: enableNetworkCheck,
        minLoadingDuration: minLoadingDuration,
        loadingTimeout: loadingTimeout,
        onPreloadData: onPreloadData,
        onNetworkStatusChanged: onNetworkStatusChanged,
        onLoadingStart: onLoadingStart,
        onLoadingComplete: onLoadingComplete,
        onLoadingError: onLoadingError,
      ),
    );
    return this;
  }

  /// 设置参数验证器
  RouteBuilder parameterValidator(
    bool Function(Map<String, String> parameters) validator,
  ) {
    _parameterValidator = validator;
    return this;
  }

  /// 设置转场动画
  RouteBuilder transition(Transition transition) {
    _transition = transition;
    return this;
  }

  /// 设置转场动画持续时间
  RouteBuilder transitionDuration(Duration duration) {
    _transitionDuration = duration;
    return this;
  }

  /// 设置是否为全屏对话框
  RouteBuilder fullscreenDialog(bool isFullscreen) {
    _fullscreenDialog = isFullscreen;
    return this;
  }

  /// 设置是否保持状态
  RouteBuilder maintainState(bool maintain) {
    _maintainState = maintain;
    return this;
  }

  /// 添加元数据
  RouteBuilder metadata(String key, dynamic value) {
    _metadata[key] = value;
    return this;
  }

  /// 批量添加元数据
  RouteBuilder metadataMap(Map<String, dynamic> metadata) {
    _metadata.addAll(metadata);
    return this;
  }

  /// 构建路由配置
  RouteConfig build() {
    if (_path == null) {
      throw ArgumentError('路由路径不能为空');
    }
    if (_pageBuilder == null) {
      throw ArgumentError('页面构建器不能为空');
    }

    return RouteConfig(
      path: _path!,
      pageBuilder: _pageBuilder!,
      title: _title,
      features: List.unmodifiable(_features),
      parameterValidator: _parameterValidator,
      transition: _transition,
      transitionDuration: _transitionDuration,
      fullscreenDialog: _fullscreenDialog,
      maintainState: _maintainState,
      metadata: Map.unmodifiable(_metadata),
    );
  }

  /// 重置构建器
  RouteBuilder reset() {
    _path = null;
    _pageBuilder = null;
    _title = null;
    _features.clear();
    _parameterValidator = null;
    _transition = null;
    _transitionDuration = null;
    _fullscreenDialog = false;
    _maintainState = true;
    _metadata.clear();
    return this;
  }

  /// 复制构建器
  RouteBuilder copy() {
    final newBuilder = RouteBuilder();
    newBuilder._path = _path;
    newBuilder._pageBuilder = _pageBuilder;
    newBuilder._title = _title;
    newBuilder._features.addAll(_features);
    newBuilder._parameterValidator = _parameterValidator;
    newBuilder._transition = _transition;
    newBuilder._transitionDuration = _transitionDuration;
    newBuilder._fullscreenDialog = _fullscreenDialog;
    newBuilder._maintainState = _maintainState;
    newBuilder._metadata.addAll(_metadata);
    return newBuilder;
  }

  /// 获取当前配置信息
  Map<String, dynamic> getConfiguration() {
    return {
      'path': _path,
      'title': _title,
      'features_count': _features.length,
      'features': _features.map((f) => f.featureName).toList(),
      'has_parameter_validator': _parameterValidator != null,
      'transition': _transition?.toString(),
      'transition_duration': _transitionDuration?.inMilliseconds,
      'fullscreen_dialog': _fullscreenDialog,
      'maintain_state': _maintainState,
      'metadata': _metadata,
    };
  }

  @override
  String toString() {
    return 'RouteBuilder(path: $_path, title: $_title, features: ${_features.length})';
  }
}

/// 路由组构建器
///
/// 用于构建路由组配置
class RouteGroupBuilder {
  String? _name;
  String _prefix = '';
  final List<RouteConfig> _routes = [];
  final List<IRouteFeature> _groupFeatures = [];
  String? _description;

  /// 设置组名称
  RouteGroupBuilder name(String name) {
    _name = name;
    return this;
  }

  /// 设置路由前缀
  RouteGroupBuilder prefix(String prefix) {
    _prefix = prefix;
    return this;
  }

  /// 设置组描述
  RouteGroupBuilder description(String description) {
    _description = description;
    return this;
  }

  /// 添加路由
  RouteGroupBuilder route(RouteConfig route) {
    _routes.add(route);
    return this;
  }

  /// 批量添加路由
  RouteGroupBuilder routes(List<RouteConfig> routes) {
    _routes.addAll(routes);
    return this;
  }

  /// 使用构建器添加路由
  RouteGroupBuilder routeBuilder(
    RouteBuilder Function(RouteBuilder) builderFunction,
  ) {
    final builder = RouteBuilder();
    final route = builderFunction(builder).build();
    _routes.add(route);
    return this;
  }

  /// 添加组级别功能特性
  RouteGroupBuilder groupFeature(IRouteFeature feature) {
    _groupFeatures.add(feature);
    return this;
  }

  /// 批量添加组级别功能特性
  RouteGroupBuilder groupFeatures(List<IRouteFeature> features) {
    _groupFeatures.addAll(features);
    return this;
  }

  /// 添加组级别权限功能特性
  RouteGroupBuilder withGroupPermissions({
    List<AppPermission> required = const [],
    List<AppPermission> optional = const [],
    bool showGuide = true,
    bool allowSkipOptional = true,
    String? deniedRedirectRoute,
  }) {
    _groupFeatures.add(
      PermissionRouteFeature(
        requiredPermissions: required,
        optionalPermissions: optional,
        showGuide: showGuide,
        allowSkipOptional: allowSkipOptional,
        deniedRedirectRoute: deniedRedirectRoute,
      ),
    );
    return this;
  }

  /// 添加组级别分析功能特性
  RouteGroupBuilder withGroupAnalytics({
    Map<String, dynamic> customParameters = const {},
  }) {
    _groupFeatures.add(
      AnalyticsRouteFeature(customParameters: customParameters),
    );
    return this;
  }

  /// 构建路由组
  RouteGroup build() {
    if (_name == null) {
      throw ArgumentError('路由组名称不能为空');
    }

    return RouteGroup(
      name: _name!,
      prefix: _prefix,
      routes: List.unmodifiable(_routes),
      groupFeatures: List.unmodifiable(_groupFeatures),
      description: _description,
    );
  }

  /// 重置构建器
  RouteGroupBuilder reset() {
    _name = null;
    _prefix = '';
    _routes.clear();
    _groupFeatures.clear();
    _description = null;
    return this;
  }

  /// 获取当前配置信息
  Map<String, dynamic> getConfiguration() {
    return {
      'name': _name,
      'prefix': _prefix,
      'routes_count': _routes.length,
      'group_features_count': _groupFeatures.length,
      'description': _description,
    };
  }

  @override
  String toString() {
    return 'RouteGroupBuilder(name: $_name, prefix: $_prefix, routes: ${_routes.length})';
  }
}

/// 路由构建器工厂
///
/// 提供常用路由配置的快速创建方法
class RouteBuilderFactory {
  /// 创建基础路由
  static RouteBuilder basic(
    String path,
    Widget Function() pageBuilder, {
    String? title,
  }) {
    return RouteBuilder().path(path).page(pageBuilder).title(title);
  }

  /// 创建需要权限的路由
  static RouteBuilder withPermissions(
    String path,
    Widget Function() pageBuilder, {
    String? title,
    List<AppPermission> required = const [],
    List<AppPermission> optional = const [],
  }) {
    return RouteBuilder()
        .path(path)
        .page(pageBuilder)
        .title(title)
        .withPermissions(required: required, optional: optional)
        .withAnalytics();
  }

  /// 创建相机路由
  static RouteBuilder camera(
    String path,
    Widget Function() pageBuilder, {
    String? title,
    bool required = false,
  }) {
    return RouteBuilder()
        .path(path)
        .page(pageBuilder)
        .title(title ?? '相机')
        .withPermissions(
          required:
              required ? [AppPermission.camera, AppPermission.storage] : [],
          optional:
              required ? [] : [AppPermission.camera, AppPermission.storage],
        )
        .withAnalytics(pageName: 'camera_page');
  }

  /// 创建地图路由
  static RouteBuilder map(
    String path,
    Widget Function() pageBuilder, {
    String? title,
    bool required = false,
  }) {
    return RouteBuilder()
        .path(path)
        .page(pageBuilder)
        .title(title ?? '地图')
        .withPermissions(
          required: required ? [AppPermission.location] : [],
          optional: required ? [] : [AppPermission.location],
        )
        .withAnalytics(pageName: 'map_page')
        .withLoading(enableNetworkCheck: true);
  }

  /// 创建需要网络的路由
  static RouteBuilder network(
    String path,
    Widget Function() pageBuilder, {
    String? title,
    Future<bool> Function()? preloadData,
  }) {
    return RouteBuilder()
        .path(path)
        .page(pageBuilder)
        .title(title)
        .withLoading(enableNetworkCheck: true, onPreloadData: preloadData)
        .withAnalytics();
  }

  /// 创建完整功能路由
  static RouteBuilder full(
    String path,
    Widget Function() pageBuilder, {
    String? title,
    List<AppPermission> requiredPermissions = const [],
    List<AppPermission> optionalPermissions = const [],
    Future<bool> Function()? preloadData,
    Map<String, dynamic> analyticsParams = const {},
  }) {
    return RouteBuilder()
        .path(path)
        .page(pageBuilder)
        .title(title)
        .withPermissions(
          required: requiredPermissions,
          optional: optionalPermissions,
        )
        .withLoading(onPreloadData: preloadData)
        .withAnalytics(customParameters: analyticsParams);
  }
}
