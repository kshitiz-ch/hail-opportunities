import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/swp_detail_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/edit_swp_form_fields.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/goal_inputs/dates_selector.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_status_switch.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class EditSwpScreen extends StatelessWidget {
  EditSwpScreen() {
    final controller = Get.find<SwpDetailController>();
    controller.prefillSWPFormData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Edit SWP',
        subtitleText: 'Easily customize your SWP',
      ),
      body: GetBuilder<SwpDetailController>(
        builder: (controller) {
          if (controller.fundMinWithdrawalResponse.state ==
              NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(30).copyWith(top: 20, bottom: 100),
            child: Form(
              key: controller.schemeFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: DatesSelector(
                      orderType: 'SWP',
                      selectedDays: controller.updatedSwp.days ?? [],
                      onChanged: (selectedDays) {
                        controller.updateDays(selectedDays);
                      },
                    ),
                  ),
                  EditSWPFormField(),
                  SizedBox(height: 40),
                  _buildSwpStatusSwitch()
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

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<SwpDetailController>(
      builder: (SwpDetailController controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return ActionButton(
              heroTag: kDefaultHeroTag,
              text: 'Update & Save',
              showProgressIndicator:
                  controller.editSwpResponse.state == NetworkState.loading,
              margin: EdgeInsets.symmetric(
                vertical: isKeyboardVisible ? 0 : 24.0,
                horizontal: isKeyboardVisible ? 0 : 30.0,
              ),
              borderRadius: isKeyboardVisible ? 0.0 : 51.0,
              onPressed: () async {
                await onPressCTA(controller, context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> onPressCTA(
    SwpDetailController controller,
    BuildContext context,
  ) async {
    if (!controller.client.isProposalEnabled) {
      CommonUI.showBottomSheet(
        context,
        child: ClientNonIndividualWarningBottomSheet(),
      );
    } else {
      if (controller.schemeFormKey.currentState!.validate()) {
        if (controller.updatedSwp.startDate!
            .isAfter(controller.updatedSwp.endDate!)) {
          showToast(text: 'End Date should be after the Start Date');
          return;
        }
        if (controller.updatedSwp.days.isNullOrEmpty) {
          showToast(text: 'Select SWP days');
          return;
        }
        await controller.editSWP();
        if (controller.editSwpResponse.state == NetworkState.loaded) {
          AutoRouter.of(context).push(
            ProposalSuccessRoute(
              client: controller.client,
              productName: 'Edit Swp',
              proposalUrl: controller.ticketResponse?.customerUrl,
            ),
          );
        } else if (controller.editSwpResponse.state == NetworkState.error) {
          showToast(
            text: controller.editSwpResponse.message,
          );
        }
      }
    }
  }

  Widget _buildSwpStatusSwitch() {
    return GetBuilder<SwpDetailController>(
      builder: (controller) {
        final isActive = !(controller.updatedSwp.isPaused ?? false);
        return GoalStatusSwitch(
          isActive: isActive,
          orderType: 'SWP',
          onChanged: (value) {
            controller.updateStatus(!value);
          },
        );
      },
    );
  }
}
