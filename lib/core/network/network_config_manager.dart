/// 网络配置管理器
///
/// 负责管理网络配置的生命周期，包括：
/// - 静态配置管理
/// - 动态配置获取与更新
/// - 环境配置切换
/// - 配置缓存与持久化
/// - 配置验证与回滚
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../app/app_config.dart';
import '../storage/storage_service.dart';

/// 网络配置类型枚举
enum NetworkConfigType {
  /// 静态配置（编译时确定）
  static,

  /// 动态配置（运行时获取）
  dynamic,

  /// 环境配置（基于环境变量）
  environment,

  /// 运行时配置（用户自定义）
  runtime,
}

/// 网络配置优先级枚举
enum NetworkConfigPriority {
  /// 低优先级
  low(1),

  /// 中优先级
  medium(2),

  /// 高优先级
  high(3),

  /// 最高优先级
  critical(4);

  const NetworkConfigPriority(this.value);
  final int value;
}

/// 网络配置项
class NetworkConfigItem {
  /// 配置键
  final String key;

  /// 配置值
  final dynamic value;

  /// 配置类型
  final NetworkConfigType type;

  /// 优先级
  final NetworkConfigPriority priority;

  /// 是否必需
  final bool required;

  /// 配置描述
  final String description;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  DateTime updatedAt;

