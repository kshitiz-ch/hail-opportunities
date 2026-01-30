import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:core/main.dart';
import 'package:core/modules/dashboard/models/partner_metric_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/notifications/resources/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

import 'enums.dart';

bool isEmailValid(String? value) {
  Pattern pattern =
      r"^([a-zA-Z0-9_\-\.+]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$";
  RegExp regex = new RegExp(pattern as String);
  if (value == null || !regex.hasMatch(value)) {
    return false;
  } else {
    return true;
  }
}

String getDashboradRedirectUrl(bool isProd, String url, String? apiKey) {
  String apiDomain =
      isProd ? "https://api.buildwealth.in" : "https://api.buildwealthdev.in";
  String dashboardDomain =
      isProd ? "https://app.buildwealth.in" : "https://app.buildwealthdev.in";

  final encodedUrl = Uri.encodeComponent("$dashboardDomain/$url");
  return '$apiDomain/dashboards/api/v0/mobile-redirect/?url=$encodedUrl&token=$apiKey';
}

YoutubePlayerController getVideoPlayerController(videoId) {
  YoutubePlayerController _controller;
  _controller = YoutubePlayerController.fromVideoId(
    videoId: videoId,
    autoPlay: false,
    params: const YoutubePlayerParams(
      origin: 'https://www.youtube-nocookie.com',
      // use 'https://www.youtube-nocookie.com'
      // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
      showControls: true,
      showFullscreenButton: true,
      // desktopMode: false,
      // privacyEnhanced: true,
      loop: false,
      strictRelatedVideos: true,
      showVideoAnnotations: false,
    ),
  );

  return _controller;
}

String randomKeyGenerator() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

bool isProd() {
  return F.appFlavor == Flavor.PROD;
}

String getAdvisorWebUrl() {
  if (F.appFlavor == Flavor.PROD) {
    return 'https://api.buildwealth.in';
  } else {
    return 'https://api.buildwealthdev.in';
  }
}

Future<String?> getApiKey() async {
  final SharedPreferences sharedPreferences = await prefs;
  String? apiKey = sharedPreferences.getString('apiKey');
  return apiKey;
}

Future<String?> getAgentCommunicationToken() async {
  final SharedPreferences sharedPreferences = await prefs;
  String? apiKey = sharedPreferences
      .getString(SharedPreferencesKeys.agentCommunicationToken);
  return apiKey;
}

Future<bool> getIsAgentFixed() async {
  final SharedPreferences sharedPreferences = await prefs;
  bool isAgentFixed =
      sharedPreferences.getBool(SharedPreferencesKeys.isAgentFixed) ?? false;
  return isAgentFixed;
}

Future<int?> getAgentId() async {
  final SharedPreferences sharedPreferences = await prefs;
  int? agentId = sharedPreferences.getInt('agentId');
  return agentId;
}

Future<String?> getAgentExternalId() async {
  final SharedPreferences sharedPreferences = await prefs;
  String? externalAgentId =
      sharedPreferences.getString(SharedPreferencesKeys.agentExternalId);
  return externalAgentId;
}

Future<String?> getHideRevenueStatus() async {
  final SharedPreferences sharedPreferences = await prefs;
  return sharedPreferences.getString(SharedPreferencesKeys.hideRevenue);
}

Future<String> getSalesPlanId() async {
  final SharedPreferences sharedPreferences = await prefs;
  int? salesPlanType =
      sharedPreferences.getInt(SharedPreferencesKeys.salesPlanType);

  if (salesPlanType == null) {
    return '';
  }

  switch (salesPlanType) {
    case 0:
      return '';
    case 1:
      return 'insurance';
    default:
      return '';
  }
}

Future<int?> getAgentKycStatus() async {
  final SharedPreferences sharedPreferences = await prefs;
  int? agentKycStatus = sharedPreferences.getInt('agentKycStatus');
  return agentKycStatus;
}

Future<bool?> getIsGuideCompleted() async {
  final SharedPreferences sharedPreferences = await prefs;
  bool? isGuideCompleted = sharedPreferences.getBool('guideCompleted');
  return isGuideCompleted;
}

Future<String> getDeviceUniqueId() async {
  return await FlutterUdid.udid;
}

Future<PackageInfo> initPackageInfo() async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  return info;
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await initPackageInfo();
  if (Platform.isAndroid) {
    return 'android ${packageInfo.version}';
  } else {
    return 'ios ${packageInfo.version}';
  }
}

