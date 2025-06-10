/// 简化的页面基类
/// 
/// 提供纯业务导向的页面基类，不包含任何框架功能逻辑
library;

import 'package:flutter/material.dart';

/// 简化的无状态页面基类
/// 
/// 专注于业务逻辑实现，框架功能由路由层处理
abstract class SimpleStatelessPage extends StatelessWidget {
  const SimpleStatelessPage({super.key});

  /// 构建页面内容
  /// 
  /// 子类只需要实现这个方法，专注于业务逻辑
  Widget buildContent(BuildContext context);

  /// 页面初始化回调
  /// 
  /// 在页面构建前调用，可用于初始化业务数据
  void onPageInit(BuildContext context) {}

  /// 页面销毁回调
  /// 
  /// 在页面销毁时调用，可用于清理业务资源
  void onPageDispose() {}

  @override
  Widget build(BuildContext context) {
    // 执行页面初始化
    onPageInit(context);
    
    // 构建页面内容
    return buildContent(context);
  }
}

/// 简化的有状态页面基类
/// 
/// 专注于业务逻辑实现，框架功能由路由层处理
abstract class SimpleStatefulPage extends StatefulWidget {
  const SimpleStatefulPage({super.key});

  @override
  State<SimpleStatefulPage> createState() => createPageState();

  /// 创建页面状态
  /// 
  /// 子类需要实现这个方法来创建对应的状态类
  SimpleStatefulPageState createPageState();
}

/// 简化的有状态页面状态基类
/// 
/// 提供基础的状态管理功能，专注于业务逻辑
abstract class SimpleStatefulPageState<T extends SimpleStatefulPage> extends State<T> {
  /// 页面是否已初始化
  bool _isInitialized = false;

  /// 构建页面内容
  /// 
  /// 子类只需要实现这个方法，专注于业务逻辑
  Widget buildContent(BuildContext context);

  /// 页面初始化回调
  /// 
  /// 在页面首次构建时调用，可用于初始化业务数据
  Future<void> onPageInit() async {}

  /// 页面销毁回调
  /// 
  /// 在页面销毁时调用，可用于清理业务资源
  void onPageDispose() {}

  /// 页面刷新回调
  /// 
  /// 当页面需要刷新时调用
  Future<void> onPageRefresh() async {}

  /// 获取页面是否已初始化
  bool get isInitialized => _isInitialized;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    onPageDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  /// 初始化页面
  Future<void> _initializePage() async {
    if (!_isInitialized) {
      await onPageInit();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  /// 刷新页面
  Future<void> refreshPage() async {
    await onPageRefresh();
    if (mounted) {
      setState(() {
        // 触发重建
      });
    }
  }

  /// 安全的setState调用
  /// 
  /// 确保在组件未销毁时才调用setState
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// 显示加载对话框
  void showLoadingDialog({String message = '加载中...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// 显示错误提示
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: '确定',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 显示成功提示
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: '确定',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 显示确认对话框
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}

/// 页面混入
/// 
/// 提供常用的页面功能混入
mixin PageMixin {
  /// 显示提示消息
  void showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  /// 显示加载提示
  void showLoading(BuildContext context, {String message = '加载中...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// 隐藏加载提示
  void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// 安全的异步操作执行
  Future<T?> safeAsyncOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String loadingMessage = '处理中...',
    bool showLoadingDialog = true,
    void Function(String error)? onError,
  }) async {
    try {
      if (showLoadingDialog) {
        showLoading(context, message: loadingMessage);
      }

      final result = await operation();

      if (showLoadingDialog) {
        hideLoading(context);
      }

      return result;
    } catch (e) {
      if (showLoadingDialog) {
        hideLoading(context);
      }

      final errorMessage = e.toString();
      if (onError != null) {
        onError(errorMessage);
      } else {
        showMessage(context, errorMessage, isError: true);
      }

      return null;
    }
  }
}

/// 响应式页面混入
/// 
/// 提供响应式布局支持
mixin ResponsiveMixin {
  /// 获取屏幕断点
  ScreenBreakpoint getScreenBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return ScreenBreakpoint.mobile;
    } else if (width < 1024) {
      return ScreenBreakpoint.tablet;
    } else {
      return ScreenBreakpoint.desktop;
    }
  }

  /// 是否为移动端
  bool isMobile(BuildContext context) {
    return getScreenBreakpoint(context) == ScreenBreakpoint.mobile;
  }

  /// 是否为平板端
  bool isTablet(BuildContext context) {
    return getScreenBreakpoint(context) == ScreenBreakpoint.tablet;
  }

  /// 是否为桌面端
  bool isDesktop(BuildContext context) {
    return getScreenBreakpoint(context) == ScreenBreakpoint.desktop;
  }

  /// 根据屏幕大小返回不同的值
  T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getScreenBreakpoint(context)) {
      case ScreenBreakpoint.mobile:
        return mobile;
      case ScreenBreakpoint.tablet:
        return tablet ?? mobile;
      case ScreenBreakpoint.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// 屏幕断点枚举
enum ScreenBreakpoint {
  mobile,   // < 600px
  tablet,   // 600px - 1024px
  desktop,  // > 1024px
}

/// 页面状态枚举
enum PageState {
  loading,    // 加载中
  loaded,     // 已加载
  error,      // 错误状态
  empty,      // 空状态
}

/// 页面工具类
class PageUtils {
  /// 获取安全区域内边距
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// 获取状态栏高度
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 获取底部安全区域高度
  static double getBottomSafeAreaHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// 获取屏幕尺寸
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// 获取键盘高度
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// 是否显示键盘
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// 隐藏键盘
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
