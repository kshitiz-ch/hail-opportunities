import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class KycBrowser extends ChromeSafariBrowser {
  final Function()? onExit;

  KycBrowser({this.onExit});

  @override
  void onOpened() {
    LogUtil.printLog("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad(bool? didLoadSuccessfully) {
    LogUtil.printLog("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    LogUtil.printLog("ChromeSafari browser closed");
    onExit?.call();
  }
}

void openKycUrl(String kycUrl, BuildContext context) {
  //  if (!isPageAtTopStack(context, KYCWebviewRoute.name)) {
  //   AutoRouter.of(context).push(KYCWebviewRoute(
  //     kycUrl: kycController.kycUrl,
  //     fromScreen: widget.fromScreen,
  //   ));
  // }

  kycUrl +=
      '&redirect_to=https://applinks.buildwealth.in/kyc/status&new_app_version=true';
  // update to /kyc/status after below change
  //  call in kycstatus screen
  final kycUri = Uri.parse(Uri.encodeFull(kycUrl));
  LogUtil.printLog('kycUri==>${kycUri.toString()}');
  final options = ChromeSafariBrowserSettings(
    toolbarBackgroundColor: ColorConstants.primaryAppColor,
    enableUrlBarHiding: true,
    instantAppsEnabled: true,
    barCollapsingEnabled: true,
    preferredBarTintColor: ColorConstants.primaryAppColor,
    preferredControlTintColor: ColorConstants.white,
  );

  // Open In App Browser
  final browser = KycBrowser(
    onExit: () async {
      await onExitKYCBrowser(context);
    },
  );
  browser.open(
    url: WebUri.uri(kycUri),
    settings: options,
  );
}

void openKycSubFlowUrl({
  required String kycUrl,
  required BuildContext context,
  required Function onExit,
}) {
  //  if (!isPageAtTopStack(context, KYCWebviewRoute.name)) {
  //   AutoRouter.of(context).push(KYCWebviewRoute(
  //     kycUrl: kycController.kycUrl,
  //     fromScreen: widget.fromScreen,
  //   ));
  // }

  // kycUrl += '&redirect_to=https://applinks.buildwealth.in//kyc/status';
  // update to /kyc/status after below change
  //  call in kycstatus screen
  final kycUri = Uri.parse(Uri.encodeFull(kycUrl));
  LogUtil.printLog('kycUri==>${kycUri.toString()}');
  final options = ChromeSafariBrowserSettings(
    toolbarBackgroundColor: ColorConstants.primaryAppColor,
    enableUrlBarHiding: true,
    instantAppsEnabled: true,
    barCollapsingEnabled: true,
    preferredBarTintColor: ColorConstants.primaryAppColor,
    preferredControlTintColor: ColorConstants.white,
  );

  // Open In App Browser
  final browser = KycBrowser(
    onExit: () async {
      onExit();
    },
  );
  browser.open(
    url: WebUri.uri(kycUri),
    settings: options,
  );
}

Future<void> onExitKYCBrowser(BuildContext context) async {
  //  update kyc status in KycStatusRoute

  AutoRouter.of(context).push(
    KycStatusRoute(
      fromScreen: 'KYC Screen',
      sendSubmittedAnalytics: (int? kycStatus) {},
    ),
  );
}
