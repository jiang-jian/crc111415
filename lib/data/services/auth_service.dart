import '../../core/network/api_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';

/// 认证服务 - 处理登录、注册等认证相关的 API 请求
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// 登录
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/midst-auth/vws/login',
        data: request.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        return LoginResponse.fromJson(response.data!);
      } else {
        throw Exception(response.msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 发送验证码
  Future<void> sendVerificationCode(String phone) async {
    try {
      final response = await _apiClient.post(
        '/midst-auth/vws/send-code',
        data: {'phone': phone},
      );

      if (!response.isSuccess) {
        throw Exception(response.msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      final response = await _apiClient.post('/midst-auth/logout`1');

      if (!response.isSuccess) {
        throw Exception(response.msg);
      }
    } catch (e) {
      rethrow;
    }
  }
}
