import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/credit_card/credit_cards_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class CreditCardBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreditCardsController>(
        builder: (CreditCardsController controller) {
      if (controller.creditCardPromotionState == NetworkState.loading) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          height: 300,
          decoration: BoxDecoration(
            color: ColorConstants.lightBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ).toShimmer(
          baseColor: ColorConstants.lightBackgroundColor,
          highlightColor: ColorConstants.white,
        );
      }
      if (controller.creditCardPromotionState == NetworkState.error) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          height: 300,
          child: RetryWidget(
            controller.creditCardPromotionErrorMessage,
            onPressed: () {
              controller.getCreditCardPromotionalDetails();
            },
          ),
        );
      }
      if (controller.creditCardPromotionState == NetworkState.loaded) {
        final imageMap = <String, String?>{
          AllImages().travelCreditCardIcon:
              controller.creditCardPromotionModel?.travelCreditCard?.url,
          AllImages().shoppingCreditCardIcon:
              controller.creditCardPromotionModel?.shoppingCard?.url,
          AllImages().premiumCreditCardIcon:
              controller.creditCardPromotionModel?.topPremiumCard?.url,
        };
        final bannerSwiperCards = imageMap.keys
            .map<Widget>(
              ((imagePath) => _buildBanner(
                    imagePath,
                    () {
                      if (imageMap[imagePath].isNotNullOrEmpty) {
                        AutoRouter.of(context).push(
                          CreditCardWebViewRoute(
                              onNavigationRequest: (
                                InAppWebViewController controller,
                                NavigationAction action,
                              ) async {
                                final navigationUrl =
                                    action.request.url.toString();
                                if (redirectToCreditCardHome(navigationUrl)) {
                                  // go to credit card home page
                                  if (isRouteNameInStack(
                                      context, CreditCardHomeRoute.name)) {
                                    AutoRouter.of(context).popUntil(
                                      ModalRoute.withName(
                                          CreditCardHomeRoute.name),
                                    );
                                  } else {
                                    AutoRouter.of(context).popForced();
                                  }
                                  return NavigationActionPolicy.CANCEL;
                                }
                                return NavigationActionPolicy.ALLOW;
                              },
                              url: imageMap[imagePath],
                              onWebViewExit: () {
                                AutoRouter.of(context).popForced();
                              }),
                        );
                      }
                    },
                  )),
            )
            .toList();
        return Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 52),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Popular Categories',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: bannerSwiperCards,
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox();
    });
  }

  Widget _buildBanner(
    String imagePath,
    Function onTap,
  ) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          imagePath,
          height: 300,
          width: SizeConfig().screenWidth! / 2,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
