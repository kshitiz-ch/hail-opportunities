import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/goal_actions_bottomsheet.dart';
import '../widgets/goal_details.dart';

@RoutePage()
class ClientGoalScreen extends StatelessWidget {
  const ClientGoalScreen({
    Key? key,
    required this.client,
    required this.goalId,
    required this.mfInvestmentType,
    // if any fund, wscheme code of the fund is passed here
    this.wschemecodeSelected,
  })  : assert(mfInvestmentType == MfInvestmentType.Funds
            ? wschemecodeSelected != null
            : true),
        super(key: key);

  final MfInvestmentType mfInvestmentType;
  final Client client;
  final String goalId;
  final String? wschemecodeSelected;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GoalController>(
      init: GoalController(
        client: client,
        goalId: goalId,
        mfInvestmentType: mfInvestmentType,
        wschemecodeSelected: wschemecodeSelected,
      ),
      dispose: (_) {
        Get.delete<TransactionController>();
        Get.delete<SipBookController>();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: controller.goalDetailResponse.state == NetworkState.loaded
              ? _buildAppBarWithGoalDetails(controller, context)
              : CustomAppBar(titleText: ''),
          body: Container(
            padding: EdgeInsets.only(top: 10, bottom: 90),
            child: Builder(
              builder: (context) {
                if (controller.goalDetailResponse.state ==
                    NetworkState.loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.goalDetailResponse.state ==
                    NetworkState.loaded) {
                  return GoalDetails();
                }

                if (controller.goalDetailResponse.state == NetworkState.error) {
                  return RetryWidget(
                    'Failed to load Goal details. Please try again',
                    onPressed: () {
                      controller.getGoalSummary();
                    },
                  );
                }

                return SizedBox();
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildActionButton(context, controller),
        );
      },
    );
  }

  CustomAppBar _buildAppBarWithGoalDetails(
    GoalController controller,
    BuildContext context,
  ) {
    if (mfInvestmentType == MfInvestmentType.Funds) {
      SchemeMetaModel? anyFundSchemeData = controller.anyFundScheme?.schemeData;

      Widget customTitleWidget() {
        if (controller.goalSchemes.isNotEmpty) {
          return InkWell(
            onTap: () {
              AutoRouter.of(context)
                  .push(FundDetailRoute(fund: anyFundSchemeData!));
            },
            child: Text.rich(
              TextSpan(
                text: anyFundSchemeData?.displayName ?? '',
                style: context.headlineMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: CommonUI.redirectionButton(context),
                  ),
                ],
              ),
              maxLines: 2,
            ),
          );
        }
        return SizedBox.shrink();
      }

      return CustomAppBar(
        maxLine: 2,
        customTitleWidget: customTitleWidget(),
        subtitleText:
            '${fundTypeDescription(anyFundSchemeData?.fundType)} ${anyFundSchemeData?.fundCategory != null ? "| ${anyFundSchemeData?.fundCategory}" : ""}',
      );
    } else {
      return CustomAppBar(
        maxLine: 2,
        titleText: controller.goal?.displayName ?? '',
      );
    }
  }

  Widget _buildActionButton(BuildContext context, GoalController controller) {
    if (controller.goalDetailResponse.state == NetworkState.loaded) {
      return Container(
        padding: EdgeInsets.only(bottom: 10),
        child: ActionButton(
          text: 'Transact',
          onPressed: () {
            CommonUI.showBottomSheet(
              context,
              child: GoalActionsBottomSheet(),
            );
          },
        ),
      );
    }

    return SizedBox();
  }
}
