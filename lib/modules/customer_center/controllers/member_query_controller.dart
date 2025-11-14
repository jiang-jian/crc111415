/// MemberQueryController
/// 会员查询控制器
/// 作者：AI 自动生成
/// 更新时间：2025-11-11

import 'dart:math';
import 'package:get/get.dart';
import '../models/member_info_model.dart';
import '../../../core/widgets/toast.dart';
import '../../../core/widgets/loading.dart';

class MemberQueryController extends GetxController {
  final memberInfo = Rx<MemberInfoModel?>(null);
  final isLoggedIn = false.obs;
  final isLoading = false.obs;

  Future<void> simulateCardScan() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final isMainCard = random.nextBool();

    memberInfo.value = isMainCard
        ? MemberInfoModel.mockMainCard()
        : MemberInfoModel.mockSubCard();

    isLoggedIn.value = true;
    isLoading.value = false;

    Toast.success(message: '会员登录成功');
  }

  void logout() {
    memberInfo.value = null;
    isLoggedIn.value = false;
    Toast.success(message: '已退出会员登录');
  }

  Future<void> handleLossReport() async {
    if (memberInfo.value == null) return;

    Loading.show(message: '挂失中...');
    await Future.delayed(const Duration(seconds: 1));
    Loading.hide();

    final updatedInfo = MemberInfoModel.fromJson({
      ...memberInfo.value!.toJson(),
      'isLost': true,
      'lostReason': '用户申请挂失',
    });

    memberInfo.value = updatedInfo;
    Toast.success(message: '挂失成功');
  }

  Future<void> handleChangePassword(String newPassword) async {
    Loading.show(message: '修改卡密中...');
    await Future.delayed(const Duration(seconds: 1));
    Loading.hide();
    Toast.success(message: '卡密修改成功');
  }

  Future<void> handleAssetAllocation() async {
    Loading.show(message: '资产分配中...');
    await Future.delayed(const Duration(seconds: 1));
    Loading.hide();
    Toast.success(message: '资产分配成功');
  }

  Future<void> handleBindEmail(String email) async {
    if (memberInfo.value == null) return;

    Loading.show(message: '绑定中...');
    await Future.delayed(const Duration(seconds: 1));
    Loading.hide();

    final updatedInfo = MemberInfoModel.fromJson({
      ...memberInfo.value!.toJson(),
      'email': email,
    });

    memberInfo.value = updatedInfo;
    Toast.success(message: '邮箱绑定成功');
  }

  Future<void> handleBindWatch(String watchId) async {
    if (memberInfo.value == null) return;

    Loading.show(message: '绑定中...');
    await Future.delayed(const Duration(seconds: 1));
    Loading.hide();

    final updatedInfo = MemberInfoModel.fromJson({
      ...memberInfo.value!.toJson(),
      'watchId': watchId,
    });

    memberInfo.value = updatedInfo;
    Toast.success(message: '手表ID绑定成功');
  }
}
