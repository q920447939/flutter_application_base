/// 自定义 YAML 转换器示例
///
/// 展示如何创建自定义转换器来处理特定的数据转换需求
library;

import 'package:flutter_application_base/core/yaml/index.dart';

/// 基础配置类（只包含核心信息）
class BasicConfig {
  final String name;
  final String version;
  final String apiUrl;

  BasicConfig({
    required this.name,
    required this.version,
    required this.apiUrl,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'version': version, 'apiUrl': apiUrl};
  }

  @override
  String toString() {
    return 'BasicConfig(name: $name, version: $version, apiUrl: $apiUrl)';
  }
}

/// 基础配置转换器
class BasicConfigConverter implements IYamlConverter<BasicConfig> {
  @override
  String get converterName => 'basic_config';

  @override
  BasicConfig fromMap(Map<String, dynamic> map) {
    return BasicConfig(
      name: map['app']['name'] ?? 'Unknown',
      version: map['app']['version'] ?? '1.0.0',
      apiUrl: map['api']['base_url'] ?? 'https://api.example.com',
    );
  }

  @override
  Map<String, dynamic> toMap(BasicConfig object) {
    return object.toMap();
  }
}
