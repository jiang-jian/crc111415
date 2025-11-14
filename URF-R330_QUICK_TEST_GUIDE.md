# URF-R330 快速测试指南

## 🚀 快速开始

### 前置条件
- ✅ Android设备（Android 5.0+）
- ✅ 明华 URF-R330 读卡器
- ✅ USB OTG线（连接读卡器到Android设备）
- ✅ Mifare测试卡片（1K或4K）

---

## 📱 测试步骤

### 步骤1: 编译应用

```bash
# 进入项目根目录
cd /path/to/your/project

# 编译Android应用
flutter build apk --debug

# 或直接运行
flutter run
```

**预期**: 编译成功，无错误信息

---

### 步骤2: 连接读卡器

1. 将URF-R330通过USB OTG线连接到Android设备
2. 等待设备识别（约2-3秒）
3. 观察读卡器指示灯:
   - 🟢 绿灯常亮 = 正常工作
   - 🔴 红灯闪烁 = 等待刷卡

---

### 步骤3: 设备扫描测试

**操作**: 在应用中点击"扫描USB设备"按钮

**预期结果**:
```
找到 1 个读卡器:

设备名称: URF-R330
制造商: Shenzhen MingWah Aohan (明华澳汉)
Vendor ID: 0x1483
Product ID: 0x[具体型号]
规格: ISO 14443 Type A, Mifare 1K/4K, USB HID Keyboard Emulation
连接状态: 未授权
```

**如果失败**:
- 检查OTG线是否正常
- 尝试重新插拔设备
- 查看Logcat日志（过滤TAG=ExternalCardReader）

---

### 步骤4: 授权设备

**操作**: 点击"请求权限"按钮

**预期**:
1. 弹出系统授权对话框
2. 对话框显示:
   ```
   允许应用访问 USB 设备？
   
   Shenzhen MingWah Aohan
   URF-R330
   ```
3. 点击"允许"

**授权后状态**:
```
连接状态: 已连接 ✓
```

---

### 步骤5: 读卡测试

#### 5.1 准备测试

**操作**: 点击"开始读卡"按钮

**应用状态**:
```
========== 等待刷卡... ==========
提示：请将卡片放置在读卡器感应区
```

**读卡器状态**:
- 🔴 红灯快速闪烁（等待刷卡）

#### 5.2 刷卡操作

**操作**: 将Mifare卡片放在读卡器感应区

**距离**: 0-3厘米（卡片越近，读取速度越快）

**预期过程**:
1. 读卡器发出"滴"声（可选，取决于设备配置）
2. 红灯变为绿灯（读取成功）
3. 应用显示读取进度:
   ```
   接收字符: 8 (keyCode=0x25)
   接收字符: 3 (keyCode=0x20)
   接收字符: 1 (keyCode=0x1E)
   ...
   ✓ 检测到回车，卡号读取完成
   ```

#### 5.3 验证结果

**成功结果示例**:
```json
{
  "uid": "831194DD",
  "type": "Mifare Classic 1K (HID)",
  "capacity": "1KB",
  "protocol": "HID",
  "isValid": true,
  "timestamp": "2025-11-14T08:30:15Z"
}
```

**验证要点**:
- ✅ UID不为空
- ✅ UID长度为8位（Mifare 1K）或14位（Mifare 4K）
- ✅ UID只包含0-9和A-F（十六进制）
- ✅ isValid = true
- ✅ protocol = "HID"

---

## 🔍 常见问题排查

### 问题1: 设备未识别

**症状**: 扫描后显示"未找到读卡器"

**排查步骤**:
1. 检查USB连接
   ```bash
   adb shell ls /dev/bus/usb/*/
   ```
   应该能看到新的设备节点

2. 查看设备ID
   ```bash
   adb shell lsusb
   ```
   寻找Vendor ID = 1483的设备

3. 检查Logcat
   ```bash
   adb logcat -s ExternalCardReader:D
   ```
   查找"识别为读卡器"日志

**解决方案**:
- 确认OTG功能已启用
- 尝试不同的USB端口/OTG线
- 重启Android设备

---

### 问题2: 授权失败

**症状**: 点击授权后无反应或提示"授权被拒绝"

**排查步骤**:
1. 检查应用权限
   ```bash
   adb shell dumpsys package com.holox.ailand_pos | grep permission
   ```

2. 手动授权
   ```bash
   # 清除之前的授权记录
   adb shell pm clear com.holox.ailand_pos
   ```

**解决方案**:
- 卸载并重新安装应用
- 在系统设置中手动授予USB权限
- 检查是否有安全软件拦截

---

### 问题3: 读卡超时

**症状**: 刷卡后等待10秒仍无结果

**排查步骤**:
1. 检查卡片类型
   - 确认为Mifare 1K或4K卡片
   - 尝试不同的卡片

