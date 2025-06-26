/// 核心路由注册器
/// 
/// 提供系统级核心路由，如错误页、加载页等
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../base/route_registrar.dart';
import '../../../ui/page/error_screen.dart';

/// 核心路由注册器
class CoreRouteRegistrar extends MetadataRouteRegistrar {
  @override
  String get namespace => 'core';
  
  @override
  RouteLayer get layer => RouteLayer.core;
  
  @override
  List<String> get dependencies => const [];
  
  @override
  RouteMetadata getMetadata() {
    return const RouteMetadata(
      name: '核心路由',
      description: '系统级核心路由，包含错误页、加载页等',
      version: '1.0.0',
    );
  }
  
  @override
  List<RouteBase> getRoutes() {
    return [
      // 错误页路由
      GoRoute(
        path: '/core/error',
        name: 'core-error',
        builder: (context, state) {
          final error = state.extra as Exception?;
          return ErrorScreenPage(error: error ?? Exception('未知错误'));
        },
      ),
      
      // 加载页路由
      GoRoute(
        path: '/core/loading',
        name: 'core-loading',
        builder: (context, state) => const CoreLoadingPage(),
      ),
      
      // 网络错误页
      GoRoute(
        path: '/core/network-error',
        name: 'core-network-error',
        builder: (context, state) => const NetworkErrorPage(),
      ),
      
      // 404页面
      GoRoute(
        path: '/core/not-found',
        name: 'core-not-found',
        builder: (context, state) => const NotFoundPage(),
      ),
    ];
  }
}

/// 核心加载页
class CoreLoadingPage extends StatelessWidget {
  const CoreLoadingPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      ),
    );
  }
}

/// 网络错误页
class NetworkErrorPage extends StatelessWidget {
  const NetworkErrorPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('网络错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '网络连接失败',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              '请检查网络设置后重试',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 重试逻辑
                Navigator.of(context).pop();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404页面
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '页面未找到',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              '您访问的页面不存在',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 返回首页
                context.go('/');
              },
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
