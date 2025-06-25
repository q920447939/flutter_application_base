/// 存储模块使用示例
///
/// 展示如何在业务层使用存储模块
library;

import 'package:get/get.dart';
import '../../../features/auth/models/user_model.dart';
import '../services/sqlite_storage_service.dart';
import '../services/storage_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/config_repository.dart';
import '../models/user_entity.dart';

/// 用户服务示例
class UserService {
  late final UserRepository _userRepository;
  late final ConfigRepository _configRepository;

  UserService() {
    final storageService = Get.find<IStorageService>();
    _userRepository = storageService.getRepository<UserRepository>();
    _configRepository = storageService.getRepository<ConfigRepository>();
  }

  /// 创建用户
  Future<UserModel> createUser({
    required String id,
    String? username,
    String? email,
    String? phone,
    String? nickname,
  }) async {
    final now = DateTime.now();
    final entity = UserEntity(
      id: id,
      username: username,
      email: email,
      phone: phone,
      nickname: nickname,
      createdAt: now,
      updatedAt: now,
    );

    final savedEntity = await _userRepository.insert(entity);
    return savedEntity.toUserModel();
  }

  /// 获取用户
  Future<UserModel?> getUser(String id) async {
    final entity = await _userRepository.findById(id);
    return entity?.toUserModel();
  }

  /// 更新用户
  Future<UserModel> updateUser(UserModel user) async {
    final entity = UserEntity.fromUserModel(
      user.copyWith(updatedAt: DateTime.now()),
    );

    final updatedEntity = await _userRepository.update(entity);
    return updatedEntity.toUserModel();
  }

  /// 删除用户
  Future<void> deleteUser(String id) async {
    await _userRepository.delete(id);
  }

  /// 获取用户列表
  Future<List<UserModel>> getUserList({int page = 1, int size = 20}) async {
    final pageResult = await _userRepository.findPage(page, size);
    return pageResult.data.map((entity) => entity.toUserModel()).toList();
  }

  /// 搜索用户
  Future<List<UserModel>> searchUsers(String keyword) async {
    final entities = await _userRepository.searchUsers(keyword);
    return entities.map((entity) => entity.toUserModel()).toList();
  }

  /// 根据邮箱查找用户
  Future<UserModel?> findUserByEmail(String email) async {
    final entity = await _userRepository.findByEmail(email);
    return entity?.toUserModel();
  }

  /// 事务示例：批量创建用户
  Future<List<UserModel>> batchCreateUsers(
    List<Map<String, dynamic>> userDataList,
  ) async {
    final storageService = Get.find<IStorageService>();

    return await storageService.transaction(() async {
      final users = <UserModel>[];

      for (final userData in userDataList) {
        final user = await createUser(
          id: userData['id'],
          username: userData['username'],
          email: userData['email'],
          phone: userData['phone'],
          nickname: userData['nickname'],
        );
        users.add(user);
      }

      return users;
    });
  }
}

/// 配置服务示例
class ConfigService {
  late final ConfigRepository _configRepository;

  ConfigService() {
    final storageService = Get.find<IStorageService>();
    _configRepository = storageService.getRepository<ConfigRepository>();
  }

  /// 获取应用配置
  Future<String?> getAppConfig(String key, [String? defaultValue]) async {
    return await _configRepository.getString(key, defaultValue);
  }

  /// 设置应用配置
  Future<void> setAppConfig(String key, String value) async {
    await _configRepository.setValue(key, value, type: 'app');
  }

  /// 获取用户偏好设置
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    final configs = await _configRepository.findByType('user_pref_$userId');
    final preferences = <String, dynamic>{};

    for (final config in configs) {
      final key = config.key.replaceFirst('user_pref_${userId}_', '');
      try {
        preferences[key] = config.value;
      } catch (e) {
        preferences[key] = config.value;
      }
    }

    return preferences;
  }

  /// 设置用户偏好
  Future<void> setUserPreference(
    String userId,
    String key,
    dynamic value,
  ) async {
    final configKey = 'user_pref_${userId}_$key';
    await _configRepository.setValue(
      configKey,
      value,
      type: 'user_pref_$userId',
      description: '用户 $userId 的偏好设置: $key',
    );
  }

  /// 获取系统配置
  Future<Map<String, dynamic>> getSystemConfigs() async {
    final configs = await _configRepository.findByType('system');
    final systemConfigs = <String, dynamic>{};

    for (final config in configs) {
      systemConfigs[config.key] = config.value;
    }

    return systemConfigs;
  }
}

/// 存储统计服务示例
class StorageStatsService {
  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    final storageService = Get.find<IStorageService>();

    if (storageService is SqliteStorageService) {
      return await storageService.getDatabaseStats();
    }

    return {'error': '不支持的存储服务类型'};
  }

  /// 压缩数据库
  Future<void> compressDatabase() async {
    final storageService = Get.find<IStorageService>();
    await storageService.vacuum();
  }

  /// 备份数据库
  Future<void> backupDatabase(String backupPath) async {
    final storageService = Get.find<IStorageService>();
    await storageService.backup(backupPath);
  }

  /// 恢复数据库
  Future<void> restoreDatabase(String backupPath) async {
    final storageService = Get.find<IStorageService>();
    await storageService.restore(backupPath);
  }
}
