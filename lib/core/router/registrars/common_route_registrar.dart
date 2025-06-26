/// 通用业务路由注册器
/// 
/// 提供通用的业务路由，如首页、个人中心等
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../base/route_registrar.dart';
import '../has_bottom_navigator/shell_default_router.dart' as shell_routes;

/// 通用业务路由注册器
class CommonRouteRegistrar extends MetadataRouteRegistrar {
  @override
  String get namespace => 'common';
  
  @override
  RouteLayer get layer => RouteLayer.common;
  
  @override
  List<String> get dependencies => ['core'];
  
  @override
  RouteMetadata getMetadata() {
    return const RouteMetadata(
      name: '通用业务路由',
      description: '包含首页、个人中心等通用业务功能路由',
      version: '1.0.0',
    );
  }
  
  @override
  List<RouteBase> getRoutes() {
    return [
      // 复用现有的首页路由
      ...shell_routes.$appRoutes,
      
      // 个人中心相关路由
      GoRoute(
        path: '/my',
        name: 'my-center',
        builder: (context, state) => const MyCenterPage(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'my-profile',
            builder: (context, state) => const MyProfilePage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'my-settings',
            builder: (context, state) => const MySettingsPage(),
          ),
        ],
      ),
      
      // 搜索页面
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchPage(initialQuery: query);
        },
      ),
      
      // 通知页面
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ];
  }
}

/// 个人中心页面
class MyCenterPage extends StatelessWidget {
  const MyCenterPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        children: [
          // 用户信息卡片
          const UserInfoCard(),
          
          // 功能列表
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('个人资料'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/my/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/my/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

/// 用户信息卡片
class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(Icons.person, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户名',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 个人资料页面
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: const Center(
        child: Text('个人资料页面'),
      ),
    );
  }
}

/// 设置页面
class MySettingsPage extends StatelessWidget {
  const MySettingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(
        child: Text('设置页面'),
      ),
    );
  }
}

/// 搜索页面
class SearchPage extends StatelessWidget {
  final String initialQuery;
  
  const SearchPage({super.key, this.initialQuery = ''});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: '搜索...',
            border: InputBorder.none,
          ),
          controller: TextEditingController(text: initialQuery),
        ),
      ),
      body: Center(
        child: Text('搜索页面 - 查询: $initialQuery'),
      ),
    );
  }
}

/// 通知页面
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知')),
      body: const Center(
        child: Text('通知页面'),
      ),
    );
  }
}
