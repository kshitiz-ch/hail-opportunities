import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_investment_controller.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'goal_actions_bottomsheet.dart';

class GoalTopUpButton extends StatelessWidget {
  const GoalTopUpButton({
    Key? key,
    required this.text,
    required this.goalController,
    required this.investmentTypeAllowed,
  }) : super(key: key);

  final String text;
  final GoalController goalController;
  final InvestmentType investmentTypeAllowed;

  @override
  Widget build(BuildContext context) {
    Client? client = Get.find<ClientDetailController>().client;

    return GetBuilder<MfInvestmentController>(
      init: MfInvestmentController(client),
      tag: goalController.goalId,
      builder: (mfInvestmentController) {
        bool isAnyFund =
            goalController.mfInvestmentType == MfInvestmentType.Funds;

        return GoalActionTile(
          text: text,
          imagePath: investmentTypeAllowed == InvestmentType.oneTime
              ? AllImages().goalTopUp
              : AllImages().goalSip,
          onClick: () {
            if (isAnyFund) {
              _navigateToAnyFundTopUp(
                context,
                mfInvestmentController,
                useScreenLoader: true,
              );
            } else {
              _navigateToPortfolioTopUp(
                context,
                mfInvestmentController,
                useScreenLoader: true,
              );
            }
          },
        );

        return ActionButton(
          text: 'Top Up',
          showProgressIndicator: isAnyFund
              ? mfInvestmentController.fundDetailState == NetworkState.loading
              : mfInvestmentController.portfolioDetailState ==
                  NetworkState.loading,
          onPressed: () {
            if (isAnyFund) {
              _navigateToAnyFundTopUp(context, mfInvestmentController);
            } else {
              _navigateToPortfolioTopUp(context, mfInvestmentController);
            }
          },
        );
      },
    );
  }

  void _navigateToAnyFundTopUp(
      BuildContext context, MfInvestmentController controller,
      {bool useScreenLoader = false}) async {
    // Client with panUsageType other than individual not allowed to do top up
    if (!goalController.client.isProposalEnabled) {
      return CommonUI.showBottomSheet(
        context,
        child: ClientNonIndividualWarningBottomSheet(),
      );
    }

    GoalSubtypeModel portfolio = GoalSubtypeModel.fromJson(
      {
        "external_id": goalController.goalId,
        "product_variant": anyFundGoalSubtype,
        "title": goalController.anyFundScheme?.schemeData?.displayName ?? '',
      },
    );

    // Use prefetched data if present
    // This will be true if user had already clicked top up button
    if (controller.fundDetailState == NetworkState.loaded) {
      return navigateToFundDetailForTopUp(
        context,
        goalId: goalController.goalId,
        client: goalController.client,
        portfolio: portfolio,
        fundDetails: controller.fundDetail!,
        investmentTypeAllowed: investmentTypeAllowed,
      );
    }

    SchemeMetaModel fund = goalController.anyFundScheme!.schemeData!;

    // For now loader is placed on the action button
    if (useScreenLoader) {
      AutoRouter.of(context).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );
    }

    await controller.getFundDetails(fund.wschemecode ?? '');

    if (useScreenLoader) {
      AutoRouter.of(context).popForced();
    }

    controller.fundDetail?.folioOverview =
        goalController.anyFundScheme?.folioOverview;

    if (controller.fundDetailState == NetworkState.error) {
      return showToast(
          text:
              'Failed to fetch details of this fund. Please try after some time');
    }

