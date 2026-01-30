import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_list_filter.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class ApplyButtonShowCase extends StatelessWidget {
  const ApplyButtonShowCase({
    Key? key,
    required this.showCaseWrapperKey,
    required this.onTap,
    this.showCaseController,
    this.onClickFinished,
  }) : super(key: key);

  final Key showCaseWrapperKey;
  final Function onTap;
  final ShowCaseController? showCaseController;
  final Function? onClickFinished;

  @override
  Widget build(BuildContext parentContext) {
    return ShowCaseWidget(
      disableScaleAnimation: true,
      disableBarrierInteraction: false,
      onStart: (index, key) {},
      onFinish: () async {
        if (showCaseController!.activeShowCaseId ==
            showCaseIds.ApplyFilterButton.id) {
          Navigator.pop(parentContext);
        }
      },
      builder: (context) {
        return ShowCaseWrapper(
          key: showCaseWrapperKey,
          currentShowCaseId: showCaseIds.ApplyFilterButton.id,
          minRadius: 8,
          maxRadius: 24,
          constraints: BoxConstraints(
            maxHeight: 64,
            minHeight: 24,
            maxWidth: MediaQuery.of(context).size.width * 0.4,
            minWidth: MediaQuery.of(context).size.width * 0.4 - 20,
          ),
          onTargetClick: () async {
            ShowCaseWidget.of(context).next();
            await onTap();
            onClickFinished!();
          },
          rippleExpandingHeight: 64,
          rippleExpandingWidth: MediaQuery.of(context).size.width * 0.4 + 10,
          child: Container(
            constraints: BoxConstraints(
                maxHeight: 44,
                maxWidth: MediaQuery.of(context).size.width * 0.4 - 10),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                BottomSheetActionButton(
                  text: "Apply",
                  isPrimaryButton: true,
                  onPressed: () async {
                    await onTap();
                    onClickFinished!();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
