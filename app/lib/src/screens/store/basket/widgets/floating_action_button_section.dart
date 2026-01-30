import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/similar_proposals_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FloatingActionButtonSection extends StatelessWidget {
  const FloatingActionButtonSection({
    Key? key,
    required this.isUpdateProposal,
    this.tag,
  }) : super(key: key);

  final bool isUpdateProposal;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasketController>(
      id: isUpdateProposal ? GetxId.updateProposal : GetxId.createProposal,
      global: tag != null ? false : true,
      init: Get.find<BasketController>(tag: tag),
      dispose: (_) {
        // If update proposal flow, delete the local Basket Controller
        if (isUpdateProposal) {
          Get.delete<BasketController>(tag: tag);
        }
      },
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16)
              .copyWith(bottom: 25),
          color: ColorConstants.secondaryAppColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.basket.length} Fund Selected',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                        SizedBox(height: 3),
                        Text(
                          WealthyAmount.currencyFormat(
                              controller.totalAmount, 0),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ActionButton(
                      margin: EdgeInsets.zero,
                      isDisabled: (controller.isTopUpPortfolio ||
                              controller.fromCustomPortfolios)
                          ? false
                          : checkCtaDisabled(controller),
                      disabledColor: ColorConstants.white,
                      text: controller.isUpdateProposal
                          ? 'Update Proposal'
                          : 'Share Proposal',
                      showProgressIndicator: isUpdateProposal
                          ? controller.updateProposalState ==
                              NetworkState.loading
                          : controller.createProposalState ==
                              NetworkState.loading,
                      onPressed: () async {
                        if (isUpdateProposal) {
                          onUpdateProposal(context, controller);
                        } else {
                          Map<String, dynamic> wpcMapping = {};

                          try {
                            controller.basket.entries.forEach((basketFund) {
                              wpcMapping[basketFund.value.displayName ?? ""] =
                                  basketFund.value.wpc;
                            });
                          } catch (error) {}

                          MixPanelAnalytics.trackWithAgentId(
                            "share_proposal",
                            screen: 'fund_basket',
                            screenLocation: 'fund_basket',
                            properties: wpcMapping,
                          );

                          onCreateProposal(context, controller);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool checkCtaDisabled(BasketController controller) {
    if (isUpdateProposal) {
      return false;
    } else {
      if (controller.selectedClient == null) {
        return true;
      }

      if (controller.investmentType == null) {
        return true;
      }

      if (controller.investmentType == InvestmentType.SIP &&
          !(controller.isSipFieldsValid(hideToast: true))) {
        return true;
      }

      return false;
    }
  }

  void onUpdateProposal(
      BuildContext context, BasketController controller) async {
    if (!(controller.formKey.currentState?.validate() ?? false)) {
      showToast(text: 'Please input valid details');
      return;
    }

    if (controller.investmentType == InvestmentType.SIP &&
        !(controller.isSipFieldsValid())) {
      return;
    }

    if (!_validateSifGroups(controller)) return;

    await controller.updateProposal();
    if (controller.updateProposalState == NetworkState.loaded) {
      AutoRouter.of(context).push(
        ProposalSuccessRoute(
          client: controller.selectedClient,
          productName:
              controller.customPortfolioName ?? controller.portfolio!.title,
          proposalUrl: controller.proposalUrl,
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        controller.clearBasket();
      });
    }
  }

  void onCreateProposal(
      BuildContext context, BasketController controller) async {
    if (controller.selectedClient == null) {
      return showToast(text: 'Please choose a client');
    }

    if (!controller.selectedClient?.isProposalEnabled) {
      CommonUI.showBottomSheet(
        context,
        child: ClientNonIndividualWarningBottomSheet(),
      );
      return;
    }

    if (controller.investmentType == null) {
      return showToast(text: 'Please choose an investment type');
    }

    if (!(controller.formKey.currentState?.validate() ?? false)) {
      showToast(text: 'Please input valid details');
      return;
    }

    bool disableMinAmountCheck = (controller.isTopUpPortfolio &&
        controller.portfolio?.productVariant == anyFundGoalSubtype);

    if (!disableMinAmountCheck &&
        controller.isCustomPortfolio &&
        controller.totalAmount < customPortfolioMinAmount) {
      return showToast(
        context: context,
        text:
            'Min investment of the Mutual Funds should be ${WealthyAmount.currencyFormat(customPortfolioMinAmount, 0)}',
      );
    }

    if (controller.investmentType == InvestmentType.SIP &&
        !(controller.isSipFieldsValid())) {
      return;
    }

    if (!_validateSifGroups(controller)) return;

    int? agentKycStatus = await getAgentKycStatus();
    if (agentKycStatus != AgentKycStatus.APPROVED) {
      CommonUI.showBottomSheet(context, child: ProposalKycAlertBottomSheet());
      return;
    }

    final String portfolioName =
        controller.portfolioNameController!.text.isEmpty
            ? 'Custom Portfolio'
            : controller.portfolioNameController!.text;
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

      Future.delayed(Duration(seconds: 2), () {
        controller.clearBasket();
      });
    } else {
      if (controller.similarProposalsList.length > 0) {
        return CommonUI.showBottomSheet(
          context,
          child: SimilarProposalsList(
            submitButtonWidget:
                _buildSimilarProposalProceedButton(context, tag, portfolioName),
            similarProposalList: controller.similarProposalsList,
            client: controller.selectedClient,
          ),
        );
      }
    }
  }

  Widget _buildSimilarProposalProceedButton(context, tag, portfolioName) {
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
              Future.delayed(Duration(seconds: 2), () {
                controller.clearBasket();
              });

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

  // Check if SIF groups comply with minimum amount requirements
  bool _validateSifGroups(BasketController controller) {
    if (controller.investmentType == InvestmentType.oneTime) {
      final allFunds = controller.basket.values.toList();
      final sifFunds = allFunds.where((f) => f.isSif == true).toList();

      // Group SIFs by AMC to validate collective minimums
      final groupedSifFunds =
          groupBy(sifFunds, (SchemeMetaModel f) => f.amcName ?? f.amc);

      for (var entry in groupedSifFunds.entries) {
        var funds = entry.value;
        if (funds.isEmpty) continue;

        // Determine Min Amount: Priority is minAmcDepositAmt > minDepositAmt
        double minAmount = funds.first.minAmcDepositAmt ?? 0;
        if (minAmount <= 0) {
          minAmount = funds.first.minDepositAmt ?? 0;
        }

        // Calculate total amount per group
        double totalAmountEntered =
            funds.fold(0, (sum, f) => sum + (f.amountEntered ?? 0));

        // Validation: The SUM of all funds in the group must meet the AMC minimum
        bool isGroupValid = totalAmountEntered >= minAmount;

        if (!isGroupValid) {
          showToast(
              text:
                  'Please ensure minimum contribution for ${entry.key ?? "SIF"} funds');
          return false;
        }
      }
    }
    return true;
  }
}
