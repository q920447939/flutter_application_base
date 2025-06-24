/// 配置 YAML 处理器
///
/// 专门处理应用配置相关的 YAML 文件，支持环境变量替换和配置验证
library;

import 'dart:io';
import '../interfaces/yaml_processor_interface.dart';
import '../exceptions/yaml_exceptions.dart';
import '../utils/yaml_utils.dart';

/// 配置 YAML 处理器实现
class DefaultYamlProcessor extends BaseYamlProcessor {
  @override
  bool get enabled => true;

  @override
  Future<Map<String, dynamic>> processYaml(
    String yamlContent, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // 1. 替换环境变量和上下文变量
      final processedContent = _replaceVariables(yamlContent, context);

      // 2. 解析 YAML
      final yamlMap = YamlUtils.parseYamlString(processedContent);

      if (yamlMap is! Map) {
        throw YamlValidationException(
          message: '根节点必须是对象类型',
          validationErrors: ['根节点类型错误'],
        );
      }
      // 4. 返回处理后的 Map
      return Map<String, dynamic>.from(yamlMap);
    } catch (e) {
      if (e is YamlException) rethrow;

      throw YamlProcessorException(
        message: '解析 YAML 失败',
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 替换环境变量和上下文变量
  String _replaceVariables(String content, Map<String, dynamic>? context) {
    final variables = <String, dynamic>{};

    // 添加环境变量
    variables.addAll(Platform.environment);

    // 添加上下文变量
    if (context != null) {
      variables.addAll(context);
    }

    return YamlUtils.replaceVariables(content, variables);
  }
}