String getErrorMessageFromResponse(response, {String? defaultMessage}) {
  var message;
  try {
    if (response is List) {
      message = response[0];
    } else if (response is String) {
      if (response.isNotNullOrEmpty && response.contains('message')) {
        try {
          Map json = jsonDecode(response);
          message = json['message'];
        } catch (e) {
          message = response;
        }
      } else {
        message = response;
      }
    } else {
      message = response['error'] ?? response['message'];
    }

    if (message == null) {
      if (response["error"] is List) {
        message = response["error"].first;
      } else if (response["error"] is String) {
        message = json.decode(response["error"]).first;
      } else if (response["detail"] != null) {
        message = response["detail"]["message"];
      }
    }
  } catch (error) {
    LogUtil.printLog("error");
  }

  return message ?? defaultMessage ?? 'something went wrong';
}

String extractCountryCode(phoneNumber) {
  if (phoneNumber != null && phoneNumber.toString().trim().startsWith('(')) {
    RegExp regExp =
        new RegExp(r"\((.*?)\)", caseSensitive: false, multiLine: false);
    var countryCode = regExp.stringMatch(phoneNumber);
    LogUtil.printLog("countryCode $countryCode");
    return countryCode != null
        ? countryCode.toString().substring(1, countryCode.length - 1)
        : '';
  }
  return '';
}

String? getNumberCommaSeparated(dynamic num, {bool inRupees = false}) {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  String? numFormatted;

  if (num == null) {
    numFormatted = '0';
  }

  if (num is int || num is double) {
    numFormatted = num.toStringAsFixed(2).replaceAllMapped(reg, mathFunc);
  }

  if (num is String) {
    numFormatted = num.toString()
        .replaceAllMapped(reg, mathFunc as String Function(Match));
  }

  if (inRupees) {
    return '₹ $numFormatted';
  } else {
    return numFormatted;
  }
}

String sanitizePhoneNumber(phoneNumber) {
  phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]+'), '');
  if (phoneNumber.startsWith("91") && phoneNumber.length > 10) {
    phoneNumber = phoneNumber.substring(2);
  } else if (phoneNumber.startsWith("0")) {
    phoneNumber = phoneNumber.substring(1);
  }

  return phoneNumber;
}

bool isCorrectPhoneNumberFormat(String? phoneNumber) {
  if (phoneNumber != null) {
    RegExp regExp =
        new RegExp(r"^\(\+\d+\)\d+", caseSensitive: false, multiLine: false);
    return regExp.hasMatch(phoneNumber);
  }
  return false;
}

String extractPhoneNumber(phoneNumber) {
  if (phoneNumber != null && phoneNumber.toString().trim().startsWith('(')) {
    RegExp regExp = new RegExp(r"\).*", caseSensitive: false, multiLine: false);
    var number = regExp.stringMatch(phoneNumber);
    LogUtil.printLog("number $number");
    return number != null ? number.toString().substring(1, number.length) : '';
  }
  return phoneNumber ?? '';
}

handleApiError(data, {bool showToastMessage = false}) {
  String? message;
  bool isTokenExpired = false;

  try {
    if (data['response'] == null) return null;

    if (data['response'] is List) {
      message = data['response'][0];
    } else {
      message = data['response']['message'];
    }

    var body;
    try {
      body = jsonDecode(data['response']['message']);
    } catch (error) {
      LogUtil.printLog(error.toString());
    }

    if (body != null && body['error_code'] == "AUTH002") {
      isTokenExpired = true;
      AuthenticationBlocController()
          .authenticationBloc
          .add(UserLogOut(showLogoutMessage: true));
      return;
    }
  } catch (error) {
    LogUtil.printLog(error.toString());
  }

  if (showToastMessage && !isTokenExpired) {
    showToast(
      text: message,
    );
  } else {
    return message ?? 'Something went wrong please try again';
  }
}

Future<void> handleGraphqlTokenExpiry() async {
  try {
    final SharedPreferences sharedPreferences = await prefs;
    var data = await NotificationsRepository()
        .getNotificationsCount(sharedPreferences.getString('apiKey')!);
    if (data['status'] != 200) {
      handleApiError(data);
    }
  } catch (error) {
    LogUtil.printLog(error.toString());
  }
}

