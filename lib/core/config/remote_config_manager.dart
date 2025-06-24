/// 远程配置管理器
///
/// 核心配置管理实现，支持：
/// - 多策略配置获取
/// - 分层缓存机制
/// - 配置变更通知
/// - 定时更新任务
/// - 类型安全的配置访问
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'config_keys.dart';
import 'config_manager_interface.dart';
import 'strategies/http_config_fetch_strategy.dart';
import 'strategies/hybrid_config_cache_strategy.dart';

/// 远程配置管理器实现
class RemoteConfigManager implements IConfigManager {
  /// 单例实例
  static RemoteConfigManager? _instance;
  static RemoteConfigManager get instance =>
      _instance ??= RemoteConfigManager._();

  RemoteConfigManager._();

  /// 配置获取策略列表
  final List<IConfigFetchStrategy> _fetchStrategies = [];

  /// 配置缓存策略
  late IConfigCacheStrategy _cacheStrategy;

  /// 当前配置数据
  final Map<String, dynamic> _configs = {};

  /// 配置变更流控制器
  final StreamController<ConfigChangeEvent> _configChangeController =
      StreamController<ConfigChangeEvent>.broadcast();

  /// 配置变更监听器
  final Map<String, List<Function(ConfigChangeEvent)>> _changeListeners = {};

  /// 定时更新任务
  Timer? _periodicUpdateTimer;

  /// 是否正在更新
  bool _isUpdating = false;

  /// 最后更新时间
  DateTime? _lastUpdateTime;

