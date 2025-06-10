/// 页面基类（已废弃）
///
/// 此文件已被新的路由架构替代，请使用 SimpleStatelessPage 和 SimpleStatefulPage
/// @deprecated 请使用 lib/core/base/simple_page.dart 中的新基类
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 页面功能接口
abstract class IPageFeature {
  /// 功能名称
  String get featureName;

  /// 页面进入前检查
  Future<bool> onPageEnter(BuildContext context, String route);

  /// 页面构建前处理
  Widget onPageBuild(BuildContext context, Widget child);

  /// 页面退出前处理
  Future<bool> onPageExit(BuildContext context, String route);

  /// 页面销毁时处理
  void onPageDispose();
}

/// 页面生命周期状态
enum PageLifecycleState {
  initializing, // 初始化中
  checking, // 检查中
  ready, // 准备就绪
  error, // 错误状态
  denied, // 被拒绝访问
}

/// 页面配置
class PageConfig {
  /// 页面路由
  final String route;

  /// 页面标题
  final String? title;

  /// 是否显示加载状态
  final bool showLoading;

  /// 是否显示错误状态
  final bool showError;

  /// 自定义加载组件
  final Widget? customLoadingWidget;

  /// 自定义错误组件
  final Widget? customErrorWidget;

  /// 页面功能列表
  final List<IPageFeature> features;

  const PageConfig({
    required this.route,
    this.title,
    this.showLoading = true,
    this.showError = true,
    this.customLoadingWidget,
    this.customErrorWidget,
    this.features = const [],
  });
}

/// 无状态页面基类
abstract class BaseStatelessPage extends StatelessWidget {
  const BaseStatelessPage({super.key});

  /// 页面配置
  PageConfig get pageConfig;

  /// 构建页面内容（子类实现）
  Widget buildContent(BuildContext context);

  /// 页面进入前的业务检查（子类可重写）
  Future<bool> onBusinessCheck(BuildContext context) async => true;

  /// 页面错误处理（子类可重写）
  Widget onError(BuildContext context, String error) {
    return pageConfig.customErrorWidget ?? _buildDefaultErrorWidget(error);
  }

  /// 页面加载状态（子类可重写）
  Widget onLoading(BuildContext context) {
    return pageConfig.customLoadingWidget ?? _buildDefaultLoadingWidget();
  }

  @override
  Widget build(BuildContext context) {
    return _BasePageWrapper(
      config: pageConfig,
      onBusinessCheck: onBusinessCheck,
      onError: onError,
      onLoading: onLoading,
      child: buildContent(context),
    );
  }

