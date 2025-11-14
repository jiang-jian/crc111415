import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'POS System'**
  String get appName;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get newUser;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get enterUsername;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get enterPhone;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @getVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Get Code'**
  String get getVerificationCode;

  /// No description provided for @cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier:'**
  String get cashier;

  /// No description provided for @merchantCode.
  ///
  /// In en, this message translates to:
  /// **'Merchant Code:'**
  String get merchantCode;

  /// No description provided for @customerService.
  ///
  /// In en, this message translates to:
  /// **'Customer Service:'**
  String get customerService;

  /// No description provided for @quickCheckout.
  ///
  /// In en, this message translates to:
  /// **'Quick Checkout'**
  String get quickCheckout;

  /// No description provided for @giftExchange.
  ///
  /// In en, this message translates to:
  /// **'Gift Exchange'**
  String get giftExchange;

  /// No description provided for @customerCenter.
  ///
  /// In en, this message translates to:
  /// **'Customer Center'**
  String get customerCenter;

  /// No description provided for @exchangeVerification.
  ///
  /// In en, this message translates to:
  /// **'Exchange Verification'**
  String get exchangeVerification;

  /// No description provided for @activityCenter.
  ///
  /// In en, this message translates to:
  /// **'Activity Center'**
  String get activityCenter;

  /// No description provided for @orderCenter.
  ///
  /// In en, this message translates to:
  /// **'Order Center'**
  String get orderCenter;

  /// No description provided for @businessReport.
  ///
  /// In en, this message translates to:
  /// **'Business Report'**
  String get businessReport;

  /// No description provided for @financialManagement.
  ///
  /// In en, this message translates to:
  /// **'Financial Management'**
  String get financialManagement;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @networkAutoCheck.
  ///
  /// In en, this message translates to:
  /// **'Network Auto Check'**
  String get networkAutoCheck;

  /// No description provided for @externalConnectionStatus.
  ///
  /// In en, this message translates to:
  /// **'External Connection Status:'**
  String get externalConnectionStatus;

  /// No description provided for @centerServerConnectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Center Server Connection Status:'**
  String get centerServerConnectionStatus;

  /// No description provided for @pingCheckResults.
  ///
  /// In en, this message translates to:
  /// **'Ping Check Results'**
  String get pingCheckResults;

  /// No description provided for @externalPingResult.
  ///
  /// In en, this message translates to:
  /// **'External Ping Result:'**
  String get externalPingResult;

  /// No description provided for @dnsPingResult.
  ///
  /// In en, this message translates to:
  /// **'DNS Service Ping Result:'**
  String get dnsPingResult;

  /// No description provided for @centerServerPingResult.
  ///
  /// In en, this message translates to:
  /// **'Center Service Ping Result:'**
  String get centerServerPingResult;

  /// No description provided for @refreshCheck.
  ///
  /// In en, this message translates to:
  /// **'Refresh Check'**
  String get refreshCheck;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