String hyphenateString(String? str) {
  if (str.isNullOrEmpty) {
    return '';
  }

  str = str!.toLowerCase();
  List strList = str.split(" ");
  return strList.join("-");
}

String getKycStatusDescription(kycStatus) {
  switch (kycStatus) {
    case AgentKycStatus.MISSING:
      return 'Missing';
    case AgentKycStatus.INITIATED:
      return "Initiated";
    case AgentKycStatus.INPROGRESS:
      return "In-Progress";
    case AgentKycStatus.SUBMITTED:
      return "Submitted";
    case AgentKycStatus.APPROVED:
      return "Approved";
    case AgentKycStatus.REJECTED:
      return "Rejected";
    case AgentKycStatus.FAILED:
      return "Failed";
    default:
      return 'N/A';
  }
}

String getStockLogo(String? displayName) {
  const AWS_CDN = "https://i.wlycdn.com/stock-icons/";

  RegExp regex = RegExp(r'[\s-_]+');
  String stockName = (displayName ?? '').split(regex).first;

  var url = "$AWS_CDN$stockName.svg";
  return url;
}

String getAmcLogo(String? displayName) {
  final mappedAmcKey = amcLogoMapping.keys.firstWhereOrNull((amcName) =>
      displayName?.toLowerCase().contains(amcName.toLowerCase()) ?? false);

  if (mappedAmcKey.isNotNullOrEmpty) {
    return amcLogoMapping[mappedAmcKey]!;
  }

  const AWS_CDN = "https://i.wlycdn.com/amc-logos/";

  RegExp regex = RegExp(r'[\s-_]+');
  String amcName = (displayName ?? '').split(regex).first.toLowerCase();

  var url = "$AWS_CDN$amcName.png";
  return url;
}

String getAmcLogoNew(String? amcCode) {
  if (amcCode.isNullOrEmpty) return '';

  const AWS_CDN = "https://i.wlycdn.com/amc-logos-new/";

  var url = "$AWS_CDN$amcCode.png";
  return url;
}

String getWealthCaseLogo(String? displayName) {
  const AWS_CDN = "https://i.wlycdn.com/wealthcase-logos/";

  RegExp regex = RegExp(r'[\s-_]+');
  String wealthCaseName = (displayName ?? '').split(regex).first.toLowerCase();

  var url = "$AWS_CDN$wealthCaseName.png";
  return url;
}

String getBankLogo(String? displayName) {
  const AWS_CDN = "https://i.wlycdn.com/bank-logos/";

  var url =
      "$AWS_CDN${displayName.toString().split(' ')[0].toLowerCase()}-bank.png";
  return url;
}

String fundTypeDescription(String? fundType) {
  switch (fundType.toString()) {
    case "E":
    case "A_0":
    case "0":
      return FundType.Equity.name;
    case "D":
    case "A_1":
    case "1":
      return FundType.Debt.name;
    case "H":
    case "A_2":
    case "2":
      return FundType.Hybrid.name;
    case "C":
    case "C_3":
    case "3":
      return FundType.Commodity.name;
    default:
      return "";
  }
}

String getFundTypeAbbr(FundType? fundType) {
  switch (fundType) {
    case FundType.Equity:
      return "e";
    case FundType.Hybrid:
      return "h";
    case FundType.Debt:
      return "d";
    default:
      return "";
  }
}

String mfReturnTypeDescription(String? returnType) {
  switch (returnType.toString()) {
    case "G":
      return 'Growth';
    case "D":
      return 'Dividend';
    case "B":
      return 'Bonus';
    default:
      return '';
  }
}

String fundPlanTypeDescription(String? planType) {
  switch (planType.toString()) {
    case "R":
      return 'Regular';
    case "D":
      return 'Direct';
    case "0":
      return 'Others';
    default:
      return '';
  }
}

String getProductTypeDescription(String? productType) {
  switch (productType.toString().toLowerCase()) {
    case ProductType.MF:
      return "MF portfolio";
    case ProductType.FIXED_DEPOSIT:
      return "Fixed Deposit";
    case ProductType.DEBENTURE:
      return "Debenture";
    case ProductType.HEALTH:
      return "Health Insurance";
    case ProductType.TERM:
      return "Term Insurance";
    case ProductType.SAVINGS:
      return "Savings Insurance";
    case ProductType.TWO_WHEELER:
      return "Two Wheeler Insurance";
    case ProductType.UNLISTED_STOCK:
      return "Pre IPO";
    case ProductType.PMS:
      return "PMS";
    case ProductType.MF_FUND:
      return "MF Fund";
    case ProductType.DEMAT:
      return "Demat";
    default:
      return "";
  }
}

