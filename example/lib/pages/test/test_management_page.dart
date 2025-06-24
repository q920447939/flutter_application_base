/// 测试管理页面
///
/// 提供统一的测试管理和执行界面
library;

import 'package:flutter/material.dart';
import '../../test_runner/yaml_test_runner.dart';
import '../../config/test_config.dart';

/// 测试管理页面
class TestManagementPage extends StatefulWidget {
  const TestManagementPage({super.key});

  @override
  State<TestManagementPage> createState() => _TestManagementPageState();
}

class _TestManagementPageState extends State<TestManagementPage> {
  List<TestResult> _testResults = [];
  bool _isRunning = false;
  String _currentTest = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [],
      ),
      body: Column(
        children: [
          // 控制面板
          _buildControlPanel(),

          const Divider(),

          // 测试结果显示
          Expanded(child: _buildTestResults()),
        ],
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YAML 模块测试管理',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '运行各种测试以验证 YAML 模块的功能和性能',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          if (_isRunning) ...[
            LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '正在运行: $_currentTest',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runAllTests,
                  icon:
                      _isRunning
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.play_arrow),
                  label: Text(_isRunning ? '运行中...' : '运行所有测试'),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _clearResults,
                icon: const Icon(Icons.clear),
                label: const Text('清除结果'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建测试结果显示
  Widget _buildTestResults() {
    if (_testResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无测试结果',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '点击"运行所有测试"开始测试',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _testResults.length + 1, // +1 for summary
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTestSummary();
        }

        final result = _testResults[index - 1];
        return _buildTestResultCard(result);
      },
    );
  }

  /// 构建测试摘要
  Widget _buildTestSummary() {
    final total = _testResults.length;
    final passed = _testResults.where((r) => r.success).length;
    final failed = total - passed;
    final successRate = total > 0 ? (passed / total * 100) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: successRate >= 80 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  '测试摘要',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('总计', total.toString(), Colors.blue),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '通过',
                    passed.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem('失败', failed.toString(), Colors.red),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '成功率',
                    '${successRate.toStringAsFixed(1)}%',
                    successRate >= 80 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建摘要项
  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// 构建测试结果卡片
  Widget _buildTestResultCard(TestResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          result.success ? Icons.check_circle : Icons.error,
          color: result.success ? Colors.green : Colors.red,
        ),
        title: Text(result.testName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('耗时: ${result.duration.inMilliseconds}ms'),
            if (!result.success && result.errorMessage != null)
              Text(
                '错误: ${result.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing:
            result.data != null
                ? IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showTestDetails(result),
                )
                : null,
      ),
    );
  }

  /// 运行所有测试
  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
      _currentTest = '初始化测试环境...';
    });
  }

  /// 清除测试结果
  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  /// 显示测试详情
  void _showTestDetails(TestResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(result.testName),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('状态: ${result.success ? "成功" : "失败"}'),
                  Text('耗时: ${result.duration.inMilliseconds}ms'),
                  if (result.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '错误信息:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result.errorMessage!),
                  ],
                  if (result.data != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '测试数据:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result.data.toString()),
                  ],
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
