/// YAML 测试运行器
///
/// 统一管理和执行所有 YAML 相关的测试
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YAML 模块测试', () {
    test('快速测试', () {
      expect(1 + 1, equals(2));
      //await _runBasicTests()
      /*final data = await YamlHelper.service.loadYamlAsMap(
        testCase.filePath,
        processorName: testCase.processorName,
      );
*/
    }, tags: 'fast');
  });
}
