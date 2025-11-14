/// ColumnConfig
/// 表格列配置类
///
/// 基于 DataTable2 的列配置,支持固定宽度和自动扩展
///
/// 使用说明:
/// 1. width 参数 - 列宽度:
///    - 有值: 使用 fixedWidth (响应式 .w)
///    - null: 使用 ColumnSize.M 自动扩展
///
/// 2. fixed 参数 - 固定列位置:
///    - 'left': 固定在左侧 (配合 fixedLeftColumns)
///    - null: 正常可滚动列
///
/// 3. align 参数 - 文本对齐:
///    - TextAlign.left: 左对齐
///    - TextAlign.center: 居中对齐 (默认)
///    - TextAlign.right: 右对齐 (会设置 numeric: true)
///
/// 4. 示例:
///    ```dart
///    // 固定宽度列
///    ColumnConfig(
///      key: 'cardNumber',
///      title: '卡号',
///      width: 220,  // 使用 220.w
///    ),
///
///    // 固定宽度列
///    ColumnConfig(
///      key: 'store',
///      title: '门店',
///      width: 180,  // 使用 180.w
///    ),
///
///    // 自动扩展列
///    ColumnConfig(
///      key: 'remark',
///      title: '备注',
///      // 不传 width,自动扩展
///    ),
///
///    // 右对齐数字列
///    ColumnConfig(
///      key: 'amount',
///      title: '金额',
///      width: 120,
///      align: TextAlign.right,
///    ),
///    ```
///
/// 作者:AI 自动生成
/// 更新时间:2025-11-11

import 'package:flutter/material.dart';

class ColumnConfig {
  /// 列的唯一标识,对应数据中的字段名
  final String key;

  /// 列标题
  final String title;

  /// 是否可排序
  final bool sortable;

  /// 列宽度
  /// - 有值: 使用 fixedWidth (width.w)
  /// - null: 使用 ColumnSize.M 自动扩展
  final double? width;

  /// 固定列位置 (仅支持左侧固定)
  /// - 'left': 固定在左侧
  /// - null: 正常可滚动列
  final String? fixed;

  /// 文本对齐方式
  final TextAlign? align;

  /// 自定义渲染函数
  /// 参数: value - 单元格值, row - 整行数据
  final Widget Function(dynamic value, Map<String, dynamic> row)? render;

  const ColumnConfig({
    required this.key,
    required this.title,
    this.sortable = false,
    this.width,
    this.fixed,
    this.align,
    this.render,
  });
}
