import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/global_keys.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/freshchat/freshchat_service.dart';
import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/store/basket/widgets/add_fund_warning_bottomsheet.dart';
import 'package:app/src/screens/store/demat_store/widgets/demat_referral_terms_condition.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/bottomsheet/add_amount_bottom_sheet.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blitzllama_flutter/blitzllama_flutter.dart';
import 'package:core/modules/advisor/models/newsletter_model.dart';
import 'package:core/modules/authentication/models/user_data_model.dart';
import 'package:core/modules/clients/models/base_sip_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/report_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/top_up_portfolio/models/portfolio_extras_model.dart';
import 'package:core/modules/top_up_portfolio/models/portfolio_user_products_model.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshchat_sdk/freshchat_sdk.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;
import 'package:send_to_background/send_to_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

Future<void> copyData({String? data}) async {
  if (data.isNullOrEmpty) return;
  await Clipboard.setData(
    ClipboardData(text: data!),
  );
  showToast(text: 'Copied!');
}

Future<void> sendWhatsappMessage(
    {String? message, required String phoneNumber}) async {
  final link = WhatsAppUnilink(
    phoneNumber: '+91' + phoneNumber.trim(),
    text: message,
  );
  await launch('$link');
}

Future<void> callNumber({String? number}) async {
  if (number.isNullOrEmpty) return;
  final link = 'tel:$number';
  await launch(link);
}

/// Formats a value to display as a percentage
/// If the value already ends with '%', returns it as is
/// Otherwise, appends ' %' to the value
/// Returns null if the input value is null or empty
String formatAsPercentage(String? value) {
  if (value.isNullOrEmpty) return '-';

  if (value!.trim().endsWith('%')) {
    return value;
  }
  return '$value %';
}

// minimise app if back button tapped twice within 3 seconds
DateTime? minimiseApplication(
    DateTime? backButtonPressedSince, BuildContext context) {
  Widget customToastWidget() {
    return Container(
      height: 50,
      width: 150,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: ColorConstants.tertiaryBlack,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          'Tap again to exit',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.white,
              ),
        ),
      ),
    );
  }

  if (backButtonPressedSince == null) {
    backButtonPressedSince = DateTime.now();
    showCustomToast(
      context: context,
      child: customToastWidget(),
    );
  } else {
    if (DateTime.now().difference(backButtonPressedSince) <=
        Duration(seconds: 3)) {
      backButtonPressedSince = null;
      SendToBackground.sendToBackground();
    } else {
      backButtonPressedSince = DateTime.now();
      showCustomToast(
        context: context,
        child: customToastWidget(),
      );
    }
  }
  return backButtonPressedSince;
}

Future<bool> isTablet(BuildContext context) async {
  if (Platform.isIOS) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    return iosInfo.model.toLowerCase() == "ipad";
  } else {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

    // Determine if we should use mobile layout or not, 600 here is
    // a common breakpoint for a typical 7-inch tablet.
    return shortestSide > 600;
  }
}

//  Show Custom Toast
// ==================
void showCustomToast(
    {required BuildContext context,
    Widget? child,
    Widget Function(OverlayEntry? entry)? childBuilder,
    AlignmentGeometry alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 5)}) {
  final overlay = Navigator.of(context).overlay!;
  OverlayEntry? entry;

  final currentPageAtTop = AutoRouter.of(context).topRoute.name;
  AutoRouter.of(context).addListener(() {
    // Remove toast if route is changed

    // using context from global key as passed context might have been deactivated
    if (AutoRouter.of(getGlobalContext()!).topRoute.name != currentPageAtTop) {
      if (entry != null && entry!.mounted) {
        entry?.remove();
        entry = null;
      }
    }
  });

  entry = OverlayEntry(
    builder: (context) {
      return SafeArea(
        child: Align(
          alignment: alignment,
          child: Material(
            type: MaterialType.transparency,
            child: child != null
                ? child
                : childBuilder != null
                    ? childBuilder(entry)
                    : SizedBox(),
          ),
        ),
      );
    },
  );

  try {
    overlay.insert(entry!);
  } catch (error) {
    // insert can throw error in few case where its is inserted during widget building process
    LogUtil.printLog('overlay error insert');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => overlay.insert(entry!),
    );
  }

//Remove snackbar after specified duration
  Future.delayed(duration, () {
    if (entry != null && entry!.mounted) {
      entry?.remove();
      entry = null;
    }
  });
}

//  Show Toast
// ===========
void showToast({
  required String? text,
  BuildContext? context,
  Color? backgroundColor,
  Color? textColor,
  Duration duration = const Duration(seconds: 3),
}) {
  if (text.isNullOrBlank) return;

  context ??= getGlobalContext();

  // Hide Keyboard if opened
  try {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  } catch (error) {
    LogUtil.printLog(error.toString());
  }

  showCustomToast(
    duration: duration,
    context: context!,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12.0),
      width: double.infinity,
      color: backgroundColor ?? ColorConstants.black,
      child: Text(
        text ?? '',
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: textColor ?? ColorConstants.white,
            ),
      ),
    ),
  );
}

