/// CommonResult专用响应处理器
///
/// 专门处理CommonResult格式的响应，统一HTTP状态码和业务状态码处理
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/models/common_result.dart';
import 'response_handler.dart';

/// CommonResult专用响应处理器接口
abstract class CommonResultResponseHandler {
  Future<CommonResult<T>> handleResponse<T>(
    Response response, {
    T Function(Map<String, dynamic>)? fromJson,
    bool expectWrapper = true,
  });

  CommonResult<T> handleError<T>(
    ErrorType type,
    dynamic error, {
    Response? response,
    StackTrace? stackTrace,
  });
}

/// CommonResult专用响应处理器实现
class CommonResultHandler implements CommonResultResponseHandler {
  /// 单例实例
  static final CommonResultHandler _instance = CommonResultHandler._internal();
  static CommonResultHandler get instance => _instance;

  CommonResultHandler._internal();

  /// 处理响应并返回CommonResult
  @override
  Future<CommonResult<T>> handleResponse<T>(
    Response response, {
    T Function(Map<String, dynamic>)? fromJson,
    bool expectWrapper = true,
  }) async {
    try {
      // 1. 检查HTTP状态码
      if (!_isHttpSuccess(response.statusCode)) {
        return _handleHttpError<T>(response);
      }

      // 2. 检查响应数据
      if (response.data == null) {
        return CommonResult<T>.failure(code: -2, msg: '响应数据为空');
      }

      // 3. 解析CommonResult格式的响应
      return _parseCommonResult<T>(response, fromJson);
    } catch (e, stackTrace) {
      debugPrint('响应处理异常: $e');
      debugPrint('错误堆栈: $stackTrace');

      return CommonResult<T>.failure(code: -2, msg: '数据解析失败: $e');
    }
  }

  @override
  CommonResult<T> handleError<T>(
    ErrorType type,
    dynamic error, {
    Response? response,
    StackTrace? stackTrace,
  }) {
    // 记录错误信息
    final errorInfo = _buildErrorInfo(type, error, response);
    debugPrint('处理错误: $errorInfo');

    if (stackTrace != null) {
      debugPrint('错误堆栈: $stackTrace');
    }

    // 根据错误类型创建对应的CommonResult
    switch (type) {
      case ErrorType.network:
        return _createNetworkError<T>(error);
      case ErrorType.http:
        return _createHttpError<T>(response);
      case ErrorType.business:
        return _createBusinessError<T>(error, response);
      case ErrorType.parse:
        return _createParseError<T>(error);
      case ErrorType.unknown:
        return _createUnknownError<T>(error);
    }
  }

  /// 检查HTTP状态码是否成功
  bool _isHttpSuccess(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode <= 299;
  }

  /// 解析CommonResult格式的响应
  CommonResult<T> _parseCommonResult<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      return CommonResult<T>.failure(code: -2, msg: '响应数据格式错误，期望JSON对象');
    }

    // 检查必要字段
    if (!data.containsKey('code')) {
      return CommonResult<T>.failure(code: -2, msg: '响应数据缺少code字段');
    }

    final code = data['code'] as int;
    final msg = data['msg'] as String? ?? '';
    final responseData = data['data'];

    // 检查业务状态码
    if (code != 0) {
      return CommonResult<T>.failure(code: code, msg: msg);
    }

    // 业务成功，解析数据
    T? parsedData;
    if (fromJson != null && responseData != null) {
      try {
        if (responseData is Map<String, dynamic>) {
          parsedData = fromJson(responseData);
        } else {
          // 如果responseData不是Map，尝试包装成Map
          parsedData = fromJson({'data': responseData});
        }
      } catch (e) {
        return CommonResult<T>.failure(code: -2, msg: '数据解析失败: $e');
      }
    }

    return CommonResult<T>.success(data: parsedData, msg: msg);
  }

  /// 处理HTTP错误
  CommonResult<T> _handleHttpError<T>(Response response) {
    final statusCode = response.statusCode ?? -1;
    final message = _getHttpErrorMessage(statusCode);

    // 尝试从响应体中获取更详细的错误信息
    String detailedMessage = message;
    if (response.data != null) {
      try {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final serverMessage = data['message'] ?? data['msg'] ?? data['error'];
          if (serverMessage != null) {
            detailedMessage = '$message: $serverMessage';
          }
        } else if (response.data is String) {
          detailedMessage = '$message: ${response.data}';
        }
      } catch (e) {
        // 忽略解析错误，使用默认消息
      }
    }

    return CommonResult<T>.failure(code: statusCode, msg: detailedMessage);
  }

  /// 创建网络错误结果
  CommonResult<T> _createNetworkError<T>(dynamic error) {
    String message = '网络连接失败';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = '连接超时';
          break;
        case DioExceptionType.sendTimeout:
          message = '发送超时';
          break;
        case DioExceptionType.receiveTimeout:
          message = '接收超时';
          break;
        case DioExceptionType.connectionError:
          message = '网络连接错误';
          break;
        case DioExceptionType.cancel:
          message = '请求已取消';
          break;
        default:
          message = '网络请求失败: ${error.message}';
      }
    } else {
      message = '网络连接失败: $error';
    }

    return CommonResult<T>.failure(code: -1, msg: message);
  }

  /// 创建HTTP错误结果
  CommonResult<T> _createHttpError<T>(Response? response) {
    final statusCode = response?.statusCode ?? -1;
    final message = _getHttpErrorMessage(statusCode);
    return CommonResult<T>.failure(code: statusCode, msg: message);
  }

  /// 创建业务错误结果
  CommonResult<T> _createBusinessError<T>(dynamic error, Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      final code = data['code'] as int? ?? -1;
      final message = data['msg'] as String? ?? error.toString();
      return CommonResult<T>.failure(code: code, msg: message);
    }
    return CommonResult<T>.failure(code: -1, msg: error.toString());
  }

  /// 创建解析错误结果
  CommonResult<T> _createParseError<T>(dynamic error) {
    return CommonResult<T>.failure(code: -2, msg: '数据解析失败: $error');
  }

  /// 创建未知错误结果
  CommonResult<T> _createUnknownError<T>(dynamic error) {
    return CommonResult<T>.failure(code: -999, msg: '未知错误: $error');
  }

  /// 获取HTTP错误消息
  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权访问，请重新登录';
      case 403:
        return '访问被禁止，权限不足';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时，请重试';
      case 409:
        return '请求冲突';
      case 422:
        return '请求参数验证失败';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用，请稍后重试';
      case 504:
        return '网关超时';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return '客户端请求错误';
        } else if (statusCode >= 500) {
          return '服务器错误';
        }
        return 'HTTP错误: $statusCode';
    }
  }

  /// 构建错误信息
  Map<String, dynamic> _buildErrorInfo(
    ErrorType type,
    dynamic error,
    Response? response,
  ) {
    final errorInfo = <String, dynamic>{
      'type': type.toString(),
      'error': error.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (response != null) {
      errorInfo.addAll({
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'requestPath': response.requestOptions.path,
        'requestMethod': response.requestOptions.method,
      });

      // 添加响应数据（如果是业务错误）
      if (type == ErrorType.business && response.data != null) {
        errorInfo['responseData'] = response.data;
      }
    }

    return errorInfo;
  }
}
