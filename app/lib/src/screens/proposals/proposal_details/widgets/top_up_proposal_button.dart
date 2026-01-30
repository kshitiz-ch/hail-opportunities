import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpProposalButton extends StatelessWidget {
  const TopUpProposalButton(
      {Key? key, this.proposal, this.shouldDisableButton = false})
      : super(key: key);

  final ProposalModel? proposal;
  final bool shouldDisableButton;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MFPortfoliosController>(
      id: GetxId.topUpPortfolios,
      dispose: (_) {
        // Don't delete as it will cause issue in top-up button of proposal card
        // Get.delete<MFPortfoliosController>();
      },
      builder: (controller) {
        return ActionButton(
          heroTag: kDefaultHeroTag,
          text: 'Top Up Proposal',
          margin: EdgeInsets.zero,
          isDisabled: shouldDisableButton,
          showProgressIndicator:
              controller.portfolioDetailState == NetworkState.loading,
          onPressed: () async {
            await onTopUpPortfolioClick(
              proposal: proposal!,
              context: context,
              controller: controller,
            );
          },
        );
      },
    );
  }
}