//  Onboarding Text field
// ======================
Widget buildOnboardingSimpleTextField({
  required BuildContext buildContext,
  TextEditingController? controller,
  String? labelText,
  TextInputType? keyboardType,
  TextCapitalization textCapitalization = TextCapitalization.none,
  bool obscureText = false,
  String? helperText,
  TextStyle? helperStyle,
  bool isPasswordField = false,
  bool isPasswordVisible = false,
  VoidCallback? onPasswordVisibilityToggle,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 32.0),
    child: SimpleTextFormField(
      contentPadding: EdgeInsets.only(bottom: 8),
      helperText: helperText,
      enabled: true,
      controller: controller,
      obscureText: obscureText,
      helperStyle: helperStyle,
      label: labelText,
      textCapitalization: textCapitalization,
      style: Theme.of(buildContext).primaryTextTheme.headlineMedium!.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
      useLabelAsHint: true,
      keyboardType: keyboardType ?? TextInputType.visiblePassword,
      //using visble password so that underline don't show while typing
      // autocorrect: false & enableSuggestions: false not working as expected
      // keyboardType,
      labelStyle:
          Theme.of(buildContext).primaryTextTheme.headlineMedium!.copyWith(
                color: Color(0xff666666),
                height: 0.7,
              ),
      hintStyle:
          Theme.of(buildContext).primaryTextTheme.headlineMedium!.copyWith(
                color: Color(0xff7E7E7E),
                height: 0.7,
              ),
      inputFormatters: keyboardType == TextInputType.name
          ? [
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[a-zA-Z ]',
                ),
              ),
              NoLeadingSpaceFormatter()
            ]
          : null,
      maxLength: keyboardType == TextInputType.phone ? 10 : null,
      suffixIconSize: Size.fromWidth(isPasswordField ? 52 : 36),
      suffixIcon: (controller == null) || (controller.text.isEmpty)
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPasswordField)
                  IconButton(
                    constraints: BoxConstraints(maxWidth: 24, minWidth: 24),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: Center(
                      child: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Color(0xFF979797),
                      ),
                    ),
                    onPressed: onPasswordVisibilityToggle,
                  ),
                SizedBox(width: 4),
                IconButton(
                  constraints: BoxConstraints(maxWidth: 24, minWidth: 24),
                  padding: EdgeInsets.zero,
                  icon: Center(
                    child: Icon(
                      Icons.clear,
                      size: 20.0,
                      color: Color(0xFF979797),
                    ),
                  ),
                  onPressed: () {
                    controller.clear();
                    // controller.phoneNumberController.clear();
                    // controller.update(['phone-number-input']);
                  },
                ),
              ],
            ),
      onChanged: (val) {
        // controller.update(['phone-number-input']);
      },
      textInputAction: TextInputAction.next,
      borderColor: Color(0xffE1E1E1),
      validator: (value) {
        if (value.isNullOrEmpty) {
          return '$labelText is required.';
        }
        if (keyboardType == TextInputType.emailAddress) {
          if (!isEmailValid(value!)) {
            return '$labelText is not valid';
          }
        }
        return null;
      },
    ),
  );
}

Future<void> editFund(
    {required BuildContext context,
    BasketController? controller,
    required SchemeMetaModel fund}) async {
  controller ??= Get.find<BasketController>();

  // bool fromOrderDetails =
  //     isRouteNameInStack(context, CustomPortfolioDetailRoute.name);

  double? minAmount = getMinAmount(
      fund, controller.investmentType, controller.isTopUpPortfolio);

  // Show Bottom Sheet
  await CommonUI.showBottomSheet(
    context,
    child: AddAmountBottomSheetContent(
      minAmount: minAmount,
      actionButtonText: 'Update Fund',
      preFilledAmount: controller.basket[fund.basketKey]!.amountEntered,
      onPressed: (amount) async {
        if (checkMinAmountValidation(
          amountEntered: amount,
          minAmount: minAmount,
        )) {
          return;
        }

        validateAndAddFund(context, controller!, fund, () {
          controller!.addFundToBasket(
            fund,
            context,
            amount,
            toastMessage: 'Fund Updated Successfully!',
          );

          AutoRouter.of(context).popForced();
        });
      },
    ),
  );
}

Future<void> deleteFund({
  required BuildContext context,
  required BasketController controller,
  int? index,
  bool isCustomDetailScreen = false,
  SchemeMetaModel? fund,
  // required String? tag,
}) async {
  // onFundRemove(
  //   GlobalKey<AnimatedListState> listKey,
  //   SchemeMetaModel removedItem,
  // ) async {
  //   try {
  //     listKey.currentState!.removeItem(
  //       index!,
  //       (_, animation) => BasketFundListTile(
  //         tag: tag,
  //         index: 0,
  //         fund: removedItem,
  //         isLastItem: false,
  //       ),
  //       duration: const Duration(milliseconds: 300),
  //     );
  //   } catch (error) {
  //     LogUtil.printLog(error);
  //   }
  // }

  // if (Get.isRegistered<BasketController>(
  //     tag: tag.isNotNullOrEmpty ? tag : null)) {
  //   controller =
  //       Get.find<BasketController>(tag: tag.isNotNullOrEmpty ? tag : null);
  // }

  if (controller.isUpdateProposal && controller.basket.length == 1) {
    showToast(
      context: context,
      text: 'At least one fund required',
    );
    return;
  }

  SchemeMetaModel? removedItem = await controller.removeFundFromBasket(fund!);

  LogUtil.printLog("removedItem => $removedItem");

  // TODO: Update this logic
  // if (removedItem != null) {
  //   if (listKey != null) {
  //     onFundRemove(listKey, removedItem);
  //   }

  //   onFundRemove(controller.listKey, removedItem);
  // }

  // Go back if removed all the funds from basket
  if (isCustomDetailScreen && controller.basket.isEmpty) {
    AutoRouter.of(context).popForced();
  }
}

bool isKycPending(int? status) {
  return status != AgentKycStatus.APPROVED &&
      status != AgentKycStatus.SUBMITTED;
}

String? getGoalId(ProposalModel proposal) {
  try {
    return proposal.productExtrasJson!["downstream_resp"]["goal"]
        ["external_id"];
  } catch (error) {
    return '';
  }
}

