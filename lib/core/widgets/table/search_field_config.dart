/// SearchFieldConfig
/// 搜索字段配置类
/// 作者：AI 自动生成
/// 更新时间：2025-11-11

class SearchFieldConfig {
  final String key;
  final String label;
  final SearchFieldType type;
  final String? placeholder;
  final dynamic defaultValue;
  final List<SearchFieldOption>? options;
  final DateTime? minDate;
  final DateTime? maxDate;

  const SearchFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.placeholder,
    this.defaultValue,
    this.options,
    this.minDate,
    this.maxDate,
  });
}

enum SearchFieldType { input, select, date, dateRange }

class SearchFieldOption {
  final String label;
  final dynamic value;

  const SearchFieldOption({required this.label, required this.value});
}
