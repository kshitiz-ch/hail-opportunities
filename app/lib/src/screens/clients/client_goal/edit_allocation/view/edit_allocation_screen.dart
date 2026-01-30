import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/screens/clients/client_goal/edit_allocation/widgets/edit_allocation_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class EditAllocationScreen extends StatelessWidget {
  final controller = Get.find<GoalController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Edit Allocation',
        onBackPress: () {
          AutoRouter.of(context).popForced();
        },
      ),
      body: ListView.separated(
        padding: EdgeInsets.only(bottom: 50),
        itemCount: controller.editedGoalSchemes.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 20),
        itemBuilder: (BuildContext context, int index) {
          return EditAllocationCard(goalIndex: index);
        },
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildActionButton(context),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<GoalController>(
      id: 'update-goal',
      builder: (controller) {
        return ActionButton(
          showProgressIndicator:
              controller.updateGoalResponse.state == NetworkState.loading,
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          text: 'Update & Save',
          onPressed: () async {
            await controller.updateGoal();
            if (controller.updateGoalResponse.state == NetworkState.error) {
              showToast(text: controller.updateGoalResponse.message);
            }
            if (controller.updateGoalResponse.state == NetworkState.loaded) {
              showToast(text: 'Goal Fund Allocation has been updated');
              AutoRouter.of(context).popForced();
            }
          },
        );
      },
    );
  }
}
