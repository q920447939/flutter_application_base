/// 网络服务封装
///
/// 基于Dio的网络请求封装，提供：
/// - 统一的请求/响应处理
/// - 错误处理机制
/// - 请求拦截器
/// - 响应拦截器
/// - 网络状态监听
library;

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:get/get.dart' as getx;
import '../app/app_config.dart';
import '../security/certificate_pinning_service.dart';
import '../storage/storage_service.dart';

/// 网络服务类
class NetworkService {
  late final Dio _dio;
  static NetworkService? _instance;

  NetworkService._internal() {
    _dio = Dio();
    _setupDio();
  }

  /// 单例模式
  static NetworkService get instance {
    _instance ??= NetworkService._internal();
    return _instance!;
  }

  /// 配置Dio
  void _setupDio() {
    final config = AppConfig.current;

    // 基础配置
    _dio.options = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.networkTimeout,
      receiveTimeout: config.networkTimeout,
      sendTimeout: config.networkTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加拦截器
    _addInterceptors();

    // 配置证书绑定
    _configureCertificatePinning();
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
    final token = StorageService.instance.getTokenSync();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
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
    // 清除token并跳转到登录页
    StorageService.instance.clearTokenSync();
    StorageService.instance.clearUserInfoSync();

    // 跳转到登录页（避免循环导航）
    if (getx.Get.currentRoute != '/login') {
      getx.Get.offAllNamed('/login');
    }
  }

  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
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
}
