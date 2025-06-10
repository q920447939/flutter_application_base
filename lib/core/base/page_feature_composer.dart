/// 页面功能组合器
///
/// 提供页面功能的组合和管理能力
library;

import 'package:flutter/material.dart';
import 'base_page.dart';
import 'features/permission_feature.dart';
import 'features/analytics_feature.dart';
import 'features/loading_feature.dart';
import '../permissions/permission_service.dart';

/// 页面功能组合器
class PageFeatureComposer {
  final List<IPageFeature> _features = [];
  String? _route;
  String? _title;
  bool _showLoading = true;
  bool _showError = true;
  Widget? _customLoadingWidget;
  Widget? _customErrorWidget;

  /// 设置页面路由
  PageFeatureComposer route(String route) {
    _route = route;
    return this;
  }

  /// 设置页面标题
  PageFeatureComposer title(String title) {
    _title = title;
    return this;
  }

  /// 设置是否显示加载状态
  PageFeatureComposer showLoading(bool show) {
    _showLoading = show;
    return this;
  }

  /// 设置是否显示错误状态
  PageFeatureComposer showError(bool show) {
    _showError = show;
    return this;
  }

  /// 设置自定义加载组件
  PageFeatureComposer customLoading(Widget widget) {
    _customLoadingWidget = widget;
    return this;
  }

  /// 设置自定义错误组件
  PageFeatureComposer customError(Widget widget) {
    _customErrorWidget = widget;
    return this;
  }

  /// 添加权限功能
  PageFeatureComposer withPermissions({
    List<AppPermission> required = const [],
    List<AppPermission> optional = const [],
    bool showGuide = true,
    bool allowSkipOptional = true,
    Future<bool> Function(List<AppPermission>)? onDenied,
    void Function(List<AppPermission>)? onGranted,
  }) {
    _features.add(
      PermissionFeature(
        PermissionFeatureConfig(
          requiredPermissions: required,
          optionalPermissions: optional,
          showGuide: showGuide,
          allowSkipOptional: allowSkipOptional,
          onPermissionDenied: onDenied,
          onPermissionGranted: onGranted,
        ),
      ),
    );
    return this;
  }

  /// 添加分析功能
  PageFeatureComposer withAnalytics({
    String? pageName,
    Map<String, dynamic> customParameters = const {},
    void Function(String, Map<String, dynamic>)? onEnter,
    void Function(String, Duration)? onExit,
  }) {
    _features.add(
      AnalyticsFeature(
        AnalyticsFeatureConfig(
          pageName: pageName,
          customParameters: customParameters,
          onPageEnter: onEnter,
          onPageExit: onExit,
        ),
      ),
    );
    return this;
  }

  /// 添加加载功能
  PageFeatureComposer withLoading({
    bool enableNetworkCheck = true,
    int minDuration = 500,
    int timeout = 30000,
    Future<bool> Function()? preloadData,
    void Function(bool)? onNetworkChanged,
  }) {
    _features.add(
      LoadingFeature(
        LoadingFeatureConfig(
          enableNetworkCheck: enableNetworkCheck,
          minLoadingDuration: minDuration,
          loadingTimeout: timeout,
          onPreloadData: preloadData,
          onNetworkStatusChanged: onNetworkChanged,
        ),
      ),
    );
    return this;
  }

  /// 添加自定义功能
  PageFeatureComposer withFeature(IPageFeature feature) {
    _features.add(feature);
    return this;
  }

  /// 构建页面配置
  PageConfig build() {
    return PageConfig(
      route: _route ?? '',
      title: _title,
      showLoading: _showLoading,
      showError: _showError,
      customLoadingWidget: _customLoadingWidget,
      customErrorWidget: _customErrorWidget,
      features: List.unmodifiable(_features),
    );
  }
}

/// 常用页面配置预设
class PageConfigPresets {
  /// 基础页面配置
  static PageConfig basic(String route, {String? title}) {
    return PageFeatureComposer().route(route).title(title ?? '').build();
  }

  /// 需要权限的页面配置
  static PageConfig withPermissions(
    String route, {
    String? title,
    List<AppPermission> required = const [],
    List<AppPermission> optional = const [],
  }) {
    return PageFeatureComposer()
        .route(route)
        .title(title ?? '')
        .withPermissions(required: required, optional: optional)
        .withAnalytics()
        .build();
  }

  /// 相机页面配置
  static PageConfig camera(
    String route, {
    String? title,
    bool required = false,
  }) {
    return PageFeatureComposer()
        .route(route)
        .title(title ?? '相机')
        .withPermissions(
          required:
              required ? [AppPermission.camera, AppPermission.storage] : [],
          optional:
              required ? [] : [AppPermission.camera, AppPermission.storage],
        )
        .withAnalytics(pageName: 'camera_page')
        .build();
  }

  /// 地图页面配置
  static PageConfig map(String route, {String? title, bool required = false}) {
    return PageFeatureComposer()
        .route(route)
        .title(title ?? '地图')
        .withPermissions(
          required: required ? [AppPermission.location] : [],
          optional: required ? [] : [AppPermission.location],
        )
        .withAnalytics(pageName: 'map_page')
        .withLoading(enableNetworkCheck: true)
        .build();
  }

