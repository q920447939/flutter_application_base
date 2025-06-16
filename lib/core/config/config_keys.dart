/// 配置键管理
///
/// 统一管理所有远程配置的键名，避免硬编码
/// 支持分组管理和类型安全
library;

/// 配置键基类
abstract class BaseConfigKey {
  /// 配置键名
  final String key;

  /// 配置描述
  final String description;

  /// 默认值
  final dynamic defaultValue;

  /// 配置分组
  final String group;

  /// 是否为敏感配置
  final bool isSensitive;

  /// 配置类型
  final Type valueType;

  const BaseConfigKey({
    required this.key,
    required this.description,
    required this.defaultValue,
    required this.group,
    this.isSensitive = false,
    required this.valueType,
  });

  /// 获取完整的配置键（包含分组前缀）
  String get fullKey => '$group.$key';

  /// 类型安全的值转换
  T getValue<T>(dynamic value) {
    if (value == null) return defaultValue as T;

    try {
      if (T == String) return value.toString() as T;
      if (T == int) return int.parse(value.toString()) as T;
      if (T == double) return double.parse(value.toString()) as T;
      if (T == bool) return (value.toString().toLowerCase() == 'true') as T;
      return value as T;
    } catch (e) {
      return defaultValue as T;
    }
  }
}

/// 字符串配置键
class StringConfigKey extends BaseConfigKey {
  const StringConfigKey({
    required super.key,
    required super.description,
    required String super.defaultValue,
    required super.group,
    super.isSensitive = false,
  }) : super(valueType: String);
}

/// 整数配置键
class IntConfigKey extends BaseConfigKey {
  const IntConfigKey({
    required super.key,
    required super.description,
    required int super.defaultValue,
    required super.group,
    super.isSensitive = false,
  }) : super(valueType: int);
}

/// 布尔配置键
class BoolConfigKey extends BaseConfigKey {
  const BoolConfigKey({
    required super.key,
    required super.description,
    required bool super.defaultValue,
    required super.group,
    super.isSensitive = false,
  }) : super(valueType: bool);
}

/// 双精度配置键
class DoubleConfigKey extends BaseConfigKey {
  const DoubleConfigKey({
    required super.key,
    required super.description,
    required double super.defaultValue,
    required super.group,
    super.isSensitive = false,
  }) : super(valueType: double);
}

/// 应用配置键定义
class AppConfigKeys {
  AppConfigKeys._();

  // ==================== 应用基础配置 ====================
  static const String _appGroup = 'app';

  /// 应用版本检查URL
  static const appVersionCheckUrl = StringConfigKey(
    key: 'version_check_url',
    description: '应用版本检查接口地址',
    defaultValue: 'https://api.example.com/version/check',
    group: _appGroup,
  );

  /// 应用名称
  static const appDisplayName = StringConfigKey(
    key: 'display_name',
    description: '应用显示名称',
    defaultValue: 'Flutter App',
    group: _appGroup,
  );

  /// 是否启用调试模式
  static const debugModeEnabled = BoolConfigKey(
    key: 'debug_mode_enabled',
    description: '是否启用调试模式',
    defaultValue: false,
    group: _appGroup,
  );

  // ==================== 网络配置 ====================
  static const String _networkGroup = 'network';

  /// API基础URL
  static const apiBaseUrl = StringConfigKey(
    key: 'base_url',
    description: 'API服务器基础地址',
    defaultValue: 'https://api.example.com',
    group: _networkGroup,
  );

  /// 请求超时时间（秒）
  static const requestTimeout = IntConfigKey(
    key: 'request_timeout',
    description: '网络请求超时时间（秒）',
    defaultValue: 30,
    group: _networkGroup,
  );

  /// 连接超时时间（秒）
  static const connectTimeout = IntConfigKey(
    key: 'connect_timeout',
    description: '网络连接超时时间（秒）',
    defaultValue: 10,
    group: _networkGroup,
  );

  // ==================== 功能开关配置 ====================
  static const String _featureGroup = 'feature';

  /// 是否启用新功能A
  static const featureAEnabled = BoolConfigKey(
    key: 'feature_a_enabled',
    description: '是否启用新功能A',
    defaultValue: false,
    group: _featureGroup,
  );

  /// 是否启用推送通知
  static const pushNotificationEnabled = BoolConfigKey(
    key: 'push_notification_enabled',
    description: '是否启用推送通知',
    defaultValue: true,
    group: _featureGroup,
  );

  // ==================== 缓存配置 ====================
  static const String _cacheGroup = 'cache';

  /// 缓存过期时间（分钟）
  static const cacheExpireMinutes = IntConfigKey(
    key: 'expire_minutes',
    description: '缓存过期时间（分钟）',
    defaultValue: 60,
    group: _cacheGroup,
  );

  /// 最大缓存大小（MB）
  static const maxCacheSizeMB = IntConfigKey(
    key: 'max_size_mb',
    description: '最大缓存大小（MB）',
    defaultValue: 100,
    group: _cacheGroup,
  );

  // ==================== 获取所有配置键 ====================

  /// 获取所有配置键
  static List<BaseConfigKey> getAllKeys() {
    return [
      // 应用配置
      appVersionCheckUrl,
      appDisplayName,
      debugModeEnabled,

      // 网络配置
      apiBaseUrl,
      requestTimeout,
      connectTimeout,

      // 功能开关
      featureAEnabled,
      pushNotificationEnabled,

      // 缓存配置
      cacheExpireMinutes,
      maxCacheSizeMB,
    ];
  }

  /// 根据分组获取配置键
  static List<BaseConfigKey> getKeysByGroup(String group) {
    return getAllKeys().where((key) => key.group == group).toList();
  }

  /// 根据键名查找配置键
  static BaseConfigKey? findKey(String fullKey) {
    try {
      return getAllKeys().firstWhere((key) => key.fullKey == fullKey);
    } catch (e) {
      return null;
    }
  }
}