String getProductTypeSearchCategory(String productType) {
  switch (productType.toString().toLowerCase()) {
    case ProductType.MF:
      return "Portfolios";
    case ProductType.FIXED_DEPOSIT:
      return "Fixed Deposits";
    case ProductType.DEBENTURE:
      return "Debentures";
    case "insurance":
      return "Insurances";
    case ProductType.UNLISTED_STOCK:
      return "Pre IPOs";
    case ProductType.MF_FUND:
      return "Funds";
    default:
      return "Others";
  }
}

String getProductTypeSearchCategoryKey(String productType) {
  switch (productType.toString().toLowerCase()) {
    case ProductType.MF:
      return "mf";
    case ProductType.FIXED_DEPOSIT:
      return "fd";
    case ProductType.DEBENTURE:
      return "mld";
    case ProductType.HEALTH:
    case ProductType.TERM:
    case ProductType.SAVINGS:
    case ProductType.TWO_WHEELER:
      return "insurance";
    case ProductType.UNLISTED_STOCK:
      return "unlistedstock";
    case ProductType.MF_FUND:
      return "mffunds";
    default:
      return "other";
  }
}

String getOrdinalNumber(int number) {
  if (number >= 11 && number <= 13) {
    return '${number}th';
  }

  switch (number % 10) {
    case 1:
      return '${number}st';
    case 2:
      return '${number}nd';
    case 3:
      return '${number}rd';
    default:
      return '${number}th';
  }
}

bool isAdult(DateTime birthDate) {
  DateTime today = DateTime.now();

  // Date to check but moved 18 years ahead
  DateTime adultDate = DateTime(
    birthDate.year + 18,
    birthDate.month,
    birthDate.day,
  );

  return adultDate.isBefore(today);
}

bool isMockEmail(String? email) {
  if (email == null) {
    return false;
  } else {
    return email.startsWith('mock') &&
        (email.endsWith('temp') || email.endsWith("mock"));
  }
}

String getReturnPercentageText(rtrn) {
  if (rtrn == null || rtrn == 0) {
    return "-";
  }

  return "${(rtrn * 100).toStringAsFixed(2)}%";
}

String getPercentageText(value) {
  if (value == null) {
    return "NA";
  }

  if (value == 0) {
    return "0%";
  }

  return "${(value * 100).toStringAsFixed(2)}%";
}

bool checkMinAmountValidation(
    {amountEntered, minAmount, bool isTaxSaver = false}) {
  if (amountEntered == 0 || amountEntered == null) {
    showToast(
      text: 'Amount should not be zero',
    );
    return true;
  }

  if (minAmount != null && amountEntered < minAmount) {
    showToast(
      text: 'Min Amount should be ₹${minAmount.toStringAsFixed(0)}',
    );
    return true;
  }

  if (isTaxSaver && amountEntered % minAmount != 0) {
    showToast(
      text: 'Amount should be a multiple of $minAmount',
    );
    return true;
  }

  return false;
}

bool isRouteNameInStack(BuildContext context, String routeName) {
  return AutoRouter.of(context)
          .stack
          .firstWhereOrNull((route) => route.name == routeName) !=
      null;
}

bool isRouteParentOfCurrent(BuildContext context, String routeName) {
  final navigationStack = AutoRouter.of(context).stack;
  return navigationStack.length > 1 &&
      navigationStack[navigationStack.length - 2].name == routeName;
}

InvestmentType? getInvestmentTypeFromString(dynamic type) {
  if (type is int) {
    return type == 1
        ? InvestmentType.oneTime
        : type == 2
            ? InvestmentType.SIP
            : null;
  } else {
    try {
      return InvestmentType.values.firstWhere((el) =>
          el.toString().toLowerCase() ==
          'investmenttype.' + type.toLowerCase());
    } on StateError {
      // TODO: For edit proposal this can be an issue
      return InvestmentType.oneTime;
    }
  }
}

bool isPageAtTopStack(BuildContext context, String? name) {
  return AutoRouter.of(context).stack.isNotNullOrEmpty &&
      AutoRouter.of(context).stack.last.name == name;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      final String trimedText = newValue.text.trimLeft();

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}

