/// 应用配置管理
/// 
/// 管理不同环境下的应用配置，包括：
/// - API 基础URL
/// - 数据库配置
/// - 第三方服务配置
/// - 调试开关等
library;

/// 应用环境枚举
enum AppEnvironment {
  development,
  staging,
  production,
}

/// 应用配置类
class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;
  final String apiVersion;
  final bool enableLogging;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final Duration networkTimeout;
  final int maxRetryAttempts;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiVersion,
    this.enableLogging = false,
    this.enableCrashReporting = false,
    this.enableAnalytics = false,
    this.networkTimeout = const Duration(seconds: 30),
    this.maxRetryAttempts = 3,
  });

  /// 开发环境配置
  static const AppConfig development = AppConfig(
    environment: AppEnvironment.development,
    appName: 'Flutter Base Dev',
    apiBaseUrl: 'https://dev-api.example.com',
    apiVersion: 'v1',
    enableLogging: true,
    enableCrashReporting: false,
    enableAnalytics: false,
  );

  /// 测试环境配置
  static const AppConfig staging = AppConfig(
    environment: AppEnvironment.staging,
    appName: 'Flutter Base Staging',
    apiBaseUrl: 'https://staging-api.example.com',
    apiVersion: 'v1',
    enableLogging: true,
    enableCrashReporting: true,
    enableAnalytics: false,
  );

  /// 生产环境配置
  static const AppConfig production = AppConfig(
    environment: AppEnvironment.production,
    appName: 'Flutter Base',
    apiBaseUrl: 'https://api.example.com',
    apiVersion: 'v1',
    enableLogging: false,
    enableCrashReporting: true,
    enableAnalytics: true,
  );

  /// 当前配置实例
  static AppConfig _current = development;

  /// 获取当前配置
  static AppConfig get current => _current;

  /// 设置当前配置
  static void setCurrent(AppConfig config) {
    _current = config;
  }

  /// 是否为开发环境
  bool get isDevelopment => environment == AppEnvironment.development;

  /// 是否为测试环境
  bool get isStaging => environment == AppEnvironment.staging;

  /// 是否为生产环境
  bool get isProduction => environment == AppEnvironment.production;

  /// 是否为调试模式
  bool get isDebugMode => isDevelopment || isStaging;

  @override
  String toString() {
    return 'AppConfig{environment: $environment, appName: $appName, apiBaseUrl: $apiBaseUrl}';
  }
}
