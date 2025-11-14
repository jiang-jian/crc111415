// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '收银台系统';

  @override
  String get newUser => '新用户';

  @override
  String get login => '登录';

  @override
  String get username => '账号';

  @override
  String get phoneNumber => '手机号';

  @override
  String get password => '密码';

  @override
  String get enterUsername => '请输入账号';

  @override
  String get enterPhone => '请输入手机号';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get getVerificationCode => '获取验证码';

  @override
  String get cashier => '收银员：';

  @override
  String get merchantCode => '商户编码：';

  @override
  String get customerService => '客服电话：';

  @override
  String get quickCheckout => '快速收银';

  @override
  String get giftExchange => '礼品兑换';

  @override
  String get customerCenter => '顾客中心';

  @override
  String get exchangeVerification => '兑换核销';

  @override
  String get activityCenter => '活动中心';

  @override
  String get orderCenter => '订单中心';

  @override
  String get businessReport => '经营报表';

  @override
  String get financialManagement => '财务管理';

  @override
  String get settings => '设置';

  @override
  String get networkAutoCheck => '网络自动检测';

  @override
  String get externalConnectionStatus => '外网连接状态：';

  @override
  String get centerServerConnectionStatus => '中心服务器连接状态：';

  @override
  String get pingCheckResults => 'Ping检测结果';

  @override
  String get externalPingResult => '外网Ping检测结果：';

  @override
  String get dnsPingResult => 'DNS服务Ping检测结果：';

  @override
  String get centerServerPingResult => '中心服务Ping检测结果：';

  @override
  String get refreshCheck => '刷新检测';
}