class NoLeadingZeroFormatter extends TextInputFormatter {
  // Removes invalid leading zero characters
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('0') && newValue.text.length > 1) {
      String trimedText = '';
      for (int index = 0; index < newValue.text.length; index++) {
        // check for the first non-zero character
        if (newValue.text[index] != '0') {
          // get the remaining string
          trimedText = newValue.text.substring(index);
          break;
        }
      }

      if (trimedText.isNullOrEmpty) {
        trimedText = '0';
      }

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}

Future<void> launch(String url) async {
  try {
    bool res =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!res) {
      throw Exception("Couldn't launch the URL");
    }
  } catch (e) {
    LogUtil.printLog(e.toString());
  }
}

Color getRandomBgColor(int index) {
  final colorList = <Color>[
    hexToColor('#FFADAD'),
    hexToColor('#FFCBAD'),
    hexToColor('#FFE8AD'),
    hexToColor('#C7FFAD'),
    hexToColor('#ADDDFF'),
    hexToColor('#ADB0FF'),
    hexToColor('#DBADFF'),
  ];
  return colorList[index];
}

Color getRandomTextColor(int index) {
  final colorList = <Color>[
    hexToColor('#DA5050'),
    hexToColor('#FB9054'),
    hexToColor('#E8BA44'),
    hexToColor('#74D148'),
    hexToColor('#4A9DD9'),
    hexToColor('#5258D2'),
    hexToColor('#A354E1'),
  ];
  return colorList[index];
}

Future<String?> getDownloadPath() async {
  Directory? directory;

  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadDirectory();

      if (directory == null || !await directory.exists()) {
        try {
          directory = await getExternalStorageDirectory();
        } catch (error) {
          LogUtil.printLog(error.toString());
        }
      }

      if (!await directory!.exists()) {
        String appPath = directory.path;
        String rootPath = appPath.split("/Android")[0];

        directory = Directory(rootPath);
      }
    }
  } catch (err, stack) {
    LogUtil.printLog("Cannot get download folder path");
  }

  return directory?.path;
}

String getFileName(String url) {
  List splitBySlash = url.split("/");
  final fileName = splitBySlash[splitBySlash.length - 1];
  return fileName;
}

Future getDownloadDirectory() async {
  try {
    return Directory('/storage/emulated/0/Download');
  } catch (error) {
    return null;
  }
}

Future<bool> checkProductVideoViewed(String productType) async {
  final SharedPreferences sharedPreferences = await prefs;
  bool isProductVideoViewed =
      sharedPreferences.getBool('${productType}VideoViewed') ?? false;
  return isProductVideoViewed;
}

Future<void> setProductVideoWatched(String? productType) async {
  final SharedPreferences sharedPreferences = await prefs;
  sharedPreferences.setBool('${productType}VideoViewed', true);
}

Future<String> getStoreUrl() async {
  String storeUrl = '';
  PackageInfo packageInfo = await initPackageInfo();

  String appPackageName = packageInfo.packageName;
  if (Platform.isAndroid) {
    storeUrl = "https://play.google.com/store/apps/details?id=";
  } else if (Platform.isIOS) {
    storeUrl = "https://apps.apple.com/app/id";
  }

  if (storeUrl.isNotNullOrEmpty) {
    storeUrl = storeUrl + appPackageName;
  } else {
    storeUrl = 'https://onelink.to/wealthy-deeplink';
  }

  return storeUrl;
}

String extractAppVersion(String val) {
  if (val.isNullOrEmpty) {
    return '';
  }

  String appVersion = '';
  List splitByVersion = val.toLowerCase().split("v");

  bool isAppVersionExists = splitByVersion.length > 1;
  if (isAppVersionExists) {
    appVersion = splitByVersion[1];
  }

  return appVersion;
}

bool isAppVersion31OrGreater(String appVersion) {
  if (appVersion.isNullOrEmpty) {
    return false;
  }

  List<String> versions = appVersion.split(".");

  int major = int.parse(versions[0]);
  int minor = int.parse(versions[1]);

  if (major > 3) {
    return true;
  }

  if (major < 3) {
    return false;
  }

  if (minor >= 1) {
    return true;
  }

  return false;
}

Future<void> setDataUpdatedAt(String content, String? updatedAt) async {
  if (updatedAt == null) return;
  final SharedPreferences sharedPreferences = await prefs;
  await sharedPreferences.setString('${content}_updated_at', updatedAt);
}

