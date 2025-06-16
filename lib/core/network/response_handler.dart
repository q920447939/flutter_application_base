/// 统一响应处理器
/// 
/// 抽象所有HTTP状态码和业务状态码的处理逻辑，提供统一的响应处理接口
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 错误类型枚举
enum ErrorType {
  /// 网络错误 (无网络、超时等)
  network,
  /// HTTP错误 (4xx, 5xx)
  http,
  /// 业务错误 (code != 0)
  business,
  /// 解析错误
  parse,
  /// 未知错误
  unknown,
}

/// 响应处理器抽象接口
abstract class ResponseHandler {
  /// 处理响应并返回统一结果
  /// 
  /// [response] HTTP响应对象
  /// [fromJson] JSON反序列化函数
  /// [expectWrapper] 是否期望包装格式 (如 CommonResult)
  Future<T> handleResponse<T>(
    Response response, {
    T Function(Map<String, dynamic>)? fromJson,
    bool expectWrapper = true,
  });

  /// 处理错误并返回统一结果
  T handleError<T>(
    ErrorType type,
    dynamic error, {
    Response? response,
    StackTrace? stackTrace,
  });
}

/// 默认响应处理器实现
class DefaultResponseHandler implements ResponseHandler {
  /// HTTP成功状态码范围
  static const int _httpSuccessStart = 200;
  static const int _httpSuccessEnd = 299;

  @override
  Future<T> handleResponse<T>(
    Response response, {
    T Function(Map<String, dynamic>)? fromJson,
    bool expectWrapper = true,
  }) async {
    try {
      // 1. 检查HTTP状态码
      if (!_isHttpSuccess(response.statusCode)) {
        return handleError<T>(
          ErrorType.http,
          'HTTP错误: ${response.statusCode}',
          response: response,
        );
      }

      // 2. 检查响应数据
      if (response.data == null) {
        return handleError<T>(
          ErrorType.parse,
          '响应数据为空',
          response: response,
        );
      }

      // 3. 处理不同的响应格式
      if (expectWrapper) {
        return _handleWrappedResponse<T>(response, fromJson);
      } else {
        return _handleDirectResponse<T>(response, fromJson);
      }
    } catch (e, stackTrace) {
      debugPrint('响应处理异常: $e');
      return handleError<T>(
        ErrorType.parse,
        e,
        response: response,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  T handleError<T>(
    ErrorType type,
    dynamic error, {
    Response? response,
    StackTrace? stackTrace,
  }) {
    final errorInfo = _buildErrorInfo(type, error, response);
    
    debugPrint('处理错误: ${errorInfo.toString()}');
    if (stackTrace != null) {
      debugPrint('错误堆栈: $stackTrace');
    }

    // 这里返回具体的错误结果，需要根据T的类型来决定
    // 由于泛型限制，这里需要子类实现具体的错误结果创建
    throw UnimplementedError('子类需要实现具体的错误结果创建逻辑');
  }

  /// 检查HTTP状态码是否成功
  bool _isHttpSuccess(int? statusCode) {
    return statusCode != null &&
           statusCode >= _httpSuccessStart &&
           statusCode <= _httpSuccessEnd;
  }

  /// 处理包装格式的响应 (如 CommonResult<T>)
  T _handleWrappedResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data;
    
    if (data is! Map<String, dynamic>) {
      throw ArgumentError('期望Map<String, dynamic>格式的响应数据');
    }

    // 检查业务状态码
    final code = data['code'] as int?;
    if (code == null) {
      throw ArgumentError('响应数据缺少code字段');
    }

    if (code != 0) {
      // 业务错误
      return handleError<T>(
        ErrorType.business,
        data['msg'] ?? '业务处理失败',
        response: response,
      );
    }

    // 业务成功，解析数据
    if (fromJson != null) {
      final responseData = data['data'];
      if (responseData != null) {
        return fromJson(responseData as Map<String, dynamic>);
      }
    }

    // 如果没有fromJson函数，直接返回原始数据
    return data as T;
  }

  /// 处理直接格式的响应 (不包装)
  T _handleDirectResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data;

    if (fromJson != null && data is Map<String, dynamic>) {
      return fromJson(data);
    }

    return data as T;
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

/// CommonResult专用的响应处理器
class CommonResultResponseHandler extends DefaultResponseHandler {
  @override
  T handleError<T>(
    ErrorType type,
    dynamic error, {
    Response? response,
    StackTrace? stackTrace,
  }) {
    // 调用父类记录错误信息
    super.handleError(type, error, response: response, stackTrace: stackTrace);

    // 根据错误类型创建对应的CommonResult
    switch (type) {
      case ErrorType.network:
        return _createNetworkError<T>(error);
      case ErrorType.http:
        return _createHttpError<T>(error, response);
      case ErrorType.business:
        return _createBusinessError<T>(error, response);
      case ErrorType.parse:
        return _createParseError<T>(error);
      case ErrorType.unknown:
      default:
        return _createUnknownError<T>(error);
    }
  }

  /// 创建网络错误结果
  T _createNetworkError<T>(dynamic error) {
    // 这里需要导入CommonResult，为了避免循环依赖，使用动态创建
    return _createErrorResult<T>(-1, '网络连接失败: $error');
  }

  /// 创建HTTP错误结果
  T _createHttpError<T>(dynamic error, Response? response) {
    final statusCode = response?.statusCode ?? -1;
    final message = _getHttpErrorMessage(statusCode);
    return _createErrorResult<T>(statusCode, message);
  }

  /// 创建业务错误结果
  T _createBusinessError<T>(dynamic error, Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      final code = data['code'] as int? ?? -1;
      final message = data['msg'] as String? ?? error.toString();
      return _createErrorResult<T>(code, message);
    }
    return _createErrorResult<T>(-1, error.toString());
  }

  /// 创建解析错误结果
  T _createParseError<T>(dynamic error) {
    return _createErrorResult<T>(-2, '数据解析失败: $error');
  }

  /// 创建未知错误结果
  T _createUnknownError<T>(dynamic error) {
    return _createErrorResult<T>(-999, '未知错误: $error');
  }

  /// 创建错误结果 (动态创建CommonResult)
  T _createErrorResult<T>(int code, String message) {
    // 这里使用反射或工厂模式创建CommonResult
    // 为了简化，直接使用Map表示
    final result = {
      'code': code,
      'msg': message,
      'data': null,
      'success': false,
    };
    
    return result as T;
  }

  /// 获取HTTP错误消息
  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权访问';
      case 403:
        return '访问被禁止';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时';
      case 429:
        return '请求过于频繁';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return 'HTTP错误: $statusCode';
    }
  }
}
