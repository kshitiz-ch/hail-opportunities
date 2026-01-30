import 'dart:ui';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/send_tracker_request_bottom_sheet.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/button/bordered_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/advisor/models/quick_action_model.dart';
import 'package:core/modules/clients/models/base_sip_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:overflow_view/overflow_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonUI {
  static Widget clientNameCard(Client client, context,
      {Color? backgroundColor, bool showPhoneNumber = false}) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        child: ListTile(
          tileColor: Colors.white,
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          leading: CircleAvatar(
              radius: 25.0,
              child: Text(
                getInitials(
                    client.name == null || client.name.toString().isEmpty
                        ? client.email == null || client.email!.isEmpty
                            ? (showPhoneNumber ? client.phoneNumber! : '-')
                            : client.email!
                        : client.name!),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(color: Colors.white),
              ),
              backgroundColor: pickColor(0)),
          title: Text(client.name ?? '',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  )),
          subtitle: Text(
            showPhoneNumber ? client.phoneNumber! : client.email!,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: Colors.black.withOpacity(0.6),
                ),
          ),
        ),
      ),
    );
  }

  static Widget primaryButton(
      BuildContext context, String title, VoidCallback onTap,
      [double? width]) {
    Color primary = CupertinoTheme.of(context).primaryColor;
    return Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(16),
      color: primary,
      child: MaterialButton(
        minWidth: width != null ? width : MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: onTap,
        child: Text(title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  static Widget primaryButtonWidget(
    BuildContext context,
    String title,
    VoidCallback onTap, [
    Widget? image,
    double? width,
  ]) {
    return Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(10),
      color: ColorConstants.primaryAppColor,
      child: MaterialButton(
        disabledColor: Colors.white.withOpacity(0.4),
        minWidth: width != null ? width : MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image != null ? image : SizedBox.shrink(),
            SizedBox(
              width: 12,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineLarge!.copyWith(
                  fontSize: 16.toFont,
                  color: ColorConstants.white,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  static Widget secondaryButtonWidget(
    BuildContext context,
    String title,
    VoidCallback onTap, [
    Widget? image,
    double? width,
  ]) {
    return Material(
      elevation: 1.0,
      borderRadius: BorderRadius.circular(10),
      color: ColorConstants.secondaryAppColor,
      child: MaterialButton(
        disabledColor: Colors.white.withOpacity(0.4),
        minWidth: width != null ? width : MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image != null ? image : SizedBox.shrink(),
            SizedBox(
              width: 12,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineLarge!.copyWith(
                  fontSize: 16.toFont,
                  color: ColorConstants.primaryAppColor,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  static Widget secondoryButton(
      BuildContext context, Widget title, VoidCallback onTap, Color color,
      [double? width]) {
    return SizedBox(
      height: 50.toHeight,
      child: Material(
        elevation: 1.0,
        borderRadius: BorderRadius.circular(10),
        color: color,
        child: ButtonTheme(
          minWidth: width != null ? width : MediaQuery.of(context).size.width,
          height: 20,
          buttonColor: color,
          child: MaterialButton(
              disabledColor: Colors.white.withOpacity(0.4),
              padding: EdgeInsets.fromLTRB(8.0.toWidth, 0.0, 8.0.toWidth, 0.0),
              onPressed: onTap,
              child: title),
        ),
      ),
    );
    // );
  }

  static Widget circularButtons(
      BuildContext context, String title, String url, VoidCallback onTap,
      {double size = 32.0}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
              radius: (size / 2).toHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  url,
                  fit: BoxFit.fill,
                  width: size,
                  height: size,
                ),
              ),
              backgroundColor: ColorConstants.lightScaffoldBackgroundColor),
          SizedBox(
            height: 4,
          ),
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.titleMedium!,
          )
        ],
      ),
    );
  }

  static Widget circularButtonsAsset(
      BuildContext context, String title, String url, VoidCallback onTap,
      {double size = 32.0}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: (size / 2).toHeight,
            child: Image.asset(
              url,
              height: size.toHeight,
              width: size.toWidth,
              fit: BoxFit.contain,
            ),
            backgroundColor: ColorConstants.white,
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.titleMedium!,
          )
        ],
      ),
    );
  }

  static Widget richTextButton(BuildContext context, {String? agreementText}) {
    String defaultAgreementText = 'By continuing you agree to wealthy’s';
    return RichText(
      text: new TextSpan(
        children: [
          new TextSpan(
              text: agreementText ?? defaultAgreementText,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.darkGrey,
                  )),
          new TextSpan(
            text: ' Terms of Service ',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.primaryAppColor,
                ),
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch('https://www.wealthy.in/privacy');
              },
          ),
          new TextSpan(
            text: 'and',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.darkGrey,
                ),
          ),
          new TextSpan(
            text: ' Privacy Policy. ',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.primaryAppColor,
                ),
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch('https://www.wealthy.in/privacy');
              },
          ),
        ],
      ),
    );
  }

  static Widget indicator(bool isActive, Color color) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 12 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? color : color.withAlpha(100),
        ),
      ),
    );
  }

  // static Widget textButton(
  //     BuildContext context, String title, VoidCallback onTap, Color primary) {
  //   return CupertinoButton(
  //       padding: EdgeInsets.all(0.0),
  //       onPressed: () {
  //         onTap();
  //       },
  //       child: Text(title,
  //           style: Theme.of(context)
  //               .primaryTextTheme
  //               .titleMedium!
  //               .copyWith(color: primary, fontWeight: FontWeight.bold)));
  // }

  static Widget backButton(
      BuildContext context, bool showBackground, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 55.toWidth,
        height: 55.toHeight,
        decoration: showBackground
            ? BoxDecoration(
                color: ColorConstants.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50.0))
            : BoxDecoration(),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios,
            size: 55.toWidth,
            color: showBackground
                ? ColorConstants.white
                : ColorConstants.secondaryAppColor,
          ),
        ),
      ),
    );
  }

  static Widget closeButton(
      BuildContext context, bool showBackground, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 55.toWidth,
        height: 55.toHeight,
        decoration: showBackground
            ? BoxDecoration(
                color: ColorConstants.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50.0))
            : BoxDecoration(),
        child: Center(
          child: Icon(
            Icons.close,
            size: 24.toWidth,
            color: showBackground
                ? ColorConstants.white
                : ColorConstants.secondaryAppColor,
          ),
        ),
      ),
    );
  }

  static Widget mfIconButton(BuildContext context, bool showBackground,
      VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 55.toWidth,
        height: 55.toHeight,
        decoration: showBackground
            ? BoxDecoration(
                color: ColorConstants.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50.0))
            : BoxDecoration(),
        child: Center(
          child: Icon(
            icon,
            size: 24.toWidth,
            color: showBackground
                ? ColorConstants.white
                : ColorConstants.secondaryAppColor,
          ),
        ),
      ),
    );
  }

  static Widget imageIconButton(
      BuildContext context, VoidCallback onTap, String icon) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 55.toWidth,
        height: 55.toHeight,
        child: Image.asset(
          icon,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  static Widget primaryTextFormField(
      TextEditingController controller, String labelText, String hintText,
      [bool? isValid, Function(String)? onChanged, bool? isSecure]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.black54),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          height: 54,
          child: CupertinoTextField(
              // put this in a row for icons
              obscureText: isSecure != null ? isSecure : false,
              onChanged: onChanged,
              controller: controller,
              placeholder: hintText,
              textAlign: TextAlign.left,
              padding: EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                  border: isValid == null
                      ? Border.all(color: Colors.transparent)
                      : (isValid
                          ? Border.all(color: Colors.black)
                          : Border.all(color: Colors.red)))),
        )
      ],
    );
  }

  static Widget progressSpinner(BuildContext context) {
    Color primary = Theme.of(context).primaryColor;
    return TextButton(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(primary),
      ),
      onPressed: () {},
    );
  }

  static dynamic showAlertDialog(
      BuildContext context, String message, VoidCallback okFunction) {
    Widget cancelButton = TextButton(
      child: Text('Cancel'),
      onPressed: () {
        AutoRouter.of(context).popForced();
      },
    );
    Widget okButton = TextButton(child: Text('Ok'), onPressed: okFunction);
    Widget alert = AlertDialog(
      title: Text(message),
      actions: [
        okButton,
        cancelButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future<dynamic> showBottomSheet(
    BuildContext? context, {
    double borderRadius = 36.0,
    bool isScrollControlled = true,
    bool useRootNavigator = true,
    Color? backgroundColor,
    Color? barrierColor,
    required Widget child,
    bool isBackgroundBlur = false,
    bool isDismissible = true,
  }) async {
    return isBackgroundBlur
        ? await showModalBottomSheet(
            context: context!,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(borderRadius)),
            ),
            builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SafeArea(child: child!),
            ),
          )
        : await showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(borderRadius)),
            ),
            isScrollControlled: isScrollControlled,
            isDismissible: isDismissible,
            useRootNavigator: useRootNavigator,
            context: context!,
            backgroundColor: backgroundColor ?? ColorConstants.white,
            barrierColor: barrierColor,
            enableDrag: isDismissible,
            builder: (context) {
              return SafeArea(child: child!);
            },
          );
  }

  static Widget storeProductCardButton(context, {text = "VIEW"}) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0, left: 4.0),
      child: Text(
        text,
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryAppColor,
              fontSize: 12,
            ),
      ),
    );
  }

  static Widget primaryButtonRounded(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    double? width,
  }) {
    Color primary = CupertinoTheme.of(context).primaryColor;
    TextStyle style = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );
    return Material(
      borderRadius: BorderRadius.circular(38),
      clipBehavior: Clip.antiAlias,
      color: primary,
      child: MaterialButton(
        minWidth: width != null ? width : MediaQuery.of(context).size.width / 2,
        onPressed: onTap,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }

  static Widget buildProfileDataSeperator({
    double? height,
    double? width,
    Color? color,
  }) {
    return Container(
      height: height ?? 1,
      width: width ?? SizeConfig().screenWidth,
      color: color ?? ColorConstants.separatorColor,
    );
  }

  static Widget buildHelpButton(BuildContext context) {
    return BorderedButton(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      text: 'Get Help',
      borderRadius: 100,
      textStyle: Theme.of(context)
          .primaryTextTheme
          .displaySmall!
          .copyWith(fontSize: 12, color: ColorConstants.primaryAppColor),
      borderColor: ColorConstants.primaryAppColor,
      onPressed: () {
        if (!isPageAtTopStack(context, WebViewRoute.name)) {
          AutoRouter.of(context).push(
            WebViewRoute(
              url: "https://www.buildwealth.in/partner-support",
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.contains('buildwealth.in')) {
                  //go to app login page instead web login page
                  AutoRouter.of(context).popForced();
                  return NavigationDecision.prevent;
                }
              },
            ),
          );
        }
      },
    );
  }

  static Widget termsAndCondition(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'By using this app, I agree to the ',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.darkGrey,
                    height: 1.4,
                  ),
            ),
            TextSpan(
              text: 'Terms & Conditions',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    height: 1.4,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (!isPageAtTopStack(context, WebViewRoute.name)) {
                    AutoRouter.of(context).push(WebViewRoute(
                      url: "https://www.buildwealth.in/partners-privacy",
                    ));
                  }
                },
            ),
            TextSpan(
              text: '\nand ',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.darkGrey,
                    height: 1.4,
                  ),
            ),
            TextSpan(
              text: 'Privacy Policy.',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    height: 1.4,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (!isPageAtTopStack(context, WebViewRoute.name)) {
                    AutoRouter.of(context).push(WebViewRoute(
                      url: "https://www.buildwealth.in/partners-privacy",
                    ));
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildColumnTextInfo({
    required String title,
    required String subtitle,
    Widget? titleSuffixIcon,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    double? gap,
    int titleMaxLength = 1,
    int subtitleMaxLength = 1,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    Widget? optionalWidget,
    bool useMarqueeWidget = false,
    bool expandTextWidget = false,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleSuffixIcon != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: expandTextWidget == true ? 1 : 0,
                child: Text(
                  title,
                  maxLines: titleMaxLength,
                  style: titleStyle,
                ),
              ),
              titleSuffixIcon
            ],
          )
        else
          Text(
            title,
            maxLines: titleMaxLength,
            style: titleStyle,
          ),
        Padding(
          padding: EdgeInsets.only(top: gap ?? 5.0),
          child: useMarqueeWidget && subtitleMaxLength == 1
              ? MarqueeWidget(
                  child: Text(
                    subtitle,
                    maxLines: subtitleMaxLength,
                    style: subtitleStyle,
                    textAlign: crossAxisAlignment == CrossAxisAlignment.end
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                )
              : Text(
                  subtitle,
                  maxLines: subtitleMaxLength,
                  style: subtitleStyle,
                  textAlign: crossAxisAlignment == CrossAxisAlignment.end
                      ? TextAlign.right
                      : TextAlign.left,
                ),
        ),
        if (optionalWidget != null) optionalWidget
      ],
    );
  }

  static Widget buildProposalFundsOverview(
      {required BuildContext context,
      required int fundCount,
      double? fundAmount}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryAppColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildColumnTextInfo(
            gap: 9,
            title: 'Funds Selected',
            subtitle:
                fundCount.toString() + ' Fund' + (fundCount > 1 ? 's' : ''),
            subtitleStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: ColorConstants.black,
                    ),
            titleStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: ColorConstants.tertiaryBlack,
                    ),
          ),
          buildColumnTextInfo(
            gap: 9,
            title: 'Total Amount',
            subtitle: WealthyAmount.currencyFormat(fundAmount, 2),
            subtitleStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: ColorConstants.black,
                    ),
            titleStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: ColorConstants.tertiaryBlack,
                    ),
          )
        ],
      ),
    );
  }

  static Widget buildColumnText(
    BuildContext context, {
    required String label,
    required String value,
    bool centerText = false,
    double labelFontSize = 14,
    double valueFontSize = 14,
  }) {
    return Column(
      crossAxisAlignment:
          centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.tertiaryBlack,
                height: 1.4,
                fontSize: labelFontSize,
              ),
        ),
        SizedBox(
          height: 6,
        ),
        // Subtitle
        Text(
          value,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
        ),
      ],
    );
  }

  static Widget buildRoundedFullAMCLogo(
      {required double radius, String? amcName, String? amcCode}) {
    return SizedBox(
      height: radius * 2,
      width: radius * 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: getAmcLogo(amcName),
          fit: BoxFit.contain,
          errorWidget: amcCode.isNotNullOrEmpty
              ? (context, url, error) => CachedNetworkImage(
                    imageUrl: getAmcLogoNew(amcCode),
                    fit: BoxFit.contain,
                  )
              : null,
        ),
      ),
    );
  }

  static buildPortfolioAMCLogos() {
    return GetBuilder<MFPortfolioDetailController>(
        id: 'funds',
        builder: (controller) {
          if (controller.fundsResult.schemeMetas.isNullOrEmpty) {
            return SizedBox();
          }
          return OverflowView.flexible(
            spacing: -5,
            children: controller.fundsResult.schemeMetas!
                .map<Widget>(
                  (fund) => CommonUI.buildRoundedFullAMCLogo(
                      radius: 12, amcName: fund.displayName),
                )
                .toList(),
            builder: (_, remaining) => SizedBox(),
          );
        });
  }

  static Widget buildWebViewProgressiveLoader(int loadingPercentage,
      [Color? color]) {
    return Container(
      width: (SizeConfig().screenWidth! * loadingPercentage) / 100,
      height: 3,
      color: color ?? ColorConstants.primaryAppColor,
    );
  }

  static Widget buildPaymentToolTip(
      {String? message, required BuildContext context}) {
    return Tooltip(
      margin: EdgeInsets.only(
          right: 32, left: (SizeConfig().screenWidth! - 64) / 2),
      padding: EdgeInsets.all(10),
      textStyle: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            color: ColorConstants.white,
          ),
      decoration: BoxDecoration(
        color: ColorConstants.black,
        borderRadius: BorderRadius.circular(12),
      ),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: Duration(seconds: 2),
      waitDuration: Duration.zero,
      message: message,
      child: Icon(
        Icons.info,
        color: ColorConstants.darkGrey,
      ),
    );
  }

  static Widget redirectionButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        color: ColorConstants.primaryAppColor,
        size: 12,
      ),
    );
  }

  static Widget triggerSyncUI(BuildContext context, Client client) {
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "trigger_sync",
          screen: 'user_profile',
          screenLocation: 'tracker_card',
        );

        if (client != null) {
          CommonUI.showBottomSheet(
            context,
            child: SendTrackerRequestBottomSheet(client: client),
          );
        }
      },
      child: Row(
        children: [
          Image.asset(
            AllImages().syncIcon,
            height: 16,
            width: 16,
          ),
          SizedBox(width: 4),
          Text(
            'Trigger Sync',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.primaryAppColor),
          )
        ],
      ),
    );
  }

  static Map<String, dynamic> getSIPStatusData(BaseSip baseSip) {
    Map<String, dynamic> data = {};
    if (baseSip.pauseDate != null && baseSip.isActive == true) {
      data['icon'] = Icons.pause;
      data['iconBackgroundColor'] = ColorConstants.yellowAccentColor;
      data['statusText'] = 'Paused';
    } else if (baseSip.isSipActive == true) {
      data['icon'] = Icons.done;
      data['iconBackgroundColor'] = ColorConstants.greenAccentColor;
      data['statusText'] = 'Active';
    } else {
      data['icon'] = Icons.warning;
      data['iconBackgroundColor'] = ColorConstants.redAccentColor;
      data['statusText'] = 'Inactive';
    }

    return data;
  }

  static Map<String, dynamic> getSIPStatusDataNew(
      SipUserDataModel sipUserData) {
    Map<String, dynamic> data = {};
    final isInactive = sipUserData.endDate?.isBefore(DateTime.now());
    if (isInactive == true) {
      data['icon'] = Icons.warning;
      data['iconBackgroundColor'] = ColorConstants.redAccentColor;
      data['statusText'] = 'Inactive';
    } else if (sipUserData.mandateApproved == false) {
      data['icon'] = Icons.pending;
      data['iconBackgroundColor'] = ColorConstants.redAccentColor;
      data['statusText'] = 'Pending eMandate ';
    } else if (sipUserData.isPaused == true) {
      data['icon'] = Icons.pause;
      data['iconBackgroundColor'] = ColorConstants.yellowAccentColor;
      data['statusText'] = 'Paused';
    } else if (sipUserData.isSipActive == true) {
      data['icon'] = Icons.done;
      data['iconBackgroundColor'] = ColorConstants.greenAccentColor;
      data['statusText'] = 'Active';
    } else {
      data['icon'] = Icons.warning;
      data['iconBackgroundColor'] = ColorConstants.redAccentColor;
      data['statusText'] = 'Inactive';
    }

    return data;
  }

  static Widget sipStatusUI({
    required BaseSip baseSip,
    required BuildContext context,
  }) {
    final data = getSIPStatusData(baseSip);

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: data['statusText'] == 'Inactive'
            ? Border.all(
                color: ColorConstants.redAccentColor.withOpacity(0.2),
              )
            : Border(),
        color: ColorConstants.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(right: 6),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: data['iconBackgroundColor'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'],
              size: 16,
              color: ColorConstants.white,
            ),
          ),
          Text(
            data['statusText'],
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                ),
          )
        ],
      ),
    );
  }

  static Widget sipStatusUINew({
    required SipUserDataModel sipUserData,
    required BuildContext context,
  }) {
    final data = getSIPStatusDataNew(sipUserData);

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: data['statusText'] == 'Inactive'
            ? Border.all(
                color: ColorConstants.redAccentColor.withOpacity(0.2),
              )
            : Border(),
        color: ColorConstants.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(right: 6),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: data['iconBackgroundColor'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'],
              size: 16,
              color: ColorConstants.white,
            ),
          ),
          Text(
            data['statusText'],
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                ),
          )
        ],
      ),
    );
  }

  static Widget buildShimmerWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
      decoration: BoxDecoration(
        color: ColorConstants.lightBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 120,
    ).toShimmer(
      baseColor: ColorConstants.lightBackgroundColor,
      highlightColor: ColorConstants.white,
    );
  }

  static Widget bottomsheetCloseIcon(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.close,
          color: ColorConstants.tertiaryBlack,
          size: 18,
        ),
      ),
    );
  }

  static Widget bottomsheetRoundedCloseIcon(BuildContext context,
      {Function? onClose}) {
    return InkWell(
      onTap: () {
        if (onClose != null) {
          onClose();
        } else {
          AutoRouter.of(context).popForced();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          alignment: Alignment.topRight,
          height: 26,
          width: 26,
          margin: EdgeInsets.only(right: 10, top: 10),
          decoration: BoxDecoration(
            color: ColorConstants.darkScaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static Widget infinityLoader() {
    return Container(
      height: 30,
      margin: EdgeInsets.only(bottom: 10, top: 10),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  static Widget buildRedDot({double? rightOffset}) {
    return Positioned(
      top: 0,
      right: rightOffset,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      ),
    );
  }

  static monthYearSelector(
    BuildContext context, {
    required DateTime? selectedDate,
    required void Function(DateTime date) onDateSelect,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    showMonthPicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: startDate,
      lastDate: endDate ?? DateTime.now(),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        dialogSettings: PickerDialogSettings(
          dialogBackgroundColor: Colors.white,
          dialogRoundedCornersRadius: 10,
        ),
        dateButtonsSettings: PickerDateButtonsSettings(
          selectedMonthBackgroundColor: ColorConstants.primaryAppColor,
          selectedMonthTextColor: ColorConstants.white,
          unselectedMonthsTextColor: ColorConstants.black,
        ),
        headerSettings: PickerHeaderSettings(
          headerIconsSize: 24,
          headerBackgroundColor: ColorConstants.primaryAppv3Color,
          headerCurrentPageTextStyle: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          headerSelectedIntervalTextStyle: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          // headerTextColor: Colors.black,
        ),
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: Text(
            'Select',
            style: context.headlineMedium?.copyWith(
              color: ColorConstants.primaryAppColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          cancelWidget: Text(
            'Cancel',
            style: context.headlineMedium?.copyWith(
              color: ColorConstants.primaryAppColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ).then((date) {
      if (date != null) {
        onDateSelect(date);
      }
    });
  }

  static Widget buildInfoToolTip(
      {required String toolTipMessage,
      BuildContext? context,
      Widget? toolTipIcon,
      String? titleText,
      TextStyle? titleStyle,
      double rightPadding = 0,
      Duration? showDuration,
      void Function()? onTriggered}) {
    return Tooltip(
      onTriggered: onTriggered,
      showDuration: showDuration ?? Duration(seconds: 2),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: ColorConstants.black, borderRadius: BorderRadius.circular(6)),
      triggerMode: TooltipTriggerMode.tap,
      textStyle: Theme.of(context ?? getGlobalContext()!)
          .primaryTextTheme
          .titleLarge!
          .copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
      message: toolTipMessage,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titleText.isNotNullOrEmpty)
            Text(
              titleText!,
              style: titleStyle,
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3).copyWith(
              right: rightPadding,
            ),
            child: toolTipIcon ??
                Icon(
                  Icons.info_outline,
                  color: ColorConstants.black,
                  size: 16,
                ),
          ),
        ],
      ),
    );
  }

  static Widget buildInfiniteLoader({double height = 30}) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: 10, top: 10),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  static Widget onboardingLinkClipBoard(
      BuildContext context, String referralUrl,
      {String fromScreen = 'clients'}) {
    return Container(
      height: 30,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              referralUrl,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.black,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: CommonUI.buildProfileDataSeperator(
              height: 24,
              width: 1,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              MixPanelAnalytics.trackWithAgentId(
                "referral_link_copy",
                screen: fromScreen,
                screenLocation: fromScreen,
              );

              await copyData(
                data: getClientinviteLink(referralUrl),
              );
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AllImages().copyIconOnboardingLink,
                  height: 12,
                  width: 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    'Copy',
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.primaryAppColor,
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  static Widget buildInfoText(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.info_outline,
              color: ColorConstants.tertiaryBlack,
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildQuickActionItem(
      {required QuickActionModel quickActionModel,
      required BuildContext context}) {
    void _sendQuickActionAnalytics(String? name, {String? moduleName}) {
      try {
        String pageName = name?.toLowerCase() ?? '';
        if (quickActionNameMap.containsKey(pageName)) {
          pageName = quickActionNameMap[pageName] ?? name ?? '';
        }

        MixPanelAnalytics.trackWithAgentId(
          "page_viewed",
          properties: {
            "page_name": pageName.toCapitalized(),
            "source": "Quick Action",
            if (moduleName.isNotNullOrEmpty) "module_name": moduleName,
            ...getDefaultMixPanelFields(name ?? '-'),
          },
        );
      } catch (_) {}
    }

    return InkWell(
      onTap: () {
        final deeplinkUrl = quickActionModel.deeplinkUrl;

        final moduleName =
            getModuleName(quickActionName: quickActionModel.name ?? '');

        _sendQuickActionAnalytics(
          quickActionModel.name,
          moduleName: moduleName,
        );

        if (deeplinkUrl.isNotNullOrEmpty) {
          bool isExternalUrl = deeplinkUrl!.contains("http") &&
              !(deeplinkUrl.contains("applinks.buildwealth.in"));

          if (isExternalUrl) {
            launch(deeplinkUrl);
            return;
          }

          bool hasLimitedAccess = false;
          if (Get.isRegistered<HomeController>()) {
            hasLimitedAccess = Get.find<HomeController>().hasLimitedAccess;
          }

          if (hasLimitedAccess &&
              (deeplinkUrl.contains("revenue-sheet") ||
                  deeplinkUrl.contains("payout"))) {
            return showToast(
                text: "This feature is not available for this account");
          }

          try {
            AutoRouter.of(context).pushNamed(deeplinkUrl);
          } catch (error) {
            showToast(
                text:
                    "To access this feature, please update to the latest version of the app");
          }
        } else {
          showToast(text: 'Deeplink Url not found');
        }
      },
      child: Container(
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.all(3),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20),
              //   border: Border.all(
              //     color: ColorConstants.black.withOpacity(0.1),
              //   ),
              // ),
              child: Image.network(quickActionModel.imageUrl),
            ),
            SizedBox(height: 5),
            Text.rich(
              TextSpan(
                text: quickActionModel.name,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(),
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildProfilePicLoader(double radius) {
    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
        color: ColorConstants.lightBackgroundColor,
        shape: BoxShape.circle,
      ),
    ).toShimmer(
      baseColor: ColorConstants.lightBackgroundColor,
      highlightColor: ColorConstants.white,
    );
  }

  static Widget buildNewTag(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: ColorConstants.errorColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'New',
        style: Theme.of(context)
            .primaryTextTheme
            .titleMedium!
            .copyWith(color: Colors.white, height: 1),
      ),
    );
  }

  static Widget buildCheckbox({
    required bool? value,
    required Function(bool?)? onChanged,
    OutlinedBorder? shape,
    Color? unselectedBorderColor,
    Color? selectedBorderColor,
    Color? checkColor,
    Color? fillColor,
    double? borderWidth,
    bool showFillColor = true,
  }) {
    return Checkbox(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      value: value,
      fillColor: showFillColor
          ? WidgetStateProperty.all(
              fillColor ?? ColorConstants.primaryAppColor.withOpacity(0.05),
            )
          : null,
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          width: borderWidth ?? 1.0,
          color: value == true
              ? selectedBorderColor ?? ColorConstants.primaryAppColor
              : unselectedBorderColor ?? ColorConstants.borderColor,
        ),
      ),
      checkColor: checkColor ?? ColorConstants.primaryAppColor,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
      onChanged: onChanged,
    );
  }
}

class ClickableText extends StatelessWidget {
  final String? text;
  final Function? onClick;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? fontHeight;
  final EdgeInsets? padding;
  final Color? textColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final MainAxisAlignment mainAxisAlignment;

  const ClickableText({
    Key? key,
    this.text,
    this.fontWeight,
    this.onClick,
    this.fontSize,
    this.padding,
    this.fontHeight,
    this.textColor,
    this.suffixIcon,
    this.prefixIcon,
    this.mainAxisAlignment = MainAxisAlignment.start,
    // this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick as void Function()?,
      child: Container(
        // color: Colors.red,
        padding: padding == null ? EdgeInsets.zero : padding,
        child: suffixIcon == null && prefixIcon == null
            ? _buildTextWidget(context)
            : Row(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (prefixIcon != null) prefixIcon!,
                  _buildTextWidget(context),
                  if (suffixIcon != null) suffixIcon!,
                ],
              ),
      ),
      splashColor: ColorConstants.lightGrey,
      highlightColor: ColorConstants.lightGrey,
    );
  }

  _buildTextWidget(BuildContext context) {
    return Text(
      text!,
      style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
            color: textColor ?? ColorConstants.primaryAppColor,
            fontWeight: fontWeight ?? FontWeight.w700,
            height: prefixIcon == null && suffixIcon == null
                ? fontHeight ?? (18 / 12)
                : null,
            fontSize: fontSize ?? (12),
          ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  // [dash length, space length, dash length, space length, ...]

  DottedBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashPattern = const [5, 5], // Default 5px dash, 5px space
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Use round caps for a 'dotted' look

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // This is a simplified drawing logic. A more robust solution
    // would use PathMetrics to accurately traverse curves and handle corners.
    // This example draws dots along a straight line based on the pattern.
    // To draw along the Rect path accurately requires PathMetrics and more complex calculations.

    // --- Simplified drawing concept (might not look perfect, especially corners) ---
    double distance = 0;
    final totalLength = 2 *
        (size.width + size.height); // Approximate total length for a rectangle

    while (distance < totalLength) {
      // Draw a dash/dot
      if (dashPattern.isNotEmpty) {
        double dash = dashPattern[0];
        // In a real implementation, calculate points along the path using PathMetrics
        // This simplified version doesn't accurately follow the rectangle path

        // For demonstration, let's just draw points along the outline conceptually
        // A correct implementation would use getTangentForOffset(distance) from PathMetrics

        // Example: Drawing points roughly
        if (distance < size.width) {
          // Top edge
          canvas.drawPoints(PointMode.points, [Offset(distance, 0)], paint);
        } else if (distance < size.width + size.height) {
          // Right edge
          canvas.drawPoints(PointMode.points,
              [Offset(size.width, distance - size.width)], paint);
        } // ... continue for bottom and left edges (this gets complicated quickly)

        distance += dash;
      }

      // Skip a space
      if (dashPattern.length > 1) {
        double space = dashPattern[1];
        distance += space;
      } else {
        // If only dash length is provided, just add dash length and break (or repeat)
        break; // Simplified
      }
      // Cycle through the dash pattern indices (more complex)
    }

    // --- End Simplified drawing concept ---

    // --- A more accurate approach uses PathMetrics ---
    final PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double currentDistance = 0;
      bool draw = true; // Start by drawing a dash/dot

      while (currentDistance < pathMetric.length) {
        double segmentLength;
        if (draw) {
          segmentLength = dashPattern[0]; // Dash length
        } else {
          segmentLength = dashPattern[1]; // Space length
        }

        // Ensure we don't go past the end of the path segment
        segmentLength =
            segmentLength.clamp(0.0, pathMetric.length - currentDistance);

        if (draw) {
          // Get the tangent (position and direction) at the current distance
          final tangent = pathMetric.getTangentForOffset(currentDistance);
          if (tangent != null) {
            // For dots, draw a point (circle)
            canvas.drawPoints(PointMode.points, [tangent.position], paint);

            // For dashes (short lines), you would need the next point as well
            // final nextTangent = pathMetric.getTangentForOffset(currentDistance + segmentLength);
            // if (nextTangent != null) {
            //   canvas.drawLine(tangent.position, nextTangent.position, paint);
            // }
          }
        }

        currentDistance += segmentLength;
        draw = !draw; // Alternate between drawing and skipping

        // If you have a pattern like [d1, s1, d2, s2, ...], you need to
        // cycle through the dashPattern indices (more complex state management)
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Return true if the parameters (color, strokeWidth, dashPattern) might have changed
    // For simplicity, we always repaint here.
    return true; // Or check if properties changed
  }
}