2. 检查读卡器配置
   - 确认URF-R330已配置为HID键盘模式
   - 检查输出格式（应为十六进制）

3. 查看原始数据
   ```bash
   adb logcat -s ExternalCardReader:D | grep "接收字符"
   ```

**解决方案**:
- 调整卡片位置（尝试不同角度）
- 清洁读卡器感应区
- 使用配置工具检查读卡器设置

---

### 问题4: UID格式错误

**症状**: 读取的UID包含非法字符或长度不正确

**可能原因**:
1. 读卡器输出格式设置错误
2. 键盘码映射不匹配
3. 数据传输中断

**解决方案**:
1. 重新配置URF-R330:
   - 下载配置工具（需要Windows PC）
   - 设置输出格式为"十六进制 - 大写"
   - 禁用前缀/后缀

2. 检查日志中的keyCode:
   ```
   接收字符: ? (keyCode=0xXX)
   ```
   对比 `hidKeyCodeToChar` 映射表

---

## 📊 性能基准

### 正常指标

| 指标 | 标准值 | 可接受范围 |
|------|--------|------------|
| 设备识别时间 | < 1秒 | 0.5-3秒 |
| 授权响应时间 | < 0.5秒 | 0.2-1秒 |
| 读卡时间 | 1-2秒 | 0.8-5秒 |
| UID长度（1K） | 8字符 | 8字符 |
| UID长度（4K） | 14字符 | 14字符 |

### 压力测试

**连续读卡测试** (建议):
```
测试卡片数: 20张
成功率要求: > 95%
平均耗时: < 3秒/张
```

**批量测试脚本**:
```bash
#!/bin/bash
for i in {1..20}; do
    echo "测试 $i/20"
    adb logcat -c
    # 刷卡操作
    sleep 3
    adb logcat -d | grep "UID:" || echo "失败"
done
```

---

## 🛠️ 调试技巧

### 实时日志监控

```bash
# 方法1: 过滤ExternalCardReader
adb logcat -s ExternalCardReader:D *:S

# 方法2: 查看完整USB通信
adb logcat | grep -E "(ExternalCardReader|USB|HID)"

# 方法3: 保存到文件
adb logcat -s ExternalCardReader:D > test.log
```

### USB数据包抓取

```bash
# 启用USB调试日志
adb shell setprop log.tag.USB DEBUG

# 查看USB事件
adb logcat -s UsbService:D UsbDeviceManager:D
```

### 关键日志位置

| 操作 | 日志标记 |
|------|----------|
| 设备连接 | `USB device attached` |
| 设备识别 | `✓ 识别为读卡器` |
| 接口声明 | `✓ HID接口声明成功` |
| 开始读卡 | `========== 等待刷卡` |
| 接收数据 | `接收字符: X (keyCode=0x..)` |
| 读卡完成 | `卡号: XXXXXXXX` |

---

## ✅ 测试检查清单

### 基础功能测试
- [ ] 设备识别成功
- [ ] 授权对话框正常弹出
- [ ] 授权后连接状态变为"已连接"
- [ ] 点击"开始读卡"后显示等待提示
- [ ] 刷卡后能读取到UID
- [ ] UID格式正确（8或14位十六进制）
- [ ] 返回数据包含正确的type和protocol字段

### 边界情况测试
- [ ] 无卡片时超时处理正常
- [ ] 重复刷同一张卡片，UID一致
- [ ] 快速连续刷卡，每次都能正确识别
- [ ] 读卡过程中拔出设备，应用不崩溃
- [ ] 设备断开后重连，仍能正常工作

### 兼容性测试
- [ ] Mifare 1K卡片读取正常
- [ ] Mifare 4K卡片读取正常（如有）
- [ ] 不同品牌的Mifare卡片都能识别

### 性能测试
- [ ] 连续读卡20次，成功率>95%
- [ ] 单次读卡时间<3秒
- [ ] 内存占用无异常增长
- [ ] 长时间运行无内存泄漏

---

## 📞 获取帮助

### 如果所有测试都失败

请提供以下信息以便排查:

1. **设备信息**
   ```bash
   adb shell getprop ro.build.version.release  # Android版本
   adb shell getprop ro.product.model          # 设备型号
   ```

2. **读卡器信息**
   ```bash
   adb shell lsusb | grep 1483
   ```

3. **完整日志**
   ```bash
   adb logcat -s ExternalCardReader:D > full_log.txt
   ```

4. **测试卡片信息**
   - 卡片类型（Mifare 1K/4K）
   - 卡片UID（如果能通过其他读卡器读取）

### 技术支持渠道

- 📧 Email: [填写支持邮箱]
- 💬 GitHub Issues: [项目仓库地址]
- 📱 社区论坛: [论坛链接]

---

**测试指南版本**: v1.0  
**最后更新**: 2025-11-14  
**适用修复版本**: v2.0.0+
