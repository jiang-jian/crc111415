/// 登录响应模型
class LoginResponse {
  final String? username;
  final String? token;
  final String? tokenName;
  final int? isLogin;
  final int? changePwdStatus;

  LoginResponse({
    this.username,
    this.token,
    this.tokenName,
    this.isLogin,
    this.changePwdStatus,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      username: json['username'] as String?,
      token: json['token'] as String?,
      tokenName: json['tokenName'] as String?,
      isLogin: json['isLogin'] as int?,
      changePwdStatus: json['changePwdStatus'] as int?,
    );
  }
}
