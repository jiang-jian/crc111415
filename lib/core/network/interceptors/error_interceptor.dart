import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import '../../storage/storage_service.dart';
import '../../constants/app_constants.dart';
import '../../widgets/toast.dart';
import '../../../app/routes/router_config.dart';

/// 错误拦截器 - 统一处理错误
class ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查业务状态码
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'] as int?;
      final msg = data['msg'] as String?;

      if (code != null && code != 0) {
        _handleBusinessError(code, msg ?? '请求失败');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = '网络错误';
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '连接超时，请检查网络';
        break;

      case DioExceptionType.badResponse:
        errorMessage = _handleHttpError(err.response?.statusCode);
        break;

      case DioExceptionType.cancel:
        errorMessage = '请求已取消';
        break;

      case DioExceptionType.connectionError:
        errorMessage = '网络连接失败，请检查网络';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = '证书验证失败';
        break;

      case DioExceptionType.unknown:
        errorMessage = '未知错误: ${err.message}';
        break;
    }

    _showErrorToast(errorMessage);
    handler.next(err);
  }

  /// 处理业务错误码
  void _handleBusinessError(int code, String message) {
    switch (code) {
      case 401:
        // 未授权，清除用户数据并跳转到登录页
        _clearAuthAndRedirectToLogin();
        _showErrorToast('登录已过期，请重新登录');
        break;

      case 403:
        _showErrorToast('权限不足');
        break;

      case 404:
        _showErrorToast('请求的资源不存在');
        break;

      case 500:
        _showErrorToast('服务器内部错误');
        break;

      default:
        _showErrorToast(message);
    }
  }

  /// 处理 HTTP 状态码错误
  String _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        _clearAuthAndRedirectToLogin();
        return '未授权，请重新登录';
      case 403:
        return '权限不足';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败 ($statusCode)';
    }
  }

  /// 清除认证信息并跳转到登录页
  void _clearAuthAndRedirectToLogin() {
    try {
      final storage = getx.Get.find<StorageService>();
      storage.remove(StorageKeys.token);
      storage.remove(StorageKeys.userId);
      storage.remove(StorageKeys.username);
      storage.remove(StorageKeys.merchantCode);

      // 延迟跳转，避免在拦截器中直接跳转导致的问题
      Future.delayed(const Duration(milliseconds: 100), () {
        final currentRoute = AppRouter.getCurrentRoute();
        if (currentRoute != '/login') {
          AppRouter.go('/login');
        }
      });
    } catch (e) {
      debugPrint('清除认证信息失败: $e');
    }
  }

  /// 显示错误提示
  void _showErrorToast(String message) {
    Toast.error(message: message);
  }
}
