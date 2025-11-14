/// 打印机状态中文翻译工具类
class PrinterStatusTranslation {
  /// 获取状态的中文翻译
  static String getChineseTranslation(String status) {
    final upperStatus = status.toUpperCase();

    // 基本状态翻译
    if (upperStatus == 'READY') return '就绪';
    if (upperStatus == 'UNKNOWN') return '未知';
    if (upperStatus == 'ERROR') return '错误';
    if (upperStatus == 'OFFLINE') return '离线';
    if (upperStatus == 'COMM') return '通信异常';

    // 错误状态
    if (upperStatus.contains('ERR_PAPER_OUT')) return '缺纸';
    if (upperStatus.contains('ERR_PAPER_JAM')) return '堵纸';
    if (upperStatus.contains('ERR_PAPER_MISMATCH')) return '纸张不匹配';
    if (upperStatus.startsWith('ERR_')) return '错误';

    // 警告状态
    if (upperStatus.contains('WARN_')) return '警告';
    if (upperStatus.contains('WARNING')) return '警告';

    // 打印机类型翻译
    if (upperStatus.contains('THERMAL')) return '热敏打印机';

    // 未知状态返回原文
    return status;
  }

  /// 格式化显示：英文(中文)
  static String formatWithTranslation(String status) {
    if (status.isEmpty) return '';
    final chinese = getChineseTranslation(status);
    if (chinese == status) {
      // 如果没有翻译，只显示原文
      return status;
    }
    return '$status（$chinese）';
  }
}
