/// 加载状态功能
/// 
/// 实现页面加载状态管理和网络请求状态显示
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base_page.dart';

/// 加载功能配置
class LoadingFeatureConfig {
  /// 是否启用全局加载状态
  final bool enableGlobalLoading;
  
  /// 是否启用网络状态检查
  final bool enableNetworkCheck;
  
  /// 最小加载时间（毫秒）
  final int minLoadingDuration;
  
  /// 加载超时时间（毫秒）
  final int loadingTimeout;
  
  /// 自定义加载组件
  final Widget? customLoadingWidget;
  
  /// 自定义网络错误组件
  final Widget? customNetworkErrorWidget;
  
  /// 页面数据预加载回调
  final Future<bool> Function()? onPreloadData;
  
  /// 网络状态变化回调
  final void Function(bool isConnected)? onNetworkStatusChanged;

  const LoadingFeatureConfig({
    this.enableGlobalLoading = true,
    this.enableNetworkCheck = true,
    this.minLoadingDuration = 500,
    this.loadingTimeout = 30000,
    this.customLoadingWidget,
    this.customNetworkErrorWidget,
    this.onPreloadData,
    this.onNetworkStatusChanged,
  });
}

/// 加载功能实现
class LoadingFeature implements IPageFeature {
  final LoadingFeatureConfig config;
  bool _isLoading = false;
  bool _isNetworkConnected = true;

  LoadingFeature(this.config);

  @override
  String get featureName => 'LoadingFeature';

  @override
  Future<bool> onPageEnter(BuildContext context, String route) async {
    if (config.enableNetworkCheck) {
      _isNetworkConnected = await _checkNetworkStatus();
      if (!_isNetworkConnected) {
        config.onNetworkStatusChanged?.call(false);
        return false;
      }
    }

    if (config.onPreloadData != null) {
      _isLoading = true;
      
      try {
        // 确保最小加载时间
        final futures = <Future>[
          config.onPreloadData!(),
          Future.delayed(Duration(milliseconds: config.minLoadingDuration)),
        ];

        // 添加超时控制
        await Future.wait(futures).timeout(
          Duration(milliseconds: config.loadingTimeout),
        );

        _isLoading = false;
        return true;
      } catch (e) {
        _isLoading = false;
        debugPrint('数据预加载失败: $e');
        return false;
      }
    }

    return true;
  }

  @override
  Widget onPageBuild(BuildContext context, Widget child) {
    if (!_isNetworkConnected && config.enableNetworkCheck) {
      return config.customNetworkErrorWidget ?? _buildNetworkErrorWidget(context);
    }

    if (_isLoading && config.enableGlobalLoading) {
      return config.customLoadingWidget ?? _buildLoadingWidget(context);
    }

    return child;
  }

  @override
  Future<bool> onPageExit(BuildContext context, String route) async {
    return true;
  }

  @override
  void onPageDispose() {
    _isLoading = false;
  }

  /// 检查网络状态
  Future<bool> _checkNetworkStatus() async {
    try {
      // 这里可以集成具体的网络检查库，如 connectivity_plus
      // final connectivityResult = await Connectivity().checkConnectivity();
      // return connectivityResult != ConnectivityResult.none;
      
      // 简单的网络检查示例
      return true; // 暂时返回 true
    } catch (e) {
      debugPrint('网络状态检查失败: $e');
      return false;
    }
  }

  /// 构建加载组件
  Widget _buildLoadingWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '页面加载中...',
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建网络错误组件
  Widget _buildNetworkErrorWidget(BuildContext context) {
    return Scaffold(
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
            Text(
              '网络连接失败',
              style: Get.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '请检查您的网络连接',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                _isNetworkConnected = await _checkNetworkStatus();
                config.onNetworkStatusChanged?.call(_isNetworkConnected);
                if (_isNetworkConnected) {
                  // 重新加载页面
                  Get.back();
                  Get.toNamed(Get.currentRoute);
                }
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 加载功能构建器
class LoadingFeatureBuilder {
  /// 创建基础加载功能
  static LoadingFeature basic() {
    return LoadingFeature(const LoadingFeatureConfig());
  }

  /// 创建带数据预加载的功能
  static LoadingFeature withPreload(Future<bool> Function() preloadData) {
    return LoadingFeature(LoadingFeatureConfig(
      onPreloadData: preloadData,
    ));
  }

  /// 创建带网络检查的功能
  static LoadingFeature withNetworkCheck({
    void Function(bool isConnected)? onNetworkStatusChanged,
  }) {
    return LoadingFeature(LoadingFeatureConfig(
      enableNetworkCheck: true,
      onNetworkStatusChanged: onNetworkStatusChanged,
    ));
  }

  /// 创建自定义加载功能
  static LoadingFeature custom(LoadingFeatureConfig config) {
    return LoadingFeature(config);
  }
}
