import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/stp_detail_controller.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/goal_inputs/amount_input.dart';
import 'package:app/src/widgets/input/goal_inputs/dates_selector.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_date_input.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_status_switch.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class EditStpFormScreen extends StatelessWidget {
  const EditStpFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Edit STP',
      ),
      body: GetBuilder<StpDetailController>(
        id: GetxId.form,
        builder: (controller) {
          double minAmount = controller.switchInSchemeData?.minDepositAmt ?? 0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(30).copyWith(top: 20, bottom: 100),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: DatesSelector(
                      orderType: 'STP',
                      selectedDays: controller.selectedDays,
                      onChanged: (value) {
                        controller.updateStpDays(value);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: AmountInput(
                      amountController: controller.amountController,
                      minAmount: minAmount,
                      validator: (value) {
                        if (value?.isNullOrEmpty ?? true) {
                          return 'This fields is required';
                        }

                        if ((double.tryParse(value!) ?? 0) < minAmount) {
                          return 'Min Amount should be ${WealthyAmount.currencyFormat(minAmount, 0)}';
                        }

                        return null;
                      },
                    ),
                  ),

                  // Start Date
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: GoalDateInput(
                      controller: controller.startDateController,
                      label: 'Start Date',
                      onDateSelect: controller.updateStartDate,
                    ),
                  ),

                  // End Date
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: GoalDateInput(
                      controller: controller.endDateController,
                      label: 'End Date',
                      onDateSelect: controller.updateEndDate,
                      startDate: controller.startDate,
                    ),
                  ),

                  _buildStpStatusSwitch()
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FixedCenterDockedFabLocation(),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildStpStatusSwitch() {
    return GetBuilder<StpDetailController>(
      builder: (controller) {
        return GoalStatusSwitch(
          isActive: controller.isActive,
          orderType: 'STP',
          onChanged: (value) {
            controller.toggleIsActive(value);
          },
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<StpDetailController>(
      id: GetxId.sendTicket,
      builder: (controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return ActionButton(
              heroTag: kDefaultHeroTag,
              text: 'Update & Save',
              showProgressIndicator: controller.updateStpOrderResponse.state ==
                  NetworkState.loading,
              margin: EdgeInsets.symmetric(
                vertical: isKeyboardVisible ? 0 : 24.0,
                horizontal: isKeyboardVisible ? 0 : 30.0,
              ),
              borderRadius: isKeyboardVisible ? 0.0 : 51.0,
              onPressed: () async {
                if (controller.selectedDays.isEmpty) {
                  return showToast(text: 'Please select days for STP');
                }

                if (controller.formKey.currentState!.validate()) {
                  if (!controller.client.isProposalEnabled) {
                    CommonUI.showBottomSheet(
                      context,
                      child: ClientNonIndividualWarningBottomSheet(),
                    );
                  } else {
                    await controller.updateStpOrder();
                    if (controller.updateStpOrderResponse.state ==
                        NetworkState.loaded) {
                      AutoRouter.of(context).push(
                        ProposalSuccessRoute(
                          client: controller.client,
                          productName: 'Edit Stp',
                          proposalUrl: controller.ticketResponse?.customerUrl,
                        ),
                      );
                    } else if (controller.updateStpOrderResponse.state ==
                        NetworkState.error) {
                      showToast(
                        text: controller.updateStpOrderResponse.message,
                      );
                    }
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}
