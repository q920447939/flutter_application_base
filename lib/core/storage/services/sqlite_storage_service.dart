/// SQLite存储服务实现
/// 
/// 基于Drift的SQLite存储服务实现
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import '../repositories/base_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/config_repository.dart';
import 'storage_service.dart';

/// SQLite存储服务实现
class SqliteStorageService implements IStorageService {
  late final AppDatabase _database;
  final Map<Type, IBaseRepository> _repositories = {};
  bool _isInitialized = false;
  String? _databasePath;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String? get databasePath => _databasePath;

  @override
  Future<void> initialize() async {
    try {
      debugPrint('开始初始化SQLite存储服务...');
      
      // 获取数据库路径
      final dbFolder = await getApplicationDocumentsDirectory();
      _databasePath = p.join(dbFolder.path, 'app_database.db');
      
      // 初始化数据库
      _database = AppDatabase();
      
      // 注册仓储
      _registerRepositories();
      
      _isInitialized = true;
      debugPrint('SQLite存储服务初始化完成');
      debugPrint('数据库路径: $_databasePath');
    } catch (e) {
      debugPrint('SQLite存储服务初始化失败: $e');
      throw StorageException('SQLite存储服务初始化失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  /// 注册所有仓储
  void _registerRepositories() {
    _repositories[UserRepository] = UserRepository(_database);
    _repositories[ConfigRepository] = ConfigRepository(_database);
    // 注册其他仓储...
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
      debugPrint('开始关闭SQLite存储服务...');
      
      if (_isInitialized) {
        await _database.close();
        _repositories.clear();
        _isInitialized = false;
      }
      
      debugPrint('SQLite存储服务已关闭');
    } catch (e) {
      debugPrint('关闭SQLite存储服务时出错: $e');
      throw StorageException('关闭存储服务失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<int> getDatabaseSize() async {
    if (_databasePath == null) return 0;
    
    try {
      final file = File(_databasePath!);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      throw StorageException('获取数据库大小失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> vacuum() async {
    if (!_isInitialized) {
      throw StorageException('存储服务未初始化，请先调用initialize()');
    }
    
    try {
      debugPrint('开始压缩数据库...');
      await _database.customStatement('VACUUM');
      debugPrint('数据库压缩完成');
    } catch (e) {
      throw StorageException('数据库压缩失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> backup(String backupPath) async {
    if (_databasePath == null) {
      throw StorageException('数据库路径未知，无法备份');
    }
    
    try {
      debugPrint('开始备份数据库到: $backupPath');
      
      final sourceFile = File(_databasePath!);
      if (!await sourceFile.exists()) {
        throw StorageException('源数据库文件不存在');
      }
      
      final backupFile = File(backupPath);
      await sourceFile.copy(backupPath);
      
      debugPrint('数据库备份完成');
    } catch (e) {
      throw StorageException('数据库备份失败', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> restore(String backupPath) async {
    if (_databasePath == null) {
      throw StorageException('数据库路径未知，无法恢复');
    }
    
    try {
      debugPrint('开始从备份恢复数据库: $backupPath');
      
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw StorageException('备份文件不存在');
      }
      
      // 关闭当前数据库连接
      if (_isInitialized) {
        await _database.close();
      }
      
      // 复制备份文件
      await backupFile.copy(_databasePath!);
      
      // 重新初始化数据库
      _database = AppDatabase();
      _registerRepositories();
      
      debugPrint('数据库恢复完成');
    } catch (e) {
      throw StorageException('数据库恢复失败', e is Exception ? e : Exception(e.toString()));
    }
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
        'databasePath': _databasePath,
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      throw StorageException('获取数据库统计信息失败', e is Exception ? e : Exception(e.toString()));
    }
  }
}
