/// 框架模块接口定义
///
/// 定义了框架模块的标准接口，所有框架模块都应该实现此接口
library;

/// 框架模块接口
abstract class FrameworkModule {
  /// 模块名称，必须唯一
  String get name;

  /// 初始化优先级，数字越小优先级越高
  int get priority => 100;

  /// 依赖的模块名称列表
  List<String> get dependencies => [];

  /// 模块描述
  String get description => '';

  /// 模块版本
  String get version => '1.0.0';

  /// 是否启用此模块
  bool get enabled => true;

  /// 初始化模块
  ///
  /// 在应用启动时调用，用于初始化模块的各种配置和服务
  Future<void> initialize();

  /// 销毁模块
  ///
  /// 在应用关闭时调用，用于清理资源
  Future<void> dispose();

  /// 获取模块配置信息
  Map<String, dynamic> getModuleInfo() {
    return {
      'name': name,
      'description': description,
      'version': version,
      'priority': priority,
      'dependencies': dependencies,
      'enabled': enabled,
    };
  }
}

/// 模块初始化结果
class ModuleInitializationResult {
  /// 是否成功
  final bool success;

  /// 模块名称
  final String moduleName;

  /// 初始化耗时
  final Duration duration;

  /// 错误信息（如果失败）
  final String? error;

  /// 警告信息
  final List<String> warnings;

  const ModuleInitializationResult({
    required this.success,
    required this.moduleName,
    required this.duration,
    this.error,
    this.warnings = const [],
  });

  /// 创建成功结果
  factory ModuleInitializationResult.success({
    required String moduleName,
    required Duration duration,
    List<String> warnings = const [],
  }) {
    return ModuleInitializationResult(
      success: true,
      moduleName: moduleName,
      duration: duration,
      warnings: warnings,
    );
  }

  /// 创建失败结果
  factory ModuleInitializationResult.failure({
    required String moduleName,
    required Duration duration,
    required String error,
    List<String> warnings = const [],
  }) {
    return ModuleInitializationResult(
      success: false,
      moduleName: moduleName,
      duration: duration,
      error: error,
      warnings: warnings,
    );
  }
}

/// 模块状态枚举
enum ModuleStatus {
  /// 未初始化
  notInitialized,

  /// 初始化中
  initializing,

  /// 已初始化
  initialized,

  /// 初始化失败
  failed,

  /// 已销毁
  disposed,
}

/// 模块运行时信息
class ModuleRuntimeInfo {
  /// 模块实例
  final FrameworkModule module;

  /// 模块状态
  ModuleStatus status;

  /// 初始化结果
  ModuleInitializationResult? initializationResult;

  /// 最后健康检查时间
  DateTime? lastHealthCheck;

  /// 最后健康检查结果
  bool? lastHealthCheckResult;

  ModuleRuntimeInfo({
    required this.module,
    this.status = ModuleStatus.notInitialized,
    this.initializationResult,
    this.lastHealthCheck,
    this.lastHealthCheckResult,
  });

  /// 获取模块运行时信息
  Map<String, dynamic> toMap() {
    return {
      'module': module.getModuleInfo(),
      'status': status.name,
      'initializationResult':
          initializationResult != null
              ? {
                'success': initializationResult!.success,
                'duration': initializationResult!.duration.inMilliseconds,
                'error': initializationResult!.error,
                'warnings': initializationResult!.warnings,
              }
              : null,
      'lastHealthCheck': lastHealthCheck?.toIso8601String(),
      'lastHealthCheckResult': lastHealthCheckResult,
    };
  }
}
