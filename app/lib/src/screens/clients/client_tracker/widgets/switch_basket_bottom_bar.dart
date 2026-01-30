import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/tracker_fund_switch_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwitchBasketBottomBar extends StatelessWidget {
  void navigateToSwitchBasketScreen(BuildContext context) {
    AutoRouter.of(context).push(
      ClientTrackerSwitchBasketRoute(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      child: GetBuilder<ClientTrackerSwitchController>(
        builder: (controller) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: controller.switchBasket.isNotEmpty
                ? addToNonEmptyBasketWidget(
                    context: context,
                    controller: controller,
                  )
                : addEmptyBasketWidget(
                    context: context,
                    controller: controller,
                  ),
          );
        },
      ),
    );
  }

  void openFundSwitchBottomSheet(
    ClientTrackerSwitchController controller,
    BuildContext context,
  ) {
    CommonUI.showBottomSheet(
      context,
      child: TrackerFundSwitchBottomSheet(),
    );
  }

  Widget addEmptyBasketWidget(
      {required BuildContext context,
      required ClientTrackerSwitchController controller}) {
    return ActionButton(
      text: 'Continue',
      isDisabled: controller.selectedTrackerFundIndex < 0 ||
          controller.selectedSwitchFundIndex < 0,
      onPressed: () {
        openFundSwitchBottomSheet(controller, context);
      },
    );
  }

  Widget addToNonEmptyBasketWidget(
      {required BuildContext context,
      required ClientTrackerSwitchController controller}) {
    return Container(
      decoration: BoxDecoration(
          color: ColorConstants.white,
          border: Border(
            top: BorderSide(
              color: ColorConstants.lightGrey,
            ),
          )),
      padding: const EdgeInsets.symmetric(horizontal: 14)
          .copyWith(top: 20, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                margin: EdgeInsets.zero,
                isDisabled: controller.selectedTrackerFundIndex < 0 ||
                    controller.selectedSwitchFundIndex < 0,
                text: 'Add to Basket',
                height: 48,
                onPressed: () {
                  openFundSwitchBottomSheet(controller, context);
                },
              ),
              SizedBox(
                width: 16,
              ),
              ActionButton(
                responsiveButtonMaxWidthRatio: 0.4,
                margin: EdgeInsets.zero,
                bgColor: ColorConstants.secondaryAppColor,
                text: 'View Basket',
                height: 56,
                onPressed: () {
                  navigateToSwitchBasketScreen(context);
                },
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: ColorConstants.primaryAppColor,
                        ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 15),
            child: CommonUI.buildProfileDataSeperator(
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
          Text(
            '${controller.switchBasket.length} Fund${controller.switchBasket.length > 1 ? 's  ' : ' '}',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ],
      ),
    );
  }
}
