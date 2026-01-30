import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/filter_action_buttons.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class FilterButtonShowCase extends StatelessWidget {
  const FilterButtonShowCase({
    Key? key,
    required this.showCaseWrapperKey,
    required this.onShowCaseTap,
    this.showCaseController,
    this.onClickFinished,
  }) : super(key: key);

  final Key showCaseWrapperKey;
  final Function onShowCaseTap;
  final ShowCaseController? showCaseController;
  final Function? onClickFinished;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      disableScaleAnimation: true,
      disableBarrierInteraction: false,
      onStart: (index, key) {},
      onFinish: () async {
        if (showCaseController!.activeShowCaseId ==
            showCaseIds.FilterFunds.id) {
          //* calling it twice as to skip the step of sheet open (check showCaseList)
          await showCaseController!.setActiveShowCase();
          await showCaseController!.setActiveShowCase();
          onClickFinished!();
        }
      },
      builder: (context) {
        return ShowCaseWrapper(
          key: showCaseWrapperKey,
          currentShowCaseId: showCaseIds.FilterFunds.id,
          minRadius: 4,
          maxRadius: 8,
          constraints: BoxConstraints(
            maxHeight: 34,
            minHeight: 24,
            maxWidth: 125,
            minWidth: 40,
          ),
          extraSpacing: EdgeInsets.only(right: 0),
          onTargetClick: () async {
            ShowCaseWidget.of(context).next();
            await onShowCaseTap();
            onClickFinished!();
          },
          rippleExpandingHeight: 34,
          rippleExpandingWidth: 125,
          child: FilterButtons(onShowCaseTap: onShowCaseTap),
        );
      },
    );
  }
}
