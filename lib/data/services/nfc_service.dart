import 'dart:io';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:get/get.dart';
import 'package:android_intent_plus/android_intent.dart';

/// NFC 读卡服务
class NfcService extends GetxService {
  // NFC 是否可用
  final isNfcAvailable = false.obs;

  // NFC 是否已启用
  final isNfcEnabled = false.obs;

  // 读卡状态
  final isReading = false.obs;

  // 卡片数据
  final cardData = Rxn<Map<String, dynamic>>();

  /// 初始化 NFC 服务
  Future<NfcService> init() async {
    await checkNfcAvailability();
    return this;
  }

  /// 检查 NFC 是否可用
  /// 返回 NFC 可用性状态
  Future<NfcAvailability> checkNfcAvailability() async {
    try {
      // 桌面平台暂不支持 NFC
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        isNfcAvailable.value = false;
        isNfcEnabled.value = false;
        return NfcAvailability.unsupported;
      }

      // 移动平台检查真实的 NFC 状态
      final availability = await NfcManager.instance.checkAvailability();
      print('[NfcService] NFC 可用性状态: $availability');

      // unsupported: 设备硬件不支持 NFC
      // disabled: 设备支持但用户未启用
      // enabled: 设备支持且已启用

      isNfcAvailable.value = (availability != NfcAvailability.unsupported);
      isNfcEnabled.value = (availability == NfcAvailability.enabled);

      return availability;
    } catch (e) {
      print('[NfcService] 检查 NFC 可用性失败: $e');
      isNfcAvailable.value = false;
      isNfcEnabled.value = false;
      return NfcAvailability.unsupported;
    }
  }

  /// 打开系统 NFC 设置页面
  Future<bool> openNfcSettings() async {
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        print('[NfcService] 桌面平台不支持打开 NFC 设置');
        return false;
      }

      if (Platform.isAndroid) {
        print('[NfcService] 尝试打开 Android NFC 设置页面');
        try {
          // 创建 Intent 打开 NFC 设置
          final intent = AndroidIntent(action: 'android.settings.NFC_SETTINGS');
          await intent.launch();
          print('[NfcService] 成功打开 NFC 设置页面');
          return true;
        } catch (e) {
          print('[NfcService] 无法打开 NFC 设置: $e，尝试打开无线设置');
          // 如果无法打开 NFC 设置，尝试打开无线和网络设置
          try {
            final intent = AndroidIntent(
              action: 'android.settings.WIRELESS_SETTINGS',
            );
            await intent.launch();
            return true;
          } catch (e2) {
            print('[NfcService] 打开无线设置也失败: $e2');
            return false;
          }
        }
      }

      if (Platform.isIOS) {
        print('[NfcService] iOS 不支持直接打开 NFC 设置');
        // iOS 不允许直接打开 NFC 设置
        return false;
      }

      return false;
    } catch (e) {
      print('[NfcService] 打开 NFC 设置失败: $e');
      return false;
    }
  }

  /// 读取 M1 卡片
  Future<Map<String, dynamic>?> readM1Card() async {
    print('[NfcService] readM1Card 被调用');

    if (!isNfcAvailable.value) {
      print('[NfcService] NFC 不可用');
      throw Exception('NFC 不可用');
    }

    if (!isNfcEnabled.value) {
      print('[NfcService] NFC 未启用');
      throw Exception('NFC 未启用');
    }

    try {
      print('[NfcService] 开始读卡，设置 isReading = true');
      isReading.value = true;

      // 桌面平台模拟读卡
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        print('[NfcService] 桌面平台，模拟读卡');
        // 模拟读卡延迟
        await Future.delayed(const Duration(seconds: 2));

        // 模拟读取的 M1 卡数据
        final mockCardData = {
          'uid': '04:A1:B2:C3:D4:E5:F6',
          'type': 'Mifare Classic 1K',
          'capacity': '1024 bytes',
          'timestamp': DateTime.now().toIso8601String(),
          'isValid': true,
        };

        print('[NfcService] 模拟读卡成功: $mockCardData');
        cardData.value = mockCardData;
        isReading.value = false;
        return mockCardData;
      }

      // 移动平台真实读卡
      print('[NfcService] 移动平台，开始 NFC 会话');
      Map<String, dynamic>? result;

      // nfc_manager 4.1 版本新增 pollingOptions 参数
      // 使用 iso14443 选项来读取 Mifare Classic (M1) 卡片
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443, // 用于读取 Mifare Classic/Ultralight 等卡片
        },
        onDiscovered: (NfcTag tag) async {
          print('[NfcService] 检测到 NFC 标签');
          try {
            // 尝试读取 Mifare Classic 卡片
            String? uid;

            // 在 Android 上尝试使用 NfcA
            if (Platform.isAndroid) {
              print('[NfcService] Android 平台，尝试读取 NfcA');
              try {
                // 尝试从 NfcA 获取 UID
                final nfcA = NfcAAndroid.from(tag);
                if (nfcA != null) {
                  final identifier = nfcA.tag.id;
                  uid = identifier
                      .map((e) => e.toRadixString(16).padLeft(2, '0'))
                      .join(':')
                      .toUpperCase();
                  print('[NfcService] 成功读取 UID: $uid');
                } else {
                  print('[NfcService] NfcA 为 null');
                }
              } catch (e) {
                print('[NfcService] 读取 NfcA 失败: $e');
              }
            }

            // 在 iOS 上尝试使用 MiFare
            if (Platform.isIOS && uid == null) {
              print('[NfcService] iOS 平台，尝试读取 MiFare');
              try {
                final miFare = MiFareIos.from(tag);
                if (miFare != null) {
                  final identifier = miFare.identifier;
                  uid = identifier
                      .map((e) => e.toRadixString(16).padLeft(2, '0'))
                      .join(':')
                      .toUpperCase();
                  print('[NfcService] 成功读取 UID: $uid');
                } else {
                  print('[NfcService] MiFare 为 null');
                }
              } catch (e) {
                print('[NfcService] 读取 MiFare 失败: $e');
              }
            }

            if (uid != null) {
              // 读取 M1 卡片信息
              result = {
                'uid': uid,
                'type': 'Mifare Classic',
                'timestamp': DateTime.now().toIso8601String(),
                'isValid': true,
              };

              print('[NfcService] 卡片数据组装完成: $result');
              cardData.value = result;
              print('[NfcService] 读卡成功，保持会话不关闭，避免触发系统返回');
              // 关键修复：不要立即停止会话，这会在Android上触发返回行为
              // 会话将在用户离开页面时由 stopReading() 方法统一清理
            } else {
              print('[NfcService] UID 为空，无法读取卡片信息');
              await NfcManager.instance.stopSession(errorMessageIos: '读取失败');
              throw Exception('无法读取卡片信息');
            }
          } catch (e) {
            print('[NfcService] 读取卡片数据异常: $e');
            try {
              await NfcManager.instance.stopSession(errorMessageIos: '读取失败');
            } catch (stopError) {
              print('[NfcService] 停止会话异常: $stopError');
            }
            rethrow;
          }
        },
      );

      print('[NfcService] NFC 会话结束，结果: $result');
      // 如果读取成功，保持 isReading 为 true，表示会话仍在进行
      // 这样可以避免在Android上触发返回
      final isValid = result?['isValid'] == true;
      if (isValid) {
        print('[NfcService] 读取成功，保持会话状态');
        // 不设置 isReading 为 false，保持会话
      } else {
        isReading.value = false;
      }
      return result;
    } catch (e) {
      print('[NfcService] 读取 M1 卡片异常: $e');
      isReading.value = false;
      rethrow;
    }
  }

  /// 停止读卡
  Future<void> stopReading() async {
    try {
      print('[NfcService] 停止读卡会话');
      if (Platform.isAndroid || Platform.isIOS) {
        await NfcManager.instance.stopSession();
      }
      isReading.value = false;
      print('[NfcService] 读卡会话已停止');
    } catch (e) {
      print('[NfcService] 停止读卡失败: $e');
      isReading.value = false;
    }
  }

  @override
  void onClose() {
    stopReading();
    super.onClose();
  }
}
