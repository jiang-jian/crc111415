/// 网络检测状态枚举
enum NetworkCheckStatus {
  /// 待检测
  pending,

  /// 检测中
  checking,

  /// 成功
  success,

  /// 失败
  failed,
}

/// 网络检测结果模型
class NetworkCheckResult {
  /// 状态
  final NetworkCheckStatus status;

  /// 错误信息
  final String? errorMessage;

  /// 延迟时间(毫秒)
  final int? latency;

  /// 检测时间
  final DateTime timestamp;

  NetworkCheckResult({
    required this.status,
    this.errorMessage,
    this.latency,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 创建待检测状态
  factory NetworkCheckResult.pending() {
    return NetworkCheckResult(status: NetworkCheckStatus.pending);
  }

  /// 创建检测中状态
  factory NetworkCheckResult.checking() {
    return NetworkCheckResult(status: NetworkCheckStatus.checking);
  }

  /// 创建成功状态
  factory NetworkCheckResult.success({int? latency}) {
    return NetworkCheckResult(
      status: NetworkCheckStatus.success,
      latency: latency,
    );
  }

  /// 创建失败状态
  factory NetworkCheckResult.failed(String errorMessage) {
    return NetworkCheckResult(
      status: NetworkCheckStatus.failed,
      errorMessage: errorMessage,
    );
  }

  /// 是否成功
  bool get isSuccess => status == NetworkCheckStatus.success;

  /// 是否失败
  bool get isFailed => status == NetworkCheckStatus.failed;

  /// 是否检测中
  bool get isChecking => status == NetworkCheckStatus.checking;

  /// 是否待检测
  bool get isPending => status == NetworkCheckStatus.pending;
}