  /// 默认加载组件
  Widget _buildDefaultLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('页面加载中...'),
          ],
        ),
      ),
    );
  }

  /// 默认错误组件
  Widget _buildDefaultErrorWidget(String error) {
    return Scaffold(
      appBar: AppBar(title: Text(pageConfig.title ?? '错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面加载失败', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error, style: Get.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 有状态页面基类
abstract class BaseStatefulPage extends StatefulWidget {
  const BaseStatefulPage({super.key});

  /// 页面配置
  PageConfig get pageConfig;
}

/// 有状态页面状态基类
abstract class BaseStatefulPageState<T extends BaseStatefulPage>
    extends State<T> {
  /// 页面生命周期状态
  PageLifecycleState _lifecycleState = PageLifecycleState.initializing;

  /// 错误信息
  String? _errorMessage;

  /// 获取页面配置
  PageConfig get pageConfig => widget.pageConfig;

  /// 获取当前生命周期状态
  PageLifecycleState get lifecycleState => _lifecycleState;

  /// 构建页面内容（子类实现）
  Widget buildContent(BuildContext context);

  /// 页面进入前的业务检查（子类可重写）
  Future<bool> onBusinessCheck(BuildContext context) async => true;

  /// 页面错误处理（子类可重写）
  Widget onError(BuildContext context, String error) {
    return pageConfig.customErrorWidget ?? _buildDefaultErrorWidget(error);
  }

  /// 页面加载状态（子类可重写）
  Widget onLoading(BuildContext context) {
    return pageConfig.customLoadingWidget ?? _buildDefaultLoadingWidget();
  }

  /// 页面状态变化回调（子类可重写）
  void onLifecycleStateChanged(
    PageLifecycleState oldState,
    PageLifecycleState newState,
  ) {}

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    // 执行页面功能的销毁处理
    for (final feature in pageConfig.features) {
      feature.onPageDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_lifecycleState) {
      case PageLifecycleState.initializing:
      case PageLifecycleState.checking:
        return pageConfig.showLoading
            ? onLoading(context)
            : const SizedBox.shrink();
      case PageLifecycleState.error:
        return pageConfig.showError
            ? onError(context, _errorMessage ?? '未知错误')
            : const SizedBox.shrink();
      case PageLifecycleState.denied:
        return onError(context, '访问被拒绝');
      case PageLifecycleState.ready:
        return buildContent(context);
    }
  }

  /// 初始化页面
  Future<void> _initializePage() async {
    try {
      _updateLifecycleState(PageLifecycleState.checking);

      // 执行页面功能检查
      for (final feature in pageConfig.features) {
        final canEnter = await feature.onPageEnter(context, pageConfig.route);
        if (!canEnter) {
          _updateLifecycleState(PageLifecycleState.denied);
          return;
        }
      }

      // 执行业务检查
      final businessCheckPassed = await onBusinessCheck(context);
      if (!businessCheckPassed) {
        _updateLifecycleState(PageLifecycleState.denied);
        return;
      }

      _updateLifecycleState(PageLifecycleState.ready);
    } catch (e) {
      _errorMessage = e.toString();
      _updateLifecycleState(PageLifecycleState.error);
    }
  }

  /// 更新生命周期状态
  void _updateLifecycleState(PageLifecycleState newState) {
    if (_lifecycleState != newState) {
      final oldState = _lifecycleState;
      setState(() {
        _lifecycleState = newState;
      });
      onLifecycleStateChanged(oldState, newState);
    }
  }

  /// 默认加载组件
  Widget _buildDefaultLoadingWidget() {
    return Scaffold(
      appBar:
          pageConfig.title != null
              ? AppBar(title: Text(pageConfig.title!))
              : null,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('页面加载中...'),
          ],
        ),
      ),
    );
  }

  /// 默认错误组件
  Widget _buildDefaultErrorWidget(String error) {
    return Scaffold(
      appBar: AppBar(title: Text(pageConfig.title ?? '错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面加载失败', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error, style: Get.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 页面包装器（用于无状态页面）
class _BasePageWrapper extends StatefulWidget {
  final PageConfig config;
  final Future<bool> Function(BuildContext) onBusinessCheck;
  final Widget Function(BuildContext, String) onError;
  final Widget Function(BuildContext) onLoading;
  final Widget child;

  const _BasePageWrapper({
    required this.config,
    required this.onBusinessCheck,
    required this.onError,
    required this.onLoading,
    required this.child,
  });

  @override
  State<_BasePageWrapper> createState() => _BasePageWrapperState();
}

class _BasePageWrapperState extends State<_BasePageWrapper> {
  PageLifecycleState _lifecycleState = PageLifecycleState.initializing;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    // 执行页面功能的销毁处理
    for (final feature in widget.config.features) {
      feature.onPageDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_lifecycleState) {
      case PageLifecycleState.initializing:
      case PageLifecycleState.checking:
        return widget.config.showLoading
            ? widget.onLoading(context)
            : const SizedBox.shrink();
      case PageLifecycleState.error:
        return widget.config.showError
            ? widget.onError(context, _errorMessage ?? '未知错误')
            : const SizedBox.shrink();
      case PageLifecycleState.denied:
        return widget.onError(context, '访问被拒绝');
      case PageLifecycleState.ready:
        // 应用页面功能的构建处理
        Widget result = widget.child;
        for (final feature in widget.config.features) {
          result = feature.onPageBuild(context, result);
        }
        return result;
    }
  }

  /// 初始化页面
  Future<void> _initializePage() async {
    try {
      setState(() {
        _lifecycleState = PageLifecycleState.checking;
      });

      // 执行页面功能检查
      for (final feature in widget.config.features) {
        final canEnter = await feature.onPageEnter(
          context,
          widget.config.route,
        );
        if (!canEnter) {
          setState(() {
            _lifecycleState = PageLifecycleState.denied;
          });
          return;
        }
      }

      // 执行业务检查
      final businessCheckPassed = await widget.onBusinessCheck(context);
      if (!businessCheckPassed) {
        setState(() {
          _lifecycleState = PageLifecycleState.denied;
        });
        return;
      }

      setState(() {
        _lifecycleState = PageLifecycleState.ready;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _lifecycleState = PageLifecycleState.error;
      });
    }
  }
}
