/// 测试专用的存储服务
/// 
/// 使用内存数据库，避免依赖path_provider等插件
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_application_base/core/storage/database/app_database.dart';
import 'package:flutter_application_base/core/storage/services/storage_service.dart';
import 'package:flutter_application_base/core/storage/repositories/base_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/user_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/config_repository.dart';

/// 测试专用的存储服务实现
class TestStorageService implements IStorageService {
  late final AppDatabase _database;
  final Map<Type, IBaseRepository> _repositories = {};
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get databasePath => ':memory:';

  @override
  Future<void> initialize() async {
    try {
      // 使用内存数据库，避免依赖path_provider
      _database = AppDatabase.connect(NativeDatabase.memory(logStatements: true));
      
      // 注册仓储
      _registerRepositories();
      
      _isInitialized = true;
      print('测试存储服务初始化完成');
    } catch (e) {
      throw StorageException('测试存储服务初始化失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 注册所有仓储
  void _registerRepositories() {
    _repositories[UserRepository] = UserRepository(_database);
    _repositories[ConfigRepository] = ConfigRepository(_database);
  }

  @override
  T getRepository<T extends IBaseRepository>() {
    if (!_isInitialized) {
      throw StorageException('存储服务未初始化，请先调用initialize()');
    }
    
    final repository = _repositories[T];
    if (repository == null) {
      throw StorageException('仓储 $T 未注册');
    }
    return repository as T;
  }

  @override
  Future<R> transaction<R>(Future<R> Function() action) async {
    if (!_isInitialized) {
      throw StorageException('存储服务未初始化，请先调用initialize()');
    }
    
    try {
      return await _database.transaction(() async {
        return await action();
      });
    } catch (e) {
      throw StorageException('事务执行失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> dispose() async {
    try {
      if (_isInitialized) {
        await _database.close();
        _repositories.clear();
        _isInitialized = false;
      }
      print('测试存储服务已关闭');
    } catch (e) {
      throw StorageException('关闭存储服务失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<int> getDatabaseSize() async {
    // 内存数据库无法获取实际大小，返回模拟值
    return 1024;
  }

  @override
  Future<void> vacuum() async {
    if (!_isInitialized) {
      throw StorageException('存储服务未初始化，请先调用initialize()');
    }
    
    try {
      await _database.customStatement('VACUUM');
    } catch (e) {
      throw StorageException('数据库压缩失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> backup(String backupPath) async {
    // 内存数据库无法备份，抛出异常
    throw StorageException('内存数据库不支持备份操作');
  }

  @override
  Future<void> restore(String backupPath) async {
    // 内存数据库无法恢复，抛出异常
    throw StorageException('内存数据库不支持恢复操作');
  }

  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getDatabaseStats() async {
    if (!_isInitialized) {
      throw StorageException('存储服务未初始化，请先调用initialize()');
    }
    
    try {
      final userRepo = getRepository<UserRepository>();
      final configRepo = getRepository<ConfigRepository>();
      
      final userCount = await userRepo.count();
      final configCount = await configRepo.count();
      final dbSize = await getDatabaseSize();
      
      return {
        'userCount': userCount,
        'configCount': configCount,
        'databaseSize': dbSize,
        'databasePath': databasePath,
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      throw StorageException('获取数据库统计信息失败', e is Exception ? e : Exception(e.toString()));
    }
  }
}
