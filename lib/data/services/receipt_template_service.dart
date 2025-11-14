import 'dart:convert';
import 'package:get/get.dart';
import '../../core/storage/storage_service.dart';
import '../models/receipt_template_model.dart';

/// 小票模板服务
/// 负责模板的存储、读取、解析和占位符替换
class ReceiptTemplateService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  static const String _storageKeyPrefix = 'receipt_template_';

  // 当前活动的模板缓存
  final Rx<ReceiptTemplate?> currentCustodyTemplate = Rx<ReceiptTemplate?>(
    null,
  );
  final Rx<ReceiptTemplate?> currentPaymentTemplate = Rx<ReceiptTemplate?>(
    null,
  );
  final Rx<ReceiptTemplate?> currentExchangeTemplate = Rx<ReceiptTemplate?>(
    null,
  );

  /// 初始化服务
  Future<ReceiptTemplateService> init() async {
    _addLog('========== 初始化小票模板服务 ==========');

    // 加载所有模板
    await loadAllTemplates();

    _addLog('========== 初始化完成 ==========');
    return this;
  }

  /// 加载所有模板
  Future<void> loadAllTemplates() async {
    try {
      currentCustodyTemplate.value = await getTemplate(
        ReceiptTemplateType.custody,
      );
      currentPaymentTemplate.value = await getTemplate(
        ReceiptTemplateType.payment,
      );
      currentExchangeTemplate.value = await getTemplate(
        ReceiptTemplateType.exchange,
      );

      _addLog('✓ 已加载所有模板');
    } catch (e) {
      _addLog('✗ 加载模板失败: $e');
    }
  }

  /// 获取指定类型的模板
  Future<ReceiptTemplate?> getTemplate(ReceiptTemplateType type) async {
    try {
      final key = _getStorageKey(type);
      final jsonString = _storage.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        _addLog('未找到 ${type.displayName} 模板，返回默认模板');
        return _getDefaultTemplate(type);
      }

      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final template = ReceiptTemplate.fromMap(map);

      _addLog('✓ 已加载 ${type.displayName} 模板');
      return template;
    } catch (e) {
      _addLog('✗ 获取模板失败: $e');
      return _getDefaultTemplate(type);
    }
  }

  /// 保存模板
  Future<bool> saveTemplate(ReceiptTemplate template) async {
    try {
      final key = _getStorageKey(template.type);
      final updatedTemplate = template.copyWith(updatedAt: DateTime.now());

      final jsonString = jsonEncode(updatedTemplate.toMap());
      await _storage.setString(key, jsonString);

      // 更新缓存
      _updateCache(updatedTemplate);

      _addLog('✓ 已保存 ${template.type.displayName} 模板');
      return true;
    } catch (e) {
      _addLog('✗ 保存模板失败: $e');
      return false;
    }
  }

  /// 删除模板
  Future<bool> deleteTemplate(ReceiptTemplateType type) async {
    try {
      final key = _getStorageKey(type);
      await _storage.remove(key);

      // 清除缓存
      _updateCache(null, type: type);

      _addLog('✓ 已删除 ${type.displayName} 模板');
      return true;
    } catch (e) {
      _addLog('✗ 删除模板失败: $e');
      return false;
    }
  }

  /// 渲染模板（替换占位符，支持循环语法）
  String renderTemplate(ReceiptTemplate template, ReceiptPrintData data) {
    String result = template.content;

    // 1. 处理商品列表循环渲染
    result = _renderProductLoop(result, data);

    // 2. 替换基础占位符
    final replacements = {
      '{{storeName}}': data.storeName,
      '{{operatorName}}': data.operatorName,
      '{{storageId}}': data.storageId,
      '{{memberId}}': data.memberId,
      '{{memberName}}': data.memberName,
      '{{telephone}}': data.telephone,
      '{{numberTickets}}': data.numberTickets.toString(),
      '{{storeAddress}}': data.storeAddress,
      '{{operationTime}}': _formatDateTime(data.operationTime),
      '{{printTime}}': _formatDateTime(data.printTime),
      '{{barcode}}': data.barcode ?? '',
    };

    replacements.forEach((placeholder, value) {
      result = result.replaceAll(placeholder, value);
    });

    // 3. 替换支付相关占位符（带金额格式化）
    if (data.subtotal != null) {
      result = result.replaceAll('{{subtotal}}', _formatAmount(data.subtotal!));
    }
    if (data.discount != null) {
      result = result.replaceAll('{{discount}}', _formatAmount(data.discount!));
    }
    if (data.totalAmount != null) {
      result = result.replaceAll(
        '{{totalAmount}}',
        _formatAmount(data.totalAmount!),
      );
    }
    if (data.paidAmount != null) {
      result = result.replaceAll(
        '{{paidAmount}}',
        _formatAmount(data.paidAmount!),
      );
    }
    if (data.changeAmount != null) {
      result = result.replaceAll(
        '{{changeAmount}}',
        _formatAmount(data.changeAmount!),
      );
    }
    if (data.qrcodeData != null) {
      result = result.replaceAll('{{qrcodeData}}', data.qrcodeData!);
    }

    _addLog('✓ 模板渲染完成');
    return result;
  }

  /// 渲染商品列表循环
  String _renderProductLoop(String template, ReceiptPrintData data) {
    // 匹配 {{#products}}...{{/products}} 语法
    final loopPattern = RegExp(
      r'\{\{#products\}\}([\s\S]*?)\{\{/products\}\}',
      multiLine: true,
    );

    return template.replaceAllMapped(loopPattern, (match) {
      final loopContent = match.group(1) ?? '';
      if (data.products == null || data.products!.isEmpty) {
        return '';
      }

      final buffer = StringBuffer();
      for (final product in data.products!) {
        String itemContent = loopContent;

        // 列宽定义（保证对齐）：
        // 商品名(9字符左对齐) + 单价(7字符右对齐) + 数量(5字符右对齐) + 价格(7字符右对齐)
        // 总宽度28字符，适配58mm热敏纸（32字符宽度）
        
        // 格式化价格列（始终在第一行对应列位置显示）
        final unitPrice = _padString(
          _formatAmount(product.unitPrice, withSymbol: false),
          7,
          alignRight: true,
        );
        final quantity = _padString(
          product.quantity.toString(),
          5,
          alignRight: true,
        );
        final totalPrice = _padString(
          _formatAmount(product.totalPrice, withSymbol: false),
          7,
          alignRight: true,
        );

        // 商品名支持自动换行
        final nameLines = _wrapText(product.name, 9);
        
        // 构建商品行内容（严格列对齐）：
        // 第1行：商品名第1部分 + 单价 + 数量 + 价格（价格信息始终在第一行）
        // 第2-N行：商品名剩余部分 + 空白列（保持对齐）
        final emptyPrice = _padString('', 7, alignRight: true);  // 空白单价列
        final emptyQty = _padString('', 5, alignRight: true);    // 空白数量列
        final emptyTotal = _padString('', 7, alignRight: true);  // 空白价格列
        
        String nameContent;
        if (nameLines.length == 1) {
          // 单行：商品名 + 单价 + 数量 + 价格
          nameContent = nameLines[0] + unitPrice + quantity + totalPrice;
        } else {
          // 多行：
          // 第1行：商品名 + 单价 + 数量 + 价格
          // 第2-N行：商品名 + 空白 + 空白 + 空白（保持列对齐）
          final allLines = <String>[];
          allLines.add(nameLines[0] + unitPrice + quantity + totalPrice); // 第1行显示价格
          for (int i = 1; i < nameLines.length; i++) {
            allLines.add(nameLines[i] + emptyPrice + emptyQty + emptyTotal); // 后续行空白
          }
          nameContent = allLines.join('\n');
        }

        // 替换商品相关占位符
        itemContent = itemContent.replaceAll('{{name}}', nameContent);
        itemContent = itemContent.replaceAll('{{unitPrice}}', '');
        itemContent = itemContent.replaceAll('{{quantity}}', '');
        itemContent = itemContent.replaceAll('{{totalPrice}}', '');

        buffer.write(itemContent);
      }

      return buffer.toString();
    });
  }

  /// 格式化金额（千分位 + 迪拜货币符号 AED）
  String _formatAmount(double amount, {bool withSymbol = true}) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // 添加千分位分隔符
    final intWithCommas = intPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );

    final result = '$intWithCommas.$decPart';
    return withSymbol ? 'AED $result' : result;
  }

  /// 字符串填充（固定宽度对齐）
  String _padString(String text, int width, {bool alignRight = false}) {
    // 计算实际字符宽度（中文2字符，英文1字符）
    int actualWidth = 0;
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      // 判断是否为中文字符（CJK统一汉字）
      if (code >= 0x4E00 && code <= 0x9FFF) {
        actualWidth += 2;
      } else {
        actualWidth += 1;
      }
    }

    // 计算需要填充的空格数
    final paddingNeeded = width - actualWidth;
    if (paddingNeeded <= 0) {
      // 超长则截断
      return text.substring(0, (width / 2).ceil());
    }

    if (alignRight) {
      return ' ' * paddingNeeded + text;
    } else {
      return text + ' ' * paddingNeeded;
    }
  }

  /// 计算文本实际显示宽度（中文2字符，英文1字符）
  int _calculateTextWidth(String text) {
    int width = 0;
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (code >= 0x4E00 && code <= 0x9FFF) {
        width += 2; // 中文字符
      } else {
        width += 1; // 英文/数字/符号
      }
    }
    return width;
  }

  /// 将长文本按指定宽度分行（支持换行）
  List<String> _wrapText(String text, int maxWidth) {
    if (_calculateTextWidth(text) <= maxWidth) {
      return [_padString(text, maxWidth, alignRight: false)];
    }

    final List<String> lines = [];
    String currentLine = '';
    int currentWidth = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charWidth = _calculateTextWidth(char);

      if (currentWidth + charWidth > maxWidth) {
        // 当前行满了，保存并开始新行
        lines.add(_padString(currentLine, maxWidth, alignRight: false));
        currentLine = char;
        currentWidth = charWidth;
      } else {
        currentLine += char;
        currentWidth += charWidth;
      }
    }

    // 添加最后一行
    if (currentLine.isNotEmpty) {
      lines.add(_padString(currentLine, maxWidth, alignRight: false));
    }

    return lines;
  }

  /// 生成打印内容（包含模板渲染和格式化）
  Future<String> generatePrintContent(
    ReceiptTemplateType type,
    ReceiptPrintData data,
  ) async {
    try {
      final template = await getTemplate(type);

      if (template == null) {
        throw Exception('未找到 ${type.displayName} 模板');
      }

      final content = renderTemplate(template, data);

      _addLog('✓ 生成打印内容成功');
      return content;
    } catch (e) {
      _addLog('✗ 生成打印内容失败: $e');
      rethrow;
    }
  }

  /// 获取默认模板
  ReceiptTemplate _getDefaultTemplate(ReceiptTemplateType type) {
    final now = DateTime.now();

    switch (type) {
      case ReceiptTemplateType.custody:
        return ReceiptTemplate(
          id: 'default_custody',
          type: ReceiptTemplateType.custody,
          content: _getDefaultCustodyTemplate(),
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

      case ReceiptTemplateType.payment:
        return ReceiptTemplate(
          id: 'default_payment',
          type: ReceiptTemplateType.payment,
          content: _getDefaultPaymentTemplate(),
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );

      case ReceiptTemplateType.exchange:
        return ReceiptTemplate(
          id: 'default_exchange',
          type: ReceiptTemplateType.exchange,
          content: _getDefaultExchangeTemplate(),
          createdAt: now,
          updatedAt: now,
          isActive: true,
        );
    }
  }

  /// 默认托管小票模板
  String _getDefaultCustodyTemplate() {
    return '''
[center]<xl>HOLOX超乐场</xl>[/center]
[center]===[/center]
[left]**存币单号：**{{storageId}}[/left]
[left]**门店：**{{storeName}}[/left]
[center]---[/center]
[center]{{barcode}}[/center]
[center]---[/center]
[left]会员编号：{{memberId}}[/left]
[left]操作时间：{{operationTime}}[/left]
[left]**彩票数量：**<large>{{numberTickets}}</large>[/left]
[center]===[/center]
[left]<small>打印时间：{{printTime}}</small>[/left]
[left]<small>操作员：{{operatorName}}</small>[/left]
[left]<small>地址：{{storeAddress}}</small>[/left]
[left]<small>电话：{{telephone}}</small>[/left]
[center]===[/center]
[center]请妥善保管好您的小票[/center]
[center]如需兑换礼品请持小票到收银台兑换！[/center]
[center]**感谢惠顾！祝您游玩愉快！**[/center]
[center]===[/center]
''';
  }

  /// 默认支付小票模板
  String _getDefaultPaymentTemplate() {
    return '''
[center]<xl>**HOLOX超乐城**</xl>[/center]
[left]存币单号：{{storageId}}[/left]
[left]门店：{{storeName}}[/left]
[center]============================[/center]
[left]商品        单价 数量   价格[/left]
[center]----------------------------[/center]
{{#products}}
[left]{{name}} {{unitPrice}} {{quantity}} {{totalPrice}}[/left]
{{/products}}
[center]----------------------------[/center]
[left]小计：{{subtotal}}[/left]
[left]优惠金额：-{{discount}}[/left]
[left]应收金额：{{totalAmount}}[/left]
[left]实收金额：{{paidAmount}}[/left]
[left]找零金额：{{changeAmount}}[/left]
[center]============================[/center]
[left]打印时间：{{printTime}}[/left]
[left]操作员：{{operatorName}}[/left]
[left]地址：{{storeAddress}}[/left]
[left]电话：{{telephone}}[/left]
[center]----------------------------[/center]
[left]请当面点清所有商品及找零[/left]
[left]如有质量问题请在30天内凭小票换货[/left]
[center]============================[/center]
[center]开发票请扫描下方二维码[/center]
[center]7天内有效[/center]
[center]{{qrcodeData}}[/center]
[center]============================[/center]
[center]**谢谢惠顾！欢迎下次光临！**[/center]
''';
  }

  /// 默认兑换小票模板
  String _getDefaultExchangeTemplate() {
    return '''
[center]<xl>**HOLOX超乐城**</xl>[/center]
[left]存币单号：{{storageId}}[/left]
[left]门店：{{storeName}}[/left]
[center]============================[/center]
[left]商品        单价 数量   价格[/left]
[center]----------------------------[/center]
{{#products}}
[left]{{name}} {{unitPrice}} {{quantity}} {{totalPrice}}[/left]
{{/products}}
[center]----------------------------[/center]
[left]小计：{{subtotal}}[/left]
[left]优惠彩票：-{{discount}}[/left]
[left]应收彩票：{{totalAmount}}[/left]
[left]实收彩票：{{paidAmount}}[/left]
[left]剩余彩票：{{remainingTickets}}[/left]
[center]============================[/center]
[left]打印时间：{{printTime}}[/left]
[left]操作员：{{operatorName}}[/left]
[left]地址：{{storeAddress}}[/left]
[left]电话：{{telephone}}[/left]
[center]----------------------------[/center]
[left]请当面点清所有商品[/left]
[left]如有质量问题请在30天内凭小票换货（无退款）[/left]
[center]============================[/center]
[center]**谢谢惠顾！欢迎下次光临！**[/center]
''';
  }

  /// 更新缓存
  void _updateCache(ReceiptTemplate? template, {ReceiptTemplateType? type}) {
    final targetType = template?.type ?? type;

    if (targetType == null) return;

    switch (targetType) {
      case ReceiptTemplateType.custody:
        currentCustodyTemplate.value = template;
        break;
      case ReceiptTemplateType.payment:
        currentPaymentTemplate.value = template;
        break;
      case ReceiptTemplateType.exchange:
        currentExchangeTemplate.value = template;
        break;
    }
  }

  /// 获取存储键
  String _getStorageKey(ReceiptTemplateType type) {
    return '$_storageKeyPrefix${type.code}';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 添加日志
  void _addLog(String message) {
    print('[ReceiptTemplateService] $message');
  }

  @override
  void onClose() {
    _addLog('小票模板服务已关闭');
    super.onClose();
  }
}
