/// PackageListView
/// 套餐列表视图

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/cashier_controller.dart';
import 'package_card.dart';

class PackageListView extends GetView<CashierController> {
  const PackageListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final packages = controller.filteredPackages;

      if (packages.isEmpty) {
        return Center(
          child: Text(
            '暂无套餐',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return PackageCard(
            package: package,
            onTap: () => controller.cartController.addToCart(package),
          );
        },
      );
    });
  }
}
