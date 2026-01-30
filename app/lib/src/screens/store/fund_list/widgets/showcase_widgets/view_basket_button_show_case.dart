import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class ViewBasketButtonShowCase extends StatelessWidget {
  ViewBasketButtonShowCase(
      {Key? key, this.showCaseController, this.onClickFinished})
      : super(key: key);

  final ShowCaseController? showCaseController;
  final Function({bool? navigateToOverview})? onClickFinished;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId != showCaseIds.ViewBasketButton.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              onClickFinished!();
            });
            return SizedBox();
          }

          return SizedBox(
            width: 200,
            height: 70,
            child: ShowCaseWidget(
              disableScaleAnimation: true,
              disableBarrierInteraction: false,
              onStart: (index, key) {},
              onFinish: () async {
                if (showCaseController!.activeShowCaseId ==
                    showCaseIds.ViewBasketButton.id) {
                  await showCaseController!.setActiveShowCase();
                  onClickFinished!(navigateToOverview: false);
                }
              },
              builder: (context) {
                return ShowCaseWrapper(
                  currentShowCaseId: showCaseIds.ViewBasketButton.id,
                  minRadius: 24,
                  maxRadius: 44,
                  constraints: BoxConstraints(
                    maxHeight: 70,
                    minHeight: 50,
                    maxWidth: 200,
                    minWidth: 180,
                  ),
                  onTargetClick: () async {
                    await showCaseController!.setActiveShowCase();
                    ShowCaseWidget.of(context).next();
                    onClickFinished!(navigateToOverview: true);
                  },
                  child: SizedBox(
                    width: 180,
                    child: ActionButton(
                      margin: EdgeInsets.zero,
                      text: 'View Basket',
                      height: 56,
                      onPressed: () async {
                        if (showCaseController!.activeShowCaseId ==
                            showCaseIds.ViewBasketButton.id) {
                          await showCaseController!.setActiveShowCase();
                          onClickFinished!(navigateToOverview: false);
                        }
                      },
                      textStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            color: ColorConstants.white,
                          ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
