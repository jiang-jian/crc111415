import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes/router_config.dart';

/// 面包屑导航项
class BreadcrumbItem {
  final String label;
  final String? path;

  const BreadcrumbItem({required this.label, this.path});
}

/// 面包屑导航组件
class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? textColor;
  final Color? activeColor;
  final Color? separatorColor;
  final double? fontSize;
  final bool disabled;

  const Breadcrumb({
    super.key,
    required this.items,
    this.textColor,
    this.activeColor,
    this.separatorColor,
    this.fontSize,
    this.disabled = false,
  });

  /// 从当前路由自动生成面包屑
  static List<BreadcrumbItem> fromContext(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final currentPath = routerState.uri.path;
    return _generateBreadcrumbs(currentPath, context);
  }

  /// 根据路径生成面包屑列表
  static List<BreadcrumbItem> _generateBreadcrumbs(
    String currentPath,
    BuildContext context,
  ) {
    final items = <BreadcrumbItem>[];
    final router = AppRouter.router;

    // 获取路由配置中的所有路由
    final routeMap = _buildRouteMap(router.configuration.routes);

    // 添加首页作为第一项
    items.add(const BreadcrumbItem(label: 'Home', path: '/home'));

    // 如果不是首页，添加当前页面
    if (currentPath != '/home' && routeMap.containsKey(currentPath)) {
      final routeInfo = routeMap[currentPath]!;
      items.add(
        BreadcrumbItem(
          label: routeInfo.label,
          path: null, // 当前页面不可点击
        ),
      );
    }

    return items;
  }

  /// 构建路由映射表（路径 -> 路由信息）
  static Map<String, _RouteInfo> _buildRouteMap(List<RouteBase> routes) {
    final map = <String, _RouteInfo>{};

    void processRoute(RouteBase route, [String parentPath = '']) {
      if (route is GoRoute) {
        final fullPath = route.path.startsWith('/')
            ? route.path
            : '$parentPath/${route.path}';

        // 使用路由的 name 作为标签，如果没有 name 则使用路径
        final label = route.name ?? '';

        map[fullPath] = _RouteInfo(
          path: fullPath,
          name: route.name,
          label: label,
        );

        // 递归处理子路由
        for (final childRoute in route.routes) {
          processRoute(childRoute, fullPath);
        }
      } else if (route is ShellRoute) {
        // 处理 ShellRoute 中的子路由
        for (final childRoute in route.routes) {
          processRoute(childRoute, parentPath);
        }
      }
    }

    for (final route in routes) {
      processRoute(route);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final defaultTextColor = disabled
        ? AppTheme.textDisabled
        : (textColor ?? AppTheme.textSecondary);
    final defaultActiveColor = disabled
        ? AppTheme.textDisabled
        : (activeColor ?? AppTheme.textPrimary);
    final defaultSeparatorColor = disabled
        ? AppTheme.borderColorLight
        : (separatorColor ?? AppTheme.textDisabled);
    final defaultFontSize = fontSize ?? 14.sp;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _BreadcrumbItemWidget(
            item: items[i],
            isLast: i == items.length - 1,
            textColor: defaultTextColor,
            activeColor: defaultActiveColor,
            fontSize: defaultFontSize,
            disabled: disabled,
          ),
          if (i < items.length - 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: defaultSeparatorColor,
              ),
            ),
        ],
      ],
    );
  }
}

/// 面包屑单项组件
class _BreadcrumbItemWidget extends StatefulWidget {
  final BreadcrumbItem item;
  final bool isLast;
  final Color textColor;
  final Color activeColor;
  final double fontSize;
  final bool disabled;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
    required this.textColor,
    required this.activeColor,
    required this.fontSize,
    this.disabled = false,
  });

  @override
  State<_BreadcrumbItemWidget> createState() => _BreadcrumbItemWidgetState();
}

class _BreadcrumbItemWidgetState extends State<_BreadcrumbItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isClickable =
        widget.item.path != null && !widget.isLast && !widget.disabled;
    final textStyle = TextStyle(
      fontSize: widget.fontSize,
      color: widget.isLast ? widget.activeColor : widget.textColor,
      fontWeight: widget.isLast ? FontWeight.w500 : FontWeight.normal,
    );

    if (!isClickable) {
      return Text(widget.item.label, style: textStyle);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.item.path != null && !widget.disabled) {
            context.go(widget.item.path!);
          }
        },
        child: Text(
          widget.item.label,
          style: textStyle.copyWith(
            color: _isHovered ? widget.activeColor : widget.textColor,
            decoration: _isHovered ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}

/// 路由信息
class _RouteInfo {
  final String path;
  final String? name;
  final String label;

  _RouteInfo({required this.path, this.name, required this.label});
}