Future<void> onTopUpPortfolioClick({
  required ProposalModel proposal,
  required MFPortfoliosController controller,
  required BuildContext context,
}) async {
  String? goalId = getGoalId(proposal);
  Client client = Client(
    taxyID: proposal.customer?.taxyID,
    name: proposal.customer?.name,
    email: proposal.customer?.email,
    phoneNumber: proposal.customer?.phoneNumber,
  );

  PortfolioUserProductsModel portfolio = PortfolioUserProductsModel(
    externalId: goalId,
    productCategory: ProductCategoryType.INVEST,
    productType: ProductType.MF,
    extras: PortfolioExtrasModel(
      goalType: proposal.productInfo?.goalType,
      goalSubtype: WealthyCast.toInt(proposal.productTypeVariant),
    ),
  );

  bool isFetchingPortfolioDetail =
      controller.portfolioDetailState == NetworkState.loading;
  if (isFetchingPortfolioDetail) {
    return null;
  }

  await controller.getGoalDetails(
      userId: client.taxyID ?? '', goalId: portfolio.externalId!);

  if (controller.portfolioDetailState == NetworkState.error) {
    return showToast(
      context: context,
      text: controller.portfolioErrorMessage.isNotNullOrEmpty
          ? controller.portfolioErrorMessage
          : 'Something went wrong',
    );
  }

  if (controller.selectedPortfolio!.isTaxSaver &&
      controller.isTaxSaverDeprecated) {
    return showToast(
        text:
            '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment, you can only invest into current year Tax Saver portfolio.');
  }

  if (!controller.canTopUp) {
    return showToast(
        text:
            '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment');
  }

  if (controller.selectedPortfolio!.goalType == GoalType.CUSTOM) {
    if (controller.portfolioFunds.length == 0) {
      return showToast(
        context: context,
        text:
            '${controller.selectedPortfolio?.title ?? 'This portfolio'} cannot be accessed at the moment. Please try after some time',
      );
    } else {
      Get.delete<BasketController>();
      AutoRouter.of(context).push(FundListRoute(
        portfolio: controller.selectedPortfolio,
        funds: controller.portfolioFunds,
        client: client,
        isTopUpPortfolio: true,
        isCustomPortfolio: true,
        fromClientInvestmentScreen: true,
        portfolioInvestment: controller.portfolioInvestment,
      ));
    }
  } else {
    AutoRouter.of(context).push(
      MfPortfolioDetailRoute(
        portfolio: controller.selectedPortfolio,
        client: client,
        isTopUpPortfolio: true,
        isSmartSwitch: controller.selectedPortfolio?.isSmartSwitch ?? false,
        fromClientInvestmentScreen: true,
        portfolioInvestment: controller.portfolioInvestment,
      ),
    );
  }
}

BuildContext? getGlobalContext() {
  return GlobalKeys.navigatorKey.currentContext;
}

double getScaleValue(
    {required BuildContext context, double customScaleValue = 1.4}) {
  return Responsive.ResponsiveValue(
    context,
    defaultValue: 1,
    conditionalValues: [
      Responsive.Condition.smallerThan(
        name: Responsive.MOBILE,
        value: 1,
      ),
      Responsive.Condition.largerThan(
        name: Responsive.TABLET,
        value: customScaleValue,
      )
    ],
  ).value.toDouble();
}

double getSafeTopPadding(double currentValue, BuildContext context) {
  return max(
    max(
      MediaQuery.of(context).viewPadding.top,
      MediaQuery.of(context).padding.top,
    ),
    currentValue,
  );
}

Future<void> shareText(String text) {
  return SharePlus.instance.share(
    ShareParams(
      text: text,
      sharePositionOrigin: shareButtonRect(),
    ),
  );
}

Future<void> shareFiles(String fileName, {String? text}) {
  if (Platform.isIOS) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(fileName)],
        sharePositionOrigin: shareButtonRect(),
      ),
    );
  }
  return SharePlus.instance.share(
    ShareParams(
      files: [XFile(fileName)],
      text: text,
      sharePositionOrigin: shareButtonRect(),
    ),
  );
}

Rect shareButtonRect() {
  RenderBox? renderBox = getGlobalContext()?.findRenderObject() as RenderBox?;
  if (renderBox == null) {
    return Rect.fromLTWH(
      0,
      0,
      SizeConfig().screenWidth!,
      SizeConfig().screenHeight / 2,
    );
  }

  Size size = renderBox.size;
  Offset position = renderBox.localToGlobal(Offset.zero);

  return Rect.fromCenter(
    center: position + Offset(size.width / 2, size.height / 2),
    width: size.width,
    height: size.height,
  );
}

Future<void> shareImage(
    {BuildContext? context,
    bool disableDownload = false,
    String? creativeUrl,
    String? text,
    int timerInSeconds = 5}) async {
  // Share the url if download is disabled
  if (disableDownload) {
    shareText(creativeUrl!);
    return;
  }

  try {
    List splitBySlash = creativeUrl!.split("/");
    final creativeFileName = splitBySlash[splitBySlash.length - 1];

    final Directory temp = await getTemporaryDirectory();

    final File imageFile = File('${temp.path}/$creativeFileName');

    bool isImageExists = await imageFile.exists();

    // if image doesn't exist in cache directory show loader
    if (!isImageExists) {
      CommonUI.showBottomSheet(
        context,
        child: SizedBox(
          height: 100,
          child: Center(
              child: CircularProgressIndicator(
            color: ColorConstants.primaryAppColor,
          )),
        ),
      );

      var response;
      try {
        response = await http.get(Uri.parse(creativeUrl));
        imageFile.writeAsBytesSync(response.bodyBytes);
        AutoRouter.of(context!).popForced();
        await shareFiles(imageFile.path, text: text);
      } catch (error) {
        AutoRouter.of(context!).popForced();
        shareText(creativeUrl);
      }
    }

    // if image exists in cache directory just share it without fetching it
    else {
      await shareFiles(imageFile.path, text: text);
    }
  } catch (error) {
    shareText(creativeUrl!);
  }
}

void navigateToProposalScreen(BuildContext context) {
  AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
  Get.find<NavigationController>().setCurrentScreen(Screens.PROPOSALS);
  if (Get.isRegistered<ProposalsController>()) {
    Get.find<ProposalsController>().getProposals();
    ProposalsController proposalController = Get.find<ProposalsController>();
    proposalController.tabController!.index = 0;
    proposalController.updateTabStatus("ALL");
    proposalController.getProposals();
  }
}

SystemUiOverlayStyle getDarkStatusBar() => const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );

