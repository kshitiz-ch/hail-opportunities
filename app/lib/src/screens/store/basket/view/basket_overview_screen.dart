import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart' as enums;
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/basket/widgets/basket_view.dart';
import 'package:app/src/screens/store/basket/widgets/investment_type_switch_section_new.dart';
import 'package:app/src/screens/store/common_new/widgets/activate_step_up_sip.dart';
import 'package:app/src/screens/store/common_new/widgets/sip_day_stepup_selector_section.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/floating_action_button_section.dart';
import '../widgets/select_client_section.dart';

@RoutePage()
class BasketOverViewScreen extends StatelessWidget {
  const BasketOverViewScreen({
    Key? key,
    this.basket = const {},
    this.isUpdateProposal = false,
    this.isTopUpPortfolio = false,
    this.fromCustomPortfolios = false,
    this.showAddMoreFundButton = true,
    this.proposal,
    this.portfolioExternalId,
  })  : assert(isUpdateProposal ? proposal != null : true),
        assert(isTopUpPortfolio ? portfolioExternalId != null : true),
        super(key: key);

  final Map<String?, SchemeMetaModel> basket;
  final bool fromCustomPortfolios;

  /// Used in Update Top-up Flow
  final bool isTopUpPortfolio;
  final String? portfolioExternalId;

  /// Used in Update Proposal Flow
  final bool isUpdateProposal;
  final ProposalModel? proposal;
  final bool showAddMoreFundButton;

  void onAddMoreFunds(context) {
    AutoRouter.of(context).popForced();

    if (fromCustomPortfolios) {
      if (isTopUpPortfolio) {
        if (isRouteNameInStack(context, FundListRoute.name)) {
          AutoRouter.of(context).popUntilRouteWithName(FundListRoute.name);
        } else {
          AutoRouter.of(context).push(FundListRoute());
        }
      } else {
        if (isRouteNameInStack(context, MfListRoute.name)) {
          AutoRouter.of(context).popUntilRouteWithName(MfListRoute.name);
        } else {
          AutoRouter.of(context)
              .push(MfListRoute(isCustomPortfoliosScreen: true));
        }
      }
    } else if (isRouteNameInStack(context, MfListRoute.name)) {
      AutoRouter.of(context).popUntilRouteWithName(MfListRoute.name);
    } else if (isRouteNameInStack(context, BaseRoute.name)) {
      final navController = Get.find<NavigationController>();
      navController.setCurrentScreen(Screens.STORE);
      AutoRouter.of(context).popUntilRouteWithName(BaseRoute.name);
    } else {
      AutoRouter.of(context).push(MfLobbyRoute());
    }
  }

  void onBackPress(BuildContext context, String? tag) async {
    final controller = Get.find<BasketController>(tag: tag);

    // if (controller.isUpdateProposal &&
    //     controller.pageController.hasClients &&
    //     controller.pageController.page!.toInt() == 1) {
    //   await controller.pageController.previousPage(
    //       duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    //   controller.update(['basket']);
    // } else {
    //   controller.update(['basket']);
    // }
    // if (controller.isTopUpPortfolio) {
    //   Get.delete<BasketController>(tag: tag);
    // }

    AutoRouter.of(context).popForced();
  }

