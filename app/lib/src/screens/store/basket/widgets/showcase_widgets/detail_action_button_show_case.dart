import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class DetailActionButtonShowCase extends StatelessWidget {
  const DetailActionButtonShowCase({
    Key? key,
    // this.basketController,
    this.showCaseController,
    this.onClickFinished,
  }) : super(key: key);

  final ShowCaseController? showCaseController;
  // final BasketController basketController;
  final Null Function({bool? navigateToSelectClient})? onClickFinished;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId !=
              showCaseIds.BasketDetailContinue.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              onClickFinished!();
            });
            return SizedBox();
          }

          return ShowCaseWidget(
            disableScaleAnimation: true,
            disableBarrierInteraction: false,
            onStart: (index, key) {},
            onFinish: () async {
              if (showCaseController!.activeShowCaseId ==
                  showCaseIds.BasketDetailContinue.id) {
                await showCaseController!.setActiveShowCase();
                onClickFinished!(navigateToSelectClient: false);
              }
            },
            builder: (context) {
              return ShowCaseWrapper(
                currentShowCaseId: showCaseIds.BasketDetailContinue.id,
                minRadius: 24,
                maxRadius: 44,
                constraints: BoxConstraints(
                  maxHeight: 70,
                  minHeight: 50,
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
                  onClickFinished!(navigateToSelectClient: true);
                },
                child: ActionButton(
                  height: 48,
                  text: 'Select Client',
                  margin: EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 34.0,
                  ),
                  borderRadius: 30.0,
                  onPressed: () async {
                    if (showCaseController!.activeShowCaseId ==
                        showCaseIds.BasketDetailContinue.id) {
                      await showCaseController!.setActiveShowCase();
                      onClickFinished!(navigateToSelectClient: true);
                    }
                  },
                ),
              );
            },
          );
        });
  }
}
