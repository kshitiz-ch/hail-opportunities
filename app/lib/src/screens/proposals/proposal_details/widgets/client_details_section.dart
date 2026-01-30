import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/proposal/proposal_detail_controller.dart';
import 'package:app/src/screens/proposals/proposal_details/widgets/portfolio_client_details_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class ClientDetailsSection extends StatelessWidget {
  const ClientDetailsSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 16,
          ),
          child: Text(
            'Client Details',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        GetBuilder<ProposalDetailController>(
          id: 'proposal',
          builder: (controller) {
            return controller.proposalDetailState == NetworkState.error
                ? SizedBox(
                    height: 320,
                    child: RetryWidget(
                      controller.proposalErrorMessage,
                      onPressed: () {
                        controller.getProposalDetails(isRetry: true);
                      },
                    ),
                  )
                : controller.proposalDetailState == NetworkState.loading
                    ? PortfolioClientDetailsCard(proposal: controller.proposal)
                        .toShimmer(
                        baseColor: ColorConstants.lightBackgroundColor,
                        highlightColor: ColorConstants.white,
                      )
                    : PortfolioClientDetailsCard(
                        proposal:
                            (controller.proposal!.isSwitchTrackerProposal ||
                                    controller.proposal!.isDematProposal)
                                ? controller.proposal
                                : controller.proposalDetail,
                      );
          },
        )
      ],
    );
  }
}
