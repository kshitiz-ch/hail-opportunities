import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/create_swp_controller.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/add_edit_swp_fund_bottomsheet.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_basket_list.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/confirm_send_ticket_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientSwpScreen extends StatelessWidget {
  final goalController = Get.find<GoalController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateSwpController>(
      init: CreateSwpController(
        goal: goalController.goal!,
        client: goalController.client,
        goalSchemes: goalController.goalSchemes,
        goalId: goalController.goalId,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Systematic Withdrawal Plan',
          ),
          body: Builder(
            builder: (context) {
              // For AnyFund, open add fund bottomsheet
              if (controller.schemeWithFolios.isNotEmpty &&
                  controller.openAddFundBottomSheet) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  CommonUI.showBottomSheet(
                    context,
                    child: AddEditSwpFundBottomSheet(),
                  );
                  controller.openAddFundBottomSheet = false;
                });
              }

              if (controller.selectedSwpSchemes.isNotEmpty) {
                return SwpBasketList();
              }

              return _buildEmptyState(context, controller);
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildActionButton(context, controller),
        );
      },
    );
  }

  Widget _buildEmptyState(
      BuildContext context, CreateSwpController controller) {
    return Center(
      child: EmptyScreen(
        message:
            "No Funds ${controller.schemeWithFolios.isEmpty ? 'Found' : 'Selected'}",
        actionButtonText:
            controller.schemeWithFolios.isNotEmpty ? '+ Add Funds' : null,
        onClick: () {
          controller.resetForm();
          CommonUI.showBottomSheet(
            context,
            child: AddEditSwpFundBottomSheet(),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, CreateSwpController controller) {
    if (controller.selectedSwpSchemes.isEmpty) {
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
                  child: AddEditSwpFundBottomSheet(),
                );
              },
            ),
          SizedBox(height: 16),
          ActionButton(
            onPressed: () {
              CommonUI.showBottomSheet(
                context,
                child: GetBuilder<CreateSwpController>(
                    id: GetxId.sendTicket,
                    builder: (controller) {
                      return ConfirmSendTicketBottomSheet(
                        title: 'SWP',
                        viaProposal: true,
                        isLoading: controller.createSwpResponse.state ==
                            NetworkState.loading,
                        onConfirm: () async {
                          await controller.createSWP();

                          if (controller.createSwpResponse.state ==
                              NetworkState.loaded) {
                            AutoRouter.of(context).push(
                              ProposalSuccessRoute(
                                client: controller.client,
                                productName: 'Create Swp',
                                proposalUrl:
                                    controller.ticketResponse?.customerUrl,
                              ),
                            );
                          }

                          if (controller.createSwpResponse.state ==
                              NetworkState.error) {
                            return showToast(
                              text: controller.createSwpResponse.message,
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