    if (controller.fundDetailState == NetworkState.loaded) {
      navigateToFundDetailForTopUp(
        context,
        goalId: goalController.goalId,
        client: goalController.client,
        portfolio: portfolio,
        fundDetails: controller.fundDetail!,
        investmentTypeAllowed: investmentTypeAllowed,
      );
    }
  }

  // void _navigateToFundDetailRoute(BuildContext context,
  //     MfInvestmentController controller, GoalSubtypeModel portfolio) {
  //   if (goalController.anyFundScheme?.folioOverviews != null &&
  //       (goalController.anyFundScheme!.folioOverviews!.length > 1)) {
  //     PortfolioInvestmentModel portfolioInvestment = PortfolioInvestmentModel(
  //       currentInvestedValue:
  //           WealthyCast.toInt(goalController.goal?.currentInvestedValue),
  //       currentValue: goalController.goal?.currentValue,
  //       currentAbsoluteReturns: goalController.goal?.currentAbsoluteReturns,
  //     );

  //     List<SchemeMetaModel> portfolioFunds = [];
  //     goalController.anyFundScheme?.folioOverviews!.forEach((FolioModel folio) {
  //       SchemeMetaModel schemeData =
  //           SchemeMetaModel.clone(goalController.anyFundScheme!.schemeData!);
  //       schemeData.folioOverview = folio;
  //       portfolioFunds.add(schemeData);
  //     });

  //     Get.delete<BasketController>();
  //     AutoRouter.of(context).push(
  //       FundListRoute(
  //         portfolio: portfolio,
  //         funds: portfolioFunds,
  //         client: goalController.client,
  //         isTopUpPortfolio: true,
  //         isCustomPortfolio: true,
  //         fromClientInvestmentScreen: true,
  //         portfolioInvestment: portfolioInvestment,
  //         investmentTypeAllowed: investmentTypeAllowed,
  //       ),
  //     );
  //   } else {
  //     navigateToFundDetailForTopUp(
  //       context,
  //       goalId: goalController.goalId,
  //       client: goalController.client,
  //       portfolio: portfolio,
  //       fundDetails: controller.fundDetail!,
  //       investmentTypeAllowed: investmentTypeAllowed,
  //     );
  //   }
  // }

  void _navigateToPortfolioTopUp(
      BuildContext context, MfInvestmentController controller,
      {bool useScreenLoader = false}) async {
    // Client with panUsageType other than individual not allowed to do top up
    if (!goalController.client.isProposalEnabled) {
      return CommonUI.showBottomSheet(
        context,
        child: ClientNonIndividualWarningBottomSheet(),
      );
    }

    // Use prefetched data if present
    // This will be true if user had already clicked top up button
    if (controller.portfolioDetailState == NetworkState.loaded) {
      return _navigateToPortfolioDetailRoute(context, controller);
    }

    // For now loader is placed on the action button
    if (useScreenLoader) {
      AutoRouter.of(context).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );
    }

    await controller.getGoalDetails(
        userId: goalController.client.taxyID!, goalId: goalController.goalId);

    if (useScreenLoader) {
      AutoRouter.of(context).popForced();
    }

    if (controller.portfolioDetailState == NetworkState.error) {
      return showToast(
        context: context,
        text: controller.portfolioErrorMessage.isNotNullOrEmpty
            ? controller.portfolioErrorMessage
            : 'Something went wrong',
      );
    }

    if (controller.portfolioDetailState == NetworkState.loaded) {
      _navigateToPortfolioDetailRoute(context, controller);
    }
  }

  void _navigateToPortfolioDetailRoute(
      BuildContext context, MfInvestmentController controller) {
    if (controller.selectedPortfolio!.isTaxSaver &&
        controller.isTaxSaverDeprecated) {
      return showToast(
          text:
              '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment, you can only invest into current year Tax Saver portfolio.');
    }

    if (!controller.canTopUp) {
      return showToast(
          text:
              '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment');
    }

    PortfolioInvestmentModel portfolioInvestment = PortfolioInvestmentModel(
      currentInvestedValue:
          WealthyCast.toInt(goalController.goal?.currentInvestedValue),
      currentValue: goalController.goal?.currentValue,
      currentAbsoluteReturns: goalController.goal?.currentAbsoluteReturns,
    );

    // Custom Portfolio
    if (controller.selectedPortfolio!.goalType == GoalType.CUSTOM) {
      if (controller.portfolioFunds.length == 0) {
        return showToast(
          context: context,
          text:
              '${controller.selectedPortfolio?.title ?? 'This portfolio'} cannot be accessed at the moment. Please try after some time',
        );
      } else {
        Get.delete<BasketController>();
        AutoRouter.of(context).push(
          FundListRoute(
            portfolio: controller.selectedPortfolio,
            funds: controller.portfolioFunds,
            client: goalController.client,
            isTopUpPortfolio: true,
            isCustomPortfolio: true,
            fromClientInvestmentScreen: true,
            portfolioInvestment: portfolioInvestment,
            investmentTypeAllowed: investmentTypeAllowed,
          ),
        );
      }
    } else {
      if ((controller.selectedPortfolio?.isSmartSwitch ?? false) &&
          investmentTypeAllowed == InvestmentType.SIP) {
        return showToast(
            text: 'SIP option is not available for this portfolio');
      }

      // Wealthy Portfolio
      AutoRouter.of(context).push(
        MfPortfolioDetailRoute(
          portfolio: controller.selectedPortfolio,
          client: goalController.client,
          isTopUpPortfolio: true,
          isSmartSwitch: controller.selectedPortfolio?.isSmartSwitch ?? false,
          fromClientInvestmentScreen: true,
          portfolioInvestment: portfolioInvestment,
          investmentTypeAllowed: investmentTypeAllowed,
        ),
      );
    }
  }
}
