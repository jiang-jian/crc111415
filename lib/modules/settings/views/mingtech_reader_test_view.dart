import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/mingtech_reader_service.dart';
import '../../../data/models/mingtech_card_model.dart';

/// 明泰读卡器测试界面
class MingtechReaderTestView extends StatefulWidget {
  const MingtechReaderTestView({super.key});

  @override
  State<MingtechReaderTestView> createState() => _MingtechReaderTestViewState();
}

class _MingtechReaderTestViewState extends State<MingtechReaderTestView> {
  final MingtechReaderService _readerService = Get.find<MingtechReaderService>();
  
  // 默认密钥（全F）
  final List<int> _defaultKey = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF];
  
  int _selectedSector = 0;
  int _selectedBlock = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('明泰MT3读卡器测试'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 设备状态卡片
            _buildDeviceStatusCard(),
            const SizedBox(height: 16),
            
            // 当前卡片信息
            _buildCurrentCardCard(),
            const SizedBox(height: 16),
            
            // 操作按钮
            _buildActionButtons(),
            const SizedBox(height: 16),
            
            // M1卡操作
            _buildM1Operations(),
            const SizedBox(height: 16),
            
            // 事件日志
            Expanded(child: _buildEventLog()),
          ],
        ),
      ),
    );
  }

  /// 设备状态卡片
  Widget _buildDeviceStatusCard() {
    return Obx(() {
      final deviceInfo = _readerService.deviceInfo.value;
      final isInitialized = _readerService.isInitialized.value;
      final isPolling = _readerService.isAutoPolling.value;

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isInitialized ? Icons.check_circle : Icons.cancel,
                    color: isInitialized ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '设备状态: ${isInitialized ? "已连接" : "未连接"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (deviceInfo != null) ..[
                const SizedBox(height: 8),
                Text('设备名称: ${deviceInfo.deviceName}'),
                Text('制造商: ${deviceInfo.manufacturer}'),
                Text('产品: ${deviceInfo.product}'),
                Text('USB ID: ${deviceInfo.usbId}'),
                Text('序列号: ${deviceInfo.serialNumber}'),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPolling ? Icons.autorenew : Icons.pause_circle_outline,
                    color: isPolling ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '自动寻卡: ${isPolling ? "运行中" : "已停止"}',
                    style: TextStyle(
                      color: isPolling ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 当前卡片信息卡片
  Widget _buildCurrentCardCard() {
    return Obx(() {
      final card = _readerService.currentCard.value;

      return Card(
        elevation: 2,
        color: card != null ? Colors.green.shade50 : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    card != null ? Icons.credit_card : Icons.credit_card_off,
                    color: card != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    card != null ? '当前卡片' : '无卡片',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (card != null) ..[
                const SizedBox(height: 8),
                Text(
                  'UID: ${card.uid}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text('类型: ${card.cardType}'),
                Text('检测时间: ${card.timestamp.toString().split('.').first}'),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// 操作按钮
  Widget _buildActionButtons() {
    return Obx(() {
      final isInitialized = _readerService.isInitialized.value;
      final isPolling = _readerService.isAutoPolling.value;

      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isInitialized ? null : _initializeDevice,
              icon: const Icon(Icons.power_settings_new),
              label: const Text('初始化设备'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: !isInitialized
                  ? null
                  : (isPolling ? _stopAutoPolling : _startAutoPolling),
              icon: Icon(isPolling ? Icons.stop : Icons.play_arrow),
              label: Text(isPolling ? '停止寻卡' : '启动寻卡'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPolling ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// M1卡操作
  Widget _buildM1Operations() {
    return Obx(() {
      final isInitialized = _readerService.isInitialized.value;
      final hasCard = _readerService.currentCard.value != null;

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'M1卡操作',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedSector,
                      decoration: const InputDecoration(
                        labelText: '扇区',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: List.generate(16, (index) => index)
                          .map((sector) => DropdownMenuItem(
                                value: sector,
                                child: Text('扇区 $sector'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSector = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedBlock,
                      decoration: const InputDecoration(
                        labelText: '块',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: List.generate(64, (index) => index)
                          .map((block) => DropdownMenuItem(
                                value: block,
                                child: Text('块 $block'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedBlock = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (!isInitialized || !hasCard)
                          ? null
                          : _authenticateSector,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('认证扇区'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (!isInitialized || !hasCard)
                          ? null
                          : _readBlock,
                      icon: const Icon(Icons.file_download),
                      label: const Text('读取块'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 事件日志
  Widget _buildEventLog() {
    return Obx(() {
      final events = _readerService.recentEvents;

      return Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '事件日志',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _readerService.recentEvents.clear();
                    },
                    child: const Text('清空'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: events.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无事件',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return ListTile(
                          dense: true,
                          leading: _getEventIcon(event.type),
                          title: Text(_getEventTitle(event)),
                          subtitle: Text(_getEventSubtitle(event)),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Icon _getEventIcon(MingtechEventType type) {
    switch (type) {
      case MingtechEventType.cardDetected:
        return const Icon(Icons.credit_card, color: Colors.green);
      case MingtechEventType.authResult:
        return const Icon(Icons.lock, color: Colors.orange);
      case MingtechEventType.blockRead:
        return const Icon(Icons.file_download, color: Colors.purple);
      case MingtechEventType.deviceReady:
        return const Icon(Icons.check_circle, color: Colors.blue);
      case MingtechEventType.error:
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  String _getEventTitle(MingtechEvent event) {
    switch (event.type) {
      case MingtechEventType.cardDetected:
        return '检测到卡片';
      case MingtechEventType.authResult:
        return event.authSuccess == true ? '认证成功' : '认证失败';
      case MingtechEventType.blockRead:
        return '块读取完成';
      case MingtechEventType.deviceReady:
        return '设备就绪';
      case MingtechEventType.deviceAttached:
        return '设备插入';
      case MingtechEventType.deviceDetached:
        return '设备拔出';
      case MingtechEventType.error:
        return '错误: ${event.errorCode ?? "UNKNOWN"}';
      default:
        return '未知事件';
    }
  }

  String _getEventSubtitle(MingtechEvent event) {
    switch (event.type) {
      case MingtechEventType.cardDetected:
        final card = event.cardData;
        return 'UID: ${card?.uid ?? "Unknown"}';
      case MingtechEventType.authResult:
        return event.data['message'] as String? ?? '';
      case MingtechEventType.blockRead:
        final data = event.blockData;
        if (data != null && data.length == 16) {
          return data
              .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(' ');
        }
        return '数据不完整';
      case MingtechEventType.error:
        return event.errorMessage ?? '未知错误';
      default:
        return event.data['message'] as String? ?? '';
    }
  }

  // 操作方法

  Future<void> _initializeDevice() async {
    final success = await _readerService.initializeDevice();
    if (success) {
      Get.snackbar('成功', '设备初始化成功');
    } else {
      Get.snackbar('失败', '设备初始化失败: ${_readerService.lastError.value}');
    }
  }

  Future<void> _startAutoPolling() async {
    final success = await _readerService.startAutoPolling();
    if (success) {
      Get.snackbar('成功', '自动寻卡已启动');
    } else {
      Get.snackbar('失败', '启动自动寻卡失败');
    }
  }

  Future<void> _stopAutoPolling() async {
    final success = await _readerService.stopAutoPolling();
    if (success) {
      Get.snackbar('成功', '自动寻卡已停止');
    } else {
      Get.snackbar('失败', '停止自动寻卡失败');
    }
  }

  Future<void> _authenticateSector() async {
    Get.snackbar('认证', '正在认证扇区 $_selectedSector...');
    
    final success = await _readerService.authSector(
      _selectedSector,
      _defaultKey,
      useKeyA: true,
    );

    if (success) {
      Get.snackbar('成功', '扇区 $_selectedSector 认证成功');
    } else {
      Get.snackbar('失败', '扇区 $_selectedSector 认证失败');
    }
  }

  Future<void> _readBlock() async {
    Get.snackbar('读取', '正在读取块 $_selectedBlock...');
    
    final data = await _readerService.readBlock(_selectedBlock);

    if (data != null) {
      final hexData = data
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(' ');
      Get.snackbar(
        '成功',
        '块 $_selectedBlock 数据:\n$hexData',
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar('失败', '读取块 $_selectedBlock 失败');
    }
  }
}