Widget buildExitLoadDescription(SchemeMetaModel? fund) {
  return Builder(
    builder: (context) {
      if (fund?.exitLoadPercentage == null) {
        return Text(
          '0%',
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
        );
      }

      String exitLoadDescription = '';
      if (fund!.exitLoadTime != null && fund.exitLoadUnit != null) {
        exitLoadDescription =
            '${fund.exitLoadTime}${fund.exitLoadUnit!.toLowerCase()}';
      }

      String exitLoadPercentageInString =
          fund.exitLoadPercentage!.toStringAsFixed(2);
      if (exitLoadPercentageInString[exitLoadPercentageInString.length - 1] ==
          "0") {
        exitLoadPercentageInString = exitLoadPercentageInString.substring(
            0, exitLoadPercentageInString.length - 1);
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fund.exitLoadPercentage != null && fund.exitLoadPercentage! > 0
                ? "${fund.exitLoadPercentage != null ? "$exitLoadPercentageInString% ${exitLoadDescription.isNotEmpty ? '($exitLoadDescription)' : ''}" : "-"}"
                : '0%',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
          ),
          if (fund.exitLoadPercentage != null &&
              fund.exitLoadPercentage! > 0 &&
              fund.exitLoadTime != null &&
              fund.exitLoadUnit != null)
            Padding(
              padding: EdgeInsets.only(left: 3),
              child: Tooltip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: ColorConstants.black,
                    borderRadius: BorderRadius.circular(6)),
                triggerMode: TooltipTriggerMode.tap,
                textStyle:
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                message:
                    'Exit load of ${fund.exitLoadPercentage!.toStringAsFixed(2)}% if redeemed within ${getExitLoadDescription(fund.exitLoadTime, fund.exitLoadUnit)}',
                child: Icon(
                  Icons.info_outline,
                  color: ColorConstants.black,
                  size: 16,
                ),
              ),
            )
        ],
      );
    },
  );
}

double getTextHeight(
  TextSpan span, {
  double? maxWidth,
  int? maxLines,
}) {
  maxWidth ??= SizeConfig().screenWidth! - 82;
  final tp = TextPainter(
    maxLines: maxLines ?? 4,
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
    text: span,
  );

  // Use maxWidth to constrain the text layout, allowing it to wrap correctly
  // If no maxWidth is provided, it defaults to screen width - 82 (as set above)
  tp.layout(minWidth: 0, maxWidth: maxWidth);

  return tp.height;
}

String getDateMonthYearFormat(DateTime? date) {
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

String getSIPStageText({
  bool isActive = true,
  bool isPaused = false,
  bool isPast = true,
  String stage = '',
}) {
  switch (stage) {
    case 'A_0':
      return 'Scheduled';
    case 'A_1':
      return 'Processing';
    case 'A_2':
      return 'NAV Allocated';
    case 'A_3':
      if (isPast) {
        return 'Failed';
      } else if (isPaused) {
        return 'Paused';
      } else if (isActive) {
        return 'Failed';
      } else {
        return 'Inactive';
      }
  }
  return '';
}

String getSIPV2StageText(String status) {
  switch (status) {
    case 'CR':
      return 'Created';
    case 'PR':
      return 'Processing';
    case 'OC':
      return 'Order Created';
    case 'OS':
      return 'Order Success';
    case 'POC':
      return 'Partial Order Created';
    case 'FL':
      return 'Failed';
    case 'PS':
      return 'Paused';
    case 'NAC':
      return 'NAV Allocated';
  }
  return '';
}

Color getSIPStageTextColor({String stage = ''}) {
  switch (stage) {
    case 'A_0':
      return ColorConstants.black;
    case 'A_1':
      return ColorConstants.primaryAppColor;
    case 'A_2':
      return ColorConstants.greenAccentColor;
    case 'A_3':
      return ColorConstants.errorColor;
  }
  return ColorConstants.black;
}

Color getSIPV2StageTextColor(String status) {
  switch (status) {
    case 'PR':
      return ColorConstants.primaryAppColor;
    case 'NAC':
      return ColorConstants.greenAccentColor;
    case 'FL':
    case 'PS':
      return ColorConstants.errorColor;
  }
  return ColorConstants.black;
}

bool redirectToCreditCardHome(String navigationUrl) {
  return navigationUrl.contains('app.buildwealth.in') ||
      navigationUrl.contains('app.buildwealthdev.in');
}

void openPermissionDialog(BuildContext context) async {
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      actionsPadding: EdgeInsets.only(right: 20, bottom: 20),
      title: Text(
        'Permission Required',
        style: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'You need to allow storage / photos permission in order to download the document',
        style: Theme.of(context).primaryTextTheme.headlineSmall,
      ),
      actions: <Widget>[
        // if user deny again, we do nothing
        ClickableText(
          onClick: () {
            Navigator.pop(context);
          },
          text: 'Don\'t allow',
          fontWeight: FontWeight.w700,
          textColor: ColorConstants.darkGrey,
          fontSize: 13,
        ),
        SizedBox(),
        ClickableText(
            onClick: () {
              openAppSettings();
              Navigator.pop(context);
            },
            text: 'Allow',
            fontWeight: FontWeight.w700,
            fontSize: 13),
      ],
    ),
  );
}

String getSIPDisplayName(BaseSip baseSip) {
  String? displayName = '';
  try {
    if (baseSip.baseSipFunds.isNotNullOrEmpty &&
        baseSip.goal?.goalSubtype?.goalType == GoalType.ANY_FUNDS) {
      final data = baseSip.sipSchemes?.firstWhere(
        (sipScheme) =>
            sipScheme.wschemecode == baseSip.baseSipFunds?.first.wschemecode,
      );
      if (data != null) {
        displayName = data.schemeName;
      }
    } else {
      displayName = baseSip.goal?.displayName;
    }
    if (displayName.isNullOrEmpty) {
      displayName = notAvailableText;
    }
  } catch (error) {
    LogUtil.printLog(error.toString());
  }
  return displayName ?? '';
}

String getSIPDisplayNameNew(SipUserDataModel sipuserData) {
  String? displayName = '';
  try {
    if (sipuserData.sipMetaFunds.isNotNullOrEmpty &&
        sipuserData.goalType == GoalType.ANY_FUNDS) {
      final data = sipuserData.sipMetaFunds?.firstWhere(
        (sipScheme) =>
            sipScheme.wschemecode ==
            sipuserData.sipMetaFunds?.first.wschemecode,
      );
      if (data != null) {
        displayName = data.schemeName;
      }
    } else {
      displayName = sipuserData.goalName;
    }
    if (displayName.isNullOrEmpty) {
      displayName = notAvailableText;
    }
  } catch (error) {
    LogUtil.printLog(error.toString());
  }
  return displayName ?? '';
}

