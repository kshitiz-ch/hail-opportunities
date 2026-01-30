import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/screens/clients/client_detail/view/client_detail_screen.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteProposalBottomSheet extends StatelessWidget {
  final ProposalModel proposal;

  const DeleteProposalBottomSheet({
    super.key,
    required this.proposal,
  });

  @override
  Widget build(BuildContext context) {
    // delete functionality via client detail screen proposal list || proposal detail screen from client detail screen
    final tag = isPageAtTopStack(context, ClientDetailRoute.name) ||
            isRouteParentOfCurrent(context, ClientDetailRoute.name)
        ? clientProposalControllerTag
        : null;
    return GetBuilder<ProposalsController>(
      id: GetxId.deleteProposal,
      tag: tag,
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please choose a reason for deleting the proposal ?',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 50),
                child: RadioButtons(
                  spacing: 25,
                  runSpacing: 0,
                  direction: Axis.vertical,
                  items: proposal.possibleFailureReasons,
                  selectedValue: controller.deleteReason,
                  onTap: (value) {
                    FocusScope.of(context).unfocus();
                    controller.updateDeleteReason(value);
                  },
                ),
              ),
              ActionButton(
                heroTag: kDefaultHeroTag,
                margin: EdgeInsets.zero,
                isDisabled: controller.deleteReason == null,
                text: 'Confirm Delete',
                onPressed: () async {
                  await controller.deleteProposal(proposal);

                  if (controller.deleteProposalResponse.state ==
                      NetworkState.error) {
                    return showToast(
                      context: context,
                      text: controller.deleteProposalResponse.message,
                    );
                  }

                  if (controller.deleteProposalResponse.state ==
                      NetworkState.loaded) {
                    showToast(
                      context: context,
                      text: 'Proposal deleted successfully',
                    );

                    AutoRouter.of(context)
                        .popUntil(ModalRoute.withName(BaseRoute.name));

                    controller.getProposals();
                  }
                },
                showProgressIndicator:
                    controller.deleteProposalResponse.state ==
                        NetworkState.loading,
              ),
            ],
          ),
        );
      },
    );
  }
}
