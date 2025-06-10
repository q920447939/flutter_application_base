/// 同步存储功能演示
///
/// 展示如何使用 StorageService 的同步功能
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/storage/storage_service.dart';
import '../core/router/auth_middleware.dart';

/// 演示应用
class SyncStorageDemoApp extends StatelessWidget {
  const SyncStorageDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sync Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SyncStorageDemoPage(),
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/protected',
          page: () => const ProtectedPage(),
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}

/// 主演示页面
class SyncStorageDemoPage extends StatefulWidget {
  const SyncStorageDemoPage({super.key});

  @override
  State<SyncStorageDemoPage> createState() => _SyncStorageDemoPageState();
}

class _SyncStorageDemoPageState extends State<SyncStorageDemoPage> {
  final StorageService _storage = StorageService.instance;
  String _status = '未初始化';
  String? _currentToken;
  Map<String, dynamic>? _currentUserInfo;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  void _refreshStatus() {
    setState(() {
      _currentToken = _storage.getTokenSync();
      _currentUserInfo = _storage.getUserInfoSync();
      _status = _currentToken != null ? '已登录' : '未登录';
    });
  }

  void _setToken() {
    final token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
    _storage.setTokenSync(token);
    _refreshStatus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token已设置: ${token.substring(0, 20)}...')),
    );
  }

  void _clearToken() {
    _storage.clearTokenSync();
    _storage.clearUserInfoSync();
    _refreshStatus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token已清除')),
    );
  }

  void _setUserInfo() {
    final userInfo = {
      'id': 12345,
      'name': 'Demo User',
      'email': 'demo@example.com',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _storage.setUserInfoSync(userInfo);
    _refreshStatus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户信息已设置')),
    );
  }

  void _testAuthMiddleware() {
    Get.toNamed('/protected');
  }

  void _testCacheStrategies() {
    // 测试不同的缓存策略
    _storage.setCacheStrategy('memory_test', CacheStrategy.memory);
    _storage.setCacheStrategy('persistent_test', CacheStrategy.persistent);
    _storage.setCacheStrategy('hybrid_test', CacheStrategy.hybrid);
    
    // 设置测试数据
    _storage.setStringSync('memory_test', 'memory_value');
    _storage.setStringSync('persistent_test', 'persistent_value');
    _storage.setStringSync('hybrid_test', 'hybrid_value');
    
    // 验证数据
    final memoryValue = _storage.getStringSync('memory_test');
    final persistentValue = _storage.getStringSync('persistent_test');
    final hybridValue = _storage.getStringSync('hybrid_test');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存策略测试结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory: $memoryValue'),
            Text('Persistent: $persistentValue'),
            Text('Hybrid: $hybridValue'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同步存储演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前状态',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('状态: $_status'),
                    Text('Token: ${_currentToken ?? '无'}'),
                    Text('用户信息: ${_currentUserInfo != null ? '已设置' : '无'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setToken,
              child: const Text('设置Token'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _setUserInfo,
              child: const Text('设置用户信息'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _clearToken,
              child: const Text('清除所有数据'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testAuthMiddleware,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('测试认证中间件'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testCacheStrategies,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('测试缓存策略'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('刷新状态'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 登录页面
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录页面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '您需要登录才能访问受保护的页面',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 模拟登录
                StorageService.instance.setTokenSync('login_token_${DateTime.now().millisecondsSinceEpoch}');
                Get.back();
                Get.toNamed('/protected');
              },
              child: const Text('模拟登录'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 受保护页面
class ProtectedPage extends StatelessWidget {
  const ProtectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final token = StorageService.instance.getTokenSync();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('受保护页面'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_open,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              '恭喜！您已成功访问受保护的页面',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Token: ${token?.substring(0, 20)}...',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
