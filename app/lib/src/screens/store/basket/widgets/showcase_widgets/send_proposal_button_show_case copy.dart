import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class SendProposalButtonShowCase extends StatelessWidget {
  const SendProposalButtonShowCase({
    Key? key,
    this.showCaseController,
    this.onClickFinished,
  }) : super(key: key);

  final ShowCaseController? showCaseController;
  // final BasketController basketController;
  final Null Function({bool? shouldSendProposal})? onClickFinished;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShowCaseController>(
        id: 'update-showcase-index',
        builder: (controller) {
          if (controller.activeShowCaseId !=
              showCaseIds.SendProposalToClient.id) {
            WidgetsBinding.instance.addPostFrameCallback((t) {
              onClickFinished!();
            });
            return SizedBox();
          }

          return Container(
            height: 70,
            child: ShowCaseWidget(
              disableScaleAnimation: true,
              disableBarrierInteraction: false,
              onStart: (index, key) {},
              onFinish: () async {
                if (showCaseController!.activeShowCaseId ==
                    showCaseIds.SendProposalToClient.id) {
                  await showCaseController!.setActiveShowCase();
                  onClickFinished!(shouldSendProposal: false);
                }
              },
              builder: (context) {
                return ShowCaseWrapper(
                  currentShowCaseId: showCaseIds.SendProposalToClient.id,
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
                    onClickFinished!(shouldSendProposal: true);
                  },
                  child: ActionButton(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    heroTag: kDefaultHeroTag,
                    text: 'Send to Client',
                    onPressed: () async {
                      if (showCaseController!.activeShowCaseId ==
                          showCaseIds.SendProposalToClient.id) {
                        await showCaseController!.setActiveShowCase();
                        onClickFinished!(shouldSendProposal: true);
                      }
                    },
                  ),
                );
              },
            ),
          );
        });
  }
}
