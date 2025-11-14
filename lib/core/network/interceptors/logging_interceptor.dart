import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 日志拦截器 - 打印请求和响应信息（仅在 Debug 模式下）
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════════',
      );
      debugPrint('║ 📤 REQUEST');
      debugPrint('║ ${options.method} ${options.uri}');
      debugPrint('║ Headers:');
      options.headers.forEach((key, value) {
        debugPrint('║   $key: $value');
      });
      if (options.queryParameters.isNotEmpty) {
        debugPrint('║ Query Parameters:');
        options.queryParameters.forEach((key, value) {
          debugPrint('║   $key: $value');
        });
      }
      if (options.data != null) {
        debugPrint('║ Body: ${options.data}');
      }
      debugPrint(
        '╚════════════════════════════════════════════════════════════════',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════════',
      );
      debugPrint('║ 📥 RESPONSE');
      debugPrint('║ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('║ Headers:');
      response.headers.map.forEach((key, value) {
        debugPrint('║   $key: $value');
      });
      debugPrint('║ Body: ${response.data}');
      debugPrint(
        '╚════════════════════════════════════════════════════════════════',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '╔════════════════════════════════════════════════════════════════',
      );
      debugPrint('║ ❌ ERROR');
      debugPrint('║ ${err.requestOptions.method} ${err.requestOptions.uri}');
      debugPrint('║ Type: ${err.type}');
      debugPrint('║ Message: ${err.message}');
      if (err.response != null) {
        debugPrint('║ Status Code: ${err.response?.statusCode}');
        debugPrint('║ Response: ${err.response?.data}');
      }
      debugPrint(
        '╚════════════════════════════════════════════════════════════════',
      );
    }
    handler.next(err);
  }
}
