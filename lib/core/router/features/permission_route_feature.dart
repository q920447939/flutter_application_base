/// 权限路由功能特性
///
/// 实现权限检查的路由功能特性，与权限中间件配合工作
library;

import 'package:get/get.dart';
import '../route_feature.dart';
import '../middlewares/permission_middleware.dart';
import '../../permissions/permission_service.dart';

/// 权限路由功能特性
class PermissionRouteFeature implements IRouteFeature {
  final PermissionMiddlewareConfig config;

  PermissionRouteFeature({
    List<AppPermission> requiredPermissions = const [],
    List<AppPermission> optionalPermissions = const [],
    bool showGuide = true,
    bool allowSkipOptional = true,
    String? deniedRedirectRoute,
    Future<bool> Function(List<AppPermission>)? onPermissionDenied,
    void Function(List<AppPermission>)? onPermissionGranted,
  }) : config = PermissionMiddlewareConfig(
         requiredPermissions: requiredPermissions,
         optionalPermissions: optionalPermissions,
         showGuide: showGuide,
         allowSkipOptional: allowSkipOptional,
         deniedRedirectRoute: deniedRedirectRoute,
         onPermissionDenied: onPermissionDenied,
         onPermissionGranted: onPermissionGranted,
       );

  /// 使用配置构造
  const PermissionRouteFeature.withConfig(this.config);

  @override
  String get featureName => 'PermissionRouteFeature';

  @override
  String get description => '权限检查路由功能特性，在路由跳转前验证所需权限';

  @override
  int get priority => 10; // 权限检查优先级较高

  @override
  bool get isEnabled => config.allPermissions.isNotEmpty;

  @override
  GetMiddleware? createMiddleware() {
    return PermissionMiddleware(config);
  }

  @override
  FeatureValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证权限列表
    if (config.allPermissions.isEmpty) {
      warnings.add('未配置任何权限，该功能特性可能不必要');
    }

    // 验证重定向路由
    if (config.deniedRedirectRoute != null) {
      final route = config.deniedRedirectRoute!;
      if (!route.startsWith('/')) {
        errors.add('重定向路由必须以 "/" 开头: $route');
      }
    }

