import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 首页菜单卡片
class MenuCard extends StatefulWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isEnabled;

  const MenuCard({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
    this.icon,
    this.isEnabled = true,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.isEnabled;
    final displayColor = isDisabled 
        ? const Color(0xFFE8E8E8) 
        : widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: displayColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: displayColor.withValues(alpha: _isHovered ? 0.4 : 0.3),
                    blurRadius: _isHovered ? 12.r : 8.r,
                    offset: Offset(0, _isHovered ? 4.h : 2.h),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : widget.onTap,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            splashColor: Colors.white.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 32.sp,
                      color: isDisabled
                          ? AppTheme.textDisabled
                          : Colors.white,
                    ),
                    SizedBox(height: AppTheme.spacingS),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.textSubtitle.copyWith(
                        color: isDisabled
                            ? AppTheme.textDisabled
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
