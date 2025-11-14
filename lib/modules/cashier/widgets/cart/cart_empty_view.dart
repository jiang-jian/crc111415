/// CartEmptyView
/// 购物车空态视图

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80.w,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂未加购商品',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
