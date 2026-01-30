import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/clients/client_goal/widgets/goal_topup_button.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mark_custom_bottomsheet.dart';

class GoalActionsBottomSheet extends StatelessWidget {
  const GoalActionsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitleAndCloseIcon(context),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildTitleAndCloseIcon(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transact',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
          ),
          CommonUI.bottomsheetCloseIcon(context)
        ],
      ),
    );
  }

  Widget _buildActions(context) {
    return GetBuilder<GoalController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(top: 24, bottom: 40),
          child: Column(
            children: [
              GoalTopUpButton(
                goalController: controller,
                text: 'Create SIP',
                investmentTypeAllowed: InvestmentType.SIP,
              ),
              // One Time Top Up
              GoalTopUpButton(
                goalController: controller,
                text: 'Additional Purchase',
                investmentTypeAllowed: InvestmentType.oneTime,
              ),
              _buildSwitchOrderButton(context, controller),
              _buildStpButton(context, controller),
              _buildWithdrawalOrderButton(context, controller),
              _buildSwpButton(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchOrderButton(
      BuildContext context, GoalController controller) {
    return GoalActionTile(
      text: 'Create Switch Order',
      imagePath: AllImages().switchOrder,
      onClick: () async {
        if (!controller.client.isProposalEnabled) {
          CommonUI.showBottomSheet(
            context,
            child: ClientNonIndividualWarningBottomSheet(),
          );
          return;
        }

        if (controller.goal?.goalSubtype?.goalType == GoalType.ANY_FUNDS &&
            !controller.isAllAnyFundSchemesFetched) {
          AutoRouter.of(context).pushNativeRoute(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
            ),
          );
          await controller.getAllAnyFundSchemes();
          // await controller.getGoalAllocation(filterBySchemeCode: false);
          AutoRouter.of(context).popForced();
        }

        bool isEmptyPortfolio = false;
        if (controller.goal?.goalSubtype?.goalType == GoalType.ANY_FUNDS) {
          isEmptyPortfolio = (controller.anyFundScheme?.currentValue ?? 0) <= 0;
        } else {
          isEmptyPortfolio = (controller.goal?.currentValue ?? 0) <= 0;
        }

        if (isEmptyPortfolio) {
          return showToast(
            text: 'Switch is not possible for this goal',
          );
        }

        if ([GoalType.CUSTOM, GoalType.ANY_FUNDS]
            .contains(controller.goal?.goalSubtype?.goalType)) {
          AutoRouter.of(context).push(
            ClientSwitchOrderRoute(
              client: controller.client,
              goalSchemes: controller.goalSchemes,
              anyFundGoalScheme: controller.anyFundScheme,
              goal: controller.goal!,
            ),
          );
        } else {
          CommonUI.showBottomSheet(
            context,
            child: MarkCustomBottomSheet(
              onMarkCustom: () {
                AutoRouter.of(context).push(
                  ClientSwitchOrderRoute(
                    client: controller.client,
                    goalSchemes: controller.goalSchemes,
                    anyFundGoalScheme: controller.anyFundScheme,
                    goal: controller.goal!,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildStpButton(BuildContext context, GoalController controller) {
    return GoalActionTile(
      text: 'Systematic Transfer Plan (STP)',
      imagePath: AllImages().switchOrder,
      onClick: () async {
        if (!controller.client.isProposalEnabled) {
          CommonUI.showBottomSheet(
            context,
            child: ClientNonIndividualWarningBottomSheet(),
          );
          return;
        }

        if (controller.goal?.goalSubtype?.goalType == GoalType.ANY_FUNDS &&
            !controller.isAllAnyFundSchemesFetched) {
          AutoRouter.of(context).pushNativeRoute(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
            ),
          );

          await controller.getAllAnyFundSchemes();
          // await controller.getGoalAllocation(filterBySchemeCode: false);
          AutoRouter.of(context).popForced();
        }

        bool isEmptyPortfolio = false;
        if (controller.goal?.goalSubtype?.goalType == GoalType.ANY_FUNDS) {
          isEmptyPortfolio = (controller.anyFundScheme?.currentValue ?? 0) <= 0;
        } else {
          isEmptyPortfolio = (controller.goal?.currentValue ?? 0) <= 0;
        }

        if (isEmptyPortfolio) {
          return showToast(
            text: 'Switch is not possible for this goal',
          );
        }

        if ([GoalType.CUSTOM, GoalType.ANY_FUNDS]
            .contains(controller.goal?.goalSubtype?.goalType)) {
          AutoRouter.of(context).push(
            ClientStpRoute(
              client: controller.client,
              goalSchemes: controller.goalSchemes,
              anyFundGoalScheme: controller.anyFundScheme,
              goal: controller.goal!,
            ),
          );
        } else {
          CommonUI.showBottomSheet(
            context,
            child: MarkCustomBottomSheet(
              onMarkCustom: () {
                AutoRouter.of(context).push(
                  ClientStpRoute(
                    client: controller.client,
                    goalSchemes: controller.goalSchemes,
                    anyFundGoalScheme: controller.anyFundScheme,
                    goal: controller.goal!,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildWithdrawalOrderButton(
      BuildContext context, GoalController controller) {
    return GoalActionTile(
      text: 'Withdrawal Order',
      imagePath: AllImages().goalSip,
      onClick: () {
        if (!controller.client.isProposalEnabled) {
          CommonUI.showBottomSheet(
            context,
            child: ClientNonIndividualWarningBottomSheet(),
          );
          return;
        }

        List<UserGoalSubtypeSchemeModel> goalSchemes;
        bool isEmptyPortfolio;
        if (controller.mfInvestmentType == MfInvestmentType.Portfolios) {
          goalSchemes = controller.goalSchemes;
          isEmptyPortfolio = (controller.goal?.currentValue ?? 0) <= 0;
        } else {
          goalSchemes = controller.anyFundScheme != null
              ? [controller.anyFundScheme!]
              : [];
          isEmptyPortfolio = (controller.anyFundScheme?.currentValue ?? 0) <= 0;
        }

        if (isEmptyPortfolio) {
          return showToast(
            text: 'Withdrawal is not possible for this goal',
          );
        }

        AutoRouter.of(context).push(
          ClientWithdrawalRoute(
            client: controller.client,
            goalSchemes: goalSchemes,
            goal: controller.goal!,
          ),
        );
      },
    );
  }
}

Widget _buildSwpButton(BuildContext context, GoalController controller) {
  return GoalActionTile(
    text: 'Systematic Withdrawal Plan (SWP)',
    imagePath: AllImages().goalSip,
    onClick: () {
      if (!controller.client.isProposalEnabled) {
        CommonUI.showBottomSheet(
          context,
          child: ClientNonIndividualWarningBottomSheet(),
        );
        return;
      }

      List<UserGoalSubtypeSchemeModel> goalSchemes;
      bool isEmptyPortfolio;
      if (controller.mfInvestmentType == MfInvestmentType.Portfolios) {
        goalSchemes = controller.goalSchemes;
        isEmptyPortfolio = (controller.goal?.currentValue ?? 0) <= 0;
      } else {
        goalSchemes =
            controller.anyFundScheme != null ? [controller.anyFundScheme!] : [];
        isEmptyPortfolio = (controller.anyFundScheme?.currentValue ?? 0) <= 0;
      }

      if (isEmptyPortfolio) {
        return showToast(
          text: 'SWP is not possible for this goal',
        );
      }

      AutoRouter.of(context).push(ClientSwpRoute());
    },
  );
}

class GoalActionTile extends StatelessWidget {
  GoalActionTile({
    required this.text,
    required this.imagePath,
    required this.onClick,
  });

  final String text;
  final String imagePath;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onClick,
        child: Container(
          padding: EdgeInsets.fromLTRB(25, 17, 20, 17),
          decoration: BoxDecoration(
              color: ColorConstants.secondaryWhite,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: Image.asset(
                  imagePath,
                  width: 21,
                ),
              ),
              Text(
                text,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primaryAppColor),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: ColorConstants.primaryAppColor, size: 16)
            ],
          ),
        ),
      ),
    );
  }
}