    // 验证权限配置的合理性
    if (config.requiredPermissions.isNotEmpty && !config.showGuide) {
      warnings.add('必需权限建议显示引导页面以提升用户体验');
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
      'required_permissions':
          config.requiredPermissions.map((p) => p.name).toList(),
      'optional_permissions':
          config.optionalPermissions.map((p) => p.name).toList(),
      'show_guide': config.showGuide,
      'allow_skip_optional': config.allowSkipOptional,
      'denied_redirect_route': config.deniedRedirectRoute,
    };
  }

  @override
  Future<void> initialize() async {
    // 权限功能特性的初始化
    // 可以在这里预检查权限状态或初始化权限服务
  }

  @override
  void dispose() {
    // 权限功能特性的清理
    // 通常权限功能特性不需要特殊的清理操作
  }

  /// 检查权限状态
  Future<Map<AppPermission, bool>> checkPermissionStatus() async {
    final results = <AppPermission, bool>{};

    for (final permission in config.allPermissions) {
      final result = await PermissionService.instance.checkPermission(
        permission,
      );
      results[permission] = result.isGranted;
    }

    return results;
  }

  /// 获取被拒绝的权限
  Future<List<AppPermission>> getDeniedPermissions() async {
    final status = await checkPermissionStatus();
    return status.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取已授权的权限
  Future<List<AppPermission>> getGrantedPermissions() async {
    final status = await checkPermissionStatus();
    return status.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// 复制并修改功能特性
  PermissionRouteFeature copyWith({
    List<AppPermission>? requiredPermissions,
    List<AppPermission>? optionalPermissions,
    bool? showGuide,
    bool? allowSkipOptional,
    String? deniedRedirectRoute,
    Future<bool> Function(List<AppPermission>)? onPermissionDenied,
    void Function(List<AppPermission>)? onPermissionGranted,
  }) {
    return PermissionRouteFeature.withConfig(
      config.copyWith(
        requiredPermissions: requiredPermissions,
        optionalPermissions: optionalPermissions,
        showGuide: showGuide,
        allowSkipOptional: allowSkipOptional,
        deniedRedirectRoute: deniedRedirectRoute,
        onPermissionDenied: onPermissionDenied,
        onPermissionGranted: onPermissionGranted,
      ),
    );
  }

  @override
  String toString() {
    return 'PermissionRouteFeature(required: ${config.requiredPermissions.length}, optional: ${config.optionalPermissions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionRouteFeature &&
        other.config.requiredPermissions == config.requiredPermissions &&
        other.config.optionalPermissions == config.optionalPermissions;
  }

  @override
  int get hashCode =>
      Object.hash(config.requiredPermissions, config.optionalPermissions);
}

/// 权限路由功能特性构建器
class PermissionRouteFeatureBuilder {
  PermissionMiddlewareConfig _config = PermissionMiddlewareConfig();

  /// 设置必需权限
  PermissionRouteFeatureBuilder requiredPermissions(
    List<AppPermission> permissions,
  ) {
    _config = _config.copyWith(requiredPermissions: permissions);
    return this;
  }

  /// 添加必需权限
  PermissionRouteFeatureBuilder addRequiredPermission(
    AppPermission permission,
  ) {
    final newPermissions = [..._config.requiredPermissions, permission];
    _config = _config.copyWith(requiredPermissions: newPermissions);
    return this;
  }

  /// 设置可选权限
  PermissionRouteFeatureBuilder optionalPermissions(
    List<AppPermission> permissions,
  ) {
    _config = _config.copyWith(optionalPermissions: permissions);
    return this;
  }

  /// 添加可选权限
  PermissionRouteFeatureBuilder addOptionalPermission(
    AppPermission permission,
  ) {
    final newPermissions = [..._config.optionalPermissions, permission];
    _config = _config.copyWith(optionalPermissions: newPermissions);
    return this;
  }

  /// 设置是否显示引导
  PermissionRouteFeatureBuilder showGuide(bool show) {
    _config = _config.copyWith(showGuide: show);
    return this;
  }

  /// 设置是否允许跳过可选权限
  PermissionRouteFeatureBuilder allowSkipOptional(bool allow) {
    _config = _config.copyWith(allowSkipOptional: allow);
    return this;
  }

  /// 设置权限被拒绝时的重定向路由
  PermissionRouteFeatureBuilder deniedRedirectRoute(String route) {
    _config = _config.copyWith(deniedRedirectRoute: route);
    return this;
  }

  /// 设置权限被拒绝时的自定义处理
  PermissionRouteFeatureBuilder onPermissionDenied(
    Future<bool> Function(List<AppPermission>) callback,
  ) {
    _config = _config.copyWith(onPermissionDenied: callback);
    return this;
  }

  /// 设置权限授权成功时的回调
  PermissionRouteFeatureBuilder onPermissionGranted(
    void Function(List<AppPermission>) callback,
  ) {
    _config = _config.copyWith(onPermissionGranted: callback);
    return this;
  }

  /// 构建权限路由功能特性
  PermissionRouteFeature build() {
    return PermissionRouteFeature.withConfig(_config);
  }
}

/// 权限路由功能特性工厂
class PermissionRouteFeatureFactory {
  /// 创建基础权限功能特性
  static PermissionRouteFeature basic({
    List<AppPermission> requiredPermissions = const [],
    List<AppPermission> optionalPermissions = const [],
  }) {
    return PermissionRouteFeature(
      requiredPermissions: requiredPermissions,
      optionalPermissions: optionalPermissions,
    );
  }

  /// 创建相机权限功能特性
  static PermissionRouteFeature camera({bool required = false}) {
    return PermissionRouteFeature(
      requiredPermissions: required ? [AppPermission.camera] : [],
      optionalPermissions: required ? [] : [AppPermission.camera],
    );
  }

  /// 创建位置权限功能特性
  static PermissionRouteFeature location({bool required = false}) {
    return PermissionRouteFeature(
      requiredPermissions: required ? [AppPermission.location] : [],
      optionalPermissions: required ? [] : [AppPermission.location],
    );
  }

  /// 创建存储权限功能特性
  static PermissionRouteFeature storage({bool required = true}) {
    return PermissionRouteFeature(
      requiredPermissions: required ? [AppPermission.storage] : [],
      optionalPermissions: required ? [] : [AppPermission.storage],
    );
  }

  /// 创建多媒体权限功能特性（相机+麦克风+存储）
  static PermissionRouteFeature multimedia({bool required = false}) {
    final permissions = [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.storage,
    ];

    return PermissionRouteFeature(
      requiredPermissions: required ? permissions : [],
      optionalPermissions: required ? [] : permissions,
    );
  }

  /// 创建通讯权限功能特性（联系人+电话+短信）
  static PermissionRouteFeature communication({bool required = false}) {
    final permissions = [
      AppPermission.contacts,
      AppPermission.phone,
      AppPermission.sms,
    ];

    return PermissionRouteFeature(
      requiredPermissions: required ? permissions : [],
      optionalPermissions: required ? [] : permissions,
    );
  }

  /// 创建自定义权限功能特性
  static PermissionRouteFeature custom(PermissionMiddlewareConfig config) {
    return PermissionRouteFeature.withConfig(config);
  }
}

/// 更新路由功能特性工厂以支持权限功能特性
extension RouteFeatureFactoryPermissionExtension on RouteFeatureFactory {
  /// 创建权限功能特性
  static IRouteFeature createPermissionFeature(
    List<AppPermission> permissions,
  ) {
    return PermissionRouteFeatureFactory.basic(
      requiredPermissions: permissions,
    );
  }
}
