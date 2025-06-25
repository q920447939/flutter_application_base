/// 存储服务接口
/// 
/// 定义统一的存储服务接口
library;

import '../repositories/base_repository.dart';

/// 存储异常
class StorageException implements Exception {
  final String message;
  final Exception? innerException;
  
  const StorageException(this.message, [this.innerException]);
  
  @override
  String toString() {
    if (innerException != null) {
      return 'StorageException: $message\nInner: $innerException';
    }
    return 'StorageException: $message';
  }
}

/// 存储服务接口
abstract class IStorageService {
  /// 初始化存储服务
  Future<void> initialize();
  
  /// 获取仓储实例
  T getRepository<T extends IBaseRepository>();
  
  /// 执行事务
  Future<R> transaction<R>(Future<R> Function() action);
  
  /// 关闭存储服务
  Future<void> dispose();
  
  /// 检查服务是否已初始化
  bool get isInitialized;
  
  /// 获取数据库路径
  String? get databasePath;
  
  /// 获取数据库大小（字节）
  Future<int> getDatabaseSize();
  
  /// 压缩数据库
  Future<void> vacuum();
  
  /// 备份数据库
  Future<void> backup(String backupPath);
  
  /// 恢复数据库
  Future<void> restore(String backupPath);
}