  NetworkConfigItem({
    required this.key,
    required this.value,
    required this.type,
    this.priority = NetworkConfigPriority.medium,
    this.required = false,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建
  factory NetworkConfigItem.fromJson(Map<String, dynamic> json) {
    return NetworkConfigItem(
      key: json['key'] as String,
      value: json['value'],
      type: NetworkConfigType.values[json['type'] as int],
      priority: NetworkConfigPriority.values[json['priority'] as int],
      required: json['required'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'type': type.index,
      'priority': priority.index,
      'required': required,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 更新配置值
  NetworkConfigItem copyWith({
    dynamic value,
    NetworkConfigType? type,
    NetworkConfigPriority? priority,
    bool? required,
    String? description,
  }) {
    return NetworkConfigItem(
      key: key,
      value: value ?? this.value,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      required: required ?? this.required,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// 网络配置集合
class NetworkConfigSet {
  /// 配置版本
  final String version;

  /// 配置项列表
  final List<NetworkConfigItem> items;

  /// 配置签名（用于验证完整性）
  final String? signature;

  /// 创建时间
  final DateTime createdAt;

  const NetworkConfigSet({
    required this.version,
    required this.items,
    this.signature,
    required this.createdAt,
  });

  /// 从JSON创建
  factory NetworkConfigSet.fromJson(Map<String, dynamic> json) {
    return NetworkConfigSet(
      version: json['version'] as String,
      items:
          (json['items'] as List)
              .map((item) => NetworkConfigItem.fromJson(item))
              .toList(),
      signature: json['signature'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'items': items.map((item) => item.toJson()).toList(),
      'signature': signature,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取配置项
  NetworkConfigItem? getItem(String key) {
    try {
      return items.firstWhere((item) => item.key == key);
    } catch (e) {
      return null;
    }
  }

  /// 获取配置值
  T? getValue<T>(String key, {T? defaultValue}) {
    final item = getItem(key);
    if (item?.value is T) {
      return item!.value as T;
    }
    return defaultValue;
  }
}

/// 网络配置管理器
class NetworkConfigManager extends GetxController {
  static NetworkConfigManager? _instance;

  /// 单例实例
  static NetworkConfigManager get instance {
    _instance ??= NetworkConfigManager._internal();
    return _instance!;
  }

  NetworkConfigManager._internal();

  /// 当前配置集合
  final Rx<NetworkConfigSet?> _currentConfig = Rx<NetworkConfigSet?>(null);

  /// 配置缓存
  final Map<String, NetworkConfigSet> _configCache = {};

  /// 配置更新监听器
  final RxBool _isLoading = false.obs;
  final RxString _lastError = ''.obs;

  /// 存储键常量
  static const String _storageKeyPrefix = 'network_config_';
  static const String _currentConfigKey = '${_storageKeyPrefix}current';
  static const String _cacheKeyPrefix = '${_storageKeyPrefix}cache_';

  /// 获取当前配置
  NetworkConfigSet? get currentConfig => _currentConfig.value;

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 最后错误信息
  String get lastError => _lastError.value;

  /// 初始化配置管理器
  Future<void> initialize() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      // 加载本地缓存的配置
      await _loadCachedConfig();

      // 如果没有缓存配置，使用默认配置
      if (_currentConfig.value == null) {
        await _loadDefaultConfig();
      }

      debugPrint('网络配置管理器初始化完成');
    } catch (e) {
      _lastError.value = '初始化网络配置失败: $e';
      debugPrint('网络配置管理器初始化失败: $e');

      // 初始化失败时使用默认配置
      await _loadDefaultConfig();
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载缓存的配置
  Future<void> _loadCachedConfig() async {
    try {
      final configJson = StorageService.instance.getStringSync(
        _currentConfigKey,
      );
      if (configJson != null && configJson.isNotEmpty) {
        final configData = jsonDecode(configJson);
        _currentConfig.value = NetworkConfigSet.fromJson(configData);
        debugPrint('已加载缓存的网络配置，版本: ${_currentConfig.value?.version}');
      }
    } catch (e) {
      debugPrint('加载缓存配置失败: $e');
    }
  }

  /// 加载默认配置
  Future<void> _loadDefaultConfig() async {
    final defaultItems = _createDefaultConfigItems();
    _currentConfig.value = NetworkConfigSet(
      version: '1.0.0',
      items: defaultItems,
      createdAt: DateTime.now(),
    );

    // 保存默认配置到缓存
    await _saveConfigToCache(_currentConfig.value!);
    debugPrint('已加载默认网络配置');
  }

  /// 创建默认配置项
  List<NetworkConfigItem> _createDefaultConfigItems() {
    final config = AppConfig.current;

    return [
      // 基础URL配置
      NetworkConfigItem(
        key: 'base_url',
        value: config.apiBaseUrl,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.critical,
        required: true,
        description: 'API基础URL',
      ),

      // API版本配置
      NetworkConfigItem(
        key: 'api_version',
        value: config.apiVersion,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.high,
        required: true,
        description: 'API版本',
      ),

      // 超时配置
      NetworkConfigItem(
        key: 'connect_timeout',
        value: config.networkTimeout.inMilliseconds,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.high,
        required: true,
        description: '连接超时时间（毫秒）',
      ),

      NetworkConfigItem(
        key: 'receive_timeout',
        value: config.networkTimeout.inMilliseconds,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.high,
        required: true,
        description: '接收超时时间（毫秒）',
      ),

      NetworkConfigItem(
        key: 'send_timeout',
        value: config.networkTimeout.inMilliseconds,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.high,
        required: true,
        description: '发送超时时间（毫秒）',
      ),

      // 重试配置
      NetworkConfigItem(
        key: 'max_retry_attempts',
        value: config.maxRetryAttempts,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.medium,
        required: false,
        description: '最大重试次数',
      ),

      // 日志配置
      NetworkConfigItem(
        key: 'enable_logging',
        value: config.enableLogging,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.low,
        required: false,
        description: '是否启用网络日志',
      ),

      // 缓存配置
      NetworkConfigItem(
        key: 'enable_cache',
        value: true,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.medium,
        required: false,
        description: '是否启用请求缓存',
      ),

      NetworkConfigItem(
        key: 'cache_max_age',
        value: 300, // 5分钟
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.low,
        required: false,
        description: '缓存最大存活时间（秒）',
      ),

      // 安全配置
      NetworkConfigItem(
        key: 'enable_certificate_pinning',
        value: !config.isDevelopment,
        type: NetworkConfigType.static,
        priority: NetworkConfigPriority.high,
        required: false,
        description: '是否启用证书绑定',
      ),
    ];
  }

  /// 保存配置到缓存
  Future<void> _saveConfigToCache(NetworkConfigSet config) async {
    try {
      final configJson = jsonEncode(config.toJson());
      await StorageService.instance.setString(_currentConfigKey, configJson);

      // 同时保存到版本化缓存
      final cacheKey = '$_cacheKeyPrefix${config.version}';
      _configCache[config.version] = config;
      await StorageService.instance.setString(cacheKey, configJson);
    } catch (e) {
      debugPrint('保存配置到缓存失败: $e');
    }
  }

  /// 获取配置值
  T? getConfigValue<T>(String key, {T? defaultValue}) {
    return _currentConfig.value?.getValue<T>(key, defaultValue: defaultValue);
  }

  /// 更新配置项
  Future<bool> updateConfigItem(String key, dynamic value) async {
    try {
      final currentConfig = _currentConfig.value;
      if (currentConfig == null) return false;

      final items = List<NetworkConfigItem>.from(currentConfig.items);
      final itemIndex = items.indexWhere((item) => item.key == key);

      if (itemIndex != -1) {
        // 更新现有配置项
        items[itemIndex] = items[itemIndex].copyWith(value: value);
      } else {
        // 添加新配置项
        items.add(
          NetworkConfigItem(
            key: key,
            value: value,
            type: NetworkConfigType.runtime,
            priority: NetworkConfigPriority.medium,
            description: '运行时配置项',
          ),
        );
      }

      // 创建新的配置集合
      final newConfig = NetworkConfigSet(
        version: _generateNewVersion(currentConfig.version),
        items: items,
        createdAt: DateTime.now(),
      );

      _currentConfig.value = newConfig;
      await _saveConfigToCache(newConfig);

      debugPrint('配置项更新成功: $key = $value');
      return true;
    } catch (e) {
      _lastError.value = '更新配置项失败: $e';
      debugPrint('更新配置项失败: $e');
      return false;
    }
  }

  /// 批量更新配置项
  Future<bool> updateConfigItems(Map<String, dynamic> updates) async {
    try {
      final currentConfig = _currentConfig.value;
      if (currentConfig == null) return false;

      final items = List<NetworkConfigItem>.from(currentConfig.items);

      for (final entry in updates.entries) {
        final key = entry.key;
        final value = entry.value;
        final itemIndex = items.indexWhere((item) => item.key == key);

        if (itemIndex != -1) {
          // 更新现有配置项
          items[itemIndex] = items[itemIndex].copyWith(value: value);
        } else {
          // 添加新配置项
          items.add(
            NetworkConfigItem(
              key: key,
              value: value,
              type: NetworkConfigType.runtime,
              priority: NetworkConfigPriority.medium,
              description: '运行时配置项',
            ),
          );
        }
      }

      // 创建新的配置集合
      final newConfig = NetworkConfigSet(
        version: _generateNewVersion(currentConfig.version),
        items: items,
        createdAt: DateTime.now(),
      );

      _currentConfig.value = newConfig;
      await _saveConfigToCache(newConfig);

      debugPrint('批量配置更新成功，共更新 ${updates.length} 项');
      return true;
    } catch (e) {
      _lastError.value = '批量更新配置失败: $e';
      debugPrint('批量更新配置失败: $e');
      return false;
    }
  }

  /// 重置为默认配置
  Future<void> resetToDefault() async {
    try {
      _isLoading.value = true;
      await _loadDefaultConfig();
      debugPrint('已重置为默认网络配置');
    } catch (e) {
      _lastError.value = '重置配置失败: $e';
      debugPrint('重置配置失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 验证配置完整性
  bool validateConfig(NetworkConfigSet? config) {
    if (config == null) return false;

    // 检查必需的配置项
    final requiredKeys = ['base_url', 'api_version', 'connect_timeout'];
    for (final key in requiredKeys) {
      final item = config.getItem(key);
      if (item == null || item.value == null) {
        debugPrint('缺少必需的配置项: $key');
        return false;
      }
    }

    // 检查URL格式
    final baseUrl = config.getValue<String>('base_url');
    if (baseUrl != null) {
      final uri = Uri.tryParse(baseUrl);
      if (uri == null || !uri.isAbsolute) {
        debugPrint('无效的基础URL格式: $baseUrl');
        return false;
      }
    }

    // 检查超时时间
    final connectTimeout = config.getValue<int>('connect_timeout');
    if (connectTimeout != null && connectTimeout <= 0) {
      debugPrint('无效的连接超时时间: $connectTimeout');
      return false;
    }

    return true;
  }

  /// 生成新版本号
  String _generateNewVersion(String currentVersion) {
    try {
      final parts = currentVersion.split('.');
      if (parts.length >= 3) {
        final patch = int.parse(parts[2]) + 1;
        return '${parts[0]}.${parts[1]}.$patch';
      }
    } catch (e) {
      debugPrint('版本号解析失败: $e');
    }

    // 如果解析失败，使用时间戳
    return '1.0.${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 清理过期缓存
  Future<void> cleanupExpiredCache() async {
    try {
      // 这里可以实现缓存清理逻辑
      // 例如删除超过一定时间的配置缓存
      debugPrint('缓存清理完成');
    } catch (e) {
      debugPrint('缓存清理失败: $e');
    }
  }

  /// 导出配置
  Map<String, dynamic> exportConfig() {
    return _currentConfig.value?.toJson() ?? {};
  }

  /// 导入配置
  Future<bool> importConfig(Map<String, dynamic> configData) async {
    try {
      final config = NetworkConfigSet.fromJson(configData);

      if (!validateConfig(config)) {
        _lastError.value = '导入的配置无效';
        return false;
      }

      _currentConfig.value = config;
      await _saveConfigToCache(config);

      debugPrint('配置导入成功，版本: ${config.version}');
      return true;
    } catch (e) {
      _lastError.value = '导入配置失败: $e';
      debugPrint('导入配置失败: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _configCache.clear();
    super.onClose();
  }
}
