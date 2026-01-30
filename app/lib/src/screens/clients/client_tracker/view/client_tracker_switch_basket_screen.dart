import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/switch_fund_basket_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientTrackerSwitchBasketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientTrackerSwitchController>(
      builder: (ClientTrackerSwitchController controller) {
        int switchBasketLength = controller.switchBasket.length;
        // final keys = controller.switchBasket.keys.toList();
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Basket',
            subtitleText: 'Your funds are listed here',
            trailingWidgets: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${switchBasketLength} Fund${switchBasketLength > 1 ? "s" : ""}',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                ),
              )
            ],
          ),
          body: controller.switchBasket.isEmpty
              ? Center(
                  child: Text(
                    'No funds available in basket',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(top: 20, bottom: 100),
                  itemCount: switchBasketLength,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 10);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return SwitchFundBasketCard(
                      basketIndex: index,
                    );
                  },
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: controller.switchBasket.isEmpty
              ? ActionButton(
                  text: 'Go Back',
                  onPressed: () {
                    AutoRouter.of(context).popForced();
                  },
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                )
              : ActionButton(
                  onPressed: () async {
                    await controller.sendTrackerSwitchProposal();
                    if (controller.trackerSwitchProposalState ==
                        NetworkState.loaded) {
                      AutoRouter.of(context).push(
                        ProposalSuccessRoute(
                          client: controller.client,
                          productName: '',
                          proposalUrl:
                              controller.clientTrackerSwitchModel?.proposalUrl,
                        ),
                      );
                    } else if (controller.trackerSwitchProposalState ==
                        NetworkState.error) {
                      showToast(
                          text: controller.trackerSwitchProposalErrorMessage);
                    }
                  },
                  showProgressIndicator:
                      controller.trackerSwitchProposalState ==
                          NetworkState.loading,
                  text: 'Share with Client',
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                ),
        );
      },
    );
  }
}
