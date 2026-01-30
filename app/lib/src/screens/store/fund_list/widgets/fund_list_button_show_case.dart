import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class FundListButtonShowCase extends StatelessWidget {
  const FundListButtonShowCase({
    Key? key,
    this.textFieldKey,
    this.showCaseController,
    this.onTargetClick,
    this.child,
  }) : super(key: key);
  final Key? textFieldKey;
  final ShowCaseController? showCaseController;
  final Function? onTargetClick;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    late FundsController fundsController;
    if (Get.isRegistered<FundsController>()) {
      fundsController = Get.find<FundsController>();
    }
    return ShowCaseWidget(
      disableScaleAnimation: true,
      disableBarrierInteraction: false,
      onStart: (index, key) {},
      onFinish: () async {
        await showCaseController!.setActiveShowCase();
        fundsController.update(['funds', 'search']);
      },
      builder: (context) {
        return Container(
          height: 52,
          width: 92,
          child: ShowCaseWrapper(
              key: textFieldKey,
              currentShowCaseId: showCaseIds.MutualFundAddButton.id,
              minRadius: 5,
              maxRadius: 10,
              constraints: BoxConstraints(
                maxHeight: 52,
                minHeight: 35,
                maxWidth: 92,
                minWidth: 72,
              ),
              onTargetClick: () async {
                await showCaseController!.setActiveShowCase();
                onTargetClick!();
                fundsController.update(['funds', 'search']);
              },
              child: child),
        );
      },
    );
  }
}
