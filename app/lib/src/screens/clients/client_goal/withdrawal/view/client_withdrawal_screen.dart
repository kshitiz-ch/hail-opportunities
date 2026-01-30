import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/withdrawal_controller.dart';
import 'package:app/src/screens/clients/client_goal/withdrawal/widgets/add_edit_fund_bottomsheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/confirm_send_ticket_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/mutual_funds/models/goal_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../widgets/confirm_send_ticket_bottomsheet.dart';
import '../widgets/withdrawal_funds_list.dart';

@RoutePage()
class ClientWithdrawalScreen extends StatelessWidget {
  const ClientWithdrawalScreen({
    Key? key,
    required this.client,
    required this.goalSchemes,
    required this.goal,
  }) : super(key: key);

  final Client client;
  final List<UserGoalSubtypeSchemeModel> goalSchemes;
  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawalController>(
      init: WithdrawalController(
        client: client,
        goalSchemes: goalSchemes,
        goal: goal,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Withdrawal',
            subtitleText: 'Funds of your choice to withdraw',
          ),
          body: Container(
            child: Builder(
              builder: (BuildContext context) {
                // For AnyFund, open add fund bottomsheet
                if (controller.schemeWithFolios.isNotEmpty &&
                    controller.openAddFundBottomSheet) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    CommonUI.showBottomSheet(
                      context,
                      child: AddEditFundBottomSheet(),
                    );
                    controller.openAddFundBottomSheet = false;
                  });
                }

                if (controller.withdrawalSchemesSelected.isNotEmpty) {
                  return WithdrawalFundsLIst();
                }

                return _buildEmptyState(context, controller);
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

  Widget _buildEmptyState(
      BuildContext context, WithdrawalController controller) {
    return Center(
      child: EmptyScreen(
        message:
            "No Funds ${controller.schemeWithFolios.isEmpty ? 'Found' : 'Selected'}",
        actionButtonText:
            controller.schemeWithFolios.isNotEmpty ? '+ Add Funds' : null,
        onClick: () {
          CommonUI.showBottomSheet(
            context,
            child: AddEditFundBottomSheet(),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, WithdrawalController controller) {
    if (controller.withdrawalSchemesSelected.isEmpty) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        border: Border(
          top: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!controller.isAllFoliosSelected)
            ClickableText(
              text: '+ Add More Funds',
              fontSize: 16,
              onClick: () {
                controller.resetForm();
                CommonUI.showBottomSheet(
                  context,
                  child: AddEditFundBottomSheet(),
                );
              },
            ),
          SizedBox(height: 16),
          ActionButton(
            onPressed: () {
              CommonUI.showBottomSheet(
                context,
                child: GetBuilder<WithdrawalController>(
                    id: GetxId.sendTicket,
                    builder: (controller) {
                      return ConfirmSendTicketBottomSheet(
                        title: 'Withdrawal',
                        viaProposal: true,
                        isLoading: controller.withdrawalOrderResponse.state ==
                            NetworkState.loading,
                        onConfirm: () async {
                          await controller.createWithdrawalOrder();

                          if (controller.withdrawalOrderResponse.state ==
                              NetworkState.loaded) {
                            AutoRouter.of(context).push(
                              ProposalSuccessRoute(
                                client: controller.client,
                                productName: 'Create Withdrawal Order',
                                proposalUrl:
                                    controller.proposalResponse?.customerUrl ??
                                        "",
                              ),
                            );
                          }

                          if (controller.withdrawalOrderResponse.state ==
                              NetworkState.error) {
                            return showToast(
                              text: controller.withdrawalOrderResponse.message,
                            );
                          }
                        },
                      );
                    }),
              );
            },
            text: 'Send Proposal',
          )
        ],
      ),
    );
  }
}
