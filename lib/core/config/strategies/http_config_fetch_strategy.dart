/// HTTP配置获取策略
///
/// 通过HTTP请求从远程服务器获取配置信息
/// 基于已封装的NetworkService，充分利用其重试、缓存、安全等策略
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config_manager_interface.dart';
import '../../network/network_service.dart';

/// HTTP配置获取策略
class HttpConfigFetchStrategy implements IConfigFetchStrategy {
  /// 网络服务实例
  NetworkService? _networkService;

  /// 配置接口URL（相对路径或绝对路径）
  final String configUrl;

  /// 额外的请求头
  final Map<String, String> extraHeaders;

  /// 请求超时时间（可选，会覆盖NetworkService的默认配置）
  final Duration? timeout;

  /// 查询参数
  final Map<String, dynamic> queryParameters;

  /// 是否使用绝对URL（如果为false，会使用NetworkService的baseUrl）
  final bool useAbsoluteUrl;

  HttpConfigFetchStrategy({
    required this.configUrl,
    this.extraHeaders = const {},
    this.timeout,
    this.queryParameters = const {},
    this.useAbsoluteUrl = false,
  });

  @override
  String get name => 'http';

  @override
  int get priority => 1; // 最高优先级

  @override
  bool get isAvailable {
    try {
      // 检查NetworkService是否已注册并初始化
      if (!Get.isRegistered<NetworkService>()) {
        debugPrint('NetworkService未注册，HTTP配置获取策略不可用');
        return false;
      }

      final networkService = Get.find<NetworkService>();
      if (!networkService.isInitialized) {
        debugPrint('NetworkService未初始化，HTTP配置获取策略不可用');
        return false;
      }

      if (configUrl.isEmpty) {
        debugPrint('配置URL为空，HTTP配置获取策略不可用');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('检查HTTP配置获取策略可用性失败: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchConfigs() async {
    if (!isAvailable) {
      throw Exception('HTTP配置获取策略不可用：网络服务未初始化或配置URL为空');
    }

    _networkService = Get.find<NetworkService>();

    try {
      debugPrint('开始获取远程配置: $configUrl');

      // 不再需要构建请求选项，直接在Options中设置

      // 使用NetworkService发起GET请求
      // NetworkService已经内置了重试、缓存、安全等策略
      final response = await _networkService!.get<dynamic>(
        _getRequestUrl(),
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: _buildHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          debugPrint('成功获取远程配置，配置项数量: ${data.length}');
          return _processConfigData(data);
        } else if (data is String) {
          // 尝试解析JSON字符串
          final jsonData = json.decode(data) as Map<String, dynamic>;
          debugPrint('成功解析远程配置JSON，配置项数量: ${jsonData.length}');
          return _processConfigData(jsonData);
        } else {
          throw Exception(
            '远程配置数据格式不正确：期望Map<String, dynamic>，实际: ${data.runtimeType}',
          );
        }
      } else {
        throw Exception('远程配置请求失败：HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取远程配置失败: $e');

      // 如果是DioException，提供更详细的错误信息
      if (e is DioException) {
        final errorMsg = _handleDioException(e);
        throw Exception('远程配置请求失败: $errorMsg');
      }

      rethrow;
    }
  }

  /// 获取请求URL
  String _getRequestUrl() {
    if (useAbsoluteUrl || configUrl.startsWith('http')) {
      return configUrl;
    }

    // 使用相对路径，让NetworkService处理baseUrl
    return configUrl.startsWith('/') ? configUrl : '/$configUrl';
  }

  /// 构建请求头
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...extraHeaders,
    };

    // 添加应用信息到请求头
    try {
      headers.addAll({
        'X-App-Version': '1.0.0', // 可以从package_info_plus获取
        'X-Client-Type': 'flutter',
        'X-Request-Source': 'config-fetch',
      });
    } catch (e) {
      debugPrint('添加应用信息到请求头失败: $e');
    }

    return headers;
  }

  /// 处理Dio异常
  String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '发送超时';
      case DioExceptionType.receiveTimeout:
        return '接收超时';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return '服务器响应错误 (HTTP $statusCode)';
      case DioExceptionType.cancel:
        return '请求被取消';
      case DioExceptionType.unknown:
        return '网络连接失败: ${error.message}';
      default:
        return '未知网络错误: ${error.message}';
    }
  }

  /// 处理配置数据
  Map<String, dynamic> _processConfigData(Map<String, dynamic> rawData) {
    final processedData = <String, dynamic>{};

    // 扁平化嵌套的配置数据
    _flattenConfigData(rawData, processedData);

    // 验证配置数据
    _validateConfigData(processedData);

    return processedData;
  }

  /// 扁平化配置数据
  void _flattenConfigData(
    Map<String, dynamic> source,
    Map<String, dynamic> target, [
    String prefix = '',
  ]) {
    source.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        // 递归处理嵌套对象
        _flattenConfigData(value, target, fullKey);
      } else {
        // 直接添加到目标Map
        target[fullKey] = value;
      }
    });
  }

  /// 验证配置数据
  void _validateConfigData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      throw Exception('远程配置数据为空');
    }

    // 检查是否包含必要的配置项
    final requiredKeys = ['app.version_check_url', 'network.base_url'];
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        debugPrint('警告：缺少必要的配置项: $key');
      }
    }

    debugPrint('配置数据验证通过，包含 ${data.length} 个配置项');
  }
}
