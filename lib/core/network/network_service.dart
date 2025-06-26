/// 网络服务封装
///
/// 基于Dio的网络请求封装，提供：
/// - 统一的请求/响应处理
/// - 错误处理机制
/// - 请求拦截器
/// - 响应拦截器
/// - 网络状态监听
/// - 动态网络配置管理
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:get/get.dart' as getx;
import '../app/app_config.dart';
import '../security/certificate_pinning_service.dart';
//import '../storage/storage_service.dart';
import '../../features/auth/models/common_result.dart';
import 'common_result_handler.dart';
import 'response_handler.dart';

/// 网络服务类
class NetworkService {
  late final Dio _dio;
  static NetworkService? _instance;

  /// 是否已初始化
  bool _isInitialized = false;

  NetworkService._internal() {
    _dio = Dio();
    _setupDio();
  }

  /// 单例模式
  static NetworkService get instance {
    _instance ??= NetworkService._internal();
    return _instance!;
  }

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 配置Dio
  void _setupDio() {
    _updateDioConfiguration();
    _addInterceptors();
    _configureCertificatePinning();
    _isInitialized = true;
  }

  /// 更新Dio配置（支持动态配置）
  void _updateDioConfiguration() {
    // 从配置管理器获取配置
    /*final baseUrl =
        configManager.getConfigValue<String>('base_url') ??
        AppConfig.current.apiBaseUrl;
    final connectTimeout =
        configManager.getConfigValue<int>('connect_timeout') ??
        AppConfig.current.networkTimeout.inMilliseconds;
    final receiveTimeout =
        configManager.getConfigValue<int>('receive_timeout') ??
        AppConfig.current.networkTimeout.inMilliseconds;
    final sendTimeout =
        configManager.getConfigValue<int>('send_timeout') ??
        AppConfig.current.networkTimeout.inMilliseconds;

    // 基础配置
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );*/
  }

  /// 重新配置网络服务（支持配置热更新）
  void reconfigure() {
    _updateDioConfiguration();
    debugPrint('网络服务配置已更新');
  }

  /// 添加拦截器
  void _addInterceptors() {
    final config = AppConfig.current;

    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加认证头
          _addAuthHeader(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 响应处理
          handler.next(response);
        },
        onError: (error, handler) {
          // 错误处理
          _handleError(error);
          handler.next(error);
        },
      ),
    );

    // 日志拦截器（仅在调试模式下）
    if (config.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  /// 配置证书绑定
  void _configureCertificatePinning() {
    // 为Dio配置证书绑定
    CertificatePinningService.instance.configureDio(_dio);
  }

  /// 添加认证头
  void _addAuthHeader(RequestOptions options) {
    // 使用同步方法获取token，避免异步等待
    /*final token = StorageService.instance.getTokenSync();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }*/
  }

  /// 错误处理
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // 超时错误
        break;
      case DioExceptionType.badResponse:
        // HTTP错误
        _handleHttpError(error);
        break;
      case DioExceptionType.cancel:
        // 请求取消
        break;
      case DioExceptionType.unknown:
        // 未知错误
        break;
      default:
        break;
    }
  }

  /// 处理HTTP错误
  void _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    switch (statusCode) {
      case 401:
        // 未授权，可能需要重新登录
        _handleUnauthorized();
        break;
      case 403:
        // 禁止访问
        break;
      case 404:
        // 资源不存在
        break;
      case 500:
        // 服务器错误
        break;
      default:
        break;
    }
  }

  /// 处理未授权错误
  void _handleUnauthorized() {
    // 跳转到登录页（避免循环导航）
    if (getx.Get.currentRoute != '/login') {
      getx.Get.offAllNamed('/login');
    }
  }

  /// GET请求（集成策略）
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _executeWithStrategies<T>(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      RequestOptions(
        path: path,
        method: 'GET',
        queryParameters: queryParameters,
      ),
    );
  }

  /// POST请求（集成策略）
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _executeWithStrategies<T>(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      RequestOptions(
        path: path,
        method: 'POST',
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  /// 执行请求并应用策略
  Future<Response<T>> _executeWithStrategies<T>(
    Future<Response<T>> Function() request,
    RequestOptions options,
  ) async {
    // 否则直接执行请求
    return await request();
  }

  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 上传文件
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: formData,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }

  // ========== 统一响应处理方法 ==========

  /// GET请求 - 返回CommonResult
  Future<CommonResult<T>> getCommonResult<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await CommonResultHandler.instance.handleResponse<T>(
        response,
        fromJson: fromJson,
      );
    } catch (e) {
      return CommonResultHandler.instance.handleError<T>(
        _getErrorType(e),
        e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// POST请求 - 返回CommonResult
  Future<CommonResult<T>> postCommonResult<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await CommonResultHandler.instance.handleResponse<T>(
        response,
        fromJson: fromJson,
      );
    } catch (e) {
      return CommonResultHandler.instance.handleError<T>(
        _getErrorType(e),
        e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// PUT请求 - 返回CommonResult
  Future<CommonResult<T>> putCommonResult<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await CommonResultHandler.instance.handleResponse<T>(
        response,
        fromJson: fromJson,
      );
    } catch (e) {
      return CommonResultHandler.instance.handleError<T>(
        _getErrorType(e),
        e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// DELETE请求 - 返回CommonResult
  Future<CommonResult<T>> deleteCommonResult<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await CommonResultHandler.instance.handleResponse<T>(
        response,
        fromJson: fromJson,
      );
    } catch (e) {
      return CommonResultHandler.instance.handleError<T>(
        _getErrorType(e),
        e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// 根据异常类型获取错误类型
  ErrorType _getErrorType(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.cancel:
          return ErrorType.network;
        case DioExceptionType.badResponse:
          return ErrorType.http;
        default:
          return ErrorType.unknown;
      }
    }
    return ErrorType.unknown;
  }
}
