/// YAML 服务接口定义
///
/// 定义了 YAML 服务的核心接口，提供统一的 YAML 处理能力
library;

import 'yaml_processor_interface.dart';
import '../models/yaml_models.dart';

/// YAML 服务核心接口
abstract class IYamlService {
  /// 初始化服务
  Future<void> initialize();

  /// 销毁服务
  Future<void> dispose();

  /// 加载 YAML 文件为 Map（新的灵活API）
  ///
  /// [filePath] 文件路径
  /// [processorName] 指定处理器名称（可选）
  /// [context] 上下文参数
  /// [useCache] 是否使用缓存
  /// 返回处理后的 Map
  Future<Map<String, dynamic>> loadYamlAsMap(
    String filePath, {
    String? processorName,
    Map<String, dynamic>? context,
    bool useCache = true,
  });

  /// 加载 YAML 文件并转换为指定类型（新的灵活API）
  ///
  /// [filePath] 文件路径
  /// [converter] 类型转换器
  /// [processorName] 指定处理器名称（可选）
  /// [context] 上下文参数
  /// [useCache] 是否使用缓存
  /// 返回转换后的强类型对象
  Future<T> loadYaml<T>(
    String filePath,
    IYamlConverter<T> converter, {
    String? processorName,
    Map<String, dynamic>? context,
    bool useCache = true,
  });

  /// 清除缓存
  ///
  /// [pattern] 缓存键模式（可选，支持正则表达式）
  Future<void> clearCache({String? pattern});
}
