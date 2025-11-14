/// 小票编辑器配置类
/// 定义不同小票类型的差异化配置（标题、描述、占位符）
import 'receipt_template_model.dart';

class ReceiptEditorConfig {
  final ReceiptTemplateType type;
  final String title; // 页面标题
  final String description; // 页面描述
  final List<PlaceholderInfo> placeholders; // 可用占位符列表

  const ReceiptEditorConfig({
    required this.type,
    required this.title,
    required this.description,
    required this.placeholders,
  });

  /// 托管小票配置
  static const custody = ReceiptEditorConfig(
    type: ReceiptTemplateType.custody,
    title: '托管小票模板配置',
    description: '配置热敏打印机托管小票打印模板',
    placeholders: [
      PlaceholderInfo('{{storeName}}', '门店名称'),
      PlaceholderInfo('{{operatorName}}', '操作员'),
      PlaceholderInfo('{{storageId}}', '存币单号'),
      PlaceholderInfo('{{memberId}}', '会员编号'),
      PlaceholderInfo('{{telephone}}', '电话'),
      PlaceholderInfo('{{numberTickets}}', '彩票数量'),
      PlaceholderInfo('{{printTime}}', '打印时间'),
      PlaceholderInfo('{{barcode}}', '条形码'),
    ],
  );

  /// 支付小票配置
  static const payment = ReceiptEditorConfig(
    type: ReceiptTemplateType.payment,
    title: '支付小票模板配置',
    description: '配置热敏打印机支付凭证打印模板（支持商品列表循环渲染）',
    placeholders: [
      PlaceholderInfo('{{storeName}}', '门店名称'),
      PlaceholderInfo('{{operatorName}}', '收银员'),
      PlaceholderInfo('{{storageId}}', '订单号'),
      PlaceholderInfo('{{memberId}}', '会员编号'),
      PlaceholderInfo('{{printTime}}', '打印时间'),
      PlaceholderInfo('{{telephone}}', '联系电话'),
      PlaceholderInfo('{{storeAddress}}', '门店地址'),
      PlaceholderInfo('{{#products}}...{{/products}}', '商品列表循环'),
      PlaceholderInfo('{{name}}', '商品名称（循环内）'),
      PlaceholderInfo('{{unitPrice}}', '单价（循环内）'),
      PlaceholderInfo('{{quantity}}', '数量（循环内）'),
      PlaceholderInfo('{{totalPrice}}', '小计（循环内）'),
      PlaceholderInfo('{{subtotal}}', '商品总计金额'),
      PlaceholderInfo('{{discount}}', '优惠金额'),
      PlaceholderInfo('{{totalAmount}}', '应付金额'),
      PlaceholderInfo('{{paidAmount}}', '实付金额'),
      PlaceholderInfo('{{changeAmount}}', '找零金额'),
      PlaceholderInfo('{{qrcodeData}}', '二维码数据'),
    ],
  );

  /// 礼品兑换小票配置
  static const exchange = ReceiptEditorConfig(
    type: ReceiptTemplateType.exchange,
    title: '礼品兑换小票模板配置',
    description: '配置热敏打印机礼品兑换凭证打印模板',
    placeholders: [
      PlaceholderInfo('{{storeName}}', '门店名称'),
      PlaceholderInfo('{{operatorName}}', '兑换员'),
      PlaceholderInfo('{{storageId}}', '兑换单号'),
      PlaceholderInfo('{{memberId}}', '会员编号'),
      PlaceholderInfo('{{memberName}}', '会员姓名'),
      PlaceholderInfo('{{numberTickets}}', '兑换彩票数'),
      PlaceholderInfo('{{printTime}}', '兑换时间'),
      PlaceholderInfo('{{barcode}}', '条形码'),
      PlaceholderInfo('{{telephone}}', '联系电话'),
      PlaceholderInfo('{{storeAddress}}', '门店地址'),
    ],
  );

  /// 根据类型获取配置
  static ReceiptEditorConfig fromType(ReceiptTemplateType type) {
    switch (type) {
      case ReceiptTemplateType.custody:
        return custody;
      case ReceiptTemplateType.payment:
        return payment;
      case ReceiptTemplateType.exchange:
        return exchange;
    }
  }
}

/// 占位符信息
class PlaceholderInfo {
  final String placeholder; // 占位符标记（如 {{storeName}}）
  final String description; // 中文描述（如 门店名称）

  const PlaceholderInfo(this.placeholder, this.description);
}
