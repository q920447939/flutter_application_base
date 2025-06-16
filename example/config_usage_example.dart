/// 配置管理使用示例
///
/// 展示如何在应用中使用远程配置管理系统
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/config/index.dart';

/// 配置使用示例页面
class ConfigUsageExamplePage extends StatefulWidget {
  const ConfigUsageExamplePage({super.key});

  @override
  State<ConfigUsageExamplePage> createState() => _ConfigUsageExamplePageState();
}

class _ConfigUsageExamplePageState extends State<ConfigUsageExamplePage> {
  late final RemoteConfigManager _configManager;
  final List<ConfigChangeEvent> _configChanges = [];

  @override
  void initState() {
    super.initState();
    _configManager = Get.find<RemoteConfigManager>();

    // 监听配置变更
    _configManager.configChangeStream.listen((event) {
      setState(() {
        _configChanges.insert(0, event);
        // 只保留最近10条变更记录
        if (_configChanges.length > 10) {
          _configChanges.removeLast();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置管理示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshConfig,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigSection(),
            const SizedBox(height: 24),
            _buildStatisticsSection(),
            const SizedBox(height: 24),
            _buildChangesSection(),
            const SizedBox(height: 24),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  /// 构建配置展示区域
  Widget _buildConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前配置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildConfigItem(
              '应用名称',
              _configManager.getString(AppConfigKeys.appDisplayName),
            ),
            _buildConfigItem(
              'API基础URL',
              _configManager.getString(AppConfigKeys.apiBaseUrl),
            ),
            _buildConfigItem(
              '请求超时时间',
              '${_configManager.getInt(AppConfigKeys.requestTimeout)}秒',
            ),
            _buildConfigItem(
              '调试模式',
              _configManager.getBool(AppConfigKeys.debugModeEnabled)
                  ? '启用'
                  : '禁用',
            ),
            _buildConfigItem(
              '功能A',
              _configManager.getBool(AppConfigKeys.featureAEnabled)
                  ? '启用'
                  : '禁用',
            ),
            _buildConfigItem(
              '推送通知',
              _configManager.getBool(AppConfigKeys.pushNotificationEnabled)
                  ? '启用'
                  : '禁用',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建配置项
  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  /// 构建统计信息区域
  Widget _buildStatisticsSection() {
    final stats = _configManager.getStatistics();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '统计信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildConfigItem('配置项总数', '${stats['total_configs']}'),
            _buildConfigItem('最后更新时间', stats['last_update_time'] ?? '未更新'),
            _buildConfigItem('更新状态', stats['is_updating'] ? '更新中' : '空闲'),
            _buildConfigItem(
              '初始化状态',
              stats['is_initialized'] ? '已初始化' : '未初始化',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建变更记录区域
  Widget _buildChangesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '配置变更记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_configChanges.isEmpty)
              const Text('暂无配置变更记录')
            else
              ..._configChanges.map((change) => _buildChangeItem(change)),
          ],
        ),
      ),
    );
  }

  /// 构建变更项
  Widget _buildChangeItem(ConfigChangeEvent change) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(change.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('旧值: ${change.oldValue}'),
          Text('新值: ${change.newValue}'),
          Text(
            '时间: ${change.timestamp.toString().substring(0, 19)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _refreshConfig,
                  child: const Text('刷新配置'),
                ),
                ElevatedButton(
                  onPressed: _clearCache,
                  child: const Text('清除缓存'),
                ),
                ElevatedButton(
                  onPressed: _testConfigChange,
                  child: const Text('测试配置变更'),
                ),
                ElevatedButton(
                  onPressed: _exportConfigs,
                  child: const Text('导出配置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 刷新配置
  Future<void> _refreshConfig() async {
    try {
      final result = await _configManager.refreshFromRemote();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '配置刷新成功，更新了 ${result.updatedCount} 个配置项'
                  : '配置刷新失败：${result.error}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('配置刷新失败：$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    try {
      await _configManager.clearCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('缓存清除成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('缓存清除失败：$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 测试配置变更
  void _testConfigChange() {
    // 手动设置一个配置值来测试变更通知
    final currentValue = _configManager.getBool(AppConfigKeys.debugModeEnabled);
    _configManager.setValue(AppConfigKeys.debugModeEnabled, !currentValue);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已切换调试模式状态'), backgroundColor: Colors.blue),
    );
  }

  /// 导出配置
  void _exportConfigs() {
    final configs = _configManager.exportAllConfigs();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('配置导出'),
            content: SingleChildScrollView(
              child: Text(
                configs.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
              ),
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
