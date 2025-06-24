/// 功能导航页面
///
/// 提供分组的功能测试导航，方便快速访问各种测试功能
library;

import 'package:flutter/material.dart';
import 'feature_groups.dart';

/// 功能导航主页
class FeatureNavigator extends StatelessWidget {
  const FeatureNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能测试导航'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: FeatureGroups.groups.length,
        itemBuilder: (context, index) {
          final group = FeatureGroups.groups[index];
          return _buildFeatureGroupCard(context, group);
        },
      ),
    );
  }

  /// 构建功能组卡片
  Widget _buildFeatureGroupCard(BuildContext context, FeatureGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          group.icon,
          color: group.color,
          size: 32,
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          group.description,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        children: group.features.map((feature) {
          return _buildFeatureItem(context, feature);
        }).toList(),
      ),
    );
  }

  /// 构建功能项
  Widget _buildFeatureItem(BuildContext context, Feature feature) {
    return ListTile(
      leading: Icon(
        feature.icon,
        color: Colors.blue,
        size: 24,
      ),
      title: Text(feature.name),
      subtitle: Text(
        feature.description,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => feature.pageBuilder(context),
          ),
        );
      },
    );
  }
}

/// 功能组数据模型
class FeatureGroup {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<Feature> features;

  const FeatureGroup({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}

/// 功能项数据模型
class Feature {
  final String name;
  final String description;
  final IconData icon;
  final Widget Function(BuildContext context) pageBuilder;

  const Feature({
    required this.name,
    required this.description,
    required this.icon,
    required this.pageBuilder,
  });
}
