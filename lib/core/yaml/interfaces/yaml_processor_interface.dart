/// YAML 处理器接口定义
///
/// 分层设计：底层负责YAML处理，上层负责类型转换
library;

/// YAML 读取器接口 - 底层：纯文件读取
abstract class IYamlReader {
  /// 读取 YAML 文件内容
  Future<String> readYamlFile(String filePath);
}

/// YAML 解析器接口 - 底层：纯YAML解析
abstract class IYamlParser {
  /// 解析 YAML 字符串为 Map
  Map<String, dynamic> parseYaml(String yamlContent);
}

abstract class IYamlProcessor {
  /// 是否启用
  bool get enabled => true;

  /// 处理 YAML 内容，返回通用 Map
  ///
  /// [yamlContent] YAML 字符串内容
  /// [context] 上下文参数，用于变量替换等
  /// 返回处理后的 Map，不绑定具体类型
  Future<Map<String, dynamic>> processYaml(
    String yamlContent, {
    Map<String, dynamic>? context,
  });
}

/// YAML 转换器接口 - 上层：类型转换
abstract class IYamlConverter<T> {
  /// 转换器名称
  String get converterName;

  /// 从 Map 转换为具体类型
  T fromMap(Map<String, dynamic> map);

  /// 从具体类型转换为 Map
  Map<String, dynamic> toMap(T object);
}

/// YAML 处理器基础抽象类
///
/// 提供通用的实现逻辑，减少重复代码
abstract class BaseYamlProcessor implements IYamlProcessor {}
