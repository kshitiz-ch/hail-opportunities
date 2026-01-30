import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/reassign_client_controller.dart';
import 'package:app/src/screens/clients/client_list/widgets/reassign_success_bottomsheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/new_search_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseEmployeeBottomsheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: SizeConfig().screenHeight * 0.8),
      child: GetBuilder<ReassignClientController>(
        id: 'employee',
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Employee ',
                      style: context.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                    ),
                    CommonUI.bottomsheetCloseIcon(context),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Choose Employee to assign ',
                          style: context.headlineSmall
                              ?.copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                        TextSpan(
                          text: getClientAssignmentText(
                              controller.reassignClientMap.values.toList()),
                          style: context.headlineSmall
                              ?.copyWith(color: ColorConstants.black),
                        ),
                        TextSpan(
                          text: ' clients',
                          style: context.headlineSmall
                              ?.copyWith(color: ColorConstants.tertiaryBlack),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 30),
                  child: NewSearchBar(
                    searchController: controller.searchEmployeeController,
                    hintText: 'Search for Employee',
                    onClear: () {
                      controller.clearEmployeeSearchBar();
                    },
                    onChanged: (value) {
                      controller.searchEmployee(value);
                    },
                  ),
                ),
                Expanded(
                  child: _buildEmployeelist(context, controller),
                ),
                _buildReassignCTA(
                  context: context,
                  isDisabled: controller.employees.isNullOrEmpty ||
                      controller.reassignTargetEmployee == null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeelist(
      BuildContext context, ReassignClientController controller) {
    if (controller.fetchEmployeesResponse.state == NetworkState.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.fetchEmployeesResponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          'Error getting employee list',
          onPressed: () {
            controller.getEmployees();
          },
        ),
      );
    }
    if (controller.employees.isNullOrEmpty) {
      return EmptyScreen(
        imagePath: AllImages().clientSearchEmptyIcon,
        imageSize: 92,
        message: 'No Employees Found!',
      );
    }
    return ListView.separated(
      itemCount: controller.employees.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildEmployeeTile(
            controller: controller,
            context: context,
            index: index - 1,
          );
        }
        return _buildEmployeeTile(
          controller: controller,
          context: context,
          index: index - 1,
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: 10),
    );
  }

  Widget _buildEmployeeTile({
    required ReassignClientController controller,
    required BuildContext context,
    required int index,
  }) {
    final isOwner = index < 0;
    final employee = isOwner ? controller.owner : controller.employees[index];
    final checkBoxValue = controller.reassignTargetEmployee != null &&
        controller.reassignTargetEmployee!.agentExternalId ==
            employee?.agentExternalId;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.secondarySeparatorColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: ColorConstants.primaryAppColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              isOwner
                  ? AllImages().ownerAgentIcon
                  : AllImages().employeeAgentIcon,
              height: 24,
              width: 24,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: CommonUI.buildColumnTextInfo(
                title:
                    '${isOwner ? 'Owner' : employee?.name ?? ''} (${employee?.customersCount} Clients)',
                subtitle:
                    'AUM ${WealthyAmount.currencyFormat(employee?.aum, 0)}',
                subtitleStyle: context.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
                titleStyle: context.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: CommonUI.buildCheckbox(
              value: checkBoxValue,
              unselectedBorderColor: ColorConstants.darkGrey,
              onChanged: (bool? value) {
                if (value == true) {
                  controller.reassignTargetEmployee = employee;
                } else {
                  controller.reassignTargetEmployee = null;
                }
                controller.update(['employee']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReassignCTA(
      {required BuildContext context, required bool isDisabled}) {
    return GetBuilder<ReassignClientController>(
      id: 'assign-unassign-client',
      builder: (controller) {
        return ActionButton(
          margin: EdgeInsets.zero,
          text: 'Confirm Reassign',
          isDisabled: isDisabled,
          onPressed: () async {
            await controller.assignUnassignClient();
            if (controller.assignUnassignResponse.state == NetworkState.error) {
              showToast(text: controller.assignUnassignResponse.message);
            }
            if (controller.assignUnassignResponse.state ==
                NetworkState.loaded) {
              CommonUI.showBottomSheet(
                context,
                child: ReassignSuccessBottomsheet(
                  clientList: controller.reassignClientMap.values.toList(),
                  employeeName: controller.reassignTargetEmployee?.name ?? '',
                ),
                isDismissible: false,
              );
            }
          },
        );
      },
    );
  }
}
