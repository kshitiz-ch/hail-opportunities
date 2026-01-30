import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/screens/proposals/delete_proposal/view/delete_proposal_bottomsheet.dart';
import 'package:app/src/screens/proposals/proposal_details/widgets/copy_proposal_link_button.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalCardNew extends StatelessWidget {
  final ProposalModel? proposal;
  final int? index;
  final bool showProposalActions;
  final bool isEmployeeFlow;

  const ProposalCardNew(
      {this.proposal,
      this.index,
      this.showProposalActions = true,
      this.isEmployeeFlow = false});

  @override
  Widget build(BuildContext context) {
    if (proposal == null) return SizedBox();
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "proposal_card_click",
          screen: 'proposals',
          screenLocation: 'proposal_card',
        );

        AutoRouter.of(context).push(
          ProposalDetailsRoute(
              proposal: proposal,
              showProposalActions: showProposalActions,
              isEmployeeFlow: isEmployeeFlow),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProposalDetails(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: ColorConstants.borderColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatusClientDetails(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: ColorConstants.borderColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CopyProposalLinkButton(
                customerUrl: proposal?.customerUrl ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalDetails(BuildContext context) {
    String displayName = proposal?.displayName ?? '';
    if (displayName.isNullOrEmpty) {
      displayName = proposal?.proposalName ?? '';
    }

    String proposalType = proposal?.proposalType ?? '';
    if (proposalType.isNullOrEmpty) {
      proposalType = proposal?.productType?.toTitleCase() ?? '';
    }

    if (proposal?.isWealthcaseProposal == true) {
      displayName = proposal?.basketName ?? '';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
              ),
            ),
            SizedBox(width: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildTopUpCTA(context),
            )
          ],
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                proposalType,
                overflow: TextOverflow.ellipsis,
                style: context.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            ),
            SizedBox(width: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildDeleteCTA(context),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteCTA(BuildContext context) {
    // show delete UI only if proposal canBeMarkedFailure && its not already deleted
    final canDelete =
        (proposal?.canBeMarkedFailure ?? false) && proposal?.isFailed == false;

    if (!canDelete) return SizedBox();

    return InkWell(
      onTap: () {
        CommonUI.showBottomSheet(
          context,
          child: DeleteProposalBottomSheet(proposal: proposal!),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              AllImages().deleteIcon,
              height: 12,
              width: 10,
              // fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Delete',
            style: context.headlineSmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.errorTextColor),
          )
        ],
      ),
    );
  }

  Widget _buildTopUpCTA(BuildContext context) {
    final canTopUp = (showProposalActions) &&
        (proposal?.canTopup ?? false) &&
        proposal?.productType?.toLowerCase() == ProductType.MF &&
        proposal?.productTypeVariant != anyFundGoalSubtype;

    if (!canTopUp) return SizedBox();

    return SizedBox(
      width: 80,
      height: 30,
      child: GetBuilder<MFPortfoliosController>(
        id: GetxId.topUpPortfolios,
        dispose: (_) {
          // Get.delete<MFPortfoliosController>();
        },
        builder: (controller) {
          final showLoader =
              controller.selectedProposalExternalId == proposal?.externalId &&
                  (controller.proposalDetailState == NetworkState.loading ||
                      controller.portfolioDetailState == NetworkState.loading);

          // controller.portfolioDetailState == NetworkState.loading &&
          //     controller.selectedProposalExternalId ==
          //         proposal.externalId;

          return ActionButton(
            customLoader: SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: ColorConstants.primaryAppColor,
              ),
            ),
            showProgressIndicator: showLoader,
            showBorder: true,
            borderColor: ColorConstants.primaryAppColor,
            borderRadius: 50,
            onPressed: () async {
              if (showLoader) {
                return null;
              }

              controller.updateProposalExternalId(proposal?.externalId);
              final proposalDetail = await controller
                  .getUpdatedProposalDetail(proposal!.externalId!);
              if (proposalDetail == null) {
                return showToast(
                    text:
                        'This proposal is not currently available for top up');
              }
              await onTopUpPortfolioClick(
                proposal: proposalDetail,
                controller: controller,
                context: context,
              );
            },
            margin: EdgeInsets.zero,
            bgColor: ColorConstants.secondaryAppColor,
            text: 'Top Up',
            textStyle:
                Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                      color: ColorConstants.primaryAppColor,
                      fontWeight: FontWeight.w700,
                    ),
          );
        },
      ),
    );
  }

  Widget _buildStatusClientDetails(BuildContext context) {
    String paymentStr = proposal?.paymentStatusStr ?? '';
    if (proposal?.isMandate == true) {
      paymentStr = 'Mandate Amount';
    } else if (proposal?.isSip == true) {
      paymentStr = "SIP Amount";
    }
    if (paymentStr.isNullOrEmpty) {
      paymentStr = 'Amount';
    }

    final amountText = proposal?.amount == null
        ? ''
        : proposal?.isWealthcaseProposal == true
            ? WealthyAmount.currencyFormatWithoutTrailingZero(
                proposal?.amount?.round(), 0)
            : WealthyAmount.currencyFormatWithoutTrailingZero(
                proposal?.amount, 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (proposal?.isFailed == true)
                        Icon(
                          Icons.close,
                          color: ColorConstants.redAccentColor,
                        )
                      else
                        Image.asset(
                          proposal?.isCompleted == true
                              ? AllImages().proposalCompletedIcon
                              : AllImages().proposalPendingIcon,
                          height: 20,
                          width: 20,
                        ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            proposal?.statusStr ?? '',
                            maxLines: 2,
                            style: context.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                crossAxisAlignment: CrossAxisAlignment.end,
                title: 'Created on',
                subtitle: getFormattedDate(proposal?.createdAt),
                titleStyle: context.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
                subtitleStyle: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
                gap: 4,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    normaliseName(proposal?.customer?.name ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  _buildCallUI(context),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                crossAxisAlignment: CrossAxisAlignment.end,
                title: '$amountText',
                subtitle: paymentStr,
                titleStyle: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.greenAccentColor,
                ),
                subtitleStyle: context.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
                gap: 4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallUI(BuildContext context) {
    final phoneNo = proposal?.customer?.phoneNumber;

    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "call_now",
          screen: 'proposals',
          screenLocation: 'proposal_card',
        );
        if (phoneNo.isNotNullOrEmpty) {
          callNumber(number: phoneNo);
        } else {
          showToast(
              text: 'Client phone number not available for this proposal');
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.call,
            size: 20,
            color: ColorConstants.primaryAppColor,
          ),
          SizedBox(width: 4),
          Text(
            phoneNo ?? 'NA',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
            ),
          )
        ],
      ),
    );
  }
}
