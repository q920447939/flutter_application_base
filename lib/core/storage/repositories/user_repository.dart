/// 用户仓储实现
///
/// 提供用户数据的CRUD操作
library;

import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/user_entity.dart';
import 'base_repository.dart';

/// User表扩展方法
extension UserExtension on User {
  /// 转换为实体
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      phone: phone,
      nickname: nickname,
      avatar: avatar,
      gender: gender,
      birthday: birthday,
      address: address,
      bio: bio,
      status: status,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }
}

/// 用户仓储实现
class UserRepository implements IBaseRepository<UserEntity, String> {
  final AppDatabase _database;

  UserRepository(this._database);

  @override
  Future<UserEntity> insert(UserEntity entity) async {
    await _database.into(_database.users).insert(entity.toCompanion());
    return entity;
  }

  @override
  Future<List<UserEntity>> insertAll(List<UserEntity> entities) async {
    await _database.batch((batch) {
      for (final entity in entities) {
        batch.insert(_database.users, entity.toCompanion());
      }
    });
    return entities;
  }

  @override
  Future<UserEntity?> findById(String id) async {
    final query = _database.select(_database.users)
      ..where((u) => u.id.equals(id));

    final user = await query.getSingleOrNull();
    return user?.toEntity();
  }

  @override
  Future<List<UserEntity>> findAll() async {
    final users = await _database.select(_database.users).get();
    return users.map((u) => u.toEntity()).toList();
  }

  @override
  Future<PageResult<UserEntity>> findPage(int page, int size) async {
    final offset = (page - 1) * size;

    // 查询总数
    final countQuery = _database.selectOnly(_database.users)
      ..addColumns([_database.users.id.count()]);
    final total = await countQuery.getSingle().then(
      (row) => row.read(_database.users.id.count()) ?? 0,
    );

    // 分页查询
    final query =
        _database.select(_database.users)
          ..limit(size, offset: offset)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]);

    final users = await query.get();
    final entities = users.map((u) => u.toEntity()).toList();

    return PageResult(data: entities, total: total, page: page, size: size);
  }

  @override
  Future<List<UserEntity>> findWhere(
    String condition, [
    List<dynamic>? args,
  ]) async {
    final query = _database.customSelect(
      'SELECT * FROM users WHERE $condition',
      variables: args?.map((arg) => Variable(arg)).toList() ?? [],
      readsFrom: {_database.users},
    );

    final results = await query.get();
    return results.map((row) => UserEntity.fromRow(row)).toList();
  }

  @override
  Future<UserEntity> update(UserEntity entity) async {
    await (_database.update(_database.users)
      ..where((u) => u.id.equals(entity.id))).write(entity.toCompanion());
    return entity;
  }

  @override
  Future<void> delete(String id) async {
    await (_database.delete(_database.users)
      ..where((u) => u.id.equals(id))).go();
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    await (_database.delete(_database.users)
      ..where((u) => u.id.isIn(ids))).go();
  }

  @override
  Future<int> count() async {
    final countQuery = _database.selectOnly(_database.users)
      ..addColumns([_database.users.id.count()]);
    final result = await countQuery.getSingle();
    return result.read(_database.users.id.count()) ?? 0;
  }

  @override
  Future<int> countWhere(String condition, [List<dynamic>? args]) async {
    final query = _database.customSelect(
      'SELECT COUNT(*) as count FROM users WHERE $condition',
      variables: args?.map((arg) => Variable(arg)).toList() ?? [],
      readsFrom: {_database.users},
    );

    final result = await query.getSingle();
    return result.read<int>('count');
  }

  @override
  Future<bool> exists(String id) async {
    final count = await countWhere('id = ?', [id]);
    return count > 0;
  }

  @override
  Future<void> clear() async {
    await _database.delete(_database.users).go();
  }

  /// 根据用户名查询
  Future<UserEntity?> findByUsername(String username) async {
    final query = _database.select(_database.users)
      ..where((u) => u.username.equals(username));

    final user = await query.getSingleOrNull();
    return user?.toEntity();
  }

  /// 根据邮箱查询
  Future<UserEntity?> findByEmail(String email) async {
    final query = _database.select(_database.users)
      ..where((u) => u.email.equals(email));

    final user = await query.getSingleOrNull();
    return user?.toEntity();
  }

  /// 根据手机号查询
  Future<UserEntity?> findByPhone(String phone) async {
    final query = _database.select(_database.users)
      ..where((u) => u.phone.equals(phone));

    final user = await query.getSingleOrNull();
    return user?.toEntity();
  }

  /// 搜索用户（按昵称、用户名、邮箱）
  Future<List<UserEntity>> searchUsers(String keyword) async {
    final query =
        _database.select(_database.users)
          ..where(
            (u) =>
                u.nickname.like('%$keyword%') |
                u.username.like('%$keyword%') |
                u.email.like('%$keyword%'),
          )
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]);

    final users = await query.get();
    return users.map((u) => u.toEntity()).toList();
  }
}
