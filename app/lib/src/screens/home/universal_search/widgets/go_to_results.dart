import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/ntypes.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoToResults extends StatelessWidget {
  const GoToResults({
    Key? key,
    required this.goToResult,
  }) : super(key: key);

  final UniversalSearchDataModel goToResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goToResult.meta?.displayName ?? 'Go To',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: goToResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              GoToScreenDataModel screenData = goToResult.data![index];

              return InkWell(
                onTap: () {
                  if (!ntypes
                      .contains((screenData.screenName ?? '').toLowerCase())) {
                    return showToast(text: "Coming Soon!");
                  }

                  final NavigationController navController =
                      Get.find<NavigationController>();
                  RemoteMessage message = RemoteMessage(
                    data: {
                      'ntype': screenData.screenName,
                      'wcontext': {
                        'amc': screenData.context?.amc,
                        'product_category': screenData.context?.category,
                        'product_type': screenData.context?.productType
                      }
                    },
                  );

                  PageRouteInfo? widgetToNavigate = navController
                      .pushNotificationHandler(message, context: context);

                  final moduleName = getModuleName(
                      routeName: widgetToNavigate?.routeName ?? '');

                  if (widgetToNavigate != null) {
                    MixPanelAnalytics.trackWithAgentId(
                      "page_viewed",
                      properties: {
                        "page_name": convertRouteToPageName(
                            widgetToNavigate.routeName,
                            ntype: screenData.screenName),
                        "source": "Smart Search",
                        'ntype': screenData.screenName,
                        ...getDefaultMixPanelFields(widgetToNavigate.routeName),
                        if (moduleName.isNotNullOrEmpty)
                          "module_name": moduleName,
                      },
                    );
                    AutoRouter.of(context).push(widgetToNavigate);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (screenData.screenName == "MF-LIST" &&
                        (screenData.context?.amc.isNotNullOrEmpty ?? false))
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: CachedNetworkImage(
                            imageUrl: getAmcLogo(screenData.displayName),
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) {
                              // fallback to new amc logo
                              return CachedNetworkImage(
                                imageUrl: getAmcLogoNew(
                                    screenData.context?.amc ?? ''),
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 32,
                        width: 32,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ColorConstants.black.withOpacity(0.1),
                          ),
                        ),
                        child: Image.asset(
                          getGoToScreenIcon(screenData),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 16),
                        child: Text(
                          screenData.displayName ?? '-',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String getGoToScreenIcon(GoToScreenDataModel screenData) {
    switch ((screenData.screenName ?? '').toLowerCase()) {
      case Ntype.revenueSheet:
        return AllImages().revenueSheetMoreIcon;
      case Ntype.payout:
        return AllImages().payoutIcon;
      case Ntype.broking:
        return AllImages().brokingBusinessMoreIcon;
      case Ntype.clientReports:
        return AllImages().holdingReport;
      case Ntype.advisorProfile:
        return AllImages().profileMore;
      case Ntype.nfo:
        return AllImages().storePreIpoIcon;
      case Ntype.mfList:
        return AllImages().storeMfIcon;
      case Ntype.clientsList:
        return AllImages().clientsCommonIcon;
      case Ntype.advisorTeam:
        return AllImages().myTeamCommonIcon;
      case Ntype.proposalsList:
        return AllImages().proposalsActive;
      case Ntype.mfTracker:
        return AllImages().trackerMore;
      case Ntype.learning:
        return AllImages().learnMore;
      case Ntype.creatives:
        return AllImages().creativesMore;
      case Ntype.sipBook:
        return AllImages().sipBookIcon;
      case Ntype.transactions:
        return AllImages().transactionIcon;
      case Ntype.businessReport:
        return AllImages().businessReportMoreIcon;
      case Ntype.cob:
        return AllImages().cobTransactionIcon;
      case Ntype.faq:
        return AllImages().faqMore;
      case Ntype.support:
        return AllImages().supportMore;
      case Ntype.planner:
        return AllImages().monthlyPlannerIcon;
      case Ntype.soa:
        return AllImages().soaDownloadMoreIcon;
      case Ntype.storeList:
        if (screenData.context?.productType == ProductType.CREDIT_CARD) {
          return AllImages().storeCreditCard;
        } else if (screenData.context?.productType ==
            ProductType.UNLISTED_STOCK) {
          return AllImages().storePreIpoIcon;
        } else if (screenData.context?.productType ==
            ProductType.FIXED_DEPOSIT) {
          return AllImages().storeFdIcon;
        } else if (screenData.context?.productType == ProductType.DEBENTURE) {
          return AllImages().storeDebentureIcon;
        } else if (screenData.context?.productType == ProductType.PMS) {
          return AllImages().storePmsIcon;
        } else if (screenData.context?.productType == ProductType.DEMAT) {
          return AllImages().storeDematIcon;
        } else if (screenData.context?.category ==
            ProductCategoryType.INSURANCE) {
          return AllImages().storeInsuranceIcon;
        }
        return AllImages().storeActive;
      default:
        return AllImages().storeActive;
    }
  }
}
