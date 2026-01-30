import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class OverviewContinueButtonShowCase extends StatelessWidget {
  OverviewContinueButtonShowCase({
    Key? key,
    this.basketController,
    this.showCaseController,
    this.onClickFinished,
  }) : super(key: key);

  final ShowCaseController? showCaseController;
  final BasketController? basketController;
  final Function({bool? navigateToBasketDetail})? onClickFinished;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId !=
              showCaseIds.BasketOverviewContinue.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              onClickFinished!();
            });
            return SizedBox();
          }

          return Container(
            height: 60,
            child: ShowCaseWidget(
              disableScaleAnimation: true,
              disableBarrierInteraction: false,
              onStart: (index, key) {},
              onFinish: () async {
                if (showCaseController!.activeShowCaseId ==
                    showCaseIds.BasketOverviewContinue.id) {
                  await showCaseController!.setActiveShowCase();
                  onClickFinished!(navigateToBasketDetail: false);
                }
              },
              builder: (context) {
                return ShowCaseWrapper(
                  currentShowCaseId: showCaseIds.BasketOverviewContinue.id,
                  minRadius: 24,
                  maxRadius: 44,
                  constraints: BoxConstraints(
                    maxHeight: 60,
                    minHeight: 48,
                    // maxWidth: 250,
                    // minWidth: 200
                    maxWidth: deviceSpecificValue(
                        context,
                        MediaQuery.of(context).size.width - 40,
                        MediaQuery.of(context).size.width / 2 + 40),
                    minWidth: deviceSpecificValue(
                        context,
                        MediaQuery.of(context).size.width - 60,
                        MediaQuery.of(context).size.width / 2),
                  ),
                  onTargetClick: () async {
                    await showCaseController!.setActiveShowCase();
                    onClickFinished!(navigateToBasketDetail: true);
                  },
                  child: ActionButton(
                    height: 48,
                    heroTag: kDefaultHeroTag,
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    isDisabled: (basketController?.portfolio?.productVariant ==
                            otherFundsGoalSubtype) &&
                        basketController!.totalAmount <
                            customPortfolioMinAmount,
                    onPressed: () async {
                      if (showCaseController!.activeShowCaseId ==
                          showCaseIds.BasketOverviewContinue.id) {
                        await showCaseController!.setActiveShowCase();
                        onClickFinished!(navigateToBasketDetail: true);
                      }
                    },
                    text: 'Continue',
                  ),
                );
              },
            ),
          );
        });
  }
}
