/// YAML 解析器实现
///
/// 底层：纯YAML解析功能
library;

import 'package:yaml/yaml.dart' as yaml;
import '../interfaces/yaml_processor_interface.dart';
import '../exceptions/yaml_exceptions.dart';

/// YAML 解析器实现
class YamlParser implements IYamlParser {
  @override
  Map<String, dynamic> parseYaml(String yamlContent) {
    try {
      final yamlMap = yaml.loadYaml(yamlContent);

      if (yamlMap == null) {
        return <String, dynamic>{};
      }

      if (yamlMap is! Map) {
        throw YamlParseException(message: 'YAML 根节点必须是对象类型');
      }

      return _convertYamlMap(yamlMap);
    } on yaml.YamlException catch (e) {
      throw YamlParseException(
        message: e.message,
        line: e.span?.start.line,
        column: e.span?.start.column,
        innerException: e,
      );
    } catch (e) {
      throw YamlParseException(
        message: '解析 YAML 时发生未知错误: $e',
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 递归转换 YamlMap 为 Map<String, dynamic>
  Map<String, dynamic> _convertYamlMap(dynamic yamlNode) {
    if (yamlNode is yaml.YamlMap) {
      final result = <String, dynamic>{};
      for (final entry in yamlNode.entries) {
        final key = entry.key.toString();
        result[key] = _convertYamlValue(entry.value);
      }
      return result;
    } else if (yamlNode is Map) {
      final result = <String, dynamic>{};
      for (final entry in yamlNode.entries) {
        final key = entry.key.toString();
        result[key] = _convertYamlValue(entry.value);
      }
      return result;
    }

    throw ArgumentError('输入不是有效的 YAML Map');
  }

  /// 递归转换 YAML 值
  dynamic _convertYamlValue(dynamic value) {
    if (value is yaml.YamlMap) {
      return _convertYamlMap(value);
    } else if (value is yaml.YamlList) {
      return value.map(_convertYamlValue).toList();
    } else if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        result[key] = _convertYamlValue(entry.value);
      }
      return result;
    } else if (value is List) {
      return value.map(_convertYamlValue).toList();
    }

    return value;
  }
}