  /// 是否已初始化
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('配置管理器已初始化，跳过重复初始化');
      return;
    }

    try {
      debugPrint('开始初始化远程配置管理器...');

      // 初始化缓存策略
      _cacheStrategy = HybridConfigCacheStrategy(cacheExpireMinutes: 60);

      // 初始化获取策略
      _initializeFetchStrategies();

      // 从缓存加载配置
      await _loadFromCache();

      // 如果缓存为空或过期，尝试从远程获取
      if (_configs.isEmpty || await _cacheStrategy.isCacheExpired()) {
        debugPrint('缓存为空或已过期，尝试从远程获取配置...');
        await refreshFromRemote();
      }

      _initialized = true;
      debugPrint('远程配置管理器初始化完成');
    } catch (e) {
      debugPrint('远程配置管理器初始化失败: $e');
      // 不抛出异常，允许应用使用默认配置运行
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁远程配置管理器...');

    stopPeriodicUpdate();
    await _configChangeController.close();
    _changeListeners.clear();
    _configs.clear();

    _initialized = false;
    debugPrint('远程配置管理器已销毁');
  }

  /// 初始化获取策略
  void _initializeFetchStrategies() {
    _fetchStrategies.clear();

    // 添加HTTP获取策略
    _fetchStrategies.add(
      HttpConfigFetchStrategy(
        configUrl: '/api/config', // 使用相对路径，让NetworkService处理baseUrl
        timeout: const Duration(seconds: 30),
        extraHeaders: {'X-Config-Version': '1.0'},
        queryParameters: {'client': 'flutter', 'version': '1.0.0'},
      ),
    );

    // 按优先级排序
    _fetchStrategies.sort((a, b) => a.priority.compareTo(b.priority));

    debugPrint('配置获取策略初始化完成，策略数量: ${_fetchStrategies.length}');
  }

  @override
  String getString(StringConfigKey key) {
    return getValue<String>(key);
  }

  @override
  int getInt(IntConfigKey key) {
    return getValue<int>(key);
  }

  @override
  bool getBool(BoolConfigKey key) {
    return getValue<bool>(key);
  }

  @override
  double getDouble(DoubleConfigKey key) {
    return getValue<double>(key);
  }

  @override
  T getValue<T>(BaseConfigKey key) {
    final value = _configs[key.fullKey];
    return key.getValue<T>(value);
  }

  @override
  void setValue(BaseConfigKey key, dynamic value) {
    final oldValue = _configs[key.fullKey];
    _configs[key.fullKey] = value;

    // 触发变更事件
    final event = ConfigChangeEvent(
      key: key.fullKey,
      oldValue: oldValue,
      newValue: value,
      timestamp: DateTime.now(),
      source: 'manual',
    );

    _notifyConfigChange(event);
  }

  @override
  bool hasConfig(BaseConfigKey key) {
    return _configs.containsKey(key.fullKey);
  }

  @override
  Future<ConfigUpdateResult> refreshFromRemote() async {
    if (_isUpdating) {
      debugPrint('配置更新正在进行中，跳过重复更新');
      return ConfigUpdateResult.failure(
        error: '配置更新正在进行中',
        duration: Duration.zero,
      );
    }

    _isUpdating = true;
    final startTime = DateTime.now();

    try {
      debugPrint('开始从远程刷新配置...');

      Map<String, dynamic>? newConfigs;
      String? lastError;

      // 尝试所有可用的获取策略
      for (final strategy in _fetchStrategies) {
        if (!strategy.isAvailable) {
          debugPrint('策略 ${strategy.name} 不可用，跳过');
          continue;
        }

        try {
          newConfigs = await strategy.fetchConfigs();
          debugPrint('使用策略 ${strategy.name} 成功获取配置');
          break;
        } catch (e) {
          lastError = e.toString();
          debugPrint('策略 ${strategy.name} 获取配置失败: $e');
        }
      }

      if (newConfigs == null) {
        throw Exception('所有配置获取策略都失败了。最后错误: $lastError');
      }

      // 更新配置并保存到缓存
      final updatedCount = await _updateConfigs(newConfigs, 'remote');
      await _cacheStrategy.saveToCache(newConfigs);

      _lastUpdateTime = DateTime.now();
      final duration = _lastUpdateTime!.difference(startTime);

      debugPrint(
        '远程配置刷新完成，更新了 $updatedCount 个配置项，耗时: ${duration.inMilliseconds}ms',
      );

      return ConfigUpdateResult.success(
        updatedCount: updatedCount,
        duration: duration,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('远程配置刷新失败: $e');

      return ConfigUpdateResult.failure(
        error: e.toString(),
        duration: duration,
      );
    } finally {
      _isUpdating = false;
    }
  }

  @override
  Future<ConfigUpdateResult> refreshFromCache() async {
    final startTime = DateTime.now();

    try {
      debugPrint('开始从缓存刷新配置...');

      final cachedConfigs = await _cacheStrategy.loadFromCache();
      if (cachedConfigs == null) {
        throw Exception('缓存中没有找到配置数据');
      }

      final updatedCount = await _updateConfigs(cachedConfigs, 'cache');
      final duration = DateTime.now().difference(startTime);

      debugPrint('缓存配置刷新完成，更新了 $updatedCount 个配置项');

      return ConfigUpdateResult.success(
        updatedCount: updatedCount,
        duration: duration,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('缓存配置刷新失败: $e');

      return ConfigUpdateResult.failure(
        error: e.toString(),
        duration: duration,
      );
    }
  }

  /// 从缓存加载配置
  Future<void> _loadFromCache() async {
    try {
      final cachedConfigs = await _cacheStrategy.loadFromCache();
      if (cachedConfigs != null) {
        _configs.clear();
        _configs.addAll(cachedConfigs);
        debugPrint('从缓存加载了 ${cachedConfigs.length} 个配置项');
      }
    } catch (e) {
      debugPrint('从缓存加载配置失败: $e');
    }
  }

  /// 更新配置数据
  Future<int> _updateConfigs(
    Map<String, dynamic> newConfigs,
    String source,
  ) async {
    int updatedCount = 0;

    for (final entry in newConfigs.entries) {
      final key = entry.key;
      final newValue = entry.value;
      final oldValue = _configs[key];

      if (oldValue != newValue) {
        _configs[key] = newValue;
        updatedCount++;

        // 触发变更事件
        final event = ConfigChangeEvent(
          key: key,
          oldValue: oldValue,
          newValue: newValue,
          timestamp: DateTime.now(),
          source: source,
        );

        _notifyConfigChange(event);
      }
    }

    return updatedCount;
  }

  /// 通知配置变更
  void _notifyConfigChange(ConfigChangeEvent event) {
    // 发送到流
    _configChangeController.add(event);

    // 通知特定监听器
    final listeners = _changeListeners[event.key];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(event);
        } catch (e) {
          debugPrint('配置变更监听器执行失败: $e');
        }
      }
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheStrategy.clearCache();
    debugPrint('配置缓存已清除');
  }

  @override
  Stream<ConfigChangeEvent> get configChangeStream =>
      _configChangeController.stream;

  @override
  DateTime? get lastUpdateTime => _lastUpdateTime;

  @override
  bool get isUpdating => _isUpdating;

  @override
  void startPeriodicUpdate({Duration interval = const Duration(minutes: 30)}) {
    stopPeriodicUpdate();

    _periodicUpdateTimer = Timer.periodic(interval, (timer) async {
      debugPrint('执行定时配置更新...');
      await refreshFromRemote();
    });

    debugPrint('定时配置更新已启动，间隔: ${interval.inMinutes} 分钟');
  }

  @override
  void stopPeriodicUpdate() {
    _periodicUpdateTimer?.cancel();
    _periodicUpdateTimer = null;
    debugPrint('定时配置更新已停止');
  }

  @override
  void addConfigChangeListener(
    String key,
    Function(ConfigChangeEvent) listener,
  ) {
    _changeListeners.putIfAbsent(key, () => []).add(listener);
  }

  @override
  void removeConfigChangeListener(String key) {
    _changeListeners.remove(key);
  }

  @override
  Map<String, dynamic> getBatchConfigs(List<BaseConfigKey> keys) {
    final result = <String, dynamic>{};
    for (final key in keys) {
      result[key.fullKey] = getValue(key);
    }
    return result;
  }

  @override
  Map<String, dynamic> exportAllConfigs() {
    return Map<String, dynamic>.from(_configs);
  }
}
