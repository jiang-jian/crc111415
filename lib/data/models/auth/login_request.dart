/// 登录请求模型
class LoginRequest {
  final String username;
  final String password;
  final String deviceCode;

  LoginRequest({
    required this.username,
    required this.password,
    required this.deviceCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'deviceCode': deviceCode,
    };
  }
}
