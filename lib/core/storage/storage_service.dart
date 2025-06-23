/// 存储服务封装
///
/// 提供统一的数据存储接口，包括：
/// - SharedPreferences 简单键值存储
/// - FlutterSecureStorage 安全存储
/// - Hive 本地数据库
library;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 存储缓存策略枚举
enum StorageCacheStrategy {
  /// 内存缓存 - 用于频繁访问的敏感数据
  memory,

  /// 持久化缓存 - 用于需要持久化的数据
  persistent,

  /// 混合缓存 - 内存+持久化
  hybrid,
}

/// 同步存储接口
abstract class ISyncStorage {
  /// 同步获取字符串
  String? getStringSync(String key);

  /// 同步设置字符串
  bool setStringSync(String key, String value);

  /// 同步删除
  bool removeSync(String key);

  /// 同步检查键是否存在
  bool containsKeySync(String key);
}

/// 存储服务类
class StorageService implements ISyncStorage {
  static StorageService? _instance;
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  late Box _hiveBox;

  // 内存缓存，用于同步访问敏感数据
  final Map<String, String> _memoryCache = {};

  // 缓存策略配置
  final Map<String, StorageCacheStrategy> _cacheStrategies = {};

  StorageService._internal();

  /// 单例模式
  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// 初始化存储服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      /* iOptions: IOSOptions(
        accessibility: KeychainItemAccessibility.first_unlock_this_device,
      ), */
    );
    _hiveBox = await Hive.openBox('app_storage');

    // 初始化缓存策略
    _initializeCacheStrategies();

    // 预加载关键数据到内存缓存
    await _preloadCriticalData();
  }

  /// 初始化缓存策略
  void _initializeCacheStrategies() {
    // 为敏感数据配置内存缓存策略
    _cacheStrategies['user_token'] = StorageCacheStrategy.memory;
    _cacheStrategies['refresh_token'] = StorageCacheStrategy.memory;
    _cacheStrategies['user_info'] = StorageCacheStrategy.hybrid;

    // 为应用设置配置持久化缓存
    _cacheStrategies.addAll({
      'theme_mode': StorageCacheStrategy.persistent,
      'language': StorageCacheStrategy.persistent,
      'notification_enabled': StorageCacheStrategy.persistent,
    });
  }

  /// 预加载关键数据到内存缓存
  Future<void> _preloadCriticalData() async {
    try {
      // 预加载用户token到内存缓存
      final token = await getSecureString('user_token');
      if (token != null) {
        _memoryCache['user_token'] = token;
      }

      // 预加载刷新token到内存缓存
      final refreshToken = await getSecureString('refresh_token');
      if (refreshToken != null) {
        _memoryCache['refresh_token'] = refreshToken;
      }
    } catch (e) {
      // 预加载失败不影响应用启动
      print('预加载关键数据失败: $e');
    }
  }

  // ==================== SharedPreferences 操作 ====================

  /// 存储字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// 存储整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// 存储双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// 存储对象（JSON序列化）
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = json.encode(value);
    return await _prefs.setString(key, jsonString);
  }

  /// 获取对象（JSON反序列化）
  Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// 删除键值对
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // ==================== FlutterSecureStorage 操作 ====================

  /// 安全存储字符串
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// 安全获取字符串
  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// 安全存储对象
  Future<void> setSecureObject(String key, Map<String, dynamic> value) async {
    final jsonString = json.encode(value);
    await _secureStorage.write(key: key, value: jsonString);
  }

  /// 安全获取对象
  Future<Map<String, dynamic>?> getSecureObject(String key) async {
    final jsonString = await _secureStorage.read(key: key);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// 删除安全存储的键值对
  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// 清除所有安全存储数据
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  /// 检查安全存储键是否存在
  Future<bool> containsSecureKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }

  // ==================== Hive 操作 ====================

  /// Hive存储数据
  Future<void> setHiveData(String key, dynamic value) async {
    await _hiveBox.put(key, value);
  }

  /// Hive获取数据
  T? getHiveData<T>(String key) {
    return _hiveBox.get(key) as T?;
  }

  /// Hive删除数据
  Future<void> removeHiveData(String key) async {
    await _hiveBox.delete(key);
  }

  /// Hive清除所有数据
  Future<void> clearHiveData() async {
    await _hiveBox.clear();
  }

  /// Hive检查键是否存在
  bool containsHiveKey(String key) {
    return _hiveBox.containsKey(key);
  }

  // ==================== 便捷方法 ====================

  /// 存储用户Token
  Future<void> setToken(String token) async {
    await setSecureString('user_token', token);
    // 同步更新内存缓存
    updateMemoryCache('user_token', token);
  }

  /// 获取用户Token
  Future<String?> getToken() async {
    final token = await getSecureString('user_token');
    // 同步更新内存缓存
    if (token != null) {
      updateMemoryCache('user_token', token);
    }
    return token;
  }

  /// 清除用户Token
  Future<void> clearToken() async {
    await removeSecure('user_token');
    // 同步清除内存缓存
    updateMemoryCache('user_token', null);
  }

  /// 存储用户信息
  Future<void> setUserInfo(Map<String, dynamic> userInfo) async {
    await setSecureObject('user_info', userInfo);
    // 同步更新内存缓存
    final jsonString = json.encode(userInfo);
    updateMemoryCache('user_info', jsonString);
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    final userInfo = await getSecureObject('user_info');
    // 同步更新内存缓存
    if (userInfo != null) {
      final jsonString = json.encode(userInfo);
      updateMemoryCache('user_info', jsonString);
    }
    return userInfo;
  }

  /// 清除用户信息
  Future<void> clearUserInfo() async {
    await removeSecure('user_info');
    // 同步清除内存缓存
    updateMemoryCache('user_info', null);
  }

  /// 设置应用设置
  Future<bool> setAppSetting(String key, dynamic value) async {
    if (value is String) {
      return await setString('setting_$key', value);
    } else if (value is int) {
      return await setInt('setting_$key', value);
    } else if (value is bool) {
      return await setBool('setting_$key', value);
    } else if (value is double) {
      return await setDouble('setting_$key', value);
    } else {
      return await setObject('setting_$key', value as Map<String, dynamic>);
    }
  }

  /// 获取应用设置
  T? getAppSetting<T>(String key) {
    if (T == String) {
      return getString('setting_$key') as T?;
    } else if (T == int) {
      return getInt('setting_$key') as T?;
    } else if (T == bool) {
      return getBool('setting_$key') as T?;
    } else if (T == double) {
      return getDouble('setting_$key') as T?;
    } else {
      return getObject('setting_$key') as T?;
    }
  }

  // ==================== 同步存储接口实现 ====================

  @override
  String? getStringSync(String key) {
    final strategy = _cacheStrategies[key] ?? StorageCacheStrategy.persistent;

    switch (strategy) {
      case StorageCacheStrategy.memory:
        return _memoryCache[key];
      case StorageCacheStrategy.persistent:
        return getString(key);
      case StorageCacheStrategy.hybrid:
        // 优先从内存缓存获取，如果没有则从持久化存储获取
        return _memoryCache[key] ?? getString(key);
    }
  }

  @override
  bool setStringSync(String key, String value) {
    final strategy = _cacheStrategies[key] ?? StorageCacheStrategy.persistent;

    switch (strategy) {
      case StorageCacheStrategy.memory:
        _memoryCache[key] = value;
        return true;
      case StorageCacheStrategy.persistent:
        // 注意：SharedPreferences的set方法是异步的，这里只能返回true
        // 实际的持久化操作需要异步进行
        setString(key, value);
        return true;
      case StorageCacheStrategy.hybrid:
        _memoryCache[key] = value;
        setString(key, value);
        return true;
    }
  }

  @override
  bool removeSync(String key) {
    final strategy = _cacheStrategies[key] ?? StorageCacheStrategy.persistent;

    switch (strategy) {
      case StorageCacheStrategy.memory:
        _memoryCache.remove(key);
        return true;
      case StorageCacheStrategy.persistent:
        remove(key);
        return true;
      case StorageCacheStrategy.hybrid:
        _memoryCache.remove(key);
        remove(key);
        return true;
    }
  }

  @override
  bool containsKeySync(String key) {
    final strategy = _cacheStrategies[key] ?? StorageCacheStrategy.persistent;

    switch (strategy) {
      case StorageCacheStrategy.memory:
        return _memoryCache.containsKey(key);
      case StorageCacheStrategy.persistent:
        return containsKey(key);
      case StorageCacheStrategy.hybrid:
        return _memoryCache.containsKey(key) || containsKey(key);
    }
  }

  // ==================== 便捷同步方法 ====================

  /// 同步获取用户Token
  String? getTokenSync() {
    return getStringSync('user_token');
  }

  /// 同步设置用户Token（仅更新内存缓存）
  bool setTokenSync(String token) {
    return setStringSync('user_token', token);
  }

  /// 同步清除用户Token
  bool clearTokenSync() {
    return removeSync('user_token');
  }

  /// 同步检查Token是否存在
  bool hasTokenSync() {
    return containsKeySync('user_token');
  }

  /// 同步获取刷新Token
  String? getRefreshTokenSync() {
    return getStringSync('refresh_token');
  }

  /// 同步设置刷新Token
  bool setRefreshTokenSync(String token) {
    return setStringSync('refresh_token', token);
  }

  /// 同步获取用户信息
  Map<String, dynamic>? getUserInfoSync() {
    final jsonString = getStringSync('user_info');
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        // JSON解析失败，返回null
        return null;
      }
    }
    return null;
  }

  /// 同步设置用户信息
  bool setUserInfoSync(Map<String, dynamic> userInfo) {
    final jsonString = json.encode(userInfo);
    return setStringSync('user_info', jsonString);
  }

  /// 同步清除用户信息
  bool clearUserInfoSync() {
    return removeSync('user_info');
  }

  /// 更新内存缓存（用于异步操作完成后同步内存状态）
  void updateMemoryCache(String key, String? value) {
    if (value != null) {
      _memoryCache[key] = value;
    } else {
      _memoryCache.remove(key);
    }
  }

  /// 清除内存缓存
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// 获取缓存策略
  StorageCacheStrategy getCacheStrategy(String key) {
    return _cacheStrategies[key] ?? StorageCacheStrategy.persistent;
  }

  /// 设置缓存策略
  void setCacheStrategy(String key, StorageCacheStrategy strategy) {
    _cacheStrategies[key] = strategy;
  }
}
