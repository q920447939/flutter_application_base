/// 简单数据库测试
/// 
/// 用于测试Drift代码生成
library;

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// 这个文件将由Drift代码生成器生成
part 'simple_database.g.dart';

/// 简单用户表
class SimpleUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 简单数据库类
@DriftDatabase(tables: [SimpleUsers])
class SimpleDatabase extends _$SimpleDatabase {
  /// 构造函数
  SimpleDatabase() : super(_openConnection());

  /// 数据库版本
  @override
  int get schemaVersion => 1;

  /// 创建数据库连接
  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      // 确保在移动平台上正确初始化SQLite
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }
      
      // 获取数据库文件路径
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'simple_database.db'));
      
      // 在调试模式下启用SQL日志
      if (kDebugMode) {
        return NativeDatabase.createInBackground(file, logStatements: true);
      }
      
      return NativeDatabase.createInBackground(file);
    });
  }
}
