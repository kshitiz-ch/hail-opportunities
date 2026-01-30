import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/home/universal_search_controller.dart';
import 'package:app/src/screens/home/universal_search/widgets/recent_search.dart';
import 'package:app/src/screens/home/widgets/quick_action_section.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'recent_clients.dart';
import 'wealthy_ai_card.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentSearch(),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WealthyAiCard(),
                  SizedBox(height: 10),
                  _buildProducts(context),
                  RecentClients(),
                  SizedBox(height: 10),
                  QuickActionSection(fromSmartSearch: true),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWealthyAiCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AllImages().wealthyAiLogo, width: 68),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your AI partner for all your product related questions.',
                  style: context.titleLarge!
                      .copyWith(color: Colors.white, height: 1.5),
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  UniversalSearchController controller =
                      Get.find<UniversalSearchController>();

                  final options = ChromeSafariBrowserSettings(
                    toolbarBackgroundColor: ColorConstants.black,
                    enableUrlBarHiding: true,
                    instantAppsEnabled: true,
                    barCollapsingEnabled: true,
                    preferredBarTintColor: ColorConstants.primaryAppColor,
                    preferredControlTintColor: ColorConstants.white,
                  );

                  // Open In App Browser
                  final browser = KycBrowser(
                    onExit: () async {
                      // await onExitKYCBrowser(context);
                    },
                  );
                  final wealthyAiUri = Uri.parse(Uri.encodeFull(
                      "https://aiapis.wealthy.in/login-redirect/?token=vCB1su2xbLkwsT5uu9gBdQ"));

                  browser.open(
                    url: WebUri.uri(wealthyAiUri),
                    settings: options,
                  );
                  // AutoRouter.of(context).push(
                  //   InsuranceWebViewRoute(
                  //     url: controller.wealthyAiUrl,
                  //     shouldHandleAppBar: true,
                  //     // onNavigationRequest: (
                  //     //   InAppWebViewController controller,
                  //     //   NavigationAction action,
                  //     // ) async {
                  //     //   final navigationUrl = action.request.url.toString();
                  //     //   if (isSavingsOrTermInsurance &&
                  //     //       navigationUrl.contains("applinks.buildwealth.in")) {
                  //     //     if (navigationUrl ==
                  //     //         "https://applinks.buildwealth.in/proposals") {
                  //     //       navigateToProposalScreen(context);
                  //     //     } else {
                  //     //       AutoRouter.of(context).popForced();
                  //     //     }
                  //     //     return NavigationActionPolicy.CANCEL;
                  //     //   } else {
                  //     //     return NavigationActionPolicy.ALLOW;
                  //     //   }
                  //     // },
                  //   ),
                  // );
                },
                child:
                    SvgPicture.asset(AllImages().wealthyAiButton, width: 100),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMutualFunds(BuildContext context) {
    Map<String, dynamic> primaryAmcList = {
      'Axis': {'image_path': AllImages().axisBankMFIcon, 'filter_code': 'axs'},
      'ICICI': {'image_path': AllImages().iciciMFIcon, 'filter_code': 'ici'},
      'SBI': {'image_path': AllImages().sbiMFIcon, 'filter_code': 'sbi'},
      'UTI': {'image_path': AllImages().utiMFIcon, 'filter_code': 'uti'},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Mutual Funds',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(
          height: 16,
        ),
        SingleChildScrollView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: primaryAmcList.keys
                .map(
                  (String amcName) => InkWell(
                    onTap: () {
                      MixPanelAnalytics.trackWithAgentId(
                        "top_mf_category_click",
                        screen: 'smart_search',
                        screenLocation: 'top_mutual_funds',
                        properties: {"amc_name": amcName},
                      );

                      AutoRouter.of(context).push(
                        MfListRoute(
                          amc: primaryAmcList[amcName]['filter_code'],
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      height: 48,
                      decoration: BoxDecoration(
                        color: ColorConstants.white,
                        border: Border.all(color: ColorConstants.borderColor),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      constraints: BoxConstraints(minWidth: 110),
                      padding: EdgeInsets.fromLTRB(8, 8, 16, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage(
                                  primaryAmcList[amcName]['image_path'],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Center(
                              child: Text(
                                amcName,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: ColorConstants.black,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProducts(BuildContext context) {
    List<Map<String, dynamic>> products = [
      {
        'name': 'Mutual Funds',
        'image': AllImages().storeMfIcon,
        'screen': MfListRoute(),
      },
      {
        'name': 'Wealthy Portfolio',
        'image': AllImages().storeWealthyPortfolioIcon,
        'screen': MfPortfolioListRoute(),
      },
      {
        'name': 'Pre IPOs',
        'image': AllImages().storePreIpoIcon,
        'ntype': 'sbi',
        'screen': PreIpoListRoute(),
      },
      {
        'name': 'Insurance',
        'image': AllImages().storeInsuranceIcon,
        'screen': InsuranceHomeRoute(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            // viewportFraction: 0.5,
            itemCount: products.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = products[index];

              return Container(
                margin: EdgeInsets.only(right: 20),
                width: 70,
                // constraints: BoxConstraints(maxWidth: 70),
                // padding: const EdgeInsets.symmetric(horizontal: 6.5),
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(21),
                //     color: ColorConstants.primaryCardColor),
                child: InkWell(
                  onTap: () {
                    MixPanelAnalytics.trackWithAgentId(
                      product['name'].toLowerCase().split(" ").join("_"),
                      screen: 'smart_search',
                      screenLocation: 'products',
                    );

                    AutoRouter.of(context).push(product['screen']);
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        padding: EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(20),
                        //   border: Border.all(
                        //     color: ColorConstants.black.withOpacity(0.1),
                        //   ),
                        // ),
                        child: Image.asset(
                          product['image'],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: product['name'],
                          style:
                              Theme.of(context).primaryTextTheme.headlineSmall!,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
