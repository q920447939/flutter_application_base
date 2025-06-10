/// 同步存储演示程序入口
///
/// 独立的演示程序，展示 getTokenSync 和相关功能
library;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/storage_service.dart';
import 'sync_storage_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  // 设置 SharedPreferences 的模拟数据（用于演示）
  SharedPreferences.setMockInitialValues({});
  
  // 初始化存储服务
  await StorageService.instance.initialize();
  
  runApp(const SyncStorageDemoApp());
}
