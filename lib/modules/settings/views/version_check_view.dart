import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/version_check_controller.dart';

class VersionCheckView extends GetView<VersionCheckController> {
  const VersionCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '版本检测',
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40.h),
          Obx(
            () => Container(
              width: 800,
              padding: EdgeInsets.all(AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVersionItem('设备ID', controller.deviceId.value),
                  SizedBox(height: 20.h),
                  _buildVersionItem('版本信息', controller.versionInfo.value),
                  SizedBox(height: 20.h),
                  _buildVersionItem('更新时间', controller.updateTime.value),
                ],
              ),
            ),
          ),
          SizedBox(height: 40.h),
          ElevatedButton(
            onPressed: controller.checkUpdate,
            child: Text(
              '检查更新',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[900]),
          ),
        ),
      ],
    );
  }
}