  /// 多媒体页面配置
  static PageConfig multimedia(
    String route, {
    String? title,
    bool required = false,
  }) {
    final permissions = [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.storage,
    ];

    return PageFeatureComposer()
        .route(route)
        .title(title ?? '多媒体')
        .withPermissions(
          required: required ? permissions : [],
          optional: required ? [] : permissions,
        )
        .withAnalytics(pageName: 'multimedia_page')
        .build();
  }

  /// 设置页面配置
  static PageConfig settings(String route, {String? title}) {
    return PageFeatureComposer()
        .route(route)
        .title(title ?? '设置')
        .withAnalytics(pageName: 'settings_page')
        .build();
  }

  /// 需要网络的页面配置
  static PageConfig network(
    String route, {
    String? title,
    Future<bool> Function()? preloadData,
  }) {
    return PageFeatureComposer()
        .route(route)
        .title(title ?? '')
        .withLoading(enableNetworkCheck: true, preloadData: preloadData)
        .withAnalytics()
        .build();
  }

  /// 完整功能页面配置
  static PageConfig full(
    String route, {
    String? title,
    List<AppPermission> requiredPermissions = const [],
    List<AppPermission> optionalPermissions = const [],
    Future<bool> Function()? preloadData,
    Map<String, dynamic> analyticsParams = const {},
  }) {
    return PageFeatureComposer()
        .route(route)
        .title(title ?? '')
        .withPermissions(
          required: requiredPermissions,
          optional: optionalPermissions,
        )
        .withLoading(preloadData: preloadData)
        .withAnalytics(customParameters: analyticsParams)
        .build();
  }
}

/// 页面工厂
class PageFactory {
  /// 创建无状态页面
  static Widget createStatelessPage({
    required PageConfig config,
    required Widget Function(BuildContext) builder,
    Future<bool> Function(BuildContext)? businessCheck,
    Widget Function(BuildContext, String)? errorBuilder,
    Widget Function(BuildContext)? loadingBuilder,
  }) {
    return _StatelessPageWrapper(
      config: config,
      builder: builder,
      businessCheck: businessCheck,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }

  /// 创建有状态页面
  static Widget createStatefulPage({
    required PageConfig config,
    required Widget Function(BuildContext, StateSetter) builder,
    Future<bool> Function(BuildContext)? businessCheck,
    Widget Function(BuildContext, String)? errorBuilder,
    Widget Function(BuildContext)? loadingBuilder,
  }) {
    return _StatefulPageWrapper(
      config: config,
      builder: builder,
      businessCheck: businessCheck,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

/// 无状态页面包装器
class _StatelessPageWrapper extends BaseStatelessPage {
  final PageConfig _config;
  final Widget Function(BuildContext) _builder;
  final Future<bool> Function(BuildContext)? _businessCheck;
  final Widget Function(BuildContext, String)? _errorBuilder;
  final Widget Function(BuildContext)? _loadingBuilder;

  const _StatelessPageWrapper({
    required PageConfig config,
    required Widget Function(BuildContext) builder,
    Future<bool> Function(BuildContext)? businessCheck,
    Widget Function(BuildContext, String)? errorBuilder,
    Widget Function(BuildContext)? loadingBuilder,
  }) : _config = config,
       _builder = builder,
       _businessCheck = businessCheck,
       _errorBuilder = errorBuilder,
       _loadingBuilder = loadingBuilder;

  @override
  PageConfig get pageConfig => _config;

  @override
  Widget buildContent(BuildContext context) => _builder(context);

  @override
  Future<bool> onBusinessCheck(BuildContext context) =>
      _businessCheck?.call(context) ?? super.onBusinessCheck(context);

  @override
  Widget onError(BuildContext context, String error) =>
      _errorBuilder?.call(context, error) ?? super.onError(context, error);

  @override
  Widget onLoading(BuildContext context) =>
      _loadingBuilder?.call(context) ?? super.onLoading(context);
}

/// 有状态页面包装器
class _StatefulPageWrapper extends BaseStatefulPage {
  final PageConfig _config;
  final Widget Function(BuildContext, StateSetter) _builder;
  final Future<bool> Function(BuildContext)? _businessCheck;
  final Widget Function(BuildContext, String)? _errorBuilder;
  final Widget Function(BuildContext)? _loadingBuilder;

  const _StatefulPageWrapper({
    required PageConfig config,
    required Widget Function(BuildContext, StateSetter) builder,
    Future<bool> Function(BuildContext)? businessCheck,
    Widget Function(BuildContext, String)? errorBuilder,
    Widget Function(BuildContext)? loadingBuilder,
  }) : _config = config,
       _builder = builder,
       _businessCheck = businessCheck,
       _errorBuilder = errorBuilder,
       _loadingBuilder = loadingBuilder;

  @override
  PageConfig get pageConfig => _config;

  @override
  State<_StatefulPageWrapper> createState() => _StatefulPageWrapperState();
}

class _StatefulPageWrapperState
    extends BaseStatefulPageState<_StatefulPageWrapper> {
  @override
  Widget buildContent(BuildContext context) =>
      widget._builder(context, setState);

  @override
  Future<bool> onBusinessCheck(BuildContext context) =>
      widget._businessCheck?.call(context) ?? super.onBusinessCheck(context);

  @override
  Widget onError(BuildContext context, String error) =>
      widget._errorBuilder?.call(context, error) ??
      super.onError(context, error);

  @override
  Widget onLoading(BuildContext context) =>
      widget._loadingBuilder?.call(context) ?? super.onLoading(context);
}
