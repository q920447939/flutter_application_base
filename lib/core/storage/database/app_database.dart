/// 应用数据库主类
///
/// 使用Drift定义应用的SQLite数据库
library;

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// 导入表定义
import 'tables/users_table.dart';
import 'tables/configs_table.dart';
import 'tables/auth_tokens_table.dart';

// 这个文件将由Drift代码生成器生成
part 'app_database.g.dart';

/// 应用数据库类
@DriftDatabase(tables: [Users, Configs, CacheEntries, AuthTokens])
class AppDatabase extends _$AppDatabase {
  /// 构造函数
  AppDatabase() : super(_openConnection());

  /// 测试构造函数
  AppDatabase.connect(QueryExecutor executor) : super(executor);

  /// 数据库版本
  @override
  int get schemaVersion => 1;

  /// 数据库迁移策略
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // 创建所有表
      await m.createAll();

      // 插入默认数据
      await _insertDefaultData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 处理数据库版本升级
      if (from < 2) {
        // 未来版本升级时的迁移逻辑
        // await _migrateV1ToV2(m);
      }
    },
    beforeOpen: (details) async {
      // 启用外键约束
      await customStatement('PRAGMA foreign_keys = ON');

      // 设置WAL模式以提高并发性能
      await customStatement('PRAGMA journal_mode = WAL');

      // 设置同步模式
      await customStatement('PRAGMA synchronous = NORMAL');

      // 设置缓存大小
      await customStatement('PRAGMA cache_size = -2000'); // 2MB
    },
  );

  /// 插入默认数据
  Future<void> _insertDefaultData() async {
    // 插入默认配置
    await into(configs).insert(
      ConfigsCompanion.insert(
        key: 'app_version',
        value: '1.0.0',
        type: const Value('system'),
        description: const Value('应用版本号'),
        isSystem: const Value(true),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(configs).insert(
      ConfigsCompanion.insert(
        key: 'database_version',
        value: '1',
        type: const Value('system'),
        description: const Value('数据库版本'),
        isSystem: const Value(true),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// 创建数据库连接
  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      // 确保在移动平台上正确初始化SQLite
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // 获取数据库文件路径
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.db'));

      // 在调试模式下启用SQL日志
      if (kDebugMode) {
        return NativeDatabase.createInBackground(file, logStatements: true);
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}
