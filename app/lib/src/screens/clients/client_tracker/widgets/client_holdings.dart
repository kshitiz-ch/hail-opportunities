import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_tracker_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'scheme_card.dart';

class ClientHoldings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: GetBuilder<ClientTrackerController>(
        builder: (ClientTrackerController controller) {
          if (controller.clientHoldingState == NetworkState.loading) {
            return Container(
              height: 200,
              margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 28.0),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            );
          }
          if (controller.clientHoldingState == NetworkState.error) {
            return SizedBox(
              height: 200,
              child: Center(
                child: RetryWidget(
                  controller.clientHoldingErrorMessage,
                  onPressed: () {
                    controller.getClientHoldingDetails();
                  },
                ),
              ),
            );
          }
          if (controller.clientHoldingState == NetworkState.loaded) {
            if (controller.clientTrackerHoldings.isNullOrEmpty) {
              return Center(
                child: EmptyScreen(
                  message: "No funds found in the client's holding",
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.showSwitchUpdateCard)
                  _buildTrackerSwitchUpdateCard(context, controller),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'External Mutual Fund Holdings',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium
                            ?.copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      InkWell(
                        onTap: () {
                          // Switch_Switch
                          AutoRouter.of(context).push(ClientTrackerSwitchRoute(
                            client: controller.client,
                            clientTrackerHoldings:
                                controller.clientTrackerHoldings,
                          ));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AllImages().trackerSwitchIcon,
                              height: 14,
                              width: 14,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                'Switch',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstants.primaryAppColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.clientTrackerHoldings.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: CommonUI.buildProfileDataSeperator(
                        color: ColorConstants.borderColor,
                      ),
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        if (controller
                                .clientTrackerHoldings[index].schemeMetaModel ==
                            null) {
                          return showToast(text: 'Fund details missing');
                        }

                        final basketController =
                            Get.isRegistered<BasketController>()
                                ? Get.find<BasketController>()
                                : Get.put(BasketController(), permanent: true);
                        AutoRouter.of(context).push(
                          FundDetailRoute(
                            fund: controller
                                .clientTrackerHoldings[index].schemeMetaModel,
                            isTopUpPortfolio: false,
                            // Basket flow is not to be supported
                            showBottomBasketAppBar: false,
                          ),
                        );
                      },
                      child: SchemeCard(
                        clientTrackerFund:
                            controller.clientTrackerHoldings[index],
                      ),
                    );
                  },
                ),
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _buildTrackerSwitchUpdateCard(
      BuildContext context, ClientTrackerController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryCardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Introducing Switch',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.black,
                        ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorConstants.primaryAppColor,
                    width: 1,
                  ),
                  color: Color.fromRGBO(103, 37, 244, 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'new',
                  style:
                      Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.primaryAppColor,
                          ),
                ),
              ),
              Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  controller.disableSwitchUpdateCard();
                },
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: ColorConstants.tertiaryBlack,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'A new feature that allows switching fund from External fund Managers to Wealthy',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          InkWell(
            onTap: () {
              AutoRouter.of(context).push(ClientTrackerSwitchRoute(
                client: controller.client,
                clientTrackerHoldings: controller.clientTrackerHoldings,
              ));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AllImages().trackerSwitchIcon,
                  height: 14,
                  width: 14,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'Try Switch Now',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.primaryAppColor,
                        ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