  @override
  Widget build(BuildContext context) {
    // Typically used to create local instances of BasketController.
    String? tag = isUpdateProposal
        ? proposal!.externalId
        : isTopUpPortfolio
            ? portfolioExternalId
            : null;

    // If update proposal flow, initialize the local Basket Controller
    if (isUpdateProposal) {
      Get.put(
        BasketController(
          basket: basket,
          isUpdateProposal: isUpdateProposal,
          isTopUpPortfolio: isTopUpPortfolio,
          selectedClient: proposal!.customer,
          proposal: proposal,
        ),
        tag: tag,
      );
      final controller = Get.find<BasketController>(tag: tag);
      LogUtil.printLog(controller.anyFundSipData);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          onBackPress(context, tag);
        });
      },
      child: GetBuilder<BasketController>(
        id: 'basket',
        initState: (_) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            final controller = Get.find<BasketController>(tag: tag);

            if (controller.selectedClient != null &&
                (!controller.isTopUpPortfolio)) {
              controller.getUserFolios();
            }

            if (!controller.isUpdateProposal) {
              if (!fromCustomPortfolios) {
                controller.initAnyFundsSipMapping();
              } else {
                controller.anyFundSipData.clear();
              }
            }

            if (controller.hasTaxSaverFunds) {
              controller.customPortFolioSipData.updateIsStepUpSipEnabled(false);
              controller.update(['basket-summary']);
            }
          });
        },
        global: tag != null ? false : true,
        init: Get.find<BasketController>(tag: tag),
        builder: (controller) {
          controller.fromCustomPortfolios = fromCustomPortfolios;
          final basket = controller.basket;
          FundsController? fundsController;

          if (Get.isRegistered<FundsController>()) {
            fundsController = Get.find<FundsController>();
          }

          bool showAddButton = false;
          if (!showAddMoreFundButton) {
            showAddButton = false;
          } else if (basket.isNotEmpty && !isUpdateProposal) {
            showAddButton = true;
            if (isTopUpPortfolio) {
              showAddButton =
                  basket.length != fundsController?.fundsResult?.length;
            }
          }
          return Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: CustomAppBar(
              showBackButton: true,
              titleText:
                  '${fromCustomPortfolios ? "Custom Portfolio" : "Fund"} Basket',
              // subtitleText: basket.isNotEmpty ? 'Choose Investment Type' : '',
              onBackPress: () {
                onBackPress(context, tag);
              },
              trailingWidgets: [
                _buildClearBasketDropdown(controller),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.only(bottom: 30),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24)
                      .copyWith(top: 20, bottom: 20),
                  child: SelectClientSection(controller: controller),
                ),
                (basket.isEmpty && !isUpdateProposal)
                    ? _buildEmptyBasketView(context)
                    : _buildBasketView(
                        context,
                        controller,
                        tag,
                        showAddButton,
                      ),
              ],
            ),
            bottomNavigationBar: basket.isEmpty
                ? SizedBox()
                // : _buildFabSection(context, controller)
                : FloatingActionButtonSection(
                    isUpdateProposal: isUpdateProposal,
                    tag: isUpdateProposal
                        ? proposal!.externalId
                        : isTopUpPortfolio
                            ? portfolioExternalId
                            : null),
            // floatingActionButtonLocation: FixedCenterDockedFabLocation(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyBasketView(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined,
            color: ColorConstants.primaryAppColor,
            size: 44,
          ),
          SizedBox(height: 16.0),
          Text(
            "There's nothing in your cart!",
            style: Theme.of(context).primaryTextTheme.headlineSmall,
          ),
          TextButton(
            child: Text('Add Funds'),
            onPressed: () {
              onAddMoreFunds(context);
            },
          )
        ],
      ),
    );
  }

  Widget _buildClearBasketDropdown(BasketController controller) {
    if (controller.isUpdateProposal || controller.isTopUpPortfolio) {
      return SizedBox();
    }
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: ColorConstants.tertiaryBlack,
      ),
      onSelected: (value) {
        controller.clearBasket();
      },
      itemBuilder: (BuildContext context) {
        return {'Clear Basket'}.map((String choice) {
          return PopupMenuItem<String>(
            height: 30,
            value: choice,
            child: Text(
              choice,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(color: ColorConstants.black),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildBasketView(
    BuildContext context,
    BasketController controller,
    String? tag,
    bool showAddButton,
  ) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          InvestmentTypeSwitchSectionNew(tag: tag),
          _buildSIPSection(context, controller, tag),
          BasketView(
            showAddButton: showAddButton,
            tag: tag,
            fromCustomPortfolios: fromCustomPortfolios,
          ),
          _buildAddMoreFunds(context, controller),
          Container(
            height: 16,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ColorConstants.secondaryWhite,
            ),
          ),
          _buildSummary(context, controller)
        ],
      ),
    );
  }

  Widget _buildAddMoreFunds(BuildContext context, BasketController controller) {
    if (controller.isUpdateProposal ||
        controller.isTopUpPortfolio &&
            (controller.portfolio?.productVariant == anyFundGoalSubtype)) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Center(
        child: ClickableText(
          text: '+ Add More Funds',
          fontSize: 15,
          onClick: () {
            onAddMoreFunds(context);
          },
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, BasketController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: Theme.of(context).primaryTextTheme.headlineMedium,
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CommonUI.buildColumnText(
                  context,
                  label: 'Funds Added',
                  value: '${controller.basket.length}',
                ),
              ),
              Expanded(
                child: CommonUI.buildColumnText(
                  context,
                  label:
                      'Total ${controller.investmentType == InvestmentType.SIP ? 'monthly SIP' : ''} Amount',
                  value: WealthyAmount.currencyFormat(
                      controller.totalMonthlyAmount, 0),
                ),
              )
            ],
          ),
          SizedBox(height: 14),
          CommonUI.buildColumnText(
            context,
            label: 'Investment Type',
            value: controller.investmentType != null
                ? controller.investmentType!.name.toUpperCase()
                : '-',
          )
        ],
      ),
    );
  }

  Widget _buildSIPSection(
      BuildContext context, BasketController controller, String? tag) {
    final isSipSelected = controller.investmentType == enums.InvestmentType.SIP;
    final isValidFlow = fromCustomPortfolios ||
        (controller.isUpdateProposal &&
            controller.proposal!.productTypeVariant != anyFundGoalSubtype);
    final showSipSection = isSipSelected && isValidFlow;
    return showSipSection
        ? GetBuilder<BasketController>(
            id: 'basket-summary',
            global: tag != null ? false : true,
            init: Get.find<BasketController>(tag: tag),
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.all(30).copyWith(top: 0),
                child: SipDayStepUpSelectorSection(
                  sipData: controller.customPortFolioSipData,
                  allowedSipDays: controller.allowedSipDays.toList(),
                  onChooseDays: (data) {
                    controller.customPortFolioSipData
                        .updateSelectedSipDays(data);
                    controller.update(['basket-summary', 'basket']);
                  },
                  openActivateStepUpSip: () {
                    openActivateStepUpSip(controller, context);
                  },
                  sipAmount: controller.totalAmount,
                  onToggleStepUpSip: (value) {
                    if (controller.hasTaxSaverFunds) {
                      return showToast(
                          text:
                              "Your basket contains a tax saver fund, so step-up is not allowed",
                          duration: Duration(seconds: 3));
                    }

                    if (value) {
                      openActivateStepUpSip(controller, context);
                    } else {
                      controller.customPortFolioSipData
                          .updateIsStepUpSipEnabled(value);
                      controller.update(['basket-summary']);
                    }
                  },
                  onChooseEndDate: (endDate) {
                    controller.customPortFolioSipData.updateEndDate(endDate);
                    controller.update(['basket-summary']);
                  },
                  onChooseStartDate: (startDate) {
                    controller.customPortFolioSipData
                        .updateStartDate(startDate);
                    controller.update(['basket-summary']);
                  },
                ),
              );
            },
          )
        : SizedBox.shrink();
  }

  void openActivateStepUpSip(
      BasketController controller, BuildContext context) {
    CommonUI.showBottomSheet(
      context,
      child: ActivateStepUpSip(
        onUpdateStepUpPeriod: (stepUpPeriod, stepUpPercentage) {
          controller.customPortFolioSipData.activateStepUpSip(
            stepUpPeriod,
            stepUpPercentage,
          );
          controller.customPortFolioSipData.updateIsStepUpSipEnabled(true);
          controller.update(['basket']);
          AutoRouter.of(context).popForced();
        },
        selectedStepUpPeriod: controller.customPortFolioSipData.stepUpPeriod,
        sipAmount: controller.totalAmount,
        stepUpPercentage: controller.customPortFolioSipData.stepUpPercentage,
        stepUpPercentageController:
            controller.customPortFolioSipData.stepUpPercentageController,
      ),
    );
  }
}
