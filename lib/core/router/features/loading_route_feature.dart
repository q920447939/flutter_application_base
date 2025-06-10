/// 加载路由功能特性
///
/// 实现页面加载管理的路由功能特性，与加载中间件配合工作
library;

import 'package:get/get.dart';
import '../route_feature.dart';
import '../middlewares/loading_middleware.dart';

/// 加载路由功能特性
class LoadingRouteFeature implements IRouteFeature {
  final LoadingMiddlewareConfig config;

  LoadingRouteFeature({
    bool enableGlobalLoading = true,
    bool enableNetworkCheck = true,
    int minLoadingDuration = 500,
    int loadingTimeout = 30000,
    Future<bool> Function()? onPreloadData,
    void Function(bool)? onNetworkStatusChanged,
    void Function(String)? onLoadingStart,
    void Function(String, Duration)? onLoadingComplete,
    void Function(String, String)? onLoadingError,
  }) : config = LoadingMiddlewareConfig(
         enableGlobalLoading: enableGlobalLoading,
         enableNetworkCheck: enableNetworkCheck,
         minLoadingDuration: minLoadingDuration,
         loadingTimeout: loadingTimeout,
         onPreloadData: onPreloadData,
         onNetworkStatusChanged: onNetworkStatusChanged,
         onLoadingStart: onLoadingStart,
         onLoadingComplete: onLoadingComplete,
         onLoadingError: onLoadingError,
       );

  /// 使用配置构造
  const LoadingRouteFeature.withConfig(this.config);

  @override
  String get featureName => 'LoadingRouteFeature';

  @override
  String get description => '页面加载管理路由功能特性，处理页面加载状态和网络检查';

  @override
  int get priority => 20; // 加载检查优先级中等

  @override
  bool get isEnabled =>
      config.enableGlobalLoading ||
      config.enableNetworkCheck ||
      config.onPreloadData != null;

  @override
  GetMiddleware? createMiddleware() {
    return LoadingMiddleware(config);
  }

  @override
  FeatureValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证加载时间配置
    if (config.minLoadingDuration < 0) {
      errors.add('最小加载时间不能为负数');
    }

    if (config.loadingTimeout <= 0) {
      errors.add('加载超时时间必须大于0');
    }

    if (config.minLoadingDuration >= config.loadingTimeout) {
      errors.add('最小加载时间不能大于或等于超时时间');
    }

    // 验证配置的合理性
    if (config.minLoadingDuration > 2000) {
      warnings.add('最小加载时间过长可能影响用户体验');
    }

    if (config.loadingTimeout < 5000) {
      warnings.add('加载超时时间过短可能导致加载失败');
    }

    // 验证功能启用状态
    if (!config.enableGlobalLoading &&
        !config.enableNetworkCheck &&
        config.onPreloadData == null) {
      warnings.add('所有加载功能都已禁用，该功能特性可能不必要');
    }

    return FeatureValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  Map<String, dynamic> getConfiguration() {
    return {
      'enable_global_loading': config.enableGlobalLoading,
      'enable_network_check': config.enableNetworkCheck,
      'min_loading_duration': config.minLoadingDuration,
      'loading_timeout': config.loadingTimeout,
      'has_preload_data_callback': config.onPreloadData != null,
      'has_network_status_callback': config.onNetworkStatusChanged != null,
      'has_loading_start_callback': config.onLoadingStart != null,
      'has_loading_complete_callback': config.onLoadingComplete != null,
      'has_loading_error_callback': config.onLoadingError != null,
    };
  }

  @override
  Future<void> initialize() async {
    // 加载功能特性的初始化
    // 可以在这里初始化网络检查服务或预加载必要资源
  }

  @override
  void dispose() {
    // 加载功能特性的清理
    // 通常加载功能特性不需要特殊的清理操作
  }

  /// 手动触发网络状态检查
  Future<bool> checkNetworkStatus() async {
    try {
      // 这里可以集成具体的网络检查逻辑
      // 示例：使用 connectivity_plus
      // final connectivityResult = await Connectivity().checkConnectivity();
      // return connectivityResult != ConnectivityResult.none;

      // 简单的网络检查示例
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // 暂时返回 true
    } catch (e) {
      return false;
    }
  }

  /// 手动执行数据预加载
  Future<bool> executePreloadData() async {
    if (config.onPreloadData == null) {
      return true;
    }

    try {
      return await config.onPreloadData!();
    } catch (e) {
      return false;
    }
  }

  /// 获取加载状态信息
  Map<String, dynamic> getLoadingStatus() {
    return {
      'global_loading_enabled': config.enableGlobalLoading,
      'network_check_enabled': config.enableNetworkCheck,
      'min_duration_ms': config.minLoadingDuration,
      'timeout_ms': config.loadingTimeout,
      'has_preload_callback': config.onPreloadData != null,
    };
  }

