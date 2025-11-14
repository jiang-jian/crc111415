import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/theme/app_theme.dart';

/// Tabs
/// 通用 Tabs 按钮组件
///
/// 特性：
/// - 按钮样式,从左对齐,自适应宽度
/// - 带边框和选中状态颜色
/// - 禁用滑动手势切换
/// - 懒加载：只有被选中的 tab 才会加载其内容
class Tabs extends StatefulWidget {
  /// Tab 标签列表
  final List<String> tabs;

  /// Tab 视图内容列表
  final List<Widget> children;

  /// Tab 切换回调
  final Function(int)? onTap;

  /// 初始选中的索引（默认 0）
  final int initialIndex;

  const Tabs({
    super.key,
    required this.tabs,
    required this.children,
    this.onTap,
    this.initialIndex = 0,
  }) : assert(tabs.length == children.length, 'tabs 和 children 数量必须一致');

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late int _selectedIndex;
  final Set<int> _loadedIndexes = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadedIndexes.add(widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: widget.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              return _buildTabButton(
                text: text,
                isSelected: _selectedIndex == index,
                onTap: () => _onTabTap(index),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: List.generate(
              widget.children.length,
              (index) => _loadedIndexes.contains(index)
                  ? widget.children[index]
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建单个 Tab 按钮
  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        highlightColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  /// Tab 点击处理
  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
      _loadedIndexes.add(index);
    });
    widget.onTap?.call(index);
  }
}
