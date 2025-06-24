/// 测试配置管理
///
/// 统一管理所有测试相关的配置和设置
library;

/// 测试配置类
class TestConfig {
  TestConfig._();

  /// YAML 测试配置
  static const yamlTestConfig = YamlTestConfig();

  /// 网络测试配置
  static const networkTestConfig = NetworkTestConfig();

  /// 存储测试配置
  static const storageTestConfig = StorageTestConfig();

  /// 主题测试配置
  static const themeTestConfig = ThemeTestConfig();
}

/// YAML 测试配置
class YamlTestConfig {
  const YamlTestConfig();

  /// 测试文件路径
  static const String configFilePath = 'assets/config/app.config.yaml';
  static const String localizationFilePath = 'assets/i18n/zh_CN.i18n.yaml';
  static const String themeFilePath = 'assets/themes/dark.theme.yaml';
  static const String templateFilePath = 'assets/templates/user_profile.template.yaml';

  /// 测试数据
  static const Map<String, dynamic> testContext = {
    'user_id': '2001',
    'username': 'test_user',
    'email': 'test@example.com',
    'display_name': 'Test User',
    'first_name': 'Test',
    'last_name': 'User',
  };

  /// 测试变量
  static const Map<String, String> testVariables = {
    'username': '测试用户',
    'field': '用户名',
    'min': '6',
  };

  /// 支持的处理器列表
  static const List<String> supportedProcessors = [
    'config',
    'localization',
    'theme',
    'data_template',
  ];

  /// 测试用例配置
  static const List<TestCase> testCases = [
    TestCase(
      name: '配置文件加载测试',
      description: '测试配置文件的加载和解析功能',
      filePath: configFilePath,
      processorName: 'config',
      expectedKeys: ['app', 'api', 'features'],
    ),
    TestCase(
      name: '本地化文件加载测试',
      description: '测试本地化文件的加载和翻译功能',
      filePath: localizationFilePath,
      processorName: 'localization',
      expectedKeys: ['_meta', 'app', 'common', 'user'],
    ),
    TestCase(
      name: '主题文件加载测试',
      description: '测试主题文件的加载和颜色解析功能',
      filePath: themeFilePath,
      processorName: 'theme',
      expectedKeys: ['colors', 'fonts', 'dimensions'],
    ),
    TestCase(
      name: '数据模板加载测试',
      description: '测试数据模板的加载和渲染功能',
      filePath: templateFilePath,
      processorName: 'data_template',
      expectedKeys: ['name', 'description', 'data'],
    ),
  ];
}

/// 网络测试配置
class NetworkTestConfig {
  const NetworkTestConfig();

  /// 测试 API 端点
  static const String testApiUrl = 'https://jsonplaceholder.typicode.com';
  static const String testPostsEndpoint = '/posts';
  static const String testUsersEndpoint = '/users';

  /// 超时配置
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 5000;

  /// 测试数据
  static const Map<String, dynamic> testPostData = {
    'title': 'Test Post',
    'body': 'This is a test post',
    'userId': 1,
  };
}

/// 存储测试配置
class StorageTestConfig {
  const StorageTestConfig();

  /// 测试键名
  static const String testStringKey = 'test_string';
  static const String testIntKey = 'test_int';
  static const String testBoolKey = 'test_bool';
  static const String testMapKey = 'test_map';

  /// 测试数据
  static const String testStringValue = 'Hello, World!';
  static const int testIntValue = 42;
  static const bool testBoolValue = true;
  static const Map<String, dynamic> testMapValue = {
    'name': 'Test',
    'age': 25,
    'active': true,
  };
}

/// 主题测试配置
class ThemeTestConfig {
  const ThemeTestConfig();

  /// 测试主题名称
  static const List<String> testThemes = [
    'light',
    'dark',
    'auto',
  ];

  /// 测试颜色
  static const List<String> testColors = [
    '#FF0000', // 红色
    '#00FF00', // 绿色
    '#0000FF', // 蓝色
    '#FFFFFF', // 白色
    '#000000', // 黑色
  ];
}

/// 测试用例配置
class TestCase {
  final String name;
  final String description;
  final String filePath;
  final String processorName;
  final List<String> expectedKeys;

  const TestCase({
    required this.name,
    required this.description,
    required this.filePath,
    required this.processorName,
    required this.expectedKeys,
  });

  @override
  String toString() {
    return 'TestCase(name: $name, filePath: $filePath, processorName: $processorName)';
  }
}

/// 测试结果类
class TestResult {
  final String testName;
  final bool success;
  final String? errorMessage;
  final Duration duration;
  final Map<String, dynamic>? data;

  TestResult({
    required this.testName,
    required this.success,
    this.errorMessage,
    required this.duration,
    this.data,
  });

  @override
  String toString() {
    return 'TestResult(testName: $testName, success: $success, duration: ${duration.inMilliseconds}ms)';
  }
}

/// 测试工具类
class TestUtils {
  TestUtils._();

  /// 格式化测试结果
  static String formatTestResult(TestResult result) {
    final status = result.success ? '✅' : '❌';
    final duration = '${result.duration.inMilliseconds}ms';
    
    if (result.success) {
      return '$status ${result.testName} ($duration)';
    } else {
      return '$status ${result.testName} ($duration) - ${result.errorMessage}';
    }
  }

  /// 生成测试报告
  static String generateTestReport(List<TestResult> results) {
    final total = results.length;
    final passed = results.where((r) => r.success).length;
    final failed = total - passed;
    final totalDuration = results.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.duration,
    );

    final buffer = StringBuffer();
    buffer.writeln('=== 测试报告 ===');
    buffer.writeln('总计: $total');
    buffer.writeln('通过: $passed');
    buffer.writeln('失败: $failed');
    buffer.writeln('成功率: ${(passed / total * 100).toStringAsFixed(1)}%');
    buffer.writeln('总耗时: ${totalDuration.inMilliseconds}ms');
    buffer.writeln('');

    for (final result in results) {
      buffer.writeln(formatTestResult(result));
    }

    return buffer.toString();
  }

  /// 验证测试数据
  static bool validateTestData(Map<String, dynamic> data, List<String> expectedKeys) {
    for (final key in expectedKeys) {
      if (!data.containsKey(key)) {
        return false;
      }
    }
    return true;
  }
}
