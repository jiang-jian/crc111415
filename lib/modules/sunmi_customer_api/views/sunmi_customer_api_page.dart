/// Sunmi Customer API 页面
/// 展示如何使用商米设备系统能力接口

import 'package:ailand_pos/core/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ailand_pos/data/services/sunmi_customer_api_service.dart';
import '../../../app/theme/app_theme.dart';

class SunmiCustomerApiPage extends StatefulWidget {
  const SunmiCustomerApiPage({super.key});

  @override
  State<SunmiCustomerApiPage> createState() => _SunmiCustomerApiPageState();
}

class _SunmiCustomerApiPageState extends State<SunmiCustomerApiPage> {
  final SunmiCustomerApiService _apiService = SunmiCustomerApiService();

  bool _isConnected = false;
  String _statusMessage = '未初始化';
  Map<String, dynamic>? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    setState(() {
      _statusMessage = '检查服务安装状态...';
    });

    // 先检查 SunmiCustomerService 是否已安装
    final isInstalled = await _apiService.checkServiceInstalled();
    print('Service installed: $isInstalled');

    if (!isInstalled) {
      setState(() {
        _isConnected = false;
        _statusMessage = '失败: SunmiCustomerService 未安装';
      });
      _showMessage('设备上未安装 SunmiCustomerService，请在商米设备上运行');
      return;
    }

    setState(() {
      _statusMessage = '服务已安装，正在连接...';
    });

    final success = await _apiService.initialize();
    print('Initialize success: $success');
    final connected = await _apiService.isConnected();
    print('Connected: $connected');

    setState(() {
      _isConnected = connected;
      _statusMessage = success ? '初始化成功' : '初始化失败（连接超时）';
    });

    if (success) {
      _loadDeviceInfo();
    } else {
      _showMessage('连接超时，请确保运行在商米设备上');
    }
  }

  /// 加载设备信息
  Future<void> _loadDeviceInfo() async {
    final info = await _apiService.getDeviceInfo();
    setState(() {
      _deviceInfo = info;
    });
  }

  /// 启用移动网络
  Future<void> _enableMobileNetwork() async {
    final success = await _apiService.enableMobileNetwork(slotIndex: 0);
    _showMessage(success ? '移动网络已启用' : '启用移动网络失败');
  }

  /// 禁用移动网络
  Future<void> _disableMobileNetwork() async {
    final success = await _apiService.disableMobileNetwork(slotIndex: 0);
    _showMessage(success ? '移动网络已禁用' : '禁用移动网络失败');
  }

  /// 显示消息
  void _showMessage(String message) {
    Toast.show(message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 连接状态卡片
            _buildStatusCard(),
            SizedBox(height: 16.h),

            // 设备信息卡片
            _buildDeviceInfoCard(),
            SizedBox(height: 16.h),

            // 网络管理功能
            _buildNetworkManagementCard(),
            SizedBox(height: 16.h),

            // 操作按钮
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务状态',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                SizedBox(width: AppTheme.spacingS),
                Text(
                  _isConnected ? '已连接' : '未连接',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text('状态: $_statusMessage'),
          ],
        ),
      ),
    );
  }

  /// 构建设备信息卡片
  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '设备信息',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadDeviceInfo,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (_deviceInfo != null) ...[
              _buildInfoRow('设备型号', _deviceInfo!['model']),
              _buildInfoRow('序列号', _deviceInfo!['serialNumber']),
              _buildInfoRow('制造商', _deviceInfo!['manufacturer']),
              _buildInfoRow('品牌', _deviceInfo!['brand']),
              _buildInfoRow('Android 版本', _deviceInfo!['androidVersion']),
              _buildInfoRow('SDK 版本', _deviceInfo!['sdkVersion']),
            ] else
              const Text('暂无设备信息'),
          ],
        ),
      ),
    );
  }

  /// 构建网络管理卡片
  Widget _buildNetworkManagementCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '网络管理',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnected ? _enableMobileNetwork : null,
                    icon: const Icon(Icons.signal_cellular_alt),
                    label: const Text('启用移动网络'),
                  ),
                ),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnected ? _disableMobileNetwork : null,
                    icon: const Icon(Icons.signal_cellular_off),
                    label: const Text('禁用移动网络'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '操作',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _initializeService,
                icon: const Icon(Icons.refresh),
                label: const Text('重新初始化'),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConnected ? _printDeviceInfoToConsole : null,
                icon: const Icon(Icons.print),
                label: const Text('打印设备信息到控制台'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '未知')),
        ],
      ),
    );
  }

  /// 打印设备信息到控制台
  Future<void> _printDeviceInfoToConsole() async {
    await _apiService.printDeviceInfo();
    _showMessage('设备信息已打印到控制台');
  }
}
