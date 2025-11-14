/// GiftGridView
/// 礼品网格展示

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/gift_exchange_controller.dart';
import '../models/gift_item.dart';
import 'gift_card.dart';
import '../../../app/theme/app_theme.dart';

class GiftGridView extends GetView<GiftExchangeController> {
  const GiftGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gifts = controller.filteredGifts;

      if (gifts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 64.w,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16.h),
              Text(
                '暂无礼品',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return _buildGiftGrid(gifts);
    });
  }

  Widget _buildGiftGrid(List<GiftItem> gifts) {
    return GridView.builder(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        mainAxisExtent: 110.h,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return GiftCard(
          gift: gift,
          onTap: () => controller.cartController.addToCart(gift),
        );
      },
    );
  }
}
