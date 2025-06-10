/// 基础控制器
///
/// 提供通用的控制器功能，包括：
/// - 加载状态管理
/// - 错误处理
/// - 生命周期管理
/// - 通用方法
library;

import 'package:get/get.dart';

/// 页面状态枚举
enum PageState { initial, loading, success, error, empty }

/// 基础控制器抽象类
abstract class BaseController extends GetxController {
  /// 页面状态
  final Rx<PageState> _pageState = PageState.initial.obs;
  PageState get pageState => _pageState.value;

  /// 错误信息
  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  /// 是否正在加载
  bool get isLoading => pageState == PageState.loading;

  /// 是否加载成功
  bool get isSuccess => pageState == PageState.success;

  /// 是否有错误
  bool get hasError => pageState == PageState.error;

  /// 是否为空状态
  bool get isEmpty => pageState == PageState.empty;

  /// 设置加载状态
  void setLoading() {
    _pageState.value = PageState.loading;
  }

  /// 设置成功状态
  void setSuccess() {
    _pageState.value = PageState.success;
  }

  /// 设置错误状态
  void setError(String message) {
    _pageState.value = PageState.error;
    _errorMessage.value = message;
  }

  /// 设置空状态
  void setEmpty() {
    _pageState.value = PageState.empty;
  }

  /// 重置状态
  void resetState() {
    _pageState.value = PageState.initial;
    _errorMessage.value = '';
  }

  /// 执行异步操作的通用方法
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    String? errorMessage,
    Function(T)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      if (showLoading) setLoading();

      final result = await operation();

      setSuccess();
      onSuccess?.call(result);
      return result;
    } catch (e) {
      final message = errorMessage ?? e.toString();
      setError(message);
      onError?.call(message);
      return null;
    }
  }

  /// 显示成功消息
  void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  /// 显示错误消息
  void showError(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  /// 显示警告消息
  void showWarning(String message) {
    Get.snackbar(
      '警告',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.secondary,
      colorText: Get.theme.colorScheme.onSecondary,
    );
  }

  /// 显示信息消息
  void showInfo(String message) {
    Get.snackbar('信息', message, snackPosition: SnackPosition.TOP);
  }

  /// 显示加载对话框
  void showLoadingDialog({String? message}) {
    /* Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message ?? '加载中...'),
          ],
        ),
      ),
      barrierDismissible: false,
    ); */
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// 显示确认对话框
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
  }) async {
    /* final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false; */
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    // 子类可以重写此方法进行初始化
    initController();
  }

  @override
  void onReady() {
    super.onReady();
    // 子类可以重写此方法进行准备工作
    onControllerReady();
  }

  @override
  void onClose() {
    // 子类可以重写此方法进行清理工作
    disposeController();
    super.onClose();
  }

  /// 控制器初始化方法，子类可重写
  void initController() {}

  /// 控制器准备就绪方法，子类可重写
  void onControllerReady() {}

  /// 控制器销毁方法，子类可重写
  void disposeController() {}
}

/// 列表控制器基类
abstract class BaseListController<T> extends BaseController {
  /// 数据列表
  final RxList<T> _items = <T>[].obs;
  List<T> get items => _items;

  /// 当前页码
  final RxInt _currentPage = 1.obs;
  int get currentPage => _currentPage.value;

  /// 每页数量
  final int pageSize;

  /// 是否还有更多数据
  final RxBool _hasMore = true.obs;
  bool get hasMore => _hasMore.value;

  /// 是否正在加载更多
  final RxBool _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  BaseListController({this.pageSize = 20});

  /// 加载数据的抽象方法，子类必须实现
  Future<List<T>> loadData(int page, int size);

  /// 刷新数据
  Future<void> refreshData() async {
    _currentPage.value = 1;
    _hasMore.value = true;
    await _loadDataInternal(isRefresh: true);
  }

  /// 加载更多数据
  Future<void> loadMoreData() async {
    if (!hasMore || isLoadingMore) return;

    _isLoadingMore.value = true;
    _currentPage.value++;
    await _loadDataInternal(isLoadMore: true);
    _isLoadingMore.value = false;
  }

  /// 内部加载数据方法
  Future<void> _loadDataInternal({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) setLoading();

      final newItems = await loadData(currentPage, pageSize);

      if (isRefresh) {
        _items.clear();
      }

      _items.addAll(newItems);

      // 判断是否还有更多数据
      if (newItems.length < pageSize) {
        _hasMore.value = false;
      }

      if (_items.isEmpty) {
        setEmpty();
      } else {
        setSuccess();
      }
    } catch (e) {
      if (isLoadMore) {
        _currentPage.value--; // 回退页码
      }
      setError(e.toString());
    }
  }

  /// 添加单个项目
  void addItem(T item) {
    _items.add(item);
    if (isEmpty) setSuccess();
  }

  /// 添加多个项目
  void addItems(List<T> newItems) {
    _items.addAll(newItems);
    if (isEmpty && newItems.isNotEmpty) setSuccess();
  }

  /// 更新项目
  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
    }
  }

  /// 删除项目
  void removeItem(T item) {
    _items.remove(item);
    if (_items.isEmpty) setEmpty();
  }

  /// 根据索引删除项目
  void removeItemAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      if (_items.isEmpty) setEmpty();
    }
  }

  /// 清空列表
  void clearItems() {
    _items.clear();
    setEmpty();
  }

  @override
  void onControllerReady() {
    super.onControllerReady();
    // 自动加载第一页数据
    refreshData();
  }
}
