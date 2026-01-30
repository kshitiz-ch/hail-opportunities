import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void handleDeepLink(Uri? uri, BuildContext context) async {
  if (uri != null &&
      uri.query.contains("auth_code") &&
      uri.query.contains("is_half_agent")) {
    navigateToHalfAgentFlow(context, uri);
    return;
  }

  if (uri == null || uri.path.isNullOrEmpty) return;

  String urlPath = uri.path;

  // Remove slash from the url end, if present
  if (urlPath.endsWith("/")) {
    urlPath = urlPath.substring(0, urlPath.length - 1);
  }

  _navigateToDeeplinkScreen(urlPath, context);
  return;

  // Check if a showcase currently visible
  // If so, call setActiveShowCase to hide the showcase
  if (Get.isRegistered<ShowCaseController>()) {
    ShowCaseController showCaseController = Get.find<ShowCaseController>();
    if (showCaseController.isShowCaseVisibleCurrently) {
      showCaseController.setActiveShowCase();
    }
  }

  if (urlPath.contains("")) {}

  if (isDeepLinkExists(path: urlPath)) {
    String queryParams = '';

    if (uri.query.isNotNullOrEmpty) {
      queryParams = '?${uri.query}';
    }
    String currentPath = AutoRouter.of(context).currentPath;
    RouteData? currentChild = AutoRouter.of(context).currentChild;

    if (currentPath == urlPath && queryParams.isEmpty) {
      // Don't do anything
    } else if ((currentPath == urlPath && queryParams.isNotEmpty) ||
        isDeepLinkCurrentPath(currentChild!, urlPath)) {
      AutoRouter.of(context).popForced();
      await Future.delayed(Duration(milliseconds: 1000));
      MixPanelAnalytics.trackWithAgentId(urlPath,
          screen: urlPath, screenLocation: "deeplink");
      AutoRouter.of(context).pushNamed(urlPath + queryParams);
    } else {
      MixPanelAnalytics.trackWithAgentId(urlPath,
          screen: urlPath, screenLocation: "deeplink");

      AutoRouter.of(context).pushNamed(urlPath + queryParams);
    }
  } else {
    final currentPath = AutoRouter.of(context).currentPath;
    if (currentPath != AppRouteName.baseScreen) {
      AutoRouter.of(context).pushNamed(AppRouteName.baseScreen);
    }
  }
}

_navigateToDeeplinkScreen(String url, BuildContext context) {
  try {
    // Sample Url
    // https://mylinks.wlthy.in/advisors/$ntype/$aggregateId/
    List pathParams = url.split("/");

    String ntype = pathParams[pathParams.length - 2];
    String aggregateId = pathParams.last;

    bool isUserOnBaseScreen =
        AutoRouter.of(context).stack.last.name == BaseRoute.name;

    if (!isUserOnBaseScreen) {
      AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
    }

    AutoRouter.of(context).push(
      DeeplinkLoaderRoute(ntype: ntype, aggregateId: aggregateId),
    );
  } catch (error) {
    print(error);
  }
}

void navigateToHalfAgentFlow(BuildContext context, Uri uri) async {
  String? authCode =
      Uri.decodeComponent(uri.queryParameters['auth_code'] ?? '');
  String currentPath = AutoRouter.of(context).currentPath;
  if (currentPath == AppRouteName.loginHalfAgentScreen) {
    AutoRouter.of(context).popForced();
    await Future.delayed(Duration(milliseconds: 1000));
  }

  AutoRouter.of(context).push(LoginHalfAgentRoute(authCode: authCode));
}

bool isDeepLinkCurrentPath(RouteData currentChild, String deepLinkPath) {
  List splitUrlBySlash = currentChild.path.split("/");
  String endPath = splitUrlBySlash.last;
  if (endPath.isNotNullOrEmpty) {
    bool isEndPathUrlParam = endPath[0] == ":";
    if (isEndPathUrlParam) {
      return deepLinkPath.contains(currentChild.path.split(":").first);
    }
  }

  return false;
}

bool isDeepLinkExists({required String path}) {
  List<String> deepLinkPathList = [
    // Home
    AppRouteName.universalSearchScreen,
    AppRouteName.rewardDetailScreen,
    AppRouteName.notificationScreen,
    AppRouteName.completeKycScreen,
    AppRouteName.profileScreen,

    // Advisor
    AppRouteName.revenueSheetScreen,
    AppRouteName.payoutScreen,
    AppRouteName.brokingScreen,
    AppRouteName.partnerNomineeScreen,
    AppRouteName.empanelmentScreen,
    AppRouteName.kycStatusScreen,

    // Store
    AppRouteName.mfListScreen,
    AppRouteName.fundDetailScreen,
    AppRouteName.mfLobbyScreen,
    AppRouteName.trackerListScreen,
    AppRouteName.creativesScreen,
    AppRouteName.storeScreen,
    AppRouteName.storeSgbScreen,
    AppRouteName.storeDematScreen,
    AppRouteName.pmsProviderListScreen,
    AppRouteName.debentureListScreen,
    AppRouteName.creditCardListScreen,
    AppRouteName.fixedDepositListScreen,
    AppRouteName.nfoDetailScreen,
    AppRouteName.topFundsNfoScreen,
    AppRouteName.curatedFundsScreen,

    // Insurance
    AppRouteName.insuranceListScreen,
    AppRouteName.insuranceDetailScreen,
    AppRouteName.preIPOListScreen,

    // Proposals
    AppRouteName.proposalListScreen,
    AppRouteName.proposalDetailsScreen,

    // Clients
    AppRouteName.clientDetailScreen,
    AppRouteName.clientListScreen,
    AppRouteName.reportScreen,
    AppRouteName.soaDownloadScreen,
    AppRouteName.businessReportTemplateScreen,
    AppRouteName.sipBookScreen,

    // Media
    AppRouteName.videoScreen,
    AppRouteName.storyScreen,
    AppRouteName.wealthAcademyScreen,
    AppRouteName.wealthAcademyPlaylistScreen,
    AppRouteName.eventDetailScreen,

    // Support
    AppRouteName.faqScreen,
    AppRouteName.supportScreen,

    // Newsletter
    AppRouteName.newsLetterScreen,
    AppRouteName.newsLetterDetailScreen,

    // My business
    AppRouteName.myBusinessScreen,
  ];

  return path.isNotNullOrEmpty &&
      deepLinkPathList.any(
        (element) {
          if (path == element) {
            return true;
          }

          // check if path has url param at the end
          List splitUrlBySlash = element.split("/");
          String endPath = splitUrlBySlash.last;
          if (endPath.isNotNullOrEmpty) {
            bool isEndPathUrlParam = endPath[0] == ":";

            if (isEndPathUrlParam) {
              element = element.split(':').first;
              return path.contains(element);
            }
          }
          return path == element;
        },
      );
}
