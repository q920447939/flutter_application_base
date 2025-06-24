/// YAML 工具类
///
/// 提供 YAML 处理相关的通用工具方法
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart' hide YamlException;
import '../exceptions/yaml_exceptions.dart';

/// YAML 工具类
class YamlUtils {
  YamlUtils._();

  /// 从文件路径读取 YAML 内容
  ///
  /// [filePath] 文件路径，支持 assets 和本地文件
  /// 返回文件内容字符串
  static Future<String> readYamlFile(String filePath) async {
    try {
      // 判断是否为 assets 文件
      if (filePath.startsWith('assets/')) {
        return await rootBundle.loadString(filePath);
      } else {
        return await rootBundle.loadString('assets/$filePath');
      }
    } catch (e) {
      if (e is YamlException) rethrow;

      throw YamlFileReadException(
        filePath,
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 解析 YAML 字符串
  ///
  /// [yamlContent] YAML 内容字符串
  /// [filePath] 文件路径（用于错误报告）
  /// 返回解析后的动态对象
  static dynamic parseYamlString(String yamlContent, {String? filePath}) {
    try {
      return loadYaml(yamlContent);
    } catch (e) {
      throw YamlParseException(
        message: '解析 YAML 内容失败',
        filePath: filePath,
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 验证 YAML 格式
  ///
  /// [yamlContent] YAML 内容字符串
  /// [filePath] 文件路径（用于错误报告）
  /// 如果格式无效会抛出异常
  static void validateYamlFormat(String yamlContent, {String? filePath}) {
    try {
      loadYaml(yamlContent);
    } catch (e) {
      throw YamlValidationException(
        message: 'YAML 格式验证失败',
        metadata: {'filePath': filePath},
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 扁平化嵌套的 Map 结构
  ///
  /// [map] 要扁平化的 Map
  /// [separator] 键分隔符，默认为 '.'
  /// [prefix] 键前缀
  /// 返回扁平化后的 Map
  static Map<String, dynamic> flattenMap(
    Map<dynamic, dynamic> map, {
    String separator = '.',
    String prefix = '',
  }) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final key =
          prefix.isEmpty
              ? entry.key.toString()
              : '$prefix$separator${entry.key}';
      final value = entry.value;

      if (value is Map) {
        result.addAll(flattenMap(value, separator: separator, prefix: key));
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// 展开扁平化的 Map 结构
  ///
  /// [flatMap] 扁平化的 Map
  /// [separator] 键分隔符，默认为 '.'
  /// 返回嵌套的 Map 结构
  static Map<String, dynamic> expandMap(
    Map<String, dynamic> flatMap, {
    String separator = '.',
  }) {
    final result = <String, dynamic>{};

    for (final entry in flatMap.entries) {
      final keys = entry.key.split(separator);
      final value = entry.value;

      Map<String, dynamic> current = result;
      for (int i = 0; i < keys.length - 1; i++) {
        final key = keys[i];
        current[key] ??= <String, dynamic>{};
        current = current[key] as Map<String, dynamic>;
      }

      current[keys.last] = value;
    }

    return result;
  }

  /// 替换字符串中的变量
  ///
  /// [content] 要处理的字符串
  /// [variables] 变量映射
  /// [pattern] 变量模式，默认为 ${variable}
  /// 返回替换后的字符串
  static String replaceVariables(
    String content,
    Map<String, dynamic> variables, {
    RegExp? pattern,
  }) {
    pattern ??= RegExp(r'\$\{([^}]+)\}');

    return content.replaceAllMapped(pattern, (match) {
      final variableName = match.group(1)!;

      // 支持默认值语法: ${VAR:default}
      final parts = variableName.split(':');
      final varName = parts[0];
      final defaultValue = parts.length > 1 ? parts[1] : '';

      // 支持嵌套访问: ${context.user.name}
      final value = _getNestedValue(variables, varName);

      if (value != null) {
        return value.toString();
      } else if (defaultValue.isNotEmpty) {
        return defaultValue;
      } else {
        // 保持原样，不替换
        return match.group(0)!;
      }
    });
  }

  /// 获取嵌套值
  ///
  /// [map] 数据映射
  /// [path] 访问路径，如 'user.profile.name'
  /// 返回找到的值或 null
  static dynamic _getNestedValue(Map<String, dynamic> map, String path) {
    final keys = path.split('.');
    dynamic current = map;

    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    return current;
  }

  /// 生成缓存键
  ///
  /// [filePath] 文件路径
  /// [processorName] 处理器名称
  /// [context] 上下文参数
  /// 返回缓存键字符串
  static String generateCacheKey(
    String filePath, {
    String? processorName,
    Map<String, dynamic>? context,
  }) {
    final buffer = StringBuffer();
    buffer.write(filePath);

    if (processorName != null) {
      buffer.write(':$processorName');
    }

    if (context != null && context.isNotEmpty) {
      final contextHash = context.toString().hashCode;
      buffer.write(':$contextHash');
    }

    return buffer.toString();
  }

  /// 验证文件路径格式
  ///
  /// [filePath] 文件路径
  /// 返回是否为有效的 YAML 文件路径
  static bool isValidYamlFilePath(String filePath) {
    if (filePath.isEmpty) return false;

    final extension = filePath.toLowerCase();
    return extension.endsWith('.yaml') || extension.endsWith('.yml');
  }

  /// 获取文件扩展名
  ///
  /// [filePath] 文件路径
  /// 返回文件扩展名（不包含点）
  static String getFileExtension(String filePath) {
    final lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == filePath.length - 1) {
      return '';
    }
    return filePath.substring(lastDotIndex + 1).toLowerCase();
  }

  /// 安全类型转换
  ///
  /// [value] 要转换的值
  /// [defaultValue] 默认值
  /// 返回转换后的值
  static T safeCast<T>(dynamic value, T defaultValue) {
    try {
      if (value == null) return defaultValue;
      if (value is T) return value;

      // 尝试基本类型转换
      if (T == String) {
        return value.toString() as T;
      } else if (T == int) {
        if (value is num) return value.toInt() as T;
        if (value is String) return int.tryParse(value) as T? ?? defaultValue;
      } else if (T == double) {
        if (value is num) return value.toDouble() as T;
        if (value is String) {
          return double.tryParse(value) as T? ?? defaultValue;
        }
      } else if (T == bool) {
        if (value is String) {
          final lower = value.toLowerCase();
          if (lower == 'true' || lower == '1') return true as T;
          if (lower == 'false' || lower == '0') return false as T;
        }
      }

      return defaultValue;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('类型转换失败: $value -> $T, 使用默认值: $defaultValue');
      }
      return defaultValue;
    }
  }
}
