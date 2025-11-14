/// 网络检测配置类
class NetworkConfig {
  /// 外网Ping地址
  static String externalPingHost = 'qq.com';

  /// 中心服务器Ping地址
  static String centerServerHost = 'dev-alland.zzss.com';

  /// DNS服务器地址
  static String dnsServerHost = '8.8.8.8';

  /// 检测超时时间（秒）
  static int checkTimeout = 2;

  /// 自动检测间隔时间（秒）
  static int autoCheckInterval = 50;

  /// Ping超时时间（秒）
  static int pingTimeout = 5;

  /// Ping重试次数
  static int pingRetryCount = 3;

  /// 配置所有Ping主机
  static void configure({
    String? externalHost,
    String? centerHost,
    String? dnsHost,
    int? timeout,
    int? interval,
    int? pingTimeoutSeconds,
    int? retryCount,
  }) {
    if (externalHost != null) externalPingHost = externalHost;
    if (centerHost != null) centerServerHost = centerHost;
    if (dnsHost != null) dnsServerHost = dnsHost;
    if (timeout != null) checkTimeout = timeout;
    if (interval != null) autoCheckInterval = interval;
    if (pingTimeoutSeconds != null) pingTimeout = pingTimeoutSeconds;
    if (retryCount != null) pingRetryCount = retryCount;
  }
}
