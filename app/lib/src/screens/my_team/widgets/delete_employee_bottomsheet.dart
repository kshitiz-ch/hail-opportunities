import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/screens/my_team/widgets/team_actions_success_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteEmployeeBottomsheet extends StatelessWidget {
  final EmployeesModel employee;

  const DeleteEmployeeBottomsheet({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delete Employee',
                style: context.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                  fontSize: 18,
                ),
              ),
              CommonUI.bottomsheetCloseIcon(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 42, bottom: 10),
            child: Center(
              child: Text(
                'Once you delete an employee, all Clients and AUM will be assigned to you (Owner)',
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            ),
          ),
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Are you sure you want to delete ',
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.tertiaryBlack,
                ),
                children: [
                  TextSpan(
                    text: '${employee.name} ?',
                    style: context.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: _buildCTA(context),
          )
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    final style = context.headlineMedium?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            margin: EdgeInsets.zero,
            height: 56,
            text: 'Cancel',
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
            bgColor: ColorConstants.secondaryButtonColor,
            textStyle: style?.copyWith(color: ColorConstants.primaryAppColor),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GetBuilder<MyTeamController>(
            id: 'remove-employee',
            builder: (controller) {
              return ActionButton(
                progressIndicatorColor: ColorConstants.errorColor,
                showProgressIndicator:
                    controller.removeEmployeeResponse.state ==
                        NetworkState.loading,
                margin: EdgeInsets.zero,
                height: 56,
                text: 'Delete',
                onPressed: () async {
                  await controller.removeEmployee(employee.externalId ?? '');
                  if (controller.removeEmployeeResponse.state ==
                      NetworkState.error) {
                    showToast(text: controller.removeEmployeeResponse.message);
                  }
                  if (controller.removeEmployeeResponse.state ==
                      NetworkState.loaded) {
                    CommonUI.showBottomSheet(
                      context,
                      child: TeamActionsSuccessBottomsheet(
                        titleText: controller.removeEmployeeResponse.message,
                        onGotIt: () {
                          controller.getEmployees();
                          AutoRouter.of(context)
                              .popUntilRouteWithName(MyTeamRoute.name);
                        },
                      ),
                      isDismissible: false,
                    );
                  }
                },
                bgColor: ColorConstants.lightRedColor,
                textStyle: style?.copyWith(color: ColorConstants.errorColor),
              );
            },
          ),
        ),
      ],
    );
  }
}
