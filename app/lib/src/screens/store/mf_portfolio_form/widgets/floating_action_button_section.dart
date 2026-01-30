import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/similar_proposals_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FloatingActionButtonSection extends StatelessWidget {
  const FloatingActionButtonSection({
    Key? key,
    required this.portfolio,
    required this.isMicroSIP,
    required this.isSmartSwitch,
  }) : super(key: key);

  final GoalSubtypeModel portfolio;
  final bool isMicroSIP;
  final bool isSmartSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.darkBlack.withOpacity(0.1),
            blurRadius: 10.0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMicroSIP)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildMicroSipBasketSummary(context),
                    ),
                  ),
                Expanded(
                  child: _buildActionButton(context),
                ),
              ],
            ),
          ),
          if (isMicroSIP)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: CommonUI.buildProfileDataSeperator(
                color: ColorConstants.borderColor,
              ),
            ),
          if (isMicroSIP)
            Center(
              child: ClickableText(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                text: 'Add More Fund',
                onClick: () {
                  AutoRouter.of(context).popForced();
                },
              ),
            ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'action-button',
      dispose: (state) {
        state.controller!.resetMfForm();
      },
      builder: (controller) {
        return ActionButton(
          heroTag: kDefaultHeroTag,
          showProgressIndicator:
              controller.userMandateState == NetworkState.loading,
          text: controller.fromClientScreen ? 'Proceed' : 'Select Client',
          isDisabled: controller.disableActionButton,
          margin: EdgeInsets.zero,
          borderRadius: 30.0,
          onPressed: () {
            if (controller.fromClientScreen &&
                !controller.selectedClient?.isProposalEnabled) {
              CommonUI.showBottomSheet(
                context,
                child: ClientNonIndividualWarningBottomSheet(),
              );
              return;
            }

            bool isFormValid =
                controller.formKey.currentState?.validate() ?? true;
            if (isMicroSIP) {
              isFormValid =
                  controller.microSipFormKey.currentState?.validate() ?? true;
            }
            if (controller.investmentType == null) {
              isFormValid = false;
              controller.updateShowSelectInvestmentTypeErrorText(true);
            }
            if (!validateSipFields(controller)) {
              return;
            }
            if (isFormValid) {
              _handleOnPressed(context, controller);
            } else {
              if (controller.scrollController != null &&
                  controller.scrollController!.hasClients) {
                // scroll to bottom
                controller.scrollController!.animateTo(
                  controller.scrollController!.position.maxScrollExtent,
                  duration: Duration(milliseconds: 100),
                  curve: Curves.ease,
                );
              }
            }
          },
        );
      },
    );
  }

  bool validateSipFields(MFPortfolioDetailController controller) {
    if (controller.investmentType == InvestmentType.SIP) {
      if (controller.sipdata.selectedSipDays.isNullOrEmpty) {
        showToast(text: 'Choose SIP days');
        return false;
      } else if (controller.sipdata.isStepUpSipEnabled) {
        if (controller.sipdata.stepUpPercentage.isNullOrZero) {
          showToast(text: 'Choose SIP Step Up Percentage');
          return false;
        }
      } else if (controller.sipdata.startDate == null ||
          controller.sipdata.endDate == null) {
        showToast(text: 'Choose Start and End Date');
        return false;
      }
    }
    return true;
  }

  Widget _buildMicroSipBasketSummary(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.tertiaryBlack,
        );
    final style2 = Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.black,
        );
    return GetBuilder<MFPortfolioDetailController>(
      id: 'basket-summary',
      builder: (basketController) {
        final fundAmount = WealthyAmount.currencyFormat(
            basketController.totalMicroSIPAmount, 0);
        final selectedFunds =
            '${basketController.microSIPBasket.length} Fund${basketController.microSIPBasket.length > 1 ? 's' : ''}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedFunds, style: style),
            SizedBox(height: 5),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Total  ',
                    style: style2.copyWith(
                      color: ColorConstants.tertiaryBlack,
                    ),
                  ),
                  TextSpan(
                    text: fundAmount,
                    style: style2,
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void _handleOnPressed(
    BuildContext context,
    MFPortfolioDetailController controller,
  ) async {
    bool isSip = controller.investmentType == InvestmentType.SIP;
    if (controller.fromClientScreen) {
      // bool isMandateStatusFetched =
      //     controller.userMandateState == NetworkState.loaded;
      // if (controller.selectedClient?.taxyID != null &&
      //     isSip &&
      //     !isMandateStatusFetched) {
      //   await controller.getUserMandateStatus();
      // }

      final totalInvestmentAmount = isMicroSIP
          ? controller.totalMicroSIPAmount
          : controller.allotmentAmount;

      AutoRouter.of(context).push(
        OrderSummaryRoute(
          otherFundSipDetails: controller.sipdata,
          isTopUpPortfolio: controller.isTopUpPortfolio,
          portfolioTitle: portfolio.title,
          totalInvestmentAmount: totalInvestmentAmount,
          funds: isMicroSIP
              ? controller.microSIPBasket.values.toList()
              : controller.fundsResult.schemeMetas,
          isSmartSwitch: isSmartSwitch,
          isMicroSIP: isMicroSIP,
          userMandateStatus: controller.userMandateStatus,
          client: controller.selectedClient,
          investmentType: controller.investmentType,
          sipDay: isSip ? controller.selectedSipDay : null,
          fab: _buildOrderSummaryScreenFab(
            context,
          ),
        ),
      );
    } else {
      AutoRouter.of(context).push(SelectClientRoute(
        checkIsClientIndividual: true,
        lastSelectedClient: controller.selectedClient,
        onClientSelected: (client, isClientNew) {
          // If client is new or client is changed then reset similar proposal list (a list of similar proposals created by the selected client)
          if (isClientNew ||
              (client?.isSourceContacts ?? false) ||
              (client?.taxyID != controller.selectedClient?.taxyID)) {
            controller.similarProposalsList = [];
            controller.hasCheckedSimilarProposals = false;
          }

          if (isClientNew) {
            AutoRouter.of(context).popForced();
          }
          _handleOnClientSelected(controller, client, context);
        },
      ));
    }
  }

  void _handleOnClientSelected(
    MFPortfolioDetailController controller,
    Client? client,
    BuildContext context,
  ) async {
    controller.selectedClient = client;
    controller.userMandateStatus = '';

    bool isSip = controller.investmentType == InvestmentType.SIP;
    // bool isMandateStatusFetched = controller.userMandateStatus!.isNotEmpty;

    // if (controller.selectedClient?.taxyID != null &&
    //     isSip &&
    //     !isMandateStatusFetched) {
    //   await controller.getUserMandateStatus();
    // }

    final totalInvestmentAmount = isMicroSIP
        ? controller.totalMicroSIPAmount
        : controller.allotmentAmount;
    AutoRouter.of(context).push(
      OrderSummaryRoute(
        otherFundSipDetails: controller.sipdata,
        portfolioTitle: portfolio.title,
        isTopUpPortfolio: controller.isTopUpPortfolio,
        totalInvestmentAmount: totalInvestmentAmount,
        funds: isMicroSIP
            ? controller.microSIPBasket.values.toList()
            : controller.fundsResult.schemeMetas,
        isSmartSwitch: isSmartSwitch,
        isMicroSIP: isMicroSIP,
        client: client,
        userMandateStatus: controller.userMandateStatus,
        investmentType: controller.investmentType,
        sipDay: isSip ? controller.selectedSipDay : null,
        fab: _buildOrderSummaryScreenFab(
          context,
        ),
      ),
    );
  }

  Widget _buildOrderSummaryScreenFab(BuildContext context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'create-proposal',
      builder: (controller) {
        return ActionButton(
          margin: EdgeInsets.symmetric(horizontal: 30),
          heroTag: kDefaultHeroTag,
          text: 'Send to Client',
          showProgressIndicator:
              controller.createProposalState == NetworkState.loading,
          onPressed: () async {
            // Check if kyc is approved
            int? agentKycStatus = await getAgentKycStatus();
            if (agentKycStatus != AgentKycStatus.APPROVED) {
              CommonUI.showBottomSheet(context,
                  child: ProposalKycAlertBottomSheet());
              return null;
            }

            // Create Proposal
            await controller.createProposal(
              isMicroSIP: isMicroSIP,
            );

            if (controller.createProposalState == NetworkState.loaded) {
              AutoRouter.of(context).push(ProposalSuccessRoute(
                proposalUrl: controller.proposalUrl,
                client: controller.selectedClient,
                productName: portfolio.title,
                expiryTime: portfolio.expiryTime,
                isBankAdded: true,
                isDematAdded: false,
              ));
            } else {
              if (controller.similarProposalsList.length > 0) {
                return CommonUI.showBottomSheet(
                  context,
                  child: SimilarProposalsList(
                    submitButtonWidget:
                        _buildSimilarProposalProceedButton(context),
                    similarProposalList: controller.similarProposalsList,
                    client: controller.selectedClient,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildSimilarProposalProceedButton(context) {
    return GetBuilder<MFPortfolioDetailController>(
      id: 'create-proposal',
      builder: (controller) {
        return ActionButton(
          text: 'Continue',
          margin: EdgeInsets.zero,
          showProgressIndicator:
              controller.createProposalState == NetworkState.loading,
          onPressed: () async {
            await controller.createProposal(fromSimilarProposalsList: true);

            if (controller.createProposalState == NetworkState.loaded) {
              AutoRouter.of(context).push(ProposalSuccessRoute(
                proposalUrl: controller.proposalUrl,
                client: controller.selectedClient,
                productName: portfolio.title,
                expiryTime: portfolio.expiryTime,
                isBankAdded: true,
                isDematAdded: false,
              ));
            }
          },
        );
      },
    );
  }
}
