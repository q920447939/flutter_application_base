/// HTTP配置获取策略使用示例
///
/// 展示如何配置和使用基于NetworkService的HTTP配置获取策略
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/config/index.dart';
import 'package:flutter_application_base/core/network/network_service.dart';

/// HTTP配置策略示例页面
class HttpConfigStrategyExamplePage extends StatefulWidget {
  const HttpConfigStrategyExamplePage({super.key});

  @override
  State<HttpConfigStrategyExamplePage> createState() =>
      _HttpConfigStrategyExamplePageState();
}

class _HttpConfigStrategyExamplePageState
    extends State<HttpConfigStrategyExamplePage> {
  late final RemoteConfigManager _configManager;
  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, dynamic> _configData = {};

  @override
  void initState() {
    super.initState();
    _configManager = Get.find<RemoteConfigManager>();
    _loadInitialData();
  }

  /// 加载初始数据
  void _loadInitialData() {
    setState(() {
      _configData = _configManager.exportAllConfigs();
      _statusMessage = '已加载 ${_configData.length} 个配置项';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP配置策略示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showStrategyInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
            const SizedBox(height: 16),
            _buildConfigDataCard(),
          ],
        ),
      ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HTTP策略状态',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isLoading ? Icons.sync : Icons.check_circle,
                  color: _isLoading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isLoading ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '网络服务状态: ${Get.find<NetworkService>().isInitialized ? "已初始化" : "未初始化"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作卡片
  Widget _buildActionsCard() {
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testHttpFetch,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('测试HTTP获取'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testCustomStrategy,
                  icon: const Icon(Icons.settings),
                  label: const Text('自定义策略'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testErrorHandling,
                  icon: const Icon(Icons.error_outline),
                  label: const Text('测试错误处理'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建配置数据卡片
  Widget _buildConfigDataCard() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '配置数据',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    _configData.isEmpty
                        ? const Center(child: Text('暂无配置数据'))
                        : ListView.builder(
                          itemCount: _configData.length,
                          itemBuilder: (context, index) {
                            final entry = _configData.entries.elementAt(index);
                            return ListTile(
                              title: Text(entry.key),
                              subtitle: Text(entry.value.toString()),
                              dense: true,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 测试HTTP获取
  Future<void> _testHttpFetch() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在从远程服务器获取配置...';
    });

    try {
      final result = await _configManager.refreshFromRemote();

      setState(() {
        _isLoading = false;
        if (result.success) {
          _statusMessage =
              '成功获取配置，更新了 ${result.updatedCount} 个配置项，耗时: ${result.duration.inMilliseconds}ms';
          _configData = _configManager.exportAllConfigs();
        } else {
          _statusMessage = '获取配置失败: ${result.error}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '获取配置异常: $e';
      });
    }
  }

  /// 测试自定义策略
  Future<void> _testCustomStrategy() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '测试自定义HTTP策略...';
    });

    /*     try {
      // 创建自定义HTTP策略
      final customStrategy = HttpConfigFetchStrategy(
        configUrl: 'https://jsonplaceholder.typicode.com/posts/1', // 测试API
        useAbsoluteUrl: true,
        extraHeaders: {
          'X-Custom-Header': 'test-value',
        },
        queryParameters: {
          'test': 'true',
        },
      );

      if (customStrategy.isAvailable) {
        final configs = await customStrategy.fetchConfigs();
        setState(() {
          _isLoading = false;
          _statusMessage = '自定义策略测试成功，获取到 ${configs.length} 个配置项';
        });
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = '自定义策略不可用';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '自定义策略测试失败: $e';
      });
    } */
  }

  /// 测试错误处理
  Future<void> _testErrorHandling() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '测试错误处理机制...';
    });

    try {
      // 创建一个会失败的HTTP策略
      final errorStrategy = HttpConfigFetchStrategy(
        configUrl: 'https://invalid-domain-for-testing.com/config',
        useAbsoluteUrl: true,
        timeout: const Duration(seconds: 5),
      );

      await errorStrategy.fetchConfigs();

      setState(() {
        _isLoading = false;
        _statusMessage = '意外成功（应该失败）';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '错误处理测试成功，捕获到错误: ${e.toString().substring(0, 100)}...';
      });
    }
  }

  /// 显示策略信息
  void _showStrategyInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('HTTP配置策略信息'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('特性:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• 基于已封装的NetworkService'),
                  Text('• 自动重试机制'),
                  Text('• 请求缓存'),
                  Text('• 安全策略'),
                  Text('• 限流保护'),
                  Text('• 详细错误处理'),
                  SizedBox(height: 16),
                  Text('优势:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• 无需手动实现重试逻辑'),
                  Text('• 统一的网络配置管理'),
                  Text('• 自动添加认证头'),
                  Text('• 支持证书绑定'),
                  Text('• 完整的日志记录'),
                ],
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
