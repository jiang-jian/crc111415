import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/notification_center_controller.dart';

class NotificationCenterPage extends GetView<NotificationCenterController> {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部操作栏
          _buildTopBar(),
          // 消息列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshMessages,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageItem(message);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建顶部操作栏
  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingDefault,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.w),
        ),
      ),
      child: Row(
        children: [
          Text('消息中心', style: AppTheme.textHeading),
          SizedBox(width: AppTheme.spacingDefault),
          Obx(() {
            final unreadCount = controller.unreadCount;
            if (unreadCount == 0) return const SizedBox.shrink();
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Text(
                '$unreadCount',
                style: AppTheme.textCaption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
          const Spacer(),
          TextButton.icon(
            onPressed: controller.markAllAsRead,
            icon: Icon(Icons.done_all, size: 18.sp),
            label: Text('全部已读', style: AppTheme.textBody),
          ),
        ],
      ),
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(message) {
    final timeFormat = DateFormat('MM-dd HH:mm');
    final isToday = DateTime.now().difference(message.time).inHours < 24;
    final timeStr = isToday
        ? DateFormat('HH:mm').format(message.time)
        : timeFormat.format(message.time);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingDefault),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图标
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: message.isRead
                      ? Colors.grey.shade200
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusDefault,
                  ),
                ),
                child: Icon(
                  message.icon,
                  size: 24.sp,
                  color: message.isRead
                      ? Colors.grey.shade600
                      : AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: AppTheme.spacingDefault),
              // 中间内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.title,
                            style: AppTheme.textSubtitle.copyWith(
                              fontWeight: message.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        // 未读标识
                        if (!message.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(left: AppTheme.spacingS),
                            decoration: const BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingS),
                    Text(
                      message.description,
                      style: AppTheme.textBody.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spacingDefault),
              // 右侧时间
              Text(
                timeStr,
                style: AppTheme.textCaption.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        // 分割线
        Divider(height: 1.h, thickness: 1.h),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无消息',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
