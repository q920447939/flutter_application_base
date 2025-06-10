/// 认证服务
///
/// 提供用户认证相关功能，包括：
/// - 登录/注册
/// - Token管理
/// - 用户状态管理
/// - 自动登录
library;

import 'package:get/get.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/storage_service.dart';
import '../models/user_model.dart';

/// 认证状态枚举
enum AuthStatus {
  initial, // 初始状态
  authenticated, // 已认证
  unauthenticated, // 未认证
  loading, // 加载中
}

/// 认证服务类
class AuthService extends GetxController {
  static AuthService? _instance;

  /// 认证状态
  final Rx<AuthStatus> _authStatus = AuthStatus.initial.obs;
  AuthStatus get authStatus => _authStatus.value;

  /// 当前用户
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  /// 访问令牌
  final RxString _accessToken = ''.obs;
  String get accessToken => _accessToken.value;

  /// 刷新令牌
  final RxString _refreshToken = ''.obs;
  String get refreshToken => _refreshToken.value;

  /// 是否已登录
  bool get isAuthenticated =>
      _authStatus.value == AuthStatus.authenticated &&
      _currentUser.value != null;

  /// 是否正在加载
  bool get isLoading => _authStatus.value == AuthStatus.loading;

  AuthService._internal();

  /// 单例模式
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  /// 初始化认证服务
  Future<void> initialize() async {
    _authStatus.value = AuthStatus.loading;

    try {
      // 尝试从存储中恢复认证状态
      await _restoreAuthState();

      if (isAuthenticated) {
        // 验证Token有效性
        await _validateToken();
      }
    } catch (e) {
      print('初始化认证服务失败: $e');
      await logout();
    } finally {
      if (_authStatus.value == AuthStatus.loading) {
        _authStatus.value = AuthStatus.unauthenticated;
      }
    }
  }

  /// 从存储中恢复认证状态
  Future<void> _restoreAuthState() async {
    final token = await StorageService.instance.getToken();
    final userInfo = await StorageService.instance.getUserInfo();

    if (token != null && token.isNotEmpty && userInfo != null) {
      _accessToken.value = token;
      _currentUser.value = UserModel.fromJson(userInfo);
      _authStatus.value = AuthStatus.authenticated;
    }
  }

  /// 验证Token有效性
  Future<void> _validateToken() async {
    try {
      final response = await NetworkService.instance.get('/auth/validate');
      if (response.statusCode == 200) {
        // Token有效，更新用户信息
        final userData = response.data['user'];
        if (userData != null) {
          _currentUser.value = UserModel.fromJson(userData);
          await _saveUserInfo();
        }
      } else {
        // Token无效，清除认证状态
        await logout();
      }
    } catch (e) {
      print('验证Token失败: $e');
      await logout();
    }
  }

  /// 登录
  Future<bool> login(LoginRequest request) async {
    try {
      _authStatus.value = AuthStatus.loading;

      final response = await NetworkService.instance.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _setAuthData(authResponse);
        return true;
      } else {
        _authStatus.value = AuthStatus.unauthenticated;
        return false;
      }
    } catch (e) {
      print('登录失败: $e');
      _authStatus.value = AuthStatus.unauthenticated;
      return false;
    }
  }

  /// 注册
  Future<bool> register(RegisterRequest request) async {
    try {
      _authStatus.value = AuthStatus.loading;

      final response = await NetworkService.instance.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _setAuthData(authResponse);
        return true;
      } else {
        _authStatus.value = AuthStatus.unauthenticated;
        return false;
      }
    } catch (e) {
      print('注册失败: $e');
      _authStatus.value = AuthStatus.unauthenticated;
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      // 调用服务器退出接口
      if (_accessToken.value.isNotEmpty) {
        await NetworkService.instance.post('/auth/logout');
      }
    } catch (e) {
      print('服务器退出登录失败: $e');
    } finally {
      // 清除本地认证数据
      await _clearAuthData();
    }
  }

  /// 刷新Token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken.value.isEmpty) {
      await logout();
      return false;
    }

    try {
      final response = await NetworkService.instance.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken.value},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _setAuthData(authResponse);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      print('刷新Token失败: $e');
      await logout();
      return false;
    }
  }

  /// 更新用户信息
  Future<bool> updateUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final response = await NetworkService.instance.put(
        '/user/profile',
        data: userInfo,
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        if (userData != null) {
          _currentUser.value = UserModel.fromJson(userData);
          await _saveUserInfo();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('更新用户信息失败: $e');
      return false;
    }
  }

  /// 修改密码
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await NetworkService.instance.put(
        '/auth/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('修改密码失败: $e');
      return false;
    }
  }

  /// 忘记密码
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await NetworkService.instance.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('发送重置密码邮件失败: $e');
      return false;
    }
  }

  /// 重置密码
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await NetworkService.instance.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('重置密码失败: $e');
      return false;
    }
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String phone) async {
    try {
      final response = await NetworkService.instance.post(
        '/auth/send-code',
        data: {'phone': phone},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('发送验证码失败: $e');
      return false;
    }
  }

  /// 设置认证数据
  Future<void> _setAuthData(AuthResponse authResponse) async {
    _accessToken.value = authResponse.accessToken;
    _refreshToken.value = authResponse.refreshToken ?? '';
    _currentUser.value = authResponse.user;
    _authStatus.value = AuthStatus.authenticated;

    // 保存到本地存储
    await StorageService.instance.setToken(_accessToken.value);
    await _saveUserInfo();
  }

  /// 清除认证数据
  Future<void> _clearAuthData() async {
    _accessToken.value = '';
    _refreshToken.value = '';
    _currentUser.value = null;
    _authStatus.value = AuthStatus.unauthenticated;

    // 清除本地存储
    await StorageService.instance.clearToken();
    await StorageService.instance.clearUserInfo();
  }

  /// 保存用户信息
  Future<void> _saveUserInfo() async {
    if (_currentUser.value != null) {
      await StorageService.instance.setUserInfo(_currentUser.value!.toJson());
    }
  }

  /// 检查是否需要刷新Token
  bool shouldRefreshToken() {
    // 这里可以根据Token的过期时间来判断
    // 简化实现，可以根据实际需求调整
    return _accessToken.value.isNotEmpty && _refreshToken.value.isNotEmpty;
  }

  /// 获取认证头
  String? getAuthorizationHeader() {
    if (_accessToken.value.isNotEmpty) {
      return 'Bearer ${_accessToken.value}';
    }
    return null;
  }
}
