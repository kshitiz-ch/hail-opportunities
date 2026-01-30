import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/switch_order_controller.dart';
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

import '../widgets/add_edit_fund_bottomsheet.dart';
import '../widgets/switch_order_schemes_list.dart';

@RoutePage()
class ClientSwitchOrderScreen extends StatelessWidget {
  const ClientSwitchOrderScreen({
    Key? key,
    required this.client,
    required this.goalSchemes,
    required this.goal,
    this.anyFundGoalScheme,
  }) : super(key: key);

  final Client client;
  final List<UserGoalSubtypeSchemeModel> goalSchemes;
  final GoalModel goal;
  final UserGoalSubtypeSchemeModel? anyFundGoalScheme;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwitchOrderController>(
      init: SwitchOrderController(
        client: client,
        goalSchemes: goalSchemes,
        goal: goal,
        anyFundGoalScheme: anyFundGoalScheme,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Create Switch Order',
            subtitleText: '',
          ),
          body: Container(
            child: Builder(
              builder: (BuildContext context) {
                if (controller.switchOrderSchemes.isNotEmpty) {
                  return SwitchOrderSchemesList();
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
      BuildContext context, SwitchOrderController controller) {
    return Center(
      child: EmptyScreen(
        message:
            "No Funds ${controller.switchOutSchemes.isEmpty ? 'Found' : 'Selected'}",
        actionButtonText:
            controller.switchOutSchemes.isNotEmpty ? '+ Add Funds' : null,
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
      BuildContext context, SwitchOrderController controller) {
    if (controller.switchOrderSchemes.isEmpty) {
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
          ClickableText(
            text: '+ Add More Funds',
            fontSize: 16,
            onClick: () {
              CommonUI.showBottomSheet(
                context,
                child: AddEditFundBottomSheet(),
              );
            },
          ),
          // if (!controller.isAllFoliosSelected)
          SizedBox(height: 16),
          ActionButton(
            onPressed: () {
              CommonUI.showBottomSheet(
                context,
                child: GetBuilder<SwitchOrderController>(
                  id: GetxId.sendTicket,
                  builder: (controller) {
                    return ConfirmSendTicketBottomSheet(
                      viaProposal: true,
                      title: 'Switch',
                      isLoading: controller.switchOrderResponse.state ==
                          NetworkState.loading,
                      onConfirm: () async {
                        await controller.createSwitchOrder();

                        if (controller.switchOrderResponse.state ==
                            NetworkState.loaded) {
                          AutoRouter.of(context).push(
                            ProposalSuccessRoute(
                              client: controller.client,
                              productName: 'Create Switch Order',
                              proposalUrl:
                                  controller.ticketResponse?.customerUrl,
                            ),
                          );
                        }

                        if (controller.switchOrderResponse.state ==
                            NetworkState.error) {
                          return showToast(
                            text: controller.switchOrderResponse.message,
                          );
                        }
                      },
                    );
                  },
                ),
              );
            },
            text: 'Send Proposal',
          )
        ],
      ),
    );
  }
}
