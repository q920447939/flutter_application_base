/// 认证服务
///
/// 提供用户认证相关功能，包括：
/// - 登录/注册
/// - Token管理
/// - 用户状态管理
/// - 自动登录
/// - 集成新的认证管理器
library;

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/storage_service.dart';
import '../models/user_model.dart';
import '../models/auth_request.dart';
import '../models/common_result.dart';
import '../models/auth_enums.dart';
import '../models/login_response.dart';
import 'auth_manager.dart';
import 'captcha_service.dart';
import 'device_info_service.dart';

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
      debugPrint('初始化认证服务失败: $e');
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
      debugPrint('验证Token失败: $e');
      await logout();
    }
  }

  /// 用户名密码登录（新接口）
  Future<bool> loginWithUsername({
    required String username,
    required String password,
    required String captcha,
    required String captchaSessionId,
    Map<String, Object>? context,
  }) async {
    try {
      _authStatus.value = AuthStatus.loading;

      final result = await AuthManager.instance.authenticateWithUsername(
        username: username,
        password: password,
        captcha: captcha,
        captchaSessionId: captchaSessionId,
        context: context,
      );

      if (result.isSuccess && result.data != null) {
        await _setTokenData(result.data!);
        debugPrint('用户名密码登录成功');
        return true;
      } else {
        _authStatus.value = AuthStatus.unauthenticated;
        debugPrint('用户名密码登录失败: ${result.msg}');
        return false;
      }
    } catch (e) {
      _authStatus.value = AuthStatus.unauthenticated;
      debugPrint('用户名密码登录异常: $e');
      return false;
    }
  }

  /// 用户名密码登录（返回详细结果）
  Future<CommonResult<LoginResponse>> loginWithUsernameDetailed({
    required String username,
    required String password,
    required String captcha,
    required String captchaSessionId,
    Map<String, Object>? context,
  }) async {
    try {
      _authStatus.value = AuthStatus.loading;

      final result = await AuthManager.instance.authenticateWithUsername(
        username: username,
        password: password,
        captcha: captcha,
        captchaSessionId: captchaSessionId,
        context: context,
      );

      if (result.isSuccess && result.data != null) {
        await _setTokenData(result.data!);
        debugPrint('用户名密码登录成功');
      } else {
        _authStatus.value = AuthStatus.unauthenticated;
        debugPrint('用户名密码登录失败: ${result.msg}');
      }

      return result;
    } catch (e) {
      _authStatus.value = AuthStatus.unauthenticated;
      debugPrint('用户名密码登录异常: $e');
      return CommonResult.networkError(msg: '登录异常: $e');
    }
  }

  /// 登录（保持向后兼容）
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
      debugPrint('登录失败: $e');
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
      debugPrint('注册失败: $e');
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
      debugPrint('服务器退出登录失败: $e');
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
      debugPrint('刷新Token失败: $e');
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
      debugPrint('更新用户信息失败: $e');
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
      debugPrint('修改密码失败: $e');
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
      debugPrint('发送重置密码邮件失败: $e');
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
      debugPrint('重置密码失败: $e');
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
      debugPrint('发送验证码失败: $e');
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

  /// 设置Token数据（简化版，仅处理token）
  Future<void> _setTokenData(LoginResponse loginResponse) async {
    _accessToken.value = loginResponse.token;
    _refreshToken.value = ''; // 简化版本暂时不处理refresh token
    _currentUser.value = null; // 简化版本暂时不处理用户信息
    _authStatus.value = AuthStatus.authenticated;

    // 保存到本地存储
    await StorageService.instance.setToken(_accessToken.value);

    debugPrint('Token已保存: ${loginResponse.hasToken ? '成功' : '失败'}');
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
