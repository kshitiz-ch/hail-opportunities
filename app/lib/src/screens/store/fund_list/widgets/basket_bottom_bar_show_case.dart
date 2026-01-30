import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class BasketBottomBarShowCase extends StatelessWidget {
  const BasketBottomBarShowCase({
    Key? key,
    required this.showCaseController,
    required this.dynamicWidget,
    required this.onClickFinished,
  }) : super(key: key);

  final ShowCaseController showCaseController;
  final Widget dynamicWidget;
  final Function onClickFinished;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId != showCaseIds.AddFundMainButton.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              onClickFinished();
            });
            return SizedBox();
          }

          return ShowCaseWidget(
            disableScaleAnimation: true,
            disableBarrierInteraction: false,
            onStart: (index, key) {},
            onFinish: () async {
              await showCaseController.setActiveShowCase();
              onClickFinished();
            },
            builder: (context) {
              return dynamicWidget;
              // return AnimatedSwitcher(
              //   duration: Duration(milliseconds: 250),
              //   child: dynamicWidget,
              // );
            },
          );
        });
  }
}
