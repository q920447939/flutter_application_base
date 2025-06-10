/// 动态详情页面组件
library;

import 'package:flutter/material.dart';
import '../../core/router/models/route_config.dart';
import '../../core/network/network_service.dart';
import 'dynamic_component_builder.dart';

/// 动态详情页面
class DynamicDetailPage extends StatefulWidget {
  final String title;
  final DataSourceConfig dataSource;
  final LayoutConfig? layout;
  final Map<String, dynamic>? arguments;
  final Map<String, dynamic>? customStyles;

  const DynamicDetailPage({
    super.key,
    required this.title,
    required this.dataSource,
    this.layout,
    this.arguments,
    this.customStyles,
  });

  @override
  State<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends State<DynamicDetailPage> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
  }

  /// 转换数据
  dynamic _transformData(dynamic data, DataTransformConfig transform) {
    // 提取数据路径
    if (transform.dataPath != null && data is Map<String, dynamic>) {
      final pathParts = transform.dataPath!.split('.');
      dynamic result = data;
      for (final part in pathParts) {
        if (result is Map<String, dynamic> && result.containsKey(part)) {
          result = result[part];
        } else {
          break;
        }
      }
      data = result;
    }

    // 应用字段映射
    if (transform.fieldMapping != null && data is Map<String, dynamic>) {
      final mappedData = <String, dynamic>{};
      transform.fieldMapping!.forEach((newKey, oldKey) {
        if (data.containsKey(oldKey)) {
          mappedData[newKey] = data[oldKey];
        }
      });
      data = mappedData;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
          
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    if (widget.layout != null) {
      // 使用自定义布局
      return DynamicComponentBuilder.buildLayout(
        widget.layout!,
        data: _data,
        arguments: widget.arguments,
        customStyles: widget.customStyles,
      );
    } else {
      // 使用默认详情页面布局
      return _buildDefaultDetailLayout();
    }
  }

  Widget _buildDefaultDetailLayout() {
    if (_data == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildDetailItems(_data!),
      ),
    );
  }

  List<Widget> _buildDetailItems(Map<String, dynamic> data) {
    final items = <Widget>[];

    data.forEach((key, value) {
      if (value != null) {
        items.add(_buildDetailItem(key, value));
        items.add(const SizedBox(height: 12));
      }
    });

    return items;
  }

  Widget _buildDetailItem(String key, dynamic value) {
    String displayKey = _formatKey(key);
    String displayValue = _formatValue(value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                displayKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Text(displayValue, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    // 将驼峰命名转换为可读的标签
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ')
        .trim();
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value ? '是' : '否';
    if (value is List) return value.join(', ');
    if (value is Map) return value.toString();
    return value.toString();
  }
}
