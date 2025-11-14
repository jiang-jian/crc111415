/// RetailGridView
/// 零售商品网格视图

import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/cashier_controller.dart';
import 'retail_card.dart';

class RetailGridView extends StatelessWidget {
  const RetailGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CashierController>();

    return Obx(() {
      final packages = controller.filteredPackages;

      if (packages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64.w,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16.h),
              Text(
                '暂无商品',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: 110.h,
        ),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return RetailCard(
            package: package,
            onTap: () => controller.cartController.addToCart(package),
          );
        },
      );
    });
  }
}
