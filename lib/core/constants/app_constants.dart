class AppConstants {
  static const String appName = 'Ailand POS';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}

class StorageKeys {
  static const String token = 'token';
  static const String tokenName = 'tokenName';
  static const String userId = 'userId';
  static const String language = 'language';
  static const String username = 'username';
  static const String merchantCode = 'merchantCode';
}

class ApiEndpoints {
  static const String baseUrl = 'https://dev-alland.zzss.com';
  static const String login = '/midst-auth/vws/login';
  static const String sendCode = '/midst-auth/vws/send-code';
  static const String logout = '/midst-auth/vws/logout';
}