String getMaskedText({
  required String text,
}) {
  // first 2 charac+ *****... + last 2 char
  final prefix = text.substring(0, 2);
  final suffix = text.substring(text.length - 3);
  return '$prefix********$suffix';
}

void navigateToFundDetailForTopUp(BuildContext context,
    {required String goalId,
    required GoalSubtypeModel portfolio,
    required Client client,
    required SchemeMetaModel fundDetails,
    InvestmentType? investmentTypeAllowed}) {
  // Remove already existing basket instance to reset state
  if (Get.isRegistered<BasketController>(tag: goalId)) {
    Get.delete<BasketController>(tag: goalId);
  }

  // Create a new instance of basket controller for top up
  Get.put<BasketController>(
    BasketController(
      selectedClient: client,
      fromClientScreen: true,
      portfolio: portfolio,
      isTopUpPortfolio: true,
      investmentTypeAllowed: investmentTypeAllowed,
    ),
    tag: goalId,
  );

  if (!Get.isRegistered<BasketController>(tag: goalId)) {
    return showToast(text: "Something went wrong. Please try again");
  }

  BasketController controller = Get.find<BasketController>(tag: goalId);
  controller.addFundToBasket(
    fundDetails,
    context,
    null,
    toastMessage: null,
  );

  AutoRouter.of(context).push(
    BasketOverViewRoute(
      fromCustomPortfolios:
          controller.portfolio?.productVariant != anyFundGoalSubtype,
      showAddMoreFundButton: false,
      isTopUpPortfolio: controller.isTopUpPortfolio,
      portfolioExternalId: controller.portfolio?.externalId,
    ),
  );

  // AutoRouter.of(context).push(
  //   FundDetailRoute(
  //     viaFundList: true,
  //     isTopUpPortfolio: true,
  //     fund: fundDetails,
  //     tag: portfolio.externalId,
  //     showBottomBasketAppBar: true,
  //     basketBottomBar: GetBuilder<BasketController>(
  //       global: false,
  //       id: 'basket',
  //       tag: goalId,
  //       init: Get.find<BasketController>(tag: goalId),
  //       builder: (controller) {
  //         if (controller.basket.containsKey(fundDetails.basketKey)) {
  //           return Container(
  //             decoration: BoxDecoration(
  //               border: Border(
  //                 top: BorderSide(
  //                   color: ColorConstants.lightGrey,
  //                   width: 1.0,
  //                 ),
  //               ),
  //             ),
  //             child: ActionButton(
  //               margin: EdgeInsets.all(30),
  //               text: 'Continue',
  //               onPressed: () {
  //                 AutoRouter.of(context).push(
  //                   BasketOverViewRoute(
  //                     fromCustomPortfolios:
  //                         controller.portfolio?.productVariant !=
  //                             anyFundGoalSubtype,
  //                     showAddMoreFundButton: false,
  //                     isTopUpPortfolio: controller.isTopUpPortfolio,
  //                     portfolioExternalId: controller.portfolio?.externalId,
  //                   ),
  //                 );
  //               },
  //               textStyle:
  //                   Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
  //                         fontWeight: FontWeight.w700,
  //                         height: 1.4,
  //                         color: ColorConstants.white,
  //                       ),
  //             ),
  //           );
  //         } else {
  //           return Container(
  //             decoration: BoxDecoration(
  //               border: Border(
  //                 top: BorderSide(
  //                   color: ColorConstants.lightGrey,
  //                   width: 1.0,
  //                 ),
  //               ),
  //             ),
  //             child: ActionButton(
  //               margin: EdgeInsets.all(30),
  //               text: 'Add Fund',
  //               height: 56,
  //               onPressed: () {
  //                 // Add the top up fund to the basket
  //                 controller.addFundToBasket(
  //                   fundDetails,
  //                   context,
  //                   null,
  //                   toastMessage: null,
  //                 );

  //                 AutoRouter.of(context).push(
  //                   BasketOverViewRoute(
  //                     fromCustomPortfolios:
  //                         controller.portfolio?.productVariant !=
  //                             anyFundGoalSubtype,
  //                     showAddMoreFundButton: false,
  //                     isTopUpPortfolio: controller.isTopUpPortfolio,
  //                     portfolioExternalId: controller.portfolio?.externalId,
  //                   ),
  //                 );
  //               },
  //               textStyle:
  //                   Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
  //                         fontWeight: FontWeight.w700,
  //                         height: 1.4,
  //                         color: ColorConstants.white,
  //                       ),
  //             ),
  //           );
  //         }
  //       },
  //     ),
  //   ),
  // );
}

Future<PermissionStatus> getStorePermissionStatus() async {
  late PermissionStatus permissionStatus;
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      return PermissionStatus.granted;
      // permissionStatus = await Permission.photos.request();
    } else {
      permissionStatus = await Permission.storage.request();
    }
  } else {
    permissionStatus = await Permission.storage.request();
  }

  return permissionStatus;
}

void openDematStoreScreen({
  required BuildContext context,
  Client? selectedClient,
}) {
  final homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());
  final isDematConsentDone =
      homeController.advisorOverviewModel?.agent?.dematTncConsentAt != null;

  if (isDematConsentDone) {
    AutoRouter.of(context).push(
      DematStoreRoute(client: selectedClient),
    );
    return;
  }

  CommonUI.showBottomSheet(
    context,
    // isDismissible: false,
    child: DematReferralTermsConditions(
      selectedClient: selectedClient,
      onDone: () {
        AutoRouter.of(context).push(
          DematStoreRoute(client: selectedClient),
        );
      },
    ),
  );
}

Future<void> doFlexibleAndroidUpdate({required Function onError}) async {
  showToast(text: 'Starting App Update...');
  final appUpdateResult = await InAppUpdate.startFlexibleUpdate();
  if (appUpdateResult == AppUpdateResult.success) {
    InAppUpdate.completeFlexibleUpdate()
      ..onError((e, st) {
        showToast(text: genericErrorMessage);
        onError();
      })
      ..catchError((error) {
        onError();
      })
      ..whenComplete(() {
        showToast(text: 'App Update Completed');
      })
      ..then((value) {});
  } else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed) {
    showToast(text: 'App Update Failed...');
    onError();
  } else if (appUpdateResult == AppUpdateResult.userDeniedUpdate) {
    showToast(text: 'App Update Denied...');
    onError();
  }
}

