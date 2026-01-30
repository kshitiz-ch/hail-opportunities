import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/insurance/insurances_controller.dart';
import 'package:app/src/screens/store/insurance_list/widgets/insurance_card_footer.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class InsuranceCard extends StatefulWidget {
  final InsuranceModel? product;
  final Client? client;
  final bool showGenerateQuoteButton;
  final bool showLottieAnimation;

  InsuranceCard({
    Key? key,
    this.product,
    this.client,
    this.showLottieAnimation = false,
    this.showGenerateQuoteButton = false,
  }) : super(key: key);

  @override
  State<InsuranceCard> createState() => _InsuranceCardState();
}

class _InsuranceCardState extends State<InsuranceCard>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
    _lottieController = AnimationController(vsync: this);
    _lottieController.duration = Duration(seconds: 1);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLottieAnimation && _lottieController.duration != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _lottieController.forward(from: 0);
      });
    }

    final productVariant =
        widget.product!.productVariant.toString().toLowerCase();
    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          InsuranceDetailRoute(
            selectedClient: widget.client,
            insuranceData: widget.product,
            productVariant: productVariant,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insuranceSectionData[productVariant]!['title'],
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                        child: Text(
                          insuranceSectionData[productVariant]!['description'],
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  child: Lottie.asset(
                    insuranceSectionData[productVariant]!['lottie'],
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController..duration = composition.duration;
                    },
                  ),
                ),
                // Image.asset(
                //   insuranceSectionData[productVariant]['image_path'],
                //   alignment: Alignment.center,
                //   height: 96,
                //   width: 96,
                // )
              ],
            ),
            widget.showGenerateQuoteButton
                ? GetBuilder<InsurancesController>(
                    id: GetxId.createProposal,
                    builder: (controller) {
                      return SizedBox(
                        width: 130,
                        child: ActionButton(
                          height: 40,
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.white,
                              ),
                          margin: EdgeInsets.zero,
                          text: 'Create Quotes',
                          onPressed: () async {
                            bool viaWebView = webViewEnabledProductVariants
                                .contains(widget.product!.productVariant);

                            bool isSavingsOrTermInsurance =
                                widget.product!.productVariant ==
                                        InsuranceProductVariant.TERM ||
                                    widget.product!.productVariant ==
                                        InsuranceProductVariant.SAVINGS;

                            // Temporary Hack
                            if (isSavingsOrTermInsurance) {
                              viaWebView = (await controller
                                      .shouldOpenWebView(productVariant))! &&
                                  !SizeConfig().isTabletDevice;
                            }

                            await controller.getProposalUrl(
                                context, widget.product!,
                                viaWebView: viaWebView);

                            if (viaWebView &&
                                controller.proposalUrlState ==
                                    NetworkState.loaded) {
                              if (!isPageAtTopStack(
                                  context, InsuranceWebViewRoute.name)) {
                                bool shouldHandleAppBar =
                                    !isSavingsOrTermInsurance;

                                AutoRouter.of(context).push(
                                  InsuranceWebViewRoute(
                                    url: controller.proposalUrl,
                                    shouldHandleAppBar: shouldHandleAppBar,
                                    onNavigationRequest: (
                                      InAppWebViewController controller,
                                      NavigationAction action,
                                    ) async {
                                      final navigationUrl =
                                          action.request.url.toString();
                                      if (isSavingsOrTermInsurance &&
                                          navigationUrl.contains(
                                              "applinks.buildwealth.in")) {
                                        if (navigationUrl ==
                                            "https://applinks.buildwealth.in/proposals") {
                                          navigateToProposalScreen(context);
                                        } else {
                                          AutoRouter.of(context).popForced();
                                        }
                                        return NavigationActionPolicy.CANCEL;
                                      } else {
                                        return NavigationActionPolicy.ALLOW;
                                      }
                                    },
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  )
                : InsuranceCardFooter(
                    productVariant: productVariant,
                    imageRadius: 18,
                    title: 'Explore products',
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.primaryAppColor,
                            ),
                  ),
          ],
        ),
      ),
    );
  }
}
