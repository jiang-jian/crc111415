import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../toast.dart';
import 'table_config.dart';
import 'column_config.dart';
import 'search_field_config.dart';

/// 通用数据表格组件，基于 DataTable2
class DataTableWidget extends StatefulWidget {
  final TableConfig config;
  final List<ColumnConfig> columns;

  const DataTableWidget({
    super.key,
    required this.config,
    required this.columns,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  final Map<String, TextEditingController> _searchControllers = {};
  final Map<String, dynamic> _searchValues = {};
  DateTimeRange? _dateRange;

  final ApiClient _apiClient = ApiClient();
  final _dataList = <Map<String, dynamic>>[].obs;
  final _totalCount = 0.obs;
  final _currentPage = 1.obs;
  final _rowsPerPage = 10.obs;
  final _isLoading = false.obs;

  @override
  void initState() {
    super.initState();

    // 初始化搜索控制器
    for (final field in widget.config.searchFields) {
      if (field.type == SearchFieldType.input) {
        _searchControllers[field.key] = TextEditingController();
      }
      if (field.defaultValue != null) {
        _searchValues[field.key] = field.defaultValue;
      }
    }

    _rowsPerPage.value = widget.config.pageSize;
    _loadData();
  }

  @override
  void dispose() {
    for (final controller in _searchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    try {
      final params = {
        'page': _currentPage.value,
        'pageSize': _rowsPerPage.value,
        ..._searchValues,
        ...widget.config.apiParams,
      };

      final response = await _apiClient.post(
        widget.config.apiUrl,
        data: params,
      );

      if (response.isSuccess) {
        _dataList.value = List<Map<String, dynamic>>.from(
          response.result ?? [],
        );
        _totalCount.value = response.total ?? 0;
      } else {
        Toast.error(message: response.msg);
      }
    } catch (e) {
      Toast.error(message: '加载数据失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 调试:生成随机数据
  void _generateMockData() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final mockData = <Map<String, dynamic>>[];

    for (int i = 0; i < 35; i++) {
      final row = <String, dynamic>{};

      for (final col in widget.columns) {
        // 根据列的 key 生成不同类型的随机数据
        if (col.key.contains('Number') ||
            col.key.contains('No') ||
            col.key == 'cardNumber') {
          row[col.key] =
              '${random + i}${(i * 1000).toString().padLeft(6, '0')}';
        } else if (col.key.contains('time') ||
            col.key.contains('Time') ||
            col.key.contains('date')) {
          final date = DateTime.now().subtract(Duration(days: i));
          row[col.key] = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
        } else if (col.key.contains('amount') ||
            col.key.contains('price') ||
            col.key.contains('total')) {
          row[col.key] = ((random % 10000) / 100 + i * 10).toStringAsFixed(2);
        } else if (col.key.contains('quantity') ||
            col.key.contains('count') ||
            col.key.contains('Coins') ||
            col.key.contains('lottery') ||
            col.key.contains('coupons') ||
            col.key.contains('doors') ||
            col.key.contains('mysteryBox') ||
            col.key.contains('props') ||
            col.key.contains('members')) {
          row[col.key] = (random % 1000 + i * 10).toString();
        } else if (col.key.contains('status') || col.key.contains('Status')) {
          final statuses = ['正常', '已用', '已退', '冻结', '失效'];
          row[col.key] = statuses[i % statuses.length];
        } else if (col.key.contains('type') || col.key.contains('Type')) {
          final types = ['普通', '会员', 'VIP', '黑金', '钻石'];
          row[col.key] = types[i % types.length];
        } else if (col.key.contains('phone')) {
          row[col.key] = '138${(10000000 + i).toString().substring(0, 8)}';
        } else if (col.key.contains('name') || col.key.contains('Name')) {
          row[col.key] = '测试${col.title}${i + 1}';
        } else if (col.key.contains('store') || col.key.contains('Store')) {
          final stores = ['深圳南山店', '广州天河店', '北京朝阳店', '上海浦东店', '成都锦江店'];
          row[col.key] = stores[i % stores.length];
        } else if (col.key.contains('level') || col.key.contains('Level')) {
          final levels = ['普通会员', '白银会员', '黄金会员', '铂金会员', '钻石会员'];
          row[col.key] = levels[i % levels.length];
        } else if (col.key.contains('operator') ||
            col.key.contains('cashier')) {
          final operators = ['张三', '李四', '王五', '赵六', '刘七'];
          row[col.key] = operators[i % operators.length];
        } else if (col.key.contains('remark') || col.key.contains('Remark')) {
          final remarks = ['', '正常交易', '促销活动', '会员日优惠', '生日特惠'];
          row[col.key] = remarks[i % remarks.length];
        } else {
          row[col.key] = '${col.title}数据${i + 1}';
        }
      }

      mockData.add(row);
    }

    _dataList.value = mockData;
    _totalCount.value = mockData.length;
    Toast.success(message: '已生成 ${mockData.length} 条测试数据');
  }

  void _handleSearch() {
    _currentPage.value = 1;
    _loadData();
  }

  void _handleReset() {
    for (final controller in _searchControllers.values) {
      controller.clear();
    }
    _searchValues.clear();
    _dateRange = null;
    setState(() {});
    _currentPage.value = 1;
    _loadData();
  }

  void _handlePageChanged(int page) {
    _currentPage.value = page;
    _loadData();
  }

  void _handleRowsPerPageChanged(int? value) {
    if (value != null) {
      _rowsPerPage.value = value;
      _currentPage.value = 1;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.config.searchable) _buildSearchBar(),
        Expanded(child: _buildTable()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.only(
        top: AppTheme.spacingDefault,
        bottom: AppTheme.spacingDefault,
      ),
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: AppTheme.spacingM,
          runSpacing: AppTheme.spacingM,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...widget.config.searchFields.map((field) {
              return SizedBox(width: 220.w, child: _buildSearchField(field));
            }),
            SizedBox(
              width: 100.w,
              height: 46.h,
              child: ElevatedButton(
                onPressed: _handleSearch,
                child: Text('查询', style: TextStyle(fontSize: 15.sp)),
              ),
            ),
            SizedBox(
              width: 80.w,
              height: 46.h,
              child: OutlinedButton(
                onPressed: _handleReset,
                child: Text('重置', style: TextStyle(fontSize: 15.sp)),
              ),
            ),
            // 调试按钮:仅在开发环境显示
            if (kDebugMode)
              SizedBox(
                width: 120.w,
                height: 46.h,
                child: OutlinedButton(
                  onPressed: _generateMockData,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange.shade400),
                    foregroundColor: Colors.orange.shade700,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('调试数据', style: TextStyle(fontSize: 14.sp))],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(SearchFieldConfig field) {
    switch (field.type) {
      case SearchFieldType.input:
        return _buildTextField(field);
      case SearchFieldType.select:
        return _buildSelectField(field);
      case SearchFieldType.date:
        return _buildDateField(field);
      case SearchFieldType.dateRange:
        return _buildDateRangeField(field);
    }
  }

  Widget _buildTextField(SearchFieldConfig field) {
    return SizedBox(
      height: 46.h,
      child: TextField(
        controller: _searchControllers[field.key],
        onChanged: (value) => _searchValues[field.key] = value,
        decoration: InputDecoration(
          hintText: field.placeholder ?? field.label,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        style: TextStyle(fontSize: 15.sp),
      ),
    );
  }

  Widget _buildSelectField(SearchFieldConfig field) {
    return SizedBox(
      height: 46.h,
      child: DropdownButtonFormField(
        initialValue: _searchValues[field.key],
        decoration: InputDecoration(
          hintText: field.placeholder ?? field.label,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          ),
        ),
        items: field.options?.map((option) {
          return DropdownMenuItem(
            value: option.value,
            child: Text(option.label),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _searchValues[field.key] = value;
          });
        },
      ),
    );
  }

  Widget _buildDateField(SearchFieldConfig field) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: field.minDate ?? DateTime(2020),
          lastDate: field.maxDate ?? DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _searchValues[field.key] = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          _searchValues[field.key]?.toString() ??
              field.placeholder ??
              field.label,
          style: TextStyle(
            fontSize: 15.sp,
            color: _searchValues[field.key] == null
                ? Colors.grey.shade600
                : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeField(SearchFieldConfig field) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: field.minDate ?? DateTime(2020),
          lastDate: field.maxDate ?? DateTime.now(),
          initialDateRange: _dateRange,
        );
        if (picked != null) {
          setState(() {
            _dateRange = picked;
            _searchValues['${field.key}Start'] = DateFormat(
              'yyyy-MM-dd',
            ).format(picked.start);
            _searchValues['${field.key}End'] = DateFormat(
              'yyyy-MM-dd',
            ).format(picked.end);
          });
        }
      },
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          _dateRange == null
              ? field.placeholder ?? field.label
              : '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}',
          style: TextStyle(
            fontSize: 15.sp,
            color: _dateRange == null
                ? Colors.grey.shade600
                : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    // 计算固定左侧列数量和总宽度
    int leftFixedCount = 0;
    double totalFixedWidth = 0;

    for (final col in widget.columns) {
      if (col.fixed == 'left') {
        leftFixedCount++;
      }
      if (col.width != null) {
        totalFixedWidth += col.width!;
      }
    }

    // 最小宽度为固定列总宽度的1.2倍，确保有足够空间
    final minTableWidth = (totalFixedWidth * 1.2)
        .clamp(600.0, double.infinity)
        .toDouble();

    return Obx(() {
      if (_isLoading.value && _dataList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_dataList.isEmpty) {
        return Center(
          child: Text(
            '暂无数据',
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
          ),
        );
      }

      return PaginatedDataTable2(
        columns: _buildColumns(),
        source: _DataSource(data: _dataList, columns: widget.columns),
        rowsPerPage: _rowsPerPage.value,
        availableRowsPerPage: widget.config.pageSizeOptions,
        onRowsPerPageChanged: widget.config.pageSizeOptions.length > 1
            ? _handleRowsPerPageChanged
            : null,
        onPageChanged: (page) =>
            _handlePageChanged((page / _rowsPerPage.value).floor() + 1),
        columnSpacing: 8.w,
        horizontalMargin: 12.w,
        minWidth: minTableWidth,
        fixedLeftColumns: leftFixedCount,
        fixedTopRows: 1,
        fixedColumnsColor: Colors.white,
        headingRowHeight: 48.h,
        dataRowHeight: 48.h,
        showFirstLastButtons: true,
        wrapInCard: false,
        headingTextStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
        headingRowColor: WidgetStateProperty.all(AppTheme.backgroundGrey),
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        empty: Center(
          child: Text(
            '暂无数据',
            style: AppTheme.textBody.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      );
    });
  }

  List<DataColumn2> _buildColumns() {
    return widget.columns.map((col) {
      // 有 width 值使用 fixedWidth，否则使用 ColumnSize 自动扩展
      if (col.width != null) {
        return DataColumn2(
          label: Center(child: Text(col.title)),
          fixedWidth: col.width!.w,
          numeric: col.align == TextAlign.right,
        );
      } else {
        return DataColumn2(
          label: Center(child: Text(col.title)),
          size: ColumnSize.M,
          numeric: col.align == TextAlign.right,
        );
      }
    }).toList();
  }
}

/// 数据源类
class _DataSource extends DataTableSource {
  final RxList<Map<String, dynamic>> data;
  final List<ColumnConfig> columns;

  _DataSource({required this.data, required this.columns});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final row = data[index];
    final cells = columns.map((column) {
      Widget cellWidget;

      if (column.render != null) {
        cellWidget = column.render!(row[column.key], row);
      } else {
        cellWidget = Text(
          row[column.key]?.toString() ?? '-',
          style: AppTheme.textBody.copyWith(fontSize: 13.sp),
          textAlign: column.align ?? TextAlign.center,
        );
      }

      return DataCell(Center(child: cellWidget));
    }).toList();

    return DataRow(cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