Future<String?> getDataUpdatedAt(String content) async {
  final SharedPreferences sharedPreferences = await prefs;
  String? dataUpdated = sharedPreferences.getString('${content}_updated_at');

  return dataUpdated;
}

bool isDataUpdatedAtExpired(
    {required String newUpdatedAt, required String currentUpdatedAt}) {
  try {
    DateTime dt1 = DateTime.parse(currentUpdatedAt);
    DateTime dt2 = DateTime.parse(newUpdatedAt);

    // Returns true if dt1 is after dt2
    return dt1.compareTo(dt2) < 0;
  } catch (error) {
    return false;
  }
}

bool isPanCorporate(String? panNumber) {
  try {
    if (panNumber.isNullOrEmpty || panNumber!.length < 4) {
      return false;
    }

    String panType = panNumber[3].toLowerCase();
    if (panType == "c" || panType == "f") {
      return true;
    }

    return false;
  } catch (error) {
    return false;
  }
}

bool checkProfessionMatchSubstring(
    String profession, List<String> substringsList) {
  bool exist = false;
  for (String substring in substringsList) {
    if (profession.contains(substring)) {
      exist = true;
      break;
    }
  }

  return exist;
}

String getFormattedDate(DateTime? date) {
  try {
    if (date == null) {
      return '-';
    }
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  } catch (error) {
    LogUtil.printLog('error==>$error');
    return '-';
  }
}

String getFormattedDateTime(DateTime? date) {
  try {
    if (date == null) {
      return '-';
    }

    final DateFormat formatter = DateFormat('dd MMM yyyy').add_jms();
    return formatter.format(date);
  } catch (error) {
    LogUtil.printLog('error==>$error');
    return '-';
  }
}

String getFormattedText(String? text, {bool showDefaultText = false}) {
  if (text.isNotNullOrEmpty) return text!;
  return showDefaultText ? '' : notAvailableText;
}

String getCreditCardBankIcon(String? bankName) {
  bankName = bankName?.toLowerCase() ?? '';
  if (bankName.contains('axis')) {
    return AllImages().axisBankIcon;
  }
  if (bankName.contains('hsbc')) {
    return AllImages().hsbcBankIcon;
  }
  if (bankName.contains('indusind')) {
    return AllImages().indusIndBankIcon;
  }
  if (bankName.contains('idfc')) {
    return AllImages().idfcBankIcon;
  }
  if (bankName.contains('chartered')) {
    return AllImages().standardChartredBankIcon;
  }
  if (bankName.contains('au')) {
    return AllImages().auBankIcon;
  }
  if (bankName.contains('sbi')) {
    return AllImages().sbiBankIcon;
  }
  return AllImages().creditCardIcon;
}

String getClientinviteLink(String referralUrl) {
  return referralUrl;
}

void shareClientInviteLink(String referralUrl) {
  shareText('''Hi,

I wanted to personally invite you to start your financial journey with me. Together, we can plan for your future, grow your wealth, and secure your family's needs.

Here's your link to get started: $referralUrl

Let me know if you have any questions—I'm here to help!''');
}

int getPhoneNumberLimitByCountry(String? countryCode) {
  if (countryCode == indiaCountryCode) {
    return 10;
  }

  if (countryCode == uaeCountryCode) {
    return 9;
  }

  return 15;
}

String getProfessionAbbreviation(String profession) {
  if (profession.isNullOrEmpty) {
    return '';
  }

  profession = profession.toLowerCase();

  if (profession.contains("bank")) {
    return "Bank";
  }

  if (profession.contains("insurance company")) {
    return "Insurance_Company";
  }

  if (profession.contains("mutual fund distributor")) {
    return "MFD";
  }

  if (profession.contains("wealth manager")) {
    return "WM";
  }

  if (profession.contains("insurance agent")) {
    return "Insurance_Agent";
  }

  if (profession.contains("lic advisor")) {
    return "LIC";
  }

  if (profession.contains("stock sub-broker")) {
    return "Sub_Broker";
  }

  if (profession.contains("tax consultant")) {
    return "CA";
  }

  if (profession.contains("loan advisor")) {
    return "Loan_Advisor";
  }

  if (profession.contains("it professional")) {
    return "IT";
  }

  if (profession.contains("others")) {
    return "others";
  }

  return profession;
}

