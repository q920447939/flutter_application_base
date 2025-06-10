/// 动态路由演示页面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/router/dynamic_route_service.dart';
import '../../core/router/app_router.dart';

/// 动态路由演示页面
class DynamicRoutesDemoPage extends StatefulWidget {
  const DynamicRoutesDemoPage({super.key});

  @override
  State<DynamicRoutesDemoPage> createState() => _DynamicRoutesDemoPageState();
}

class _DynamicRoutesDemoPageState extends State<DynamicRoutesDemoPage> {
  final DynamicRouteService _routeService = DynamicRouteService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态路由演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRoutes,
          ),
        ],
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_routeService.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载动态路由配置...'),
          ],
        ),
      );
    }

    if (_routeService.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '加载失败: ${_routeService.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshRoutes,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final routes = _routeService.getEnabledRoutes();
    
    if (routes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无动态路由配置'),
            SizedBox(height: 8),
            Text(
              '请确保后端API返回正确的路由配置',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatsCard(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return _buildRouteCard(route);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final stats = _routeService.getRouteStats();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '路由统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('总数', stats['total'].toString()),
                ),
                Expanded(
                  child: _buildStatItem('启用', stats['enabled'].toString()),
                ),
                Expanded(
                  child: _buildStatItem('需认证', stats['authRequired'].toString()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '版本: ${stats['version']}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (stats['lastUpdated'] != null)
              Text(
                '更新时间: ${stats['lastUpdated']}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRouteCard(dynamic route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _getPageTypeIcon(route.pageType),
        title: Text(route.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route.path),
            const SizedBox(height: 4),
            Row(
              children: [
                if (route.requiresAuth)
                  const Chip(
                    label: Text('需认证', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                if (route.permissions?.isNotEmpty == true) ...[
                  const SizedBox(width: 4),
                  Chip(
                    label: Text('权限: ${route.permissions!.length}', 
                               style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.purple,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToRoute(route),
      ),
    );
  }

  Widget _getPageTypeIcon(dynamic pageType) {
    switch (pageType.toString().split('.').last) {
      case 'static':
        return const Icon(Icons.web, color: Colors.blue);
      case 'dynamic':
        return const Icon(Icons.dynamic_feed, color: Colors.green);
      case 'list':
        return const Icon(Icons.list, color: Colors.orange);
      case 'detail':
        return const Icon(Icons.article, color: Colors.purple);
      case 'form':
        return const Icon(Icons.edit_note, color: Colors.red);
      case 'webview':
        return const Icon(Icons.web_asset, color: Colors.teal);
      case 'external':
        return const Icon(Icons.open_in_new, color: Colors.grey);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Future<void> _navigateToRoute(dynamic route) async {
    try {
      await AppRouter.navigateTo(route.path);
    } catch (e) {
      Get.snackbar(
        '导航失败',
        '无法导航到 ${route.path}: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _refreshRoutes() async {
    try {
      await _routeService.reloadConfig();
      Get.snackbar(
        '刷新成功',
        '动态路由配置已更新',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '刷新失败',
        '无法刷新路由配置: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
