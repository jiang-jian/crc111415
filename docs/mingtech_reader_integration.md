# 明泰MT3-URF1-R333读卡器集成文档

## 📋 目录

1. [概述](#概述)
2. [硬件规格](#硬件规格)
3. [架构设计](#架构设计)
4. [快速开始](#快速开始)
5. [API参考](#api参考)
6. [协议说明](#协议说明)
7. [故障排查](#故障排查)
8. [测试清单](#测试清单)

---

## 概述

### 功能特性

✅ **设备管理**
- 自动识别明泰MT3读卡器（VID: 0x23A4, PID: 0x020C）
- USB权限请求与管理
- 设备插拔事件监听
- 连接状态实时监控

✅ **卡片操作**
- 自动寻卡（轮询模式）
- M1卡UID读取（4字节/7字节）
- 扇区认证（KeyA/KeyB）
- 块数据读取（16字节）

✅ **事件系统**
- 实时事件推送（EventChannel）
- 卡片检测通知
- 认证结果回调
- 错误信息上报

---

## 硬件规格

### 设备信息

| 参数 | 值 |
|------|----|
| 厂商名称 | MingTech (明泰) |
| 产品型号 | MT3-URF1-R333 |
| USB VID | 0x23A4 (9124) |
| USB PID | 0x020C (524) |
| 设备类型 | HID (Human Interface Device) |
| UsagePage | 0xFF00 (Vendor Defined) |
| 通信速度 | USB Full-Speed (12 Mbps) |

### 端点配置

| 端点 | 方向 | 类型 | 包大小 | 轮询间隔 |
|------|------|------|--------|----------|
| 0x81 | IN | Interrupt | 64 bytes | 64 ms |
| 0x01 | OUT | Interrupt | 64 bytes | 10 ms |

### 支持卡片

- **Mifare Classic 1K** (4字节UID)
- **Mifare Classic 4K** (7字节UID)
- 其他兼容M1芯片的卡片

---

## 架构设计

### 系统架构

```
┌─────────────────────────────────────────────────────────┐
│  Flutter层 (Dart)                                       │
│  ├─ MingtechReaderService (服务层)                      │
│  │   ├─ 设备管理                                         │
│  │   ├─ 事件监听                                         │
│  │   └─ 状态管理 (GetX)                                 │
│  └─ MingtechCardModel (数据模型)                        │
└───────────────────┬─────────────────────────────────────┘
                    │ MethodChannel + EventChannel
┌───────────────────▼─────────────────────────────────────┐
│  Kotlin层 (Android)                                     │
│  ├─ MingtechReaderPlugin (插件主类)                     │
│  │   ├─ 方法处理 (init, auth, read)                     │
│  │   └─ 事件发送 (card_detected, error)                │
│  ├─ UsbHidManager (USB通信)                             │
│  │   ├─ 设备枚举与打开                                   │
│  │   ├─ 端点管理                                         │
│  │   └─ 数据收发                                         │
│  ├─ M1CardService (M1卡操作)                            │
│  │   ├─ 寻卡 (pollCard)                                 │
│  │   ├─ 认证 (authSector)                               │
│  │   └─ 读取 (readBlock)                                │
│  ├─ UsbReceiver (设备监听)                              │
│  │   ├─ 插拔事件                                         │
│  │   └─ 权限回调                                         │
│  └─ Protocol (协议定义)                                 │
│      ├─ 命令构建                                         │
│      └─ 响应解析                                         │
└─────────────────────────────────────────────────────────┘
```

### 文件结构

```
android/app/src/main/kotlin/com/holox/ailand_pos/
├── mingtech/
│   ├── MingtechReaderPlugin.kt       # 主插件类
│   ├── UsbHidManager.kt              # USB HID通信
│   ├── M1CardService.kt              # M1卡操作
│   ├── UsbReceiver.kt                # 设备监听
│   └── Protocol.kt                   # 协议定义
└── MainActivity.kt                   # 插件注册

lib/
├── data/
│   ├── services/
│   │   └── mingtech_reader_service.dart  # Dart服务层
│   └── models/
│       └── mingtech_card_model.dart      # 数据模型
└── modules/settings/views/
    └── mingtech_reader_test_view.dart    # 测试界面
```

---

## 快速开始

### 1. 初始化服务

```dart
import 'package:get/get.dart';
import 'package:ailand_pos/data/services/mingtech_reader_service.dart';

// 在应用启动时注册服务
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 注册读卡器服务
  await Get.putAsync(() => MingtechReaderService().init());
  
  runApp(MyApp());
}
```

### 2. 初始化设备

```dart
final MingtechReaderService readerService = Get.find();

// 初始化读卡器（会自动请求USB权限）
final success = await readerService.initializeDevice();

if (success) {
  print('设备初始化成功');
  
  // 启动自动寻卡
  await readerService.startAutoPolling();
} else {
  print('设备初始化失败: ${readerService.lastError.value}');
}
```

### 3. 监听卡片事件

```dart
// 使用Obx监听当前卡片
Obx(() {
  final card = readerService.currentCard.value;
  
  if (card != null) {
    return Text('UID: ${card.uid}');
  } else {
    return Text('请刷卡');
  }
})
```

### 4. 读取M1卡数据

```dart
// 认证扇区1（使用默认密钥FFFFFFFFFFFF）
final keyA = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];
final authSuccess = await readerService.authSector(1, keyA, useKeyA: true);

if (authSuccess) {
  // 读取块4（扇区1的第一个块）
  final blockData = await readerService.readBlock(4);
  
  if (blockData != null) {
    // 数据为16字节的List<int>
    final hexData = blockData
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
    print('块数据: $hexData');
  }
}
```

---

## API参考

### MingtechReaderService (Dart)

#### 方法

##### `initializeDevice()`
初始化读卡器设备

- **返回**: `Future<bool>`
- **说明**: 查找设备、请求权限、打开连接

##### `startAutoPolling()`
启动自动寻卡

- **返回**: `Future<bool>`
- **说明**: 每500ms轮询一次，检测卡片

##### `stopAutoPolling()`
停止自动寻卡

- **返回**: `Future<bool>`

##### `authSector(int sector, List<int> key, {bool useKeyA = true})`
认证M1卡扇区

- **参数**:
  - `sector`: 扇区号（0-15）
  - `key`: 密钥（6字节）
  - `useKeyA`: true=KeyA, false=KeyB
- **返回**: `Future<bool>`

##### `readBlock(int block)`
读取M1卡块数据

- **参数**: `block`: 块号（0-63 for 1K, 0-255 for 4K）
- **返回**: `Future<List<int>?>` - 16字节数据或null

#### 响应式属性

```dart
final deviceInfo = Rx<MingtechDeviceInfo?>(null);  // 设备信息
final isInitialized = false.obs;                   // 初始化状态
final isAutoPolling = false.obs;                   // 自动寻卡状态
final currentCard = Rx<MingtechCardData?>(null);   // 当前卡片
final recentEvents = <MingtechEvent>[].obs;        // 最近事件
final lastError = Rx<String?>(null);               // 最后错误
```

---

## 协议说明

### 报文格式

#### 命令帧

```
[0xAA][CMD][LEN][PAYLOAD...][CS][PADDING...]
│     │    │    │            │   └─ 填充到64字节
│     │    │    │            └─ 校验和（XOR）
│     │    │    └─ 载荷数据（可变长度）
│     │    └─ 载荷长度
│     └─ 命令码
└─ 帧头
```

#### 响应帧

```
[0xAA][STATUS][LEN][DATA...][CS][PADDING...]
│     │        │    │        │   └─ 填充到64字节
│     │        │    │        └─ 校验和（XOR）
│     │        │    └─ 响应数据（可变长度）
│     │        └─ 数据长度
│     └─ 状态码（0x00=成功）
└─ 帧头
```

### 命令码

| 命令码 | 名称 | 说明 |
|--------|------|------|
| 0x20 | GET_STATUS | 获取读卡器状态 |
| 0x30 | POLL_CARD | 寻卡（返回UID） |
| 0x40 | AUTH_SECTOR | 认证扇区 |
| 0x50 | READ_BLOCK | 读取块数据 |
| 0x60 | HALT_CARD | 停止操作卡片 |

### 状态码

| 状态码 | 含义 |
|--------|------|
| 0x00 | 成功 |
| 0x01 | 无卡片 |
| 0x02 | 认证失败 |
| 0x03 | 读取失败 |
| 0x04 | 超时 |
| 0xFF | 设备错误 |

### 示例命令

#### 寻卡命令

```
发送: AA 30 00 9A 00 00 00 ... (64字节)
响应: AA 00 04 A1 B2 C3 D4 XX 00 ... (UID=A1:B2:C3:D4)
```

#### 认证扇区1（KeyA）

```
发送: AA 40 08 01 60 FF FF FF FF FF FF XX 00 ...
      │  │  │  │  │  └────────────┘ │
      │  │  │  │  │       KeyA      校验和
      │  │  │  │  └─ 0x60=KeyA认证
      │  │  │  └─ 扇区号=1
      │  │  └─ 载荷长度=8
      │  └─ 命令=认证
      └─ 帧头

响应: AA 00 00 AA 00 ... (认证成功)
```

#### 读取块4

```
发送: AA 50 01 04 F5 00 00 ...
      │  │  │  │  │
      │  │  │  │  └─ 校验和
      │  │  │  └─ 块号=4
      │  │  └─ 载荷长度=1
      │  └─ 命令=读取块
      └─ 帧头

响应: AA 00 10 [16字节数据] XX 00 ...
      │  │  │   └──────┘     │
      │  │  │     块数据      校验和
      │  │  └─ 数据长度=16
      │  └─ 状态=成功
      └─ 帧头
```

**⚠️ 注意**: 以上协议为推测格式，实际协议需要根据设备测试结果调整。

---

## 故障排查

### 常见问题

#### 1. 设备未识别

**症状**: `initializeDevice()` 返回false，提示"未找到明泰读卡器"

**排查步骤**:
1. 检查USB连接是否牢固
2. 在终端执行 `adb shell lsusb` 查看设备列表
3. 确认设备VID/PID为 `23A4:020C`
4. 检查 `usb_device_filter.xml` 是否正确配置

**解决方案**:
```bash
# 查看USB设备
adb shell lsusb

# 应该看到类似输出：
# Bus 001 Device 003: ID 23a4:020c MingTech MT3-URF1-R333
```

#### 2. USB权限被拒绝

**症状**: 弹窗显示权限请求，但点击"允许"后仍然失败

**排查步骤**:
1. 检查 `AndroidManifest.xml` 是否包含 USB 权限声明
2. 确认 `UsbReceiver` 正确注册
3. 查看 logcat 日志中的权限回调

**解决方案**:
```bash
# 查看权限相关日志
adb logcat | grep -i "usb.*permission"
```

#### 3. 寻卡无响应

**症状**: 启动自动寻卡后，刷卡无任何反应

**排查步骤**:
1. 确认设备已初始化（`isInitialized.value == true`）
2. 检查自动寻卡是否启动（`isAutoPolling.value == true`）
3. 查看 logcat 中的通信日志
4. 尝试手动发送测试命令

**调试命令**:
```bash
# 查看读卡器通信日志
adb logcat | grep -E "UsbHidManager|M1CardService"

# 查看原始HID数据
adb logcat | grep -i "接收数据\|发送数据"
```

#### 4. 认证失败

**症状**: `authSector()` 返回false

**可能原因**:
- 密钥错误（默认密钥为 `FFFFFFFFFFFF`）
- 扇区号超出范围（1K卡为0-15）
- 卡片不支持M1协议
- 卡片已被移除

**解决方案**:
```dart
// 尝试使用默认密钥
final keyA = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];
final success = await readerService.authSector(sector, keyA);

// 如果失败，尝试KeyB
if (!success) {
  final keyB = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];
  await readerService.authSector(sector, keyB, useKeyA: false);
}
```

#### 5. 协议不匹配

**症状**: 所有命令都无响应或返回错误

**说明**: 实际协议格式与推测不一致

**解决方案**:
1. 使用 USBlyzer (Windows) 或 Wireshark + libusb (Linux) 抓包
2. 在官方软件中操作读卡器，记录实际报文
3. 修改 `Protocol.kt` 中的命令构建逻辑
4. 联系厂商获取协议文档

---

## 测试清单

### 功能测试

- [ ] **设备识别**
  - [ ] 插入设备后能在日志中看到检测信息
  - [ ] `initializeDevice()` 返回true
  - [ ] `deviceInfo.value` 不为null

- [ ] **权限管理**
  - [ ] 首次连接弹出权限请求
  - [ ] 允许权限后设备正常打开
  - [ ] 拒绝权限后显示错误信息
  - [ ] 断开重连后无需再次请求权限

- [ ] **寻卡功能**
  - [ ] 启动自动寻卡后状态正确
  - [ ] 刷卡后1秒内检测到卡片
  - [ ] `currentCard.value` 显示正确的UID
  - [ ] 移开卡片后状态清除
  - [ ] 连续刷多张卡，每张都能识别

- [ ] **认证功能**
  - [ ] 使用正确密钥认证成功
  - [ ] 使用错误密钥认证失败
  - [ ] 认证后读取数据成功
  - [ ] 未认证时读取数据失败

- [ ] **读取功能**
  - [ ] 读取块数据返回16字节
  - [ ] 数据内容符合预期
  - [ ] 读取控制块（扇区尾）正常
  - [ ] 读取超出范围的块返回错误

- [ ] **错误处理**
  - [ ] 无卡片时寻卡返回null
  - [ ] 通信超时有明确提示
  - [ ] 设备断开后状态正确
  - [ ] 所有错误都通过 `lastError` 上报

### 稳定性测试

- [ ] **长时间运行**
  - [ ] 自动寻卡运行30分钟无崩溃
  - [ ] 连续刷卡100次无遗漏
  - [ ] 内存占用无异常增长

- [ ] **插拔测试**
  - [ ] 拔出设备后应用不崩溃
  - [ ] 重新插入设备能自动恢复
  - [ ] 插拔10次后功能正常

- [ ] **并发测试**
  - [ ] 同时进行寻卡和读取操作
  - [ ] 快速连续调用API不死锁
  - [ ] 多个界面同时监听事件

### 兼容性测试

- [ ] **Android版本**
  - [ ] Android 9 (API 28)
  - [ ] Android 10 (API 29)
  - [ ] Android 11 (API 30)
  - [ ] Android 12+ (API 31+)

- [ ] **设备型号**
  - [ ] 商米T2
  - [ ] 其他Android收银台设备

- [ ] **卡片类型**
  - [ ] Mifare Classic 1K (4字节UID)
  - [ ] Mifare Classic 4K (7字节UID)
  - [ ] 其他M1兼容卡

---

## 附录

### M1卡扇区结构

**Mifare Classic 1K** (16扇区 × 4块 = 64块)

```
扇区0:  块0  块1  块2  块3(控制块)
扇区1:  块4  块5  块6  块7(控制块)
...     ...  ...  ...  ...
扇区15: 块60 块61 块62 块63(控制块)
```

**控制块结构** (块3, 7, 11, ..., 63):

```
[KeyA(6)] [Access Bits(4)] [KeyB(6)]
```

### 默认密钥

大多数M1卡出厂默认密钥为：
```
KeyA: FF FF FF FF FF FF
KeyB: FF FF FF FF FF FF
```

### 常用工具

- **USBlyzer** (Windows): USB协议分析工具
- **Wireshark + usbmon** (Linux): 开源抓包工具
- **NFC Tools** (Android): 测试M1卡读写
- **adb logcat**: Android日志查看

---

## 联系支持

如遇到问题无法解决，请提供以下信息：

1. Android设备型号和系统版本
2. 完整的 logcat 日志（过滤 `MingtechReader`）
3. 复现步骤
4. 使用的卡片类型
5. 截图或视频（如有）

---

**文档版本**: v1.0  
**最后更新**: 2025-11-20  
**维护者**: Agent AI
