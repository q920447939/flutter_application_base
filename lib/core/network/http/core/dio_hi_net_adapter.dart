import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../config/server_config.dart';
import '../../dio_config.dart';
import '../request/base_request.dart';
import 'hi_error.dart';
import 'hi_net_response.dart';

class DioHiNetAdapter extends HiNetAdapter {
  @override
  Future<HiNetResponse<T>> send<T>(BaseRequest request) async {
    var options = Options(headers: request.head);
    try {
      switch (request.method()) {
        case HttpMethod.GET:
          return await getDioInstance()
              .get(request.url(), options: options)
              .then((result) {
                if (ServerConfig().isDebug) {
                  if (kDebugMode) {
                    print("result is ${result.data}");
                  }
                }
                return HiNetResponse(
                  data: result.data,
                  baseRequest: request,
                  statusCode: result.statusCode,
                  statusMessage: result.statusMessage,
                );
              });
        case HttpMethod.POST:
          return await getDioInstance()
              .post(request.url(), options: options, data: request.body)
              .then((result) {
                return HiNetResponse(
                  data: result.data,
                  baseRequest: request,
                  statusCode: result.statusCode,
                  statusMessage: result.statusMessage,
                );
              });
        case HttpMethod.DELETE:
          return await getDioInstance()
              .delete(request.url(), options: options)
              .then((result) {
                if (ServerConfig().isDebug) {
                  if (kDebugMode) {
                    print("result is ${result.data}");
                  }
                }
                return HiNetResponse(
                  data: result.data,
                  baseRequest: request,
                  statusCode: result.statusCode,
                  statusMessage: result.statusMessage,
                );
              });
        case HttpMethod.PUT:
          return await getDioInstance()
              .put(request.url(), options: options, data: request.body)
              .then((result) {
                if (ServerConfig().isDebug) {
                  if (kDebugMode) {
                    print("result is ${result.data}");
                  }
                }
                return HiNetResponse(
                  data: result.data,
                  baseRequest: request,
                  statusCode: result.statusCode,
                  statusMessage: result.statusMessage,
                );
              });
      }
    } on DioError catch (e) {
      throw HiNetError(code: e.response?.statusCode ?? -1, msg: e.toString());
    }
  }

  _buildData(Response response, BaseRequest request) {
    return HiNetResponse(
      data: response.data ?? "",
      baseRequest: request,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      extra: response.extra,
    );
  }
}
