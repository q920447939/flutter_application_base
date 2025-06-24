/// 配置管理器接口定义
///
/// 定义配置管理的核心契约，支持多种实现策略
library;

import 'dart:async';
import 'config_keys.dart';

/// 配置更新结果
class ConfigUpdateResult {
  /// 是否成功
  final bool success;

  /// 更新的配置数量
  final int updatedCount;

  /// 错误信息
  final String? error;

  /// 更新耗时
  final Duration duration;

  /// 更新时间戳
  final DateTime timestamp;

  const ConfigUpdateResult({
    required this.success,
    required this.updatedCount,
    this.error,
    required this.duration,
    required this.timestamp,
  });

  /// 创建成功结果
  factory ConfigUpdateResult.success({
    required int updatedCount,
    required Duration duration,
  }) {
    return ConfigUpdateResult(
      success: true,
      updatedCount: updatedCount,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  /// 创建失败结果
  factory ConfigUpdateResult.failure({
    required String error,
    required Duration duration,
  }) {
    return ConfigUpdateResult(
      success: false,
      updatedCount: 0,
      error: error,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }
}

/// 配置变更事件
class ConfigChangeEvent {
  /// 变更的配置键
  final String key;

  /// 旧值
  final dynamic oldValue;

  /// 新值
  final dynamic newValue;

  /// 变更时间
  final DateTime timestamp;

  /// 变更来源
  final String source;

  const ConfigChangeEvent({
    required this.key,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
    required this.source,
  });
}

/// 配置管理器接口
abstract class IConfigManager {
  /// 初始化配置管理器
  Future<void> initialize();

  /// 销毁配置管理器
  Future<void> dispose();

  /// 获取字符串配置
  String getString(StringConfigKey key);

  /// 获取整数配置
  int getInt(IntConfigKey key);

  /// 获取布尔配置
  bool getBool(BoolConfigKey key);

  /// 获取双精度配置
  double getDouble(DoubleConfigKey key);

  /// 获取原始值（任意类型）
  T getValue<T>(BaseConfigKey key);

  /// 设置配置值（仅内存缓存）
  void setValue(BaseConfigKey key, dynamic value);

  /// 检查配置是否存在
  bool hasConfig(BaseConfigKey key);

  /// 从远程服务器刷新配置
  Future<ConfigUpdateResult> refreshFromRemote();

  /// 从本地缓存刷新配置
  Future<ConfigUpdateResult> refreshFromCache();

  /// 清除所有缓存
  Future<void> clearCache();

  /// 获取配置变更流
  Stream<ConfigChangeEvent> get configChangeStream;

  /// 获取最后更新时间
  DateTime? get lastUpdateTime;

  /// 启动定时更新任务
  void startPeriodicUpdate({Duration interval = const Duration(minutes: 30)});

  /// 停止定时更新任务
  void stopPeriodicUpdate();

  /// 是否正在更新中
  bool get isUpdating;

  /// 注册配置变更监听器
  void addConfigChangeListener(
    String key,
    Function(ConfigChangeEvent) listener,
  );

  /// 移除配置变更监听器
  void removeConfigChangeListener(String key);

  /// 批量获取配置
  Map<String, dynamic> getBatchConfigs(List<BaseConfigKey> keys);

  /// 导出所有配置（用于调试）
  Map<String, dynamic> exportAllConfigs();
}

/// 配置获取策略接口
abstract class IConfigFetchStrategy {
  /// 策略名称
  String get name;

  /// 获取配置数据
  Future<Map<String, dynamic>> fetchConfigs();

  /// 是否可用
  bool get isAvailable;

  /// 优先级（数字越小优先级越高）
  int get priority;
}

/// 配置缓存策略接口
abstract class IConfigCacheStrategy {
  /// 策略名称
  String get name;

  /// 保存配置到缓存
  Future<void> saveToCache(Map<String, dynamic> configs);

  /// 从缓存加载配置
  Future<Map<String, dynamic>?> loadFromCache();

  /// 清除缓存
  Future<void> clearCache();

  /// 检查缓存是否过期
  Future<bool> isCacheExpired();

  /// 获取缓存时间戳
  Future<DateTime?> getCacheTimestamp();
}