  /// 复制并修改功能特性
  LoadingRouteFeature copyWith({
    bool? enableGlobalLoading,
    bool? enableNetworkCheck,
    int? minLoadingDuration,
    int? loadingTimeout,
    Future<bool> Function()? onPreloadData,
    void Function(bool)? onNetworkStatusChanged,
    void Function(String)? onLoadingStart,
    void Function(String, Duration)? onLoadingComplete,
    void Function(String, String)? onLoadingError,
  }) {
    return LoadingRouteFeature.withConfig(
      config.copyWith(
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
  }

  @override
  String toString() {
    return 'LoadingRouteFeature(globalLoading: ${config.enableGlobalLoading}, networkCheck: ${config.enableNetworkCheck})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingRouteFeature &&
        other.config.enableGlobalLoading == config.enableGlobalLoading &&
        other.config.enableNetworkCheck == config.enableNetworkCheck &&
        other.config.minLoadingDuration == config.minLoadingDuration &&
        other.config.loadingTimeout == config.loadingTimeout;
  }

  @override
  int get hashCode => Object.hash(
    config.enableGlobalLoading,
    config.enableNetworkCheck,
    config.minLoadingDuration,
    config.loadingTimeout,
  );
}

/// 加载路由功能特性构建器
class LoadingRouteFeatureBuilder {
  LoadingMiddlewareConfig _config = const LoadingMiddlewareConfig();

  /// 设置是否启用全局加载状态
  LoadingRouteFeatureBuilder enableGlobalLoading(bool enable) {
    _config = _config.copyWith(enableGlobalLoading: enable);
    return this;
  }

  /// 设置是否启用网络检查
  LoadingRouteFeatureBuilder enableNetworkCheck(bool enable) {
    _config = _config.copyWith(enableNetworkCheck: enable);
    return this;
  }

  /// 设置最小加载时间
  LoadingRouteFeatureBuilder minLoadingDuration(int milliseconds) {
    _config = _config.copyWith(minLoadingDuration: milliseconds);
    return this;
  }

  /// 设置加载超时时间
  LoadingRouteFeatureBuilder loadingTimeout(int milliseconds) {
    _config = _config.copyWith(loadingTimeout: milliseconds);
    return this;
  }

  /// 设置数据预加载回调
  LoadingRouteFeatureBuilder onPreloadData(Future<bool> Function() callback) {
    _config = _config.copyWith(onPreloadData: callback);
    return this;
  }

  /// 设置网络状态变化回调
  LoadingRouteFeatureBuilder onNetworkStatusChanged(
    void Function(bool) callback,
  ) {
    _config = _config.copyWith(onNetworkStatusChanged: callback);
    return this;
  }

  /// 设置加载开始回调
  LoadingRouteFeatureBuilder onLoadingStart(void Function(String) callback) {
    _config = _config.copyWith(onLoadingStart: callback);
    return this;
  }

  /// 设置加载完成回调
  LoadingRouteFeatureBuilder onLoadingComplete(
    void Function(String, Duration) callback,
  ) {
    _config = _config.copyWith(onLoadingComplete: callback);
    return this;
  }

  /// 设置加载失败回调
  LoadingRouteFeatureBuilder onLoadingError(
    void Function(String, String) callback,
  ) {
    _config = _config.copyWith(onLoadingError: callback);
    return this;
  }

  /// 构建加载路由功能特性
  LoadingRouteFeature build() {
    return LoadingRouteFeature.withConfig(_config);
  }
}

/// 加载路由功能特性工厂
class LoadingRouteFeatureFactory {
  /// 创建基础加载功能特性
  static LoadingRouteFeature basic() {
    return LoadingRouteFeature();
  }

  /// 创建带网络检查的功能特性
  static LoadingRouteFeature withNetworkCheck({
    void Function(bool)? onNetworkStatusChanged,
  }) {
    return LoadingRouteFeature(
      enableNetworkCheck: true,
      onNetworkStatusChanged: onNetworkStatusChanged,
    );
  }

  /// 创建带数据预加载的功能特性
  static LoadingRouteFeature withPreload(Future<bool> Function() preloadData) {
    return LoadingRouteFeature(onPreloadData: preloadData);
  }

  /// 创建快速加载功能特性（较短的加载时间）
  static LoadingRouteFeature fast() {
    return LoadingRouteFeature(minLoadingDuration: 200, loadingTimeout: 10000);
  }

  /// 创建慢速加载功能特性（较长的加载时间，适用于复杂页面）
  static LoadingRouteFeature slow() {
    return LoadingRouteFeature(minLoadingDuration: 1000, loadingTimeout: 60000);
  }

  /// 创建完整功能的加载特性
  static LoadingRouteFeature full({
    bool enableNetworkCheck = true,
    int minLoadingDuration = 500,
    int loadingTimeout = 30000,
    Future<bool> Function()? preloadData,
    void Function(bool)? onNetworkStatusChanged,
    void Function(String)? onLoadingStart,
    void Function(String, Duration)? onLoadingComplete,
    void Function(String, String)? onLoadingError,
  }) {
    return LoadingRouteFeature(
      enableNetworkCheck: enableNetworkCheck,
      minLoadingDuration: minLoadingDuration,
      loadingTimeout: loadingTimeout,
      onPreloadData: preloadData,
      onNetworkStatusChanged: onNetworkStatusChanged,
      onLoadingStart: onLoadingStart,
      onLoadingComplete: onLoadingComplete,
      onLoadingError: onLoadingError,
    );
  }

  /// 创建自定义加载功能特性
  static LoadingRouteFeature custom(LoadingMiddlewareConfig config) {
    return LoadingRouteFeature.withConfig(config);
  }
}

/// 更新路由功能特性工厂以支持加载功能特性
extension RouteFeatureFactoryLoadingExtension on RouteFeatureFactory {
  /// 创建加载功能特性
  static IRouteFeature createLoadingFeature({
    bool enableNetworkCheck = true,
    Future<bool> Function()? preloadData,
  }) {
    return LoadingRouteFeatureFactory.withPreload(
      preloadData ?? () async => true,
    );
  }
}
