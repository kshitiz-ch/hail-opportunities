import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/proposal/proposal_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/proposals/delete_proposal/view/delete_proposal_bottomsheet.dart';
import 'package:app/src/screens/proposals/proposal_details/widgets/client_bank_card.dart';
import 'package:app/src/screens/proposals/proposal_details/widgets/copy_proposal_link_button.dart';
import 'package:app/src/screens/proposals/proposal_details/widgets/top_up_proposal_button.dart';
import 'package:app/src/screens/proposals/proposal_details/widgets/update_mf_bottom_sheet_content.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../widgets/client_details_section.dart';
import '../widgets/funds_list_section.dart';
import '../widgets/profile_status_section.dart';
import '../widgets/switch_tracker_funds_section.dart';

const editDisabledProductsList = [
  ProductType.DEBENTURE,
  ProductType.FIXED_DEPOSIT,
  ProductType.UNLISTED_STOCK
];

@RoutePage()
class ProposalDetailsScreen extends StatelessWidget {
  // Fields
  ProposalModel? proposal;
  final bool showProposalActions;
  String? proposalId;
  final bool isEmployeeFlow;

  // Constructor
  ProposalDetailsScreen(
      {Key? key,
      this.proposal,
      @pathParam this.proposalId,
      this.showProposalActions = true,
      this.isEmployeeFlow = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (proposal == null) {
      proposal = ProposalModel.fromJson({"external_id": proposalId});
    }
    // Initialize ProposalDetailController
    Get.put(ProposalDetailController(proposal));

    return GetBuilder<ProposalDetailController>(
        id: 'proposal-data',
        dispose: (_) => Get.delete<ProposalDetailController>(),
        builder: (controller) {
          if (controller.proposalDataState == NetworkState.loading ||
              controller.proposalDataState == NetworkState.error) {
            return _buildProposalErrorScreen(context, controller);
          }

          return Scaffold(
            backgroundColor: ColorConstants.white,
            // AppBar
            appBar: CustomAppBar(
              showBackButton: true,
            ),

            // Body
            body: GetBuilder<ProposalDetailController>(
              id: 'proposal',
              builder: (controller) {
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

                return SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                        ).copyWith(top: 16),
                        child: Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.headlineMedium!.copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      // if (isEmployeeFlow)
                      // Client Details Section
                      ClientDetailsSection(),

                      CopyProposalLinkButton(
                        customerUrl: controller.proposal?.customerUrl ?? '',
                      ),

                      if (proposal?.bankModel != null)
                        ClientBankCard(bank: proposal!.bankModel!),

                      // Profile Status Section
                      if (controller.proposal!.userProfileStatuses!.length > 0)
                        ProfileStatusSection(),

                      // Funds List Section
                      if (controller.proposal?.isSwitchTrackerProposal ?? false)
                        SwitchTrackerFundsSection(controller: controller)
                      else if (controller.proposal!.productType ==
                          ProductType.MF)
                        FundsListSection(
                            isSmartSwitch: controller.proposalDetail.productInfo
                                    ?.isSmartSwitch ??
                                false),
                    ],
                  ),
                );
              },
            ),

            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,

            floatingActionButton:
                showProposalActions ? _buildProposalActions(context) : null,
          );
        });
  }

  void _navigateToMfProposalEditScreen(
      BuildContext context, ProposalDetailController controller) {
    bool isTopUpPortfolio =
        controller.proposal?.productExtrasJson!["goal_id"] != null;

    if (controller.proposal!.productType == ProductType.MF) {
      if (controller.hasNfoFunds) {
        return showToast(text: "This proposal cannot be edited");
      }

      if (controller.isMicroSIP || controller.isCustom) {
        String? tag = controller.proposal!.externalId;
        if (Get.isRegistered<BasketController>(tag: tag)) {
          Get.find<BasketController>(tag: tag).restoreBasket();
          Get.find<BasketController>(tag: tag).anyFundSipData = {};
          Get.find<BasketController>(tag: tag).initAnyFundsSipMapping();
        }
        AutoRouter.of(context).push(BasketOverViewRoute(
            basket: controller.fundsResult.schemeMetas!.asMap().map(
              (key, value) {
                SchemeMetaModel schemeModel;

                try {
                  // To avoid shallow copy
                  schemeModel = SchemeMetaModel.clone(value);
                } catch (error) {
                  schemeModel = value;
                }

                return MapEntry(schemeModel.basketKey, schemeModel);
              },
            ),
            isUpdateProposal: true,
            proposal: controller.proposalDetail,
            isTopUpPortfolio: isTopUpPortfolio,
            portfolioExternalId:
                controller.proposal?.productExtrasJson!["goal_id"]));
      } else {
        CommonUI.showBottomSheet(context,
            child: UpdateMfBottomSheetContent(
                proposal: controller.proposalDetail,
                isTopUpPortfolio: isTopUpPortfolio));
      }
    }
  }

  Widget _buildProposalActions(context) {
    return GetBuilder<ProposalDetailController>(
      id: 'action-button',
      builder: (controller) {
        bool canEditProposal = controller.proposal!.canEdit! &&
            !editDisabledProductsList
                .contains(controller.proposal!.productType);
        bool canTopUp = controller.proposal!.canTopup! &&
            controller.proposal!.productType!.toLowerCase() == ProductType.MF &&
            controller.proposal!.productTypeVariant != anyFundGoalSubtype;

        bool shouldDisableUpdateButton =
            controller.proposalDetailState != NetworkState.loaded ||
                (controller.proposal!.productType == ProductType.MF
                    ? controller.fundsState != NetworkState.loaded
                    : false);

        bool shouldDisableDeleteButton =
            controller.proposalDetailState != NetworkState.loaded ||
                (controller.proposal!.productType == ProductType.MF
                    ? controller.fundsState != NetworkState.loaded
                    : false);

        // show delete UI only if proposal canBeMarkedFailure && its not already deleted
        final canDelete = (proposal?.canBeMarkedFailure ?? false) &&
            proposal?.isFailed == false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              canDelete
                  ? Expanded(
                      child: ActionButton(
                        text: 'Delete',
                        margin: EdgeInsets.zero,
                        textStyle: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              color: shouldDisableDeleteButton
                                  ? ColorConstants.tertiaryBlack
                                  : ColorConstants.primaryAppColor,
                            ),
                        bgColor: shouldDisableDeleteButton
                            ? ColorConstants.secondaryWhite
                            : ColorConstants.secondaryAppColor,
                        isDisabled: shouldDisableDeleteButton,
                        onPressed: () async {
                          if (controller.proposalDetailState !=
                              NetworkState.loaded) {
                            return;
                          }

                          CommonUI.showBottomSheet(
                            context,
                            child:
                                DeleteProposalBottomSheet(proposal: proposal!),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              if (controller.proposal!.canBeMarkedFailure! &&
                  (canEditProposal || canTopUp))
                SizedBox(
                  width: 30,
                ),
              canEditProposal
                  ? Expanded(
                      child: _buildEditProposalButton(
                          context: context,
                          controller: controller,
                          shouldDisableUpdateButton: shouldDisableUpdateButton),
                    )
                  : canTopUp
                      ? Expanded(
                          child: TopUpProposalButton(
                            proposal: controller.proposalDetail,
                            shouldDisableButton: shouldDisableUpdateButton,
                          ),
                        )
                      : SizedBox(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditProposalButton(
      {BuildContext? context,
      required ProposalDetailController controller,
      bool? shouldDisableUpdateButton}) {
    bool isProductInsurance =
        controller.proposal!.productCategory == ProductCategoryType.INSURANCE;

    String buttonText = 'Edit Proposal';
    // if (isProductInsurance) {
    //   buttonText = 'Go To Proposal';
    // } else {
    //   buttonText = 'Edit Proposal';
    // }

    return GetBuilder<ProposalDetailController>(
      id: 'edit-proposal',
      builder: (controller) {
        return ActionButton(
          heroTag: kDefaultHeroTag,
          text: buttonText,
          margin: EdgeInsets.zero,
          showProgressIndicator:
              controller.getInsuranceEditUrlState == NetworkState.loading ||
                  controller.checkingWebViewState == NetworkState.loading,
          isDisabled: shouldDisableUpdateButton,
          onPressed: () async {
            // For Insurance
            if (isProductInsurance) {
              String proposalEditUrl = (await controller.getProposalEditUrl())!;

              if (proposalEditUrl.isNullOrEmpty) {
                return showToast(
                    text:
                        'Failed to fetch edit proposal Url. Please try after some time');
              }

              bool viaWebView = webViewEnabledProductVariants
                  .contains(controller.proposal!.productTypeVariant);

              bool isSavingsOrTermInsurance =
                  controller.proposal!.productTypeVariant ==
                          InsuranceProductVariant.TERM ||
                      controller.proposal!.productTypeVariant ==
                          InsuranceProductVariant.SAVINGS;

              if (isSavingsOrTermInsurance &&
                  controller.proposal?.appVersion != null &&
                  controller.proposal!.appVersion.isNotNullOrEmpty) {
                proposalEditUrl +=
                    '&app_version=${controller.proposal?.appVersion}';

                String appVersionExtracted =
                    extractAppVersion(controller.proposal?.appVersion ?? '');

                // WebView should be disabled for;
                // Tablets
                // If flag from cloudflare is false
                // App version is less than v3.1.0
                viaWebView = (await controller.shouldOpenWebView(
                        controller.proposal!.productTypeVariant!))! &&
                    isAppVersion31OrGreater(appVersionExtracted) &&
                    !SizeConfig().isTabletDevice;
              }

              if (viaWebView) {
                if (!isPageAtTopStack(context!, InsuranceWebViewRoute.name)) {
                  bool shouldHandleAppBar = !isSavingsOrTermInsurance;

                  AutoRouter.of(context).push(
                    InsuranceWebViewRoute(
                      url: proposalEditUrl,
                      shouldHandleAppBar: shouldHandleAppBar,
                      onNavigationRequest: (
                        InAppWebViewController controller,
                        NavigationAction action,
                      ) async {
                        final navigationUrl = action.request.url.toString();
                        if (isSavingsOrTermInsurance &&
                            navigationUrl.contains("applinks.buildwealth.in")) {
                          if (navigationUrl ==
                              "https://applinks.buildwealth.in/proposals") {
                            navigateToProposalScreen(context);
                          } else {
                            AutoRouter.of(context).popForced();
                          }
                          return NavigationActionPolicy.CANCEL;
                        } else {
                          return NavigationActionPolicy.ALLOW;
                        }
                      },
                    ),
                  );
                }
              } else {
                launch(proposalEditUrl);
              }
              return;
            } else {
              _navigateToMfProposalEditScreen(context!, controller);
            }
          },
        );
      },
    );
  }

  Widget _buildProposalErrorScreen(
      BuildContext context, ProposalDetailController controller) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
      ),
      backgroundColor: ColorConstants.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32),
        height: MediaQuery.of(context).size.height,
        child: controller.proposalDataState == NetworkState.loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Text(
                  'We cannot find the proposal.\nPlease make sure the proposal is not deleted',
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
