/// YAML 读取器实现
///
/// 底层：纯文件读取功能
library;

import 'dart:io';
import 'package:flutter/services.dart';
import '../interfaces/yaml_processor_interface.dart';
import '../exceptions/yaml_exceptions.dart';

/// YAML 读取器实现
class YamlReader implements IYamlReader {
  @override
  Future<String> readYamlFile(String filePath) async {
    try {
      // 判断是否为 assets 文件
      if (filePath.startsWith('assets/') || !filePath.contains('/')) {
        return await rootBundle.loadString(filePath);
      }

      // 本地文件
      final file = File(filePath);
      if (!await file.exists()) {
        throw YamlFileNotFoundException(filePath);
      }

      return await file.readAsString();
    } catch (e) {
      if (e is YamlException) rethrow;

      throw YamlFileReadException(
        filePath,
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
