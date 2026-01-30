import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/clients/client_goal/widgets/mark_custom_bottomsheet.dart';
import 'package:app/src/screens/clients/client_goal/widgets/scheme_overview.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'portfolio_allocation_card.dart';

class GoalAllocation extends StatelessWidget {
  const GoalAllocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      builder: (controller) {
        if (controller.goalSchemes.isEmpty) {
          return SizedBox();
        }

        return Container(
          padding: EdgeInsets.only(top: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.mfInvestmentType == MfInvestmentType.Portfolios
                        ? 'Allocation'
                        : 'Overview',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineLarge!
                        .copyWith(fontSize: 14),
                  ),
                  _buildEditAllocationButton(controller, context),
                ],
              ),
              SizedBox(height: 15),
              if (controller.mfInvestmentType == MfInvestmentType.Funds)
                _buildAnyFundOverview(context, controller)
              else
                _buildFundsOverview(controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundsOverview(GoalController controller) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: controller.goalSchemes.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 20),
      itemBuilder: (BuildContext context, int index) {
        UserGoalSubtypeSchemeModel goalScheme = controller.goalSchemes[index];

        return PortfolioAllocationCard(goalScheme: goalScheme);
      },
    );
  }

  Widget _buildAnyFundOverview(
      BuildContext context, GoalController controller) {
    UserGoalSubtypeSchemeModel? anyFundScheme = controller.anyFundScheme;

    if (anyFundScheme == null) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: SchemeOverview(
        scheme: anyFundScheme,
        mfInvestmentType: controller.mfInvestmentType,
      ),
    );
  }

  Widget _buildEditAllocationButton(
      GoalController controller, BuildContext context) {
    if (controller.mfInvestmentType == MfInvestmentType.Funds) {
      // Edit Allocation not possible for any fund
      return SizedBox();
    }

    return ClickableText(
      text: 'Edit Allocation',
      onClick: () {
        if (controller.goal?.goalSubtype?.goalType == GoalType.CUSTOM) {
          // edit allocation possible for custom fund only

          // undo all changes
          controller.editedGoalSchemes = controller.goalSchemes
              .map<UserGoalSubtypeSchemeModel>((model) => model.clone())
              .toList();

          AutoRouter.of(context).push(EditAllocationRoute());
        } else {
          CommonUI.showBottomSheet(
            context,
            child: MarkCustomBottomSheet(
              onMarkCustom: () {
                controller.editedGoalSchemes = controller.goalSchemes
                    .map<UserGoalSubtypeSchemeModel>((model) => model.clone())
                    .toList();

                AutoRouter.of(context).push(EditAllocationRoute());
              },
            ),
          );
        }
      },
    );
  }
}
