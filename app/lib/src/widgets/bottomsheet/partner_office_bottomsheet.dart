import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/my_team/select_team_member_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnerOfficeBottomSheet extends StatelessWidget {
  const PartnerOfficeBottomSheet(
      {Key? key,
      this.title = '',
      this.showSelectAllButton = false,
      required this.onEmployeeSelect,
      this.enableAssosciates = true})
      : super(key: key);

  final String title;
  final bool enableAssosciates;
  final void Function(
          EmployeesModel? employee, List<String> agentExternalIdList)
      onEmployeeSelect;
  final bool showSelectAllButton;

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    String? partnerOfficeName;
    bool hasPartnerOfficeAssociates = false;
    if (homeController.hasPartnerOffice) {
      partnerOfficeName = homeController
          .advisorOverviewModel!.agentDesignation!.partnerOfficeName;

      hasPartnerOfficeAssociates = homeController.hasPartnerOfficeAssociates;
    }

    bool showPartnerOfficeAssociates = hasPartnerOfficeAssociates &&
        homeController.hasAssociateAccess &&
        enableAssosciates;

    return GetBuilder<SelectTeamMemberController>(
      init: SelectTeamMemberController(showSelectAllButton),
      builder: (controller) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 100),
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontSize: 18),
              ),
              SizedBox(height: 30),
              RadioButtons(
                items: [
                  DesignationType.Employee,
                  if (showPartnerOfficeAssociates) DesignationType.Member
                ],
                direction: Axis.vertical,
                selectedValue: controller.selectedDesignation,
                spacing: 30,
                itemBuilder: (context, value, index) {
                  String designationTypeDescription;
                  DesignationType designationType;

                  if (index == 0) {
                    designationType = DesignationType.Employee;
                    designationTypeDescription = 'Employees';
                  } else {
                    designationType = DesignationType.Member;
                    designationTypeDescription = 'Associates';
                  }
                  return Text(
                    '${partnerOfficeName ?? 'My Team'}\'s $designationTypeDescription',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displayMedium!
                        .copyWith(
                            fontSize: 16,
                            color: controller.selectedDesignation ==
                                    designationType
                                ? ColorConstants.black
                                : ColorConstants.tertiaryBlack),
                  );
                },
                onTap: (value) {
                  controller.updateDesignationType(value);
                },
              ),
              SizedBox(height: 40),
              Text(
                'Select any individual employee',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontSize: 16),
              ),
              SizedBox(height: 10),
              Flexible(
                child: controller.fetchEmployeesResponse.state ==
                        NetworkState.loading
                    ? _buildLoader()
                    : controller.fetchEmployeesResponse.state ==
                            NetworkState.loaded
                        ? _buildEmployeesList(controller,
                            showSelectAllButton: showSelectAllButton)
                        : _buildErrorState(controller),
              ),
              SizedBox(height: 20),
              ActionButton(
                text: 'Apply',
                isDisabled: showSelectAllButton
                    ? (controller.selectedAgentExternalIdList.isEmpty &&
                        controller.selectedTeamMember == null)
                    : controller.selectedTeamMember == null,
                margin: EdgeInsets.zero,
                onPressed: () {
                  if (controller.isAllTeamMembersSelected) {
                    onEmployeeSelect(
                        EmployeesModel.fromJson({
                          "firstName":
                              "$partnerOfficeName ${controller.selectedDesignation == DesignationType.Employee ? 'Employee' : 'Associate'}"
                        }),
                        controller.selectedAgentExternalIdList);
                  } else {
                    onEmployeeSelect(
                      controller.selectedTeamMember,
                      [],
                    );
                  }

                  AutoRouter.of(context).popForced();
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoader() {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: ColorConstants.lightBackgroundColor,
            ),
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          ),
        );
      },
    );
  }

  Widget _buildErrorState(SelectTeamMemberController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: RetryWidget(
        'Failed to load. Try again',
        onPressed: () {
          controller.getEmployees();
        },
      ),
    );
  }

  Widget _buildEmployeesList(SelectTeamMemberController controller,
      {bool showSelectAllButton = false}) {
    List<EmployeesModel> employeeListToShow =
        controller.selectedDesignation == DesignationType.Employee
            ? controller.employees
            : controller.members;

    if (employeeListToShow.isEmpty) {
      return EmptyScreen(
          message:
              'No ${controller.selectedDesignation == DesignationType.Employee ? 'Employees' : 'Associates'} Found');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: employeeListToShow.length + (showSelectAllButton ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (showSelectAllButton && index == 0) {
          return _buildSelectAllButton(context, controller);
        }

        int currentIndex;
        if (showSelectAllButton) {
          currentIndex = index - 1;
        } else {
          currentIndex = index;
        }

        EmployeesModel employeeModel = employeeListToShow[currentIndex];

        bool isEmployeeSelected = controller.selectedTeamMember?.externalId ==
            employeeModel.externalId;

        if ((employeeModel.firstName == null &&
                employeeModel.lastName == null &&
                employeeModel.email == null) ||
            employeeModel.agentExternalId == null) {
          return SizedBox();
        }

        String displayName = '';
        if (employeeModel.firstName == null && employeeModel.lastName == null) {
          displayName = employeeModel.email ?? '';
        } else {
          displayName = (employeeModel.firstName ?? '') +
              ' ' +
              (employeeModel.lastName ?? '');
        }

        return InkWell(
          onTap: () {
            controller.updateSelectedTeamMember(employeeModel);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isEmployeeSelected
                        ? ColorConstants.primaryAppColor
                        : ColorConstants.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isEmployeeSelected
                          ? ColorConstants.primaryAppColor
                          : ColorConstants.lightGrey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.done,
                      size: 10,
                      color: ColorConstants.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    displayName.toLowerCase().toTitleCase(),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displayMedium!
                        .copyWith(
                          fontSize: 16,
                          color: isEmployeeSelected
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack,
                        ),
                  ),
                )
              ],
            ),
          ),
        );
        // return _buildMemberCard();
      },
    );
  }

  Widget _buildSelectAllButton(
    BuildContext context,
    SelectTeamMemberController controller,
  ) {
    return InkWell(
      onTap: () {
        controller.selectAllTeamMembers();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 8),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: controller.isAllTeamMembersSelected
                    ? ColorConstants.primaryAppColor
                    : ColorConstants.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: controller.isAllTeamMembersSelected
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.lightGrey,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.done,
                  size: 10,
                  color: ColorConstants.white,
                ),
              ),
            ),
            Text(
              'All ${controller.selectedDesignation == DesignationType.Employee ? 'Employees' : 'Associates'}',
              style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                    fontSize: 16,
                    color: controller.isAllTeamMembersSelected
                        ? ColorConstants.black
                        : ColorConstants.tertiaryBlack,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