Future<void> updateApp(
  BuildContext context, {
  bool doFlexibleUpdate = false,
  bool fromAppUpdateScreen = false,
}) async {
  String storeUrl = '';

  final String _androidId = 'in.wealthy.android.advisor';
  final String _iosBundleId = 'in.wealthy.ios.advisor';
  final newVersion = await NewVersionPlus(
    iOSId: _iosBundleId,
    androidId: _androidId,
  );
  final status = await newVersion.getVersionStatus();

  // Update store URL
  if (Platform.isAndroid) {
    final appPackageName = (await initPackageInfo()).packageName;
    storeUrl = status?.appStoreLink ??
        "https://play.google.com/store/apps/details?id=$appPackageName";
  } else if (Platform.isIOS) {
    storeUrl =
        status?.appStoreLink ?? "https://apps.apple.com/app/id1585943279";
  }

  // if we have to do force update then do android in app update
  // or launch store for manual update
  // else open popup that update is available
  try {
    if (Platform.isAndroid) {
      if (doFlexibleUpdate) {
        return await doFlexibleAndroidUpdate(
          onError: () async {
            final appUpdateResult = await InAppUpdate.performImmediateUpdate();
            if (appUpdateResult == AppUpdateResult.inAppUpdateFailed ||
                appUpdateResult == AppUpdateResult.userDeniedUpdate) {
              launchAppStore(context, newVersion, storeUrl);
            }
          },
        );
      } else if (fromAppUpdateScreen) {
        launchAppStore(context, newVersion, storeUrl);
      } else {
        newVersion.showUpdateDialog(context: context, versionStatus: status!);
      }
    } else if (Platform.isIOS) {
      if (fromAppUpdateScreen) {
        launchAppStore(context, newVersion, storeUrl);
      } else {
        newVersion.showUpdateDialog(context: context, versionStatus: status!);
      }
    }
  } catch (e) {
    launchAppStore(context, newVersion, storeUrl);
  }
}

void launchAppStore(
  BuildContext context,
  NewVersionPlus newVersion,
  String storeUrl,
) {
  newVersion
      .launchAppStore(
    storeUrl,
    launchMode: urlLauncher.LaunchMode.externalApplication,
  )
      .onError(
    (error, stackTrace) {
      showToast(
        context: context,
        text: 'Please visit store for updating the app',
      );
    },
  );
}

Future<FirebaseRemoteConfig> getRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 0),
      minimumFetchInterval: Duration.zero,
    ),
  );
  await remoteConfig.fetchAndActivate();
  return remoteConfig;
}

String getAmcDisplayName(String amcCode) {
  if (!Get.isRegistered<HomeController>()) {
    return amcCode;
  }

  Map<String, dynamic> amcDisplayNameMapping =
      Get.find<HomeController>().amcDisplayNameMapping;
  return amcDisplayNameMapping[amcCode] ?? amcCode;
}

void openFreshChatFAQ() {
  // set freshchat user with updated details
  FreshchatService().setUser();

  Freshchat.showFAQ(
    faqFilterType: FaqFilterType.Category,
    // open partner faq
    faqTags: ['partner'],
    // open partner chat ie Chat with us
    // to open client chat ie live chat use ['client']
    contactUsTags: ['partner'],
  );
}

void openFreshChatSupport() {
  // set freshchat user with updated details
  FreshchatService().setUser();
  Freshchat.showConversations(tags: ['partner']);
}

void handleFreshchatDeeplink(String deepLinkPath, BuildContext context) {
  final isFaqScreen = deepLinkPath == AppRouteName.faqScreen;
  final isSupportScreen = deepLinkPath == AppRouteName.supportScreen;

  if (isFaqScreen || isSupportScreen) {
    // exit faq/support dummy screen
    Future.delayed(Duration(milliseconds: 500), () {
      AutoRouter.of(context).popForced();
    });
    // open respective native view
    if (isFaqScreen) {
      openFreshChatFAQ();
    } else {
      openFreshChatSupport();
    }
  }
}

String getMonthDescription(int? monthNumber, {bool enableShortText = false}) {
  if (monthNumber == null) {
    return '';
  }
  try {
    late String month;
    switch (monthNumber) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }
    return enableShortText ? month.substring(0, 3) : month;
  } catch (e) {
    return '';
  }
}

/// Returns display text for MF transaction types
/// Possible input values are from MFOrderTypeDisplay enum:
/// - Purchase → 'One Time'
/// - SIP → 'SIP'
/// - Switch → 'Switch'
/// - SWP → 'SWP'
/// - STP → 'STP'
/// - Redemption → 'Redemption'
String mfTransactionTypeText(String selectedTransactionType) {
  switch (selectedTransactionType.toLowerCase()) {
    case 'purchase':
      return 'One Time';
    case 'sip':
      return 'SIP';
    case 'switch':
      return 'Switch';
    case 'swp':
      return 'SWP';
    case 'stp':
      return 'STP';
    case 'redemption':
      return 'Redemption';
    default:
      return selectedTransactionType;
  }
}

