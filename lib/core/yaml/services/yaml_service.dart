/// YAML 服务核心实现
///
/// 提供统一的 YAML 处理服务，支持多种处理器和缓存机制
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../interfaces/yaml_service_interface.dart';
import '../interfaces/yaml_processor_interface.dart';
import '../models/yaml_models.dart';
import '../exceptions/yaml_exceptions.dart';
import '../cache/yaml_cache.dart';
import '../processors/default_yaml_processor.dart';
import '../utils/yaml_utils.dart';

/// YAML 服务实现
class YamlService implements IYamlService {
  /// 缓存实例
  late final IYamlCache _cache;
  IYamlProcessor iYamlProcessor = DefaultYamlProcessor();

  @override
  Future<void> initialize() async {
    try {
      debugPrint('开始初始化 YAML 服务...');

      // 初始化缓存
      _cache = YamlCache(
        defaultTtl: const Duration(hours: 1),
        maxEntries: 1000,
        cleanupInterval: const Duration(minutes: 5),
      );

      debugPrint('YAML 服务初始化完成');
    } catch (e) {
      debugPrint('YAML 服务初始化失败: $e');
      throw YamlServiceException(
        message: 'YAML 服务初始化失败',
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁 YAML 服务...');

    // 清理缓存
    if (_cache is YamlCache) {
      (_cache).dispose();
    }

    debugPrint('YAML 服务已销毁');
  }

  @override
  Future<Map<String, dynamic>> loadYamlAsMap(
    String filePath, {
    String? processorName,
    Map<String, dynamic>? context,
    bool useCache = true,
  }) async {
    try {
      // 生成缓存键
      final cacheKey = YamlUtils.generateCacheKey(
        filePath,
        processorName: processorName,
        context: context,
      );

      // 检查缓存
      if (useCache) {
        final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
        if (cached != null) {
          debugPrint('从缓存加载 YAML: $filePath');
          return cached;
        }
      }

      // 读取文件内容
      final yamlContent = await YamlUtils.readYamlFile(filePath);

      // 处理 YAML 内容
      final result = await parseYamlAsMap(
        yamlContent,
        processorName: processorName,
        context: context,
      );

      // 缓存结果
      if (useCache) {
        await _cache.set(cacheKey, result);
      }

      return result;
    } catch (e) {
      if (e is YamlException) rethrow;

      throw YamlServiceException(
        message: '加载 YAML 文件失败: $filePath',
        innerException: e is Exception ? e : Exception(e.toString()),
        metadata: {'filePath': filePath, 'processorName': processorName},
      );
    }
  }

  /// 解析 YAML 内容为 Map（新API）
  Future<Map<String, dynamic>> parseYamlAsMap(
    String yamlContent, {
    String? processorName,
    Map<String, dynamic>? context,
  }) async {
    try {
      return iYamlProcessor.processYaml(yamlContent, context: context);
    } catch (e) {
      if (e is YamlException) rethrow;

      throw YamlServiceException(
        message: '解析 YAML 内容失败',
        innerException: e is Exception ? e : Exception(e.toString()),
        metadata: {'processorName': processorName},
      );
    }
  }

  @override
  Future<T> loadYaml<T>(
    String filePath,
    IYamlConverter<T> converter, {
    String? processorName,
    Map<String, dynamic>? context,
    bool useCache = true,
  }) async {
    // 先获取 Map
    final map = await loadYamlAsMap(
      filePath,
      processorName: processorName,
      context: context,
      useCache: useCache,
    );

    // 使用转换器转换为目标类型
    try {
      return converter.fromMap(map);
    } catch (e) {
      throw YamlServiceException(
        message: '转换 YAML 数据失败: $filePath',
        innerException: e is Exception ? e : Exception(e.toString()),
        metadata: {
          'filePath': filePath,
          'converterName': converter.converterName,
        },
      );
    }
  }

  @override
  Future<void> clearCache({String? pattern}) async {
    if (pattern != null) {
      await _cache.clearPattern(pattern);
    } else {
      await _cache.clear();
    }
    debugPrint('YAML 缓存已清除${pattern != null ? ' (模式: $pattern)' : ''}');
  }
}
