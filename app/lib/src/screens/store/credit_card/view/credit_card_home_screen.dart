import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/credit_card/credit_cards_controller.dart';
import 'package:app/src/screens/store/credit_card/widgets/credit_card_banner.dart';
import 'package:app/src/screens/store/credit_card/widgets/credit_card_summary.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

@RoutePage()
class CreditCardHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
      appBar: CustomAppBar(
        titleText: 'Credit Cards',
        subtitleText: 'Best Deals for your clients',
        showBackButton: true,
      ),
      body: GetBuilder<CreditCardsController>(
          init: CreditCardsController(),
          dispose: (_) => Get.delete<CreditCardsController>(),
          builder: (controller) {
            if (controller.showLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  CreditCardSummary(),
                  _buildExploreCreditCardInfoSection(context),
                  // Apply Now
                  ActionButton(
                    text: 'Apply Now',
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    onPressed: () async {
                      await controller.getCreditCardProposalUrl(context);
                      if (controller.proposalUrlState == NetworkState.loaded) {
                        if (controller.proposalUrl.isNotNullOrEmpty) {
                          AutoRouter.of(context).push(
                            CreditCardWebViewRoute(
                              url: controller.proposalUrl,
                              onNavigationRequest: (
                                InAppWebViewController controller,
                                NavigationAction action,
                              ) async {
                                final navigationUrl =
                                    action.request.url.toString();
                                LogUtil.printLog(
                                    ' onNavigationRequest navigationUrl==>$navigationUrl');
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
                              onWebViewExit: () {
                                AutoRouter.of(context).popForced();
                                // update summary data in case application is submitted
                                controller.getCreditCardSummary();
                              },
                            ),
                          );
                        }
                      } else if (controller.proposalUrlState ==
                          NetworkState.error) {
                        // showToast(text: controller.propo)
                      }
                    },
                  ),
                  CreditCardBanner(),
                  Text(
                    'Choose from huge range of',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Credit Cards from Wealthy',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: ColorConstants.black,
                        ),
                  ),
                  // Explore Card CTA
                  ActionButton(
                    showBorder: true,
                    bgColor: Colors.transparent,
                    borderColor: ColorConstants.primaryAppColor,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.primaryAppColor,
                        ),
                    text: 'Explore Cards',
                    margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    onPressed: () {
                      final url =
                          controller.creditCardPromotionModel?.library?.url;
                      if (url.isNotNullOrEmpty) {
                        AutoRouter.of(context).push(
                          CreditCardWebViewRoute(
                              onNavigationRequest: (
                                InAppWebViewController controller,
                                NavigationAction action,
                              ) async {
                                final navigationUrl =
                                    action.request.url.toString();
                                LogUtil.printLog(
                                    ' onNavigationRequest navigationUrl==>$navigationUrl');
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
                              url: url,
                              onWebViewExit: () {
                                AutoRouter.of(context).popForced();
                              }),
                        );
                      }
                    },
                  ),
                  _buildLandingImage(),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildExploreCreditCardInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Explore Credit Cards',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black,
              ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40).copyWith(
            top: 12,
            bottom: 22,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Check out the best cards available from ",
              style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                    height: 16 / 12,
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: '55+',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.black,
                        height: 16 / 12,
                      ),
                ),
                TextSpan(
                  text: " credit cards based on your client's credit score",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.tertiaryBlack,
                        height: 16 / 12,
                      ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 26).copyWith(bottom: 16),
          child: _buildCreditCardProviderIconList(),
        ),
        Text(
          'Choose from Top Credit Card Providers',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.tertiaryBlack,
              ),
        ),
      ],
    );
  }

  Widget _buildLandingImage() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Image.asset(
        AllImages().creditCardHomeLandingIcon,
        height: 225,
        width: double.infinity,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildCreditCardProviderIconList() {
    final iconList = <String>[
      AllImages().axisBankIcon,
      AllImages().standardChartredBankIcon,
      AllImages().idfcBankIcon,
      AllImages().auBankIcon,
      AllImages().indusIndBankIcon,
      AllImages().sbiBankIcon,
      AllImages().hsbcBankIcon,
    ];

    // TODO: fix below exception which occurs sometime in debug mode
    //  firstIndex == 0 || childScrollOffset(firstChild!)! - scrollOffset <= precisionErrorTolerance
    // is not true in RenderSliverFixedExtentBoxAdaptor
    // Note: no issue found in release mode at UI level

    return CarouselSlider(
      items: iconList
          .map<Widget>(
            (icon) => Image.asset(
              icon,
              height: 42,
              fit: BoxFit.fill,
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: 42,
        aspectRatio: 1,
        viewportFraction: 0.2,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        pauseAutoPlayOnManualNavigate: false,
        pauseAutoPlayOnTouch: false,
        autoPlayInterval: Duration(seconds: 1),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        onPageChanged: (int index, CarouselPageChangedReason reason) {},
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