void navigateToBasketScreen(
  BuildContext context,
  BasketController? controller, {
  required bool fromCustomPortfolios,
}) {
  if (controller?.selectedClient == null) {
    AutoRouter.of(context).push(
      SelectClientRoute(
        checkIsClientIndividual: true,
        lastSelectedClient: controller?.selectedClient,
        onClientSelected: (client, isClientNew) {
          // If client is changed then reset similar proposal list (a list of similar proposals created by the selected client)
          if (isClientNew ||
              (client?.isSourceContacts ?? false) ||
              client?.taxyID != controller?.selectedClient?.taxyID) {
            controller?.similarProposalsList = [];
            controller?.hasCheckedSimilarProposals = false;
          }

          if (isClientNew) {
            AutoRouter.of(context).popForced();
          }

          AutoRouter.of(context).popForced();
          if (controller?.isTopUpPortfolio == false) {
            if (controller?.hasOneTimeBlockedFunds == true &&
                controller?.hasSipBlockedFunds == true) {
              controller?.updateInvestmentType(null);
            } else if (controller?.hasOneTimeBlockedFunds == true) {
              controller?.updateInvestmentType(InvestmentType.SIP);
            } else if (controller?.hasSipBlockedFunds == true) {
              controller?.updateInvestmentType(InvestmentType.oneTime);
            }
          }
          AutoRouter.of(context).push(BasketOverViewRoute(
            fromCustomPortfolios: fromCustomPortfolios,
            isTopUpPortfolio: controller?.isTopUpPortfolio ?? false,
            portfolioExternalId: controller?.portfolio?.externalId,
          ));

          controller?.selectedClient = client;
          controller?.update(['basket']);
        },
      ),
    );
  } else {
    if (controller?.isTopUpPortfolio == false) {
      if (controller?.hasOneTimeBlockedFunds == true &&
          controller?.hasSipBlockedFunds == true) {
        controller?.updateInvestmentType(null);
      } else if (controller?.hasOneTimeBlockedFunds == true) {
        controller?.updateInvestmentType(InvestmentType.SIP);
      } else if (controller?.hasSipBlockedFunds == true) {
        controller?.updateInvestmentType(InvestmentType.oneTime);
      }
    }
    AutoRouter.of(context).push(BasketOverViewRoute(
      fromCustomPortfolios: fromCustomPortfolios,
      isTopUpPortfolio: controller?.isTopUpPortfolio ?? false,
      portfolioExternalId: controller?.portfolio?.externalId,
    ));
  }
}

/// Returns a list of DateTime objects representing the last 6 months including current month.
///
/// For previous months: Returns the last day of each month
/// For current month: Returns today's date (not future date)
///
/// Example: If today is August 15, 2024, returns:
/// - March 31, 2024 (last day of March)
/// - April 30, 2024 (last day of April)
/// - May 31, 2024 (last day of May)
/// - June 30, 2024 (last day of June)
/// - July 31, 2024 (last day of July)
/// - August 15, 2024 (today's date)
List<DateTime> getLastSixMonthsDate() {
  DateTime now = DateTime.now();
  List<DateTime> lastSixMonthsDate = [];

  // Loop through last 6 months (i=5 is 5 months ago, i=0 is current month)
  for (int i = 5; i >= 0; i--) {
    // Get the first day of the target month
    DateTime firstDayOfMonth = DateTime(now.year, now.month - i, 1);

    if (i == 0) {
      // For current month, use today's date to avoid future dates
      lastSixMonthsDate.add(DateTime(now.year, now.month, now.day));
    } else {
      // For previous months, use last day of that month
      // DateTime(year, month + 1, 0) gives last day of current month
      DateTime lastDayOfMonth =
          DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0);
      lastSixMonthsDate.add(lastDayOfMonth);
    }
  }

  return lastSixMonthsDate;
}

bool isDownloadableUrl(String url) {
  if (url.isNotNullOrEmpty) {
    List<String> allowedFileExtension = [
      "pdf",
      "png",
      "jpg",
      "docx",
      "doc",
      "xlxx",
      "jpeg",
      "xlsx"
    ];
    return allowedFileExtension.any(
      (fileExtension) => url.endsWith(fileExtension),
    );
  }
  return false;
}

String getReportInputTitle(ReportDateType dateType) {
  if (dateType == ReportDateType.SingleDate) {
    return 'Choose investment date';
  }
  if (dateType == ReportDateType.IntervalDate) {
    return 'Choose Interval';
  }
  if (dateType == ReportDateType.SingleYear) {
    return 'Choose Financial year';
  }
  return 'Choose Date';
}

void sendBlitzllamaUserData(AgentAuthModel? agent) {
  BlitzllamaFlutter.createUser(agent?.externalId ?? '');
  BlitzllamaFlutter.setUserName(agent?.name ?? '');
}

void validateAndAddFund(
  BuildContext context,
  BasketController controller,
  SchemeMetaModel fund,
  void Function() onProceed,
) {
  if (fund.isNfo == true) {
    if (controller.hasNonNfoInBasket == true) {
      CommonUI.showBottomSheet(
        context,
        child: AddFundWarningBottomSheet(
          onProceed: () {
            controller.clearBasket();
            onProceed();
          },
          isAddingNfo: true,
        ),
      );
    } else {
      onProceed();
    }
  } else {
    if (controller.hasNfoInBasket == true) {
      CommonUI.showBottomSheet(
        context,
        child: AddFundWarningBottomSheet(
          onProceed: () {
            controller.clearBasket();
            onProceed();
          },
          isAddingNfo: false,
        ),
      );
    } else {
      onProceed();
    }
  }
}

String getNewsLetterShareUrl(NewsLetterModel newsLetterModel) {
  // add base url
  String shareUrl = F.appFlavor == Flavor.PROD
      ? 'https://www.wealthy.in/newsletter/${newsLetterModel.contentType}'
      : 'https://www.wealthydev.in/newsletter/${newsLetterModel.contentType}';

  // add slug
  if (newsLetterModel.slug.isNotNullOrEmpty) {
    shareUrl += '/${newsLetterModel.slug}';
  }

  // add id
  shareUrl += '-${newsLetterModel.id}';

  return shareUrl;
}

Future<Map<String, dynamic>> checkReportAvailability({
  required Future<ReportModel?> Function() onRefresh,
  int maxRetry = 5,
  String? customToastMessage,
  Duration? retryDelay,
}) async {
  // do polling till report is available to download
  ReportModel? newReportModel;
  int retryCount = 0;
  bool isAvailable = false;
  bool isFailed = false;

  // Ensure maxRetry is at least 1
  maxRetry = maxRetry < 1 ? 1 : maxRetry;

  await Future.doWhile(
    () async {
      retryCount++;
      try {
        newReportModel = await onRefresh();
        isAvailable = newReportModel?.isGenerated ?? false;
        isFailed = newReportModel?.isFailure ?? false;
      } catch (e) {
        LogUtil.printLog('error==>${e.toString()}');
        // Continue retrying on exceptions unless max retries reached
      }

      // Exit early if report is available or failed
      if (isAvailable || isFailed) {
        return false;
      }

      // Wait specified delay before next retry if more retries remaining
      if (retryCount < maxRetry && retryDelay != null) {
        await Future.delayed(retryDelay);
      }

      return retryCount < maxRetry;
    },
  );
  if (!isAvailable) {
    final toastMsg = isFailed
        ? (newReportModel?.error ?? '').isNotNullOrEmpty
            ? newReportModel!.error
            : "Report generation failed. Please try again after sometime"
        : customToastMessage ??
            "Report generation is taking longer than expected. Please try again after sometime";

    showToast(
      text: toastMsg,
      duration: Duration(seconds: 3),
    );
  }

  return {
    'isAvailable': isAvailable,
    'newReportModel': newReportModel,
  };
}