String getTransactionStatusDescription(int? status) {
  String description = '';
  switch (status) {
    case TransactionStatusType.Created:
      description = "Created";
      break;
    case TransactionStatusType.Initiated:
      description = "Initiated";
      break;
    case TransactionStatusType.Processing:
      description = "Processing";
      break;
    case TransactionStatusType.Success:
      description = "Success";
      break;
    case TransactionStatusType.Fail:
      description = "Failure";
      break;
  }
  return description;
}

Color getTransactionStatusTextColor(int? status) {
  Color color = ColorConstants.black;
  switch (status) {
    case TransactionStatusType.Created:
      color = ColorConstants.greyBlue;
      break;
    case TransactionStatusType.Initiated:
      color = ColorConstants.primaryAppColor;
      break;
    case TransactionStatusType.Processing:
      color = ColorConstants.primaryAppColor;
      break;
    case TransactionStatusType.Success:
      color = ColorConstants.greenAccentColor;
      break;
    case TransactionStatusType.Fail:
      color = ColorConstants.redAccentColor;
      break;
  }
  return color;
}

String getSchemeOrderStatusDescription(String? status) {
  String description = '';
  switch (status) {
    case SchemeOrderStatusType.Progress:
      description = "Processing";
      break;
    case SchemeOrderStatusType.Success:
      description = "Success";
      break;
    case SchemeOrderStatusType.Failure:
      description = "Failure";
      break;
  }
  return description;
}

Color getSchemeOrderStatusColor(String? status) {
  Color color = ColorConstants.black;
  switch (status) {
    case SchemeOrderStatusType.Progress:
      color = ColorConstants.primaryAppColor;
      break;
    case SchemeOrderStatusType.Success:
      color = ColorConstants.greenAccentColor;
      break;
    case SchemeOrderStatusType.Failure:
      color = ColorConstants.redAccentColor;
      break;
  }
  return color;
}

String getMonthAbbreviation(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}

Color getAumProductColor(MetricType metricType) {
  switch (metricType) {
    case MetricType.Mf:
      return hexToColor("#A4D15E");
    case MetricType.PreIpo:
      return hexToColor("#244794");
    case MetricType.Pms:
      return hexToColor("#BA73B4");
    case MetricType.Mld:
      return hexToColor("#FFAD5B");
    case MetricType.Ncd:
      return hexToColor("#bbaa5c");
    case MetricType.Fd:
      return hexToColor("#ff7366");
    default:
      return hexToColor("#A4D15E");
  }
}

String? phoneNumberInputValidation(String? value, String? countryCodeSelected) {
  {
    if (value.isNullOrEmpty) {
      return 'Phone Number is required.';
    }

    if (value!.startsWith("0")) {
      return "Please enter a valid phone number";
    }

    if (countryCodeSelected == indiaCountryCode &&
        ["0", "1", "2", "3", "4"].contains(value[0])) {
      return "Please enter a valid phone number";
    }

    if (countryCodeSelected == indiaCountryCode && value.length != 10) {
      return 'Phone Number should be 10 digits long';
    }

    if (countryCodeSelected == uaeCountryCode && value.length != 9) {
      return 'Phone Number should be 9 digits long';
    }

    return null;
  }
}

String getPartnerOfficeEmployeeName(EmployeesModel? partnerEmployeeSelected) {
  String partnerOfficeEmployeeName;
  if (partnerEmployeeSelected?.firstName != null) {
    partnerOfficeEmployeeName = partnerEmployeeSelected!.firstName!;
  } else if (partnerEmployeeSelected?.lastName != null) {
    partnerOfficeEmployeeName = partnerEmployeeSelected!.lastName!;
  } else if ((partnerEmployeeSelected?.email ?? '').isNotNullOrEmpty) {
    partnerOfficeEmployeeName =
        partnerEmployeeSelected!.email!.split("@").first;
  } else {
    partnerOfficeEmployeeName = '';
  }

  return partnerOfficeEmployeeName;
}

int calculatePendingProposalCount(QueryResult response) {
  int pendingProposalsCount = 0;

  try {
    int clientConfirmedProposals =
        response.data!['hydra']['proposalStatusCounts']['clientConfirmed'] ?? 0;
    int proposalInitiatedProposals = response.data!['hydra']
            ['proposalStatusCounts']['proposalInitiated'] ??
        0;
    int activeProposals =
        response.data!['hydra']['proposalStatusCounts']['active'] ?? 0;
    pendingProposalsCount =
        clientConfirmedProposals + proposalInitiatedProposals + activeProposals;
  } catch (error) {
    LogUtil.printLog(error.toString());
  }

  return pendingProposalsCount;
}

