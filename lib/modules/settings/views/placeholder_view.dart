import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '功能开发中...',
        style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
      ),
    );
  }
}
