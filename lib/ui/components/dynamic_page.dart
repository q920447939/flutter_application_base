/// 动态页面组件
///
/// 根据布局配置动态渲染页面内容
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/router/models/route_config.dart';
import '../../core/network/network_service.dart';
import 'dynamic_component_builder.dart';

/// 动态页面
class DynamicPage extends StatefulWidget {
  final String title;
  final LayoutConfig layout;
  final DataSourceConfig? dataSource;
  final Map<String, dynamic>? arguments;
  final Map<String, dynamic>? customStyles;

  const DynamicPage({
    super.key,
    required this.title,
    required this.layout,
    this.dataSource,
    this.arguments,
    this.customStyles,
  });

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
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

    return DynamicComponentBuilder.buildLayout(
      widget.layout,
      data: _data,
      arguments: widget.arguments,
      customStyles: widget.customStyles,
    );
  }
}

/// 动态列表页面
class DynamicListPage extends StatefulWidget {
  final String title;
  final DataSourceConfig dataSource;
  final Map<String, dynamic>? arguments;
  final Map<String, dynamic>? customStyles;

  const DynamicListPage({
    super.key,
    required this.title,
    required this.dataSource,
    this.arguments,
    this.customStyles,
  });

  @override
  State<DynamicListPage> createState() => _DynamicListPageState();
}

class _DynamicListPageState extends State<DynamicListPage> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _items = [];
  int _currentPage = 1;
  bool _hasMore = true;

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

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.title), actions: [
         
        ],
      ));
  }

  Widget _buildListItem(dynamic item, int index) {
    // 这里可以根据配置或数据类型来决定如何渲染列表项
    // 暂时使用简单的卡片布局
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          item['title']?.toString() ??
              item['name']?.toString() ??
              '项目 ${index + 1}',
        ),
        subtitle:
            item['description'] != null
                ? Text(item['description'].toString())
                : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 处理点击事件
          // 可以根据配置决定跳转到详情页面或执行其他操作
        },
      ),
    );
  }
}