Future<File> getImageFileFromAssets(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);

  final Directory tempDir = await getTemporaryDirectory();

  List splitBySlash = assetPath.split("/");
  final imageFileName = splitBySlash[splitBySlash.length - 1];

  final file = File('${tempDir.path}/$imageFileName');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

String? getGenderStatus(String? status) {
  if (status == null) {
    return null;
  }

  switch (status.toUpperCase()) {
    case 'M':
      return 'Male';
    case 'F':
      return 'Female';
    case 'O':
      return 'Other';
    default:
      return null;
  }
}

String? getMaritalStatus(String? status) {
  if (status == null) {
    return null;
  }

  switch (status.toUpperCase()) {
    case 'M':
      return 'Married';
    case 'S':
      return 'Single';
    default:
      return null;
  }
}

String? getMaritalStatusDescription(String? status) {
  if (status == null) {
    return null;
  }

  switch (status.toLowerCase()) {
    case 'married':
      return 'M';
    case 'single':
      return 'S';
    default:
      return null;
  }
}

String jsonToBase64(data) {
  final bytes = utf8.encode(prettyJson(data));
  final base64Str = base64.encode(bytes);
  return base64Str;
}

String prettyJson(dynamic json) {
  var spaces = ' ' * 2;
  var encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}

String? getDematShareText(String? referralUrl) {
  if (referralUrl.isNullOrEmpty) {
    return null;
  }

  return 'Hey there! Are you ready to dive into the exciting world of trading? Look no further! Experience the best and unbeatable prices with Wealthy Stocks\n${referralUrl}';
}

String? getSgbShareText(String? referralUrl) {
  if (referralUrl.isNullOrEmpty) {
    return null;
  }

  return 'Open a demat account with Wealthy and dive into the world of special Sovereign Gold Bonds (SGB) while benefiting from India\'s lowest brokerage rates. Start investing today!\n${referralUrl}';
}

double getMinAmount(SchemeMetaModel fund, InvestmentType? investmentType,
    bool isTopUpPortfolio) {
  if (isTopUpPortfolio &&
      (fund.folioOverview?.exists ?? false) &&
      investmentType == InvestmentType.oneTime) {
    return fund.minAddDepositAmt ?? 0;
  }

  if (investmentType == InvestmentType.SIP) {
    return fund.minSipDepositAmt ?? 0;
  }

  return fund.minDepositAmt ?? 0;
}

String getMandateStageDescription(int? stage) {
  switch (stage) {
    case 0:
      return "Not Found";
    case 1:
      return "Generated";
    case 2:
      return "Sent by Customer";
    case 3:
      return "Sent to TPSL";
    case 4:
      return "Approved";
    case 5:
      return "Rejected";
    case 6:
      return "Deleted";
    default:
      return "-";
  }
}

String getFundDescription(SchemeMetaModel fund) {
  if (fund.folioOverview?.exists ?? false) {
    return 'Folio ${fund.folioOverview!.folioNumber}';
  } else {
    return 'New Folio';
    // return '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "| ${fund.fundCategory}" : ""}';
  }
}

String getFundIdentifier(SchemeMetaModel scheme) {
  return (scheme.wschemecode ?? '') + (scheme.folioOverview?.folioNumber ?? '');
}

int getDownloaderTimeoutDuration() {
  // if file size is large & network is taking lot of time
  // to download the document
  // due to low network speed or high server processing time
  // the download will fail & result in timeout exception
  // increasing timeout by 10x
  // by default its 15000
  return 150000;
}

String getBusinessReportTemplateIcon(String templateName) {
  switch (templateName) {
    case 'CLIENT-LIST-REPORT-V1':
      return AllImages().clientMasterReportIcon;
    case 'REVENUE-SHEET':
      return AllImages().revenueSheetReportIcon;
    case 'MF-AUM-REPORT':
      return AllImages().mfAumReportIcon;
    case 'SYSTEMATIC-TRANSACTION-REPORT':
      return AllImages().systematicPlanReportIcon;
    default:
      return AllImages().clientReportIcon;
  }
}
