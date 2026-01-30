import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void openWealthyAiUrl(String url) {
  final options = ChromeSafariBrowserSettings(
    shareState: CustomTabsShareState.SHARE_STATE_OFF,
    toolbarBackgroundColor: Colors.black,
    showTitle: true,
    isSingleInstance: true,
    enableUrlBarHiding: true,
    instantAppsEnabled: true,
    barCollapsingEnabled: true,
    preferredBarTintColor: Colors.black,
    preferredControlTintColor: ColorConstants.white,
  );

  // Open In App Browser
  final browser = KycBrowser(
    onExit: () async {},
  );

  final wealthyAiUri = Uri.parse(Uri.encodeFull(url));

  browser.open(
    url: WebUri.uri(wealthyAiUri),
    settings: options,
  );
}
