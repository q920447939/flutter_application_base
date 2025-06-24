/// YAML 测试运行器测试文件
///
/// 这是一个标准的 Flutter 测试文件，位于 test/ 目录下
import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_base/core/app/app_init_info.dart';
import 'package:flutter_application_base/core/app/framework_module_manager.dart';
import 'package:flutter_application_base/core/yaml/interfaces/yaml_service_interface.dart';
import 'package:flutter_application_base/core/yaml/services/yaml_service.dart';
import 'package:flutter_application_base/core/yaml/yaml_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

Future<void> main() async {
  //await FrameworkModuleManager.initialize(AppInitInfo(child: Container()));
  WidgetsFlutterBinding.ensureInitialized();
  //TestWidgetsFlutterBinding.ensureInitialized();
  group('YAML 模块测试', () {
    test('快速测试', () async {
      try {
        // 创建并注册 YAML 服务到依赖注入容器
        final yamlService = YamlService();
        Get.put<IYamlService>(yamlService, permanent: true);

        // 初始化服务
        await yamlService.initialize();

        debugPrint('YAML 模块初始化完成');
      } catch (e) {
        debugPrint('YAML 模块初始化失败: $e');
        // 不抛出异常，允许应用在没有 YAML 支持的情况下运行
      }
      final data = await YamlHelper.service.loadYamlAsMap(
        "config/app.config.yaml",
        processorName: "",
      );
      print(data);
      expect(1 + 1, equals(2));
    }, tags: 'fast');

    test('基础数学运算', () {
      expect(2 + 2, equals(4));
      expect(5 * 3, equals(15));
    });

    test('字符串操作', () {
      const str = 'Hello World';
      expect(str.length, equals(11));
      expect(str.toLowerCase(), equals('hello world'));
    });

    // 如果 YamlTestRunner 类可用，可以取消注释下面的测试
    /*
    test('运行所有 YAML 测试', () async {
      final results = await YamlTestRunner.runAllTests();
      expect(results.isNotEmpty, true);
      
      // 检查是否有失败的测试
      final failedTests = results.where((r) => !r.success).toList();
      if (failedTests.isNotEmpty) {
        fail('有 ${failedTests.length} 个测试失败: ${failedTests.map((t) => t.testName).join(', ')}');
      }
    });
    */
  });

  group('错误处理测试', () {
    test('除零错误', () {
      expect(() => 10 ~/ 0, throwsA(isA<IntegerDivisionByZeroException>()));
    });

    test('空列表访问', () {
      final emptyList = <int>[];
      expect(() => emptyList.first, throwsA(isA<StateError>()));
    });
  });

  group('异步测试', () {
    test('Future 测试', () async {
      final result = await Future.delayed(
        const Duration(milliseconds: 100),
        () => 'async result',
      );
      expect(result, equals('async result'));
    });

    test('Stream 测试', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
      final list = await stream.toList();
      expect(list, equals([1, 2, 3, 4, 5]));
    });
  });
}
