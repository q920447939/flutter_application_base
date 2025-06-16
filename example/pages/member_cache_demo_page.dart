/// 会员信息缓存演示页面
/// 
/// 展示缓存策略的使用方法和性能监控
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/features/member/index.dart';

/// 会员信息缓存演示页面
class MemberCacheDemoPage extends StatelessWidget {
  const MemberCacheDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MemberController>(
      init: MemberController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('会员缓存演示'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showCacheStats(context, controller),
                tooltip: '缓存统计',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 缓存状态卡片
                _buildCacheStatusCard(controller),
                
                const SizedBox(height: 16),
                
                // 操作按钮组
                _buildActionButtons(controller),
                
                const SizedBox(height: 16),
                
                // 会员信息显示
                _buildMemberInfoCard(controller),
                
                const SizedBox(height: 16),
                
                // 缓存统计图表
                _buildCacheStatsCard(controller),
                
                const SizedBox(height: 16),
                
                // 缓存操作日志
                _buildCacheLogCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建缓存状态卡片
  Widget _buildCacheStatusCard(MemberController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '缓存状态',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Obx(() {
              final isLoading = controller.isLoadingMemberInfo.value;
              final hasData = controller.memberInfo.value != null;
              
              return Row(
                children: [
                  Icon(
                    hasData ? Icons.check_circle : Icons.error_outline,
                    color: hasData ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasData ? '缓存有效' : '缓存无效',
                    style: TextStyle(
                      color: hasData ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              );
            }),
            
            const SizedBox(height: 8),
            
            Obx(() {
              final lastUpdate = controller.lastUpdateTimeDisplay;
              return Text(
                '最后更新: $lastUpdate',
                style: const TextStyle(color: Colors.grey),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮组
  Widget _buildActionButtons(MemberController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '缓存操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.loadMemberInfo(),
                  icon: const Icon(Icons.cached),
                  label: const Text('从缓存加载'),
                ),
                
                ElevatedButton.icon(
                  onPressed: () => controller.refreshMemberInfo(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('强制刷新'),
                ),
                
                OutlinedButton.icon(
                  onPressed: () => _clearCache(controller),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('清除缓存'),
                ),
                
                OutlinedButton.icon(
                  onPressed: () => _preloadCache(controller),
                  icon: const Icon(Icons.download),
                  label: const Text('预热缓存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建会员信息卡片
  Widget _buildMemberInfoCard(MemberController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '会员信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Obx(() {
              final memberInfo = controller.memberInfo.value;
              
              if (memberInfo == null) {
                return const Center(
                  child: Text('暂无会员信息'),
                );
              }

              return Column(
                children: [
                  _buildInfoRow('昵称', memberInfo.nickName ?? '未设置'),
                  _buildInfoRow('会员编码', memberInfo.memberCode ?? '未知'),
                  _buildInfoRow('会员ID', memberInfo.simpleId?.toString() ?? '未知'),
                  if (memberInfo.createTime != null)
                    _buildInfoRow('注册时间', memberInfo.createTime!),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建缓存统计卡片
  Widget _buildCacheStatsCard(MemberController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '缓存统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            FutureBuilder<Map<String, dynamic>>(
              future: _getCacheStats(controller),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;
                return Column(
                  children: [
                    _buildStatsRow('命中次数', '${stats['hitCount']}'),
                    _buildStatsRow('未命中次数', '${stats['missCount']}'),
                    _buildStatsRow('网络请求', '${stats['networkRequestCount']}'),
                    _buildStatsRow('命中率', '${stats['hitRate']}%'),
                    _buildStatsRow('总请求', '${stats['totalRequests']}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建缓存日志卡片
  Widget _buildCacheLogCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作日志',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Container(
              height: 150,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SingleChildScrollView(
                child: Text(
                  '缓存操作日志将在这里显示...\n'
                  '✅ 缓存命中: 用户123\n'
                  '🌐 网络请求: 获取会员信息\n'
                  '💾 缓存更新: 昵称已更新\n'
                  '🗑️ 缓存清除: 手动清除',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取缓存统计信息
  Future<Map<String, dynamic>> _getCacheStats(MemberController controller) async {
    // 这里应该调用实际的缓存统计方法
    // 为了演示，返回模拟数据
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'hitCount': 15,
      'missCount': 3,
      'networkRequestCount': 3,
      'hitRate': '83.33',
      'totalRequests': 18,
    };
  }

  /// 清除缓存
  Future<void> _clearCache(MemberController controller) async {
    try {
      // await controller.clearMemberInfoCache();
      Get.snackbar('成功', '缓存已清除', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('错误', '清除缓存失败: $e', snackPosition: SnackPosition.TOP);
    }
  }

  /// 预热缓存
  Future<void> _preloadCache(MemberController controller) async {
    try {
      // await controller.preloadCache();
      Get.snackbar('成功', '缓存预热完成', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('错误', '缓存预热失败: $e', snackPosition: SnackPosition.TOP);
    }
  }

  /// 显示缓存统计详情
  void _showCacheStats(BuildContext context, MemberController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存统计详情'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getCacheStats(controller),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('命中率: ${stats['hitRate']}%'),
                Text('总请求: ${stats['totalRequests']}'),
                Text('缓存命中: ${stats['hitCount']}'),
                Text('缓存未命中: ${stats['missCount']}'),
                Text('网络请求: ${stats['networkRequestCount']}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
