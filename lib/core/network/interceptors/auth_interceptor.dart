import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../storage/storage_service.dart';
import '../../constants/app_constants.dart';

/// 认证拦截器 - 添加 Token 和其他认证信息
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      // 获取存储服务
      final storage = getx.Get.find<StorageService>();

      // 添加 Token
      final token = storage.getString(StorageKeys.token);
      final tokenName = storage.getString(StorageKeys.tokenName) ?? 'AL-TOKEN';

      if (token != null && token.isNotEmpty) {
        options.headers[tokenName] = 'Bearer $token';
      }

      // 添加语言设置
      final language = storage.getString(StorageKeys.language) ?? 'zh';
      options.headers['Accept-Language'] = language;

      handler.next(options);
    } catch (e) {
      // 如果获取存储服务失败，继续请求
      handler.next(options);
    }
  }
}
