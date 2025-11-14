/// TableConfig
/// 表格配置类
/// 作者：AI 自动生成
/// 更新时间：2025-11-11

import 'search_field_config.dart';

class TableConfig {
  final bool searchable;
  final bool pagination;
  final int pageSize;
  final List<int> pageSizeOptions;
  final String apiUrl;
  final String apiMethod;
  final Map<String, dynamic> apiParams;
  final List<SearchFieldConfig> searchFields;
  final String rowKey;

  const TableConfig({
    this.searchable = true,
    this.pagination = true,
    this.pageSize = 10,
    this.pageSizeOptions = const [10, 20, 50],
    required this.apiUrl,
    this.apiMethod = 'post',
    this.apiParams = const {},
    this.searchFields = const [],
    this.rowKey = 'id',
  });
}
