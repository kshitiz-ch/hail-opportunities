import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/store/basket/widgets/showcase_widgets/send_proposal_button_show_case%20copy.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/button/responsive_button.dart' as Responsive;
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/similar_proposals_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'showcase_widgets/detail_action_button_show_case.dart';

class FloatingActionButtonSectionNew extends StatelessWidget {
  // Fields
  final String? tag;
  final bool fromCustomPortfolios;
  final bool isUpdateProposal;
  final bool isTopUpPortfolio;
  final bool showAddButton;

  // Constructor
  const FloatingActionButtonSectionNew({
    Key? key,
    this.tag,
    required this.fromCustomPortfolios,
    this.isTopUpPortfolio = false,
    this.isUpdateProposal = false,
    required this.showAddButton,
  }) : super(key: key);

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
                Expanded(
                  child: _buildBasketSummary(context),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: isUpdateProposal
                      ? _buildEditProposalCTA(context)
                      : _buildCreateProposalCTA(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: CommonUI.buildProfileDataSeperator(
              color: ColorConstants.borderColor,
            ),
          ),
          if (showAddButton)
            Center(
              child: ClickableText(
                padding: EdgeInsets.only(bottom: 24),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                text: 'Add More Funds',
                onClick: () {
                  onAddMoreFunds(context);
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildActionButton(BasketController controller, BuildContext context,
      {ShowCaseController? showCaseController}) {
    // If top up portfolio, client is already selected
    bool allowSelectClient =
        !((controller.fromClientScreen || controller.isTopUpPortfolio));

    bool displayShowCase = false;
    if (allowSelectClient &&
        showCaseController != null &&
        showCaseController.activeShowCaseId ==
            showCaseIds.BasketDetailContinue.id) {
      displayShowCase = true;
    }

    if (displayShowCase) {
      showCaseController!.setShowCaseVisibleCurrently(true);
      return DetailActionButtonShowCase(
        showCaseController: showCaseController,
        onClickFinished: ({bool? navigateToSelectClient}) {
          controller.update([GetxId.createProposal]);
          if (navigateToSelectClient ?? false) {
            controller.investmentType == null
                ? controller.updateShowSelectInvestmentTypeErrorText(true)
                : _handleOnPressed(controller, context);
          }
        },
      );
    }

    return Responsive.ResponsiveButton(
      child: ActionButton(
        heroTag: kDefaultHeroTag,
        bgColor: ColorConstants.primaryAppColor,
        showProgressIndicator:
            controller.userMandateState == NetworkState.loading,
        text: allowSelectClient ? 'Select Client' : 'Continue',
        margin: EdgeInsets.zero,
        borderRadius: 30.0,
        onPressed: () {
          if (!allowSelectClient &&
              !controller.selectedClient?.isProposalEnabled) {
            CommonUI.showBottomSheet(
              context,
              child: ClientNonIndividualWarningBottomSheet(),
            );
            return;
          }

          if (!(controller.formKey.currentState?.validate() ?? false)) {
            showToast(text: 'Please input valid details');
            return;
          }
          controller.investmentType == null
              ? controller.updateShowSelectInvestmentTypeErrorText(true)
              : _handleOnPressed(controller, context);
        },
      ),
    );
  }

  void _handleOnPressed(BasketController controller, BuildContext context) {
    if (!validateSipFields(controller)) {
      return;
    }
    final String portfolioName =
        controller.portfolioNameController!.text.isEmpty
            ? 'Custom Portfolio'
            : controller.portfolioNameController!.text;

    bool disableMinAmountCheck = (controller.isTopUpPortfolio &&
        controller.portfolio?.productVariant == anyFundGoalSubtype);

    if (!disableMinAmountCheck &&
        (controller.portfolio?.productVariant == otherFundsGoalSubtype) &&
        controller.totalAmount < customPortfolioMinAmount) {
      return showToast(
        context: context,
        text:
            'Min investment of the Mutual Funds should be ${WealthyAmount.currencyFormat(customPortfolioMinAmount, 0)}',
      );
    }

    if (controller.fromClientScreen) {
      _handleOnClientSelected(
        controller,
        controller.selectedClient,
        context,
        portfolioName,
      );
    } else {
      AutoRouter.of(context).push(
        SelectClientRoute(
          checkIsClientIndividual: true,
          lastSelectedClient: controller.selectedClient,
          onClientSelected: (client, isClientNew) {
            // If client is changed then reset similar proposal list (a list of similar proposals created by the selected client)
            if (isClientNew ||
                (client?.isSourceContacts ?? false) ||
                client?.taxyID != controller.selectedClient?.taxyID) {
              controller.similarProposalsList = [];
              controller.hasCheckedSimilarProposals = false;
            }

            if (isClientNew) {
              AutoRouter.of(context).popForced();
            }

            _handleOnClientSelected(
              controller,
              client,
              context,
              portfolioName,
            );
          },
        ),
      );
    }
  }

  void _sendProposalToClient(BuildContext context, BasketController controller,
      String portfolioName) async {
    int? agentKycStatus = await getAgentKycStatus();
    if (agentKycStatus != AgentKycStatus.APPROVED) {
      CommonUI.showBottomSheet(context, child: ProposalKycAlertBottomSheet());
      return;
    }
    // Create Proposal
    await controller.createProposal();

    if (controller.createProposalState == NetworkState.loaded) {
      AutoRouter.of(context).push(ProposalSuccessRoute(
        proposalUrl: controller.proposalUrl,
        client: controller.selectedClient,
        productName: portfolioName,
        expiryTime: null,
        isBankAdded: false,
        isDematAdded: false,
        isCustom: true,
      ));
    } else {
      if (controller.similarProposalsList.length > 0) {
        return CommonUI.showBottomSheet(
          context,
          child: SimilarProposalsList(
            submitButtonWidget:
                _buildSimilarProposalProceedButton(context, portfolioName),
            similarProposalList: controller.similarProposalsList,
            client: controller.selectedClient,
          ),
        );
      }
    }
  }

  void _handleOnClientSelected(
    BasketController controller,
    Client? client,
    BuildContext context,
    String portfolioName,
  ) async {
    // Client already added to basket controller from store screen
    if (!controller.fromClientScreen) {
      controller.selectedClient = client;
      controller.userMandateStatus = '';
    }

    bool isSip = controller.investmentType == InvestmentType.SIP;
    // bool isMandateStatusFetched = controller.userMandateStatus!.isNotEmpty;

    // if (controller.selectedClient?.taxyID != null && !isMandateStatusFetched) {
    //   await controller.getUserMandateStatus();
    // }

    AutoRouter.of(context).push(
      OrderSummaryRoute(
        portfolioTitle: portfolioName,
        isTopUpPortfolio: controller.isTopUpPortfolio,
        totalInvestmentAmount: controller.totalAmount,
        funds: controller.basket.values.toList(),
        isCustom: true,
        client: client,
        userMandateStatus: controller.userMandateStatus,
        investmentType: controller.investmentType,
        sipDay: isSip ? controller.selectedSipDay : null,
        otherFundSipDetails:
            fromCustomPortfolios ? controller.customPortFolioSipData : null,
        anyFundSipDetails:
            !fromCustomPortfolios ? controller.anyFundSipData : null,
        fab: _buildOrderSummaryScreenFab(
          context,
          portfolioName,
        ),
      ),
    );
  }

  Widget _buildOrderSummaryScreenFab(
    BuildContext context,
    String portfolioName,
  ) {
    return GetBuilder<BasketController>(
      id: GetxId.createProposal,
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
      builder: (controller) {
        ShowCaseController? showCaseController;
        if (Get.isRegistered<ShowCaseController>()) {
          showCaseController = Get.find<ShowCaseController>();
        }

        bool displayShowCase = false;
        if (showCaseController != null &&
            showCaseController.activeShowCaseId ==
                showCaseIds.SendProposalToClient.id) {
          displayShowCase = true;
        }

        if (displayShowCase) {
          showCaseController!.setShowCaseVisibleCurrently(true);
          return SendProposalButtonShowCase(
            showCaseController: showCaseController,
            onClickFinished: ({bool? shouldSendProposal}) {
              controller.update([GetxId.createProposal]);
              if (shouldSendProposal ?? false) {
                _sendProposalToClient(context, controller, portfolioName);
              }
            },
          );
        }

        return ActionButton(
          margin: EdgeInsets.symmetric(horizontal: 30),
          heroTag: kDefaultHeroTag,
          text: 'Send to Client',
          showProgressIndicator:
              controller.createProposalState == NetworkState.loading,
          onPressed: () async {
            _sendProposalToClient(context, controller, portfolioName);
          },
        );
      },
    );
  }

  Widget _buildSimilarProposalProceedButton(context, portfolioName) {
    return GetBuilder<BasketController>(
      id: 'create-proposal',
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
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
                productName: portfolioName,
                expiryTime: null,
                isBankAdded: false,
                isDematAdded: false,
              ));
            }
          },
        );
      },
    );
  }

  bool validateSipFields(BasketController controller) {
    final sipDaysError =
        'Choose SIP days ${!fromCustomPortfolios ? "for all funds" : ""}';
    final sipPercentError =
        'Choose SIP Step Up Percentage ${!fromCustomPortfolios ? "for all funds" : ""}';
    bool validate(SipData sipData) {
      if (sipData.selectedSipDays.isNullOrEmpty) {
        showToast(text: sipDaysError);
        return false;
      } else if (sipData.isStepUpSipEnabled) {
        if (sipData.stepUpPercentage.isNullOrZero) {
          showToast(text: sipPercentError);
          return false;
        }
      }
      return true;
    }

    if (controller.investmentType == InvestmentType.SIP) {
      if (fromCustomPortfolios) {
        return validate(controller.customPortFolioSipData);
      } else {
        bool isValid = true;
        final keys = controller.anyFundSipData.keys.toList();
        for (int index = 0; index < keys.length; index++) {
          isValid = validate(controller.anyFundSipData[keys[index]]!);
          if (!isValid) break;
        }
        if (!isValid) return false;
      }
    }
    return true;
  }

  Widget _buildEditProposalCTA(BuildContext context) {
    return GetBuilder<BasketController>(
      id: GetxId.updateProposal,
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
      dispose: (_) {
        // If update proposal flow, delete the local Basket Controller
        if (isUpdateProposal) {
          Get.delete<BasketController>(tag: tag);
        }
      },
      builder: (controller) {
        return ActionButton(
          heroTag: kDefaultHeroTag,
          text: 'Save Changes',
          margin: EdgeInsets.zero,
          borderRadius: 30.0,
          showProgressIndicator:
              controller.updateProposalState == NetworkState.loading,
          onPressed: () async {
            if (!(controller.formKey.currentState?.validate() ?? false)) {
              showToast(text: 'Please input valid details');
              return;
            }
            await controller.updateProposal();
            if (controller.updateProposalState == NetworkState.loaded) {
              AutoRouter.of(context).push(
                ProposalSuccessRoute(
                  client: controller.selectedClient,
                  productName: controller.customPortfolioName ??
                      controller.portfolio!.title,
                  proposalUrl: controller.proposalUrl,
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCreateProposalCTA(BuildContext context) {
    return GetBuilder<BasketController>(
      id: 'create-proposal',
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
      dispose: (state) => state.controller!.portfolioNameController!.clear(),
      builder: (controller) {
        ShowCaseController? showCaseController;
        if (Get.isRegistered<ShowCaseController>()) {
          showCaseController = Get.find<ShowCaseController>();
        }

        return _buildActionButton(
          controller,
          context,
          showCaseController: showCaseController,
        );
      },
    );
  }

  Widget _buildBasketSummary(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.tertiaryBlack,
        );
    final style2 = Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.black,
        );
    return GetBuilder<BasketController>(
      id: 'basket-summary',
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
      builder: (basketController) {
        final fundAmount =
            WealthyAmount.currencyFormat(basketController.totalAmount, 0);
        final selectedFunds =
            '${basketController.basket.length} Fund${basketController.basket.length > 1 ? 's' : ''}';
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

  void onAddMoreFunds(BuildContext context) {
    AutoRouter.of(context).popForced();

    if (fromCustomPortfolios) {
      if (isRouteNameInStack(context, FundListRoute.name)) {
        AutoRouter.of(context).popUntilRouteWithName(FundListRoute.name);
      } else {
        AutoRouter.of(context).push(FundListRoute());
      }
    } else if (isRouteNameInStack(context, MfListRoute.name)) {
      AutoRouter.of(context).popUntilRouteWithName(MfListRoute.name);
    } else if (isRouteNameInStack(context, MfLobbyRoute.name)) {
      AutoRouter.of(context).popUntilRouteWithName(
        MfLobbyRoute.name,
      );
    }
  }
}