bool isEmployeeLoggedIn() {
  final homeController = Get.find<HomeController>();
  return homeController.advisorOverviewModel?.isEmployee ?? false;
}

Future<String> getMonthlyPlannerUrl() async {
  String urlPath = "monthly-planner";
  String? apiKey = await getApiKey();
  return getDashboradRedirectUrl(isProd(), urlPath, apiKey);
}

void onPopInvoked(bool didPop, Function goBackHandler) {
  if (didPop) return;
  goBackHandler();
}

void navigateToDashboard(BuildContext context) {
  AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
  if (Get.isRegistered<HomeController>()) {
    HomeController homeController = Get.find<HomeController>();
    homeController.getAdvisorOverview();
  }
}

bool canPlaceFullOrder({
  required double inputValue,
  required int maxAmount,
  required double maxUnits,
  required OrderValueType orderType,
}) {
  if (orderType == OrderValueType.Units) {
    return inputValue == maxUnits;
  }
  // available amount is
  // <100 - 10
  // 100-1000 - 50
  // 1000-10000 - 100
  // 10000-1lakh - 500
  // 1Lakh+ - 1000

  final bufferSlabMap = {100: 10, 1000: 50, 10000: 100, 100000: 500};
  final inputAmount = inputValue.toInt();

  if (inputAmount > maxAmount) {
    return false;
  }

  int lowerRange = 0;
  int upperRange = 100;
  for (var bufferSlab in bufferSlabMap.entries) {
    upperRange = bufferSlab.key;
    final diff = bufferSlab.value;
    if (maxAmount >= lowerRange && maxAmount <= upperRange) {
      if ((maxAmount - diff) <= inputAmount) {
        return true;
      }
    }
    lowerRange = upperRange;
  }
  if (maxAmount > 100000) {
    return (maxAmount - 1000) <= inputAmount;
  }
  return false;
}

/// Extracts the phone number from different formats
String extractPhoneFromHint(String phoneNumber) {
  // Remove any spaces, dashes, or other formatting
  String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

  // Handle different formats
  if (cleanNumber.startsWith('+91')) {
    return cleanNumber.substring(3);
  } else if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
    return cleanNumber.substring(2);
  } else if (cleanNumber.length == 10) {
    return cleanNumber;
  }

  // For other formats, try to extract last 10 digits
  if (cleanNumber.length > 10) {
    return cleanNumber.substring(cleanNumber.length - 10);
  }

  return cleanNumber;
}

String getModuleName({String routeName = '', String quickActionName = ''}) {
  if (quickActionName.toLowerCase() == 'posters' ||
      quickActionName.toLowerCase() == 'resources') {
    return 'Resources';
  }

  if (routeName.toLowerCase() == ResourcesRoute.name.toLowerCase()) {
    return 'Resources';
  }

  return '';
}

String convertRouteToPageName(String routeName, {String? ntype}) {
  try {
    if (ntype.isNotNullOrEmpty) {
      ntype = ntype!.toLowerCase();
      if (nTypePageNameMap.containsKey(ntype)) {
        return nTypePageNameMap[ntype]!;
      }
    }

    if (routeName.isEmpty) return 'Page';

    if (routePageNameMap.containsKey(routeName)) {
      return routePageNameMap[routeName]!;
    }

    // Remove 'Route' suffix if present
    String cleanName = routeName.endsWith('Route')
        ? routeName.substring(0, routeName.length - 5)
        : routeName;

    if (cleanName.isEmpty) return 'Page';

    // Split camelCase/PascalCase into words
    List<String> words = [];
    StringBuffer currentWord = StringBuffer();

    for (int i = 0; i < cleanName.length; i++) {
      String char = cleanName[i];

      if (char == char.toUpperCase() && i > 0 && currentWord.isNotEmpty) {
        // Found uppercase letter, finish current word first
        words.add(currentWord.toString());
        currentWord.clear();
      }

      // Add current character to the current word
      currentWord.write(char);
    }

    // Add the last word
    if (currentWord.isNotEmpty) {
      words.add(currentWord.toString());
    }

    // Capitalize first letter of each word and join with spaces
    String result = words
        .where((word) => word.isNotEmpty)
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');

    return '$result';
  } catch (error) {
    LogUtil.printLog('Error in convertRouteToPageName: $error');
    return 'Page';
  }
}

// Name can be route name or quick action name
Map<String, String> getDefaultMixPanelFields(String name) {
  try {
    switch (name) {
      case ResourcesRoute.name:
      case 'Posters':
        return {"language": "English"};
      default:
        return {};
    }
  } catch (error) {
    LogUtil.printLog('Error in getDefaultMixPanelFields: $error');
    return {};
  }
}

Map<String, String> getWealthCaseCagrRow(WealthcaseModel wealthcase) {
  if (wealthcase.cagr?.cagr1y != null) {
    return {
      '1Y CAGR': wealthcase.formattedCagr1Y,
    };
  }

  if (wealthcase.performance?.sixMonths != null) {
    return {
      '6M Returns': wealthcase.performance?.sixMonths?.last.changePerc != null
          ? "${wealthcase.performance?.sixMonths?.last.changePerc}%"
          : '-',
    };
  }

  if (wealthcase.performance?.oneMonth != null) {
    return {
      '1M Returns': wealthcase.performance?.oneMonth?.last.changePerc != null
          ? "${wealthcase.performance?.oneMonth?.last.changePerc}%"
          : '-',
    };
  }

  return {
    'Return': '-',
  };
}
