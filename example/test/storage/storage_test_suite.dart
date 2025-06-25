/// 存储模块测试套件
/// 
/// 运行所有存储相关的测试
library;

import 'package:flutter_test/flutter_test.dart';

// 导入所有测试文件
import 'database_test.dart' as database_test;
import 'user_repository_test.dart' as user_repository_test;
import 'config_repository_test.dart' as config_repository_test;
import 'storage_service_test.dart' as storage_service_test;
import 'storage_integration_test.dart' as storage_integration_test;

void main() {
  group('Storage Module Test Suite', () {
    group('Database Tests', database_test.main);
    group('User Repository Tests', user_repository_test.main);
    group('Config Repository Tests', config_repository_test.main);
    group('Storage Service Tests', storage_service_test.main);
    group('Storage Integration Tests', storage_integration_test.main);
  });
}
