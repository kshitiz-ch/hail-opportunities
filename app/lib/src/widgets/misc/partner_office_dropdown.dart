import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/partner_office_dropdown_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnerOfficeDropdown extends StatelessWidget {
  final String title;
  final bool canSelectAllEmployees;
  final bool canSelectPartnerOffice;
  final String tag;
  EmployeesModel? selectedEmployee;

  final void Function(PartnerOfficeModel) onEmployeeSelect;

  PartnerOfficeDropdown({
    Key? key,
    required this.onEmployeeSelect,
    required this.title,
    required this.tag,
    this.selectedEmployee,
    this.canSelectAllEmployees = true,
    this.canSelectPartnerOffice = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    String? partnerOfficeName;
    if (homeController.hasPartnerOffice) {
      partnerOfficeName = homeController
              .advisorOverviewModel!.agentDesignation!.partnerOfficeName ??
          'Your';
    } else {
      return SizedBox();
    }

    return GetBuilder<PartnerOfficeDropdownController>(
        tag: tag,
        init:
            PartnerOfficeDropdownController(selectedEmployee: selectedEmployee),
        builder: (controller) {
          String? employeeSelectedName;
          if (controller.isPartnerOfficeSelected) {
            employeeSelectedName = '$partnerOfficeName';
          } else if (controller.isAllTeamMembersSelected) {
            employeeSelectedName = 'All Employees';
          } else {
            employeeSelectedName =
                (controller.selectedEmployee?.firstName ?? '') +
                    ' ' +
                    (controller.selectedEmployee?.lastName ?? '');
          }

          if (employeeSelectedName.trim().isNullOrEmpty) {
            return SizedBox();
          }

          return Align(
            child: InkWell(
              onTap: () {
                CommonUI.showBottomSheet(
                  context,
                  child: PartnerOfficeDropdownBottomSheet(
                    title: title,
                    onEmployeeSelect: onEmployeeSelect,
                    canSelectAllEmployees: canSelectAllEmployees,
                    tag: tag,
                    canSelectPartnerOffice: canSelectPartnerOffice,
                  ),
                  isScrollControlled: false,
                );
              },
              child: Container(
                height: 35,
                constraints: BoxConstraints(maxWidth: 150),
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorConstants.primaryAppColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: MarqueeWidget(
                        child: Text(
                          employeeSelectedName,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: ColorConstants.primaryAppColor),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: ColorConstants.primaryAppColor,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class PartnerOfficeDropdownBottomSheet extends StatelessWidget {
  final String title;
  final String tag;
  final bool canSelectAllEmployees;
  final void Function(PartnerOfficeModel) onEmployeeSelect;
  final bool canSelectPartnerOffice;

  const PartnerOfficeDropdownBottomSheet({
    Key? key,
    required this.onEmployeeSelect,
    required this.title,
    required this.tag,
    this.canSelectAllEmployees = true,
    this.canSelectPartnerOffice = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerOfficeDropdownController>(
      tag: tag,
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
                'Show $title of',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontSize: 18),
              ),
              SizedBox(height: 40),
              Flexible(
                child: controller.fetchEmployeesResponse.state ==
                        NetworkState.loading
                    ? _buildLoader()
                    : controller.fetchEmployeesResponse.state ==
                            NetworkState.loaded
                        ? _buildEmployeesList(controller, context)
                        : _buildErrorState(controller),
              ),
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

  Widget _buildErrorState(PartnerOfficeDropdownController controller) {
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

  Widget _buildEmployeesList(
    PartnerOfficeDropdownController controller,
    BuildContext context,
  ) {
    if (controller.employees.isEmpty) {
      return Center(
        child: EmptyScreen(
          message: 'No Employees Found',
          actionButtonText: 'Add Employee',
          onClick: () async {
            AutoRouter.of(context).popForced();
            await AutoRouter.of(context).push(MyTeamRoute());
            controller.getEmployees();
          },
        ),
      );
    }

    String selfAgentName = (controller.ownerAgent.firstName ?? '') +
        ' ' +
        (controller.ownerAgent.lastName ?? '');

    final homeController = Get.find<HomeController>();

    String? partnerOfficeName;
    if (homeController.hasPartnerOffice) {
      partnerOfficeName = homeController
              .advisorOverviewModel!.agentDesignation!.partnerOfficeName ??
          'Your';
    }

    return ListView(
      shrinkWrap: true,
      children: [
        // Build Partner Office
        if (canSelectPartnerOffice)
          _buildEmployeesTile(
            context,
            isSelected: controller.isPartnerOfficeSelected,
            displayName: '${(partnerOfficeName ?? '')} (Office)',
            onSelect: () {
              controller.selectPartnerOffice();
              final partnerOfficeModel = PartnerOfficeModel(
                partnerEmployeeSelected: EmployeesModel(
                  firstName: partnerOfficeName,
                  designation: 'partner-office',
                ),
                partnerEmployeeExternalIdList: [
                  controller.ownerAgent.agentExternalId!,
                  ...controller.agentExternalIdList
                ],
              );
              onEmployeeSelect(partnerOfficeModel);
            },
          ),
        // Build All Employees
        if (canSelectAllEmployees)
          _buildEmployeesTile(
            context,
            isSelected: controller.isAllTeamMembersSelected,
            displayName: 'All Employees',
            onSelect: () {
              controller.selectAllEmployees();
              final partnerOfficeModel = PartnerOfficeModel(
                partnerEmployeeExternalIdList: controller.agentExternalIdList,
              );
              onEmployeeSelect(partnerOfficeModel);
            },
          ),
        // Build self agent
        _buildEmployeesTile(
          context,
          isSelected: controller.selectedEmployee?.agentExternalId ==
              controller.ownerAgent.agentExternalId,
          displayName: '$selfAgentName (Owner)',
          onSelect: () {
            controller.updateEmployeeSelected(controller.ownerAgent);
            final partnerOfficeModel = PartnerOfficeModel(
              partnerEmployeeSelected: controller.ownerAgent,
              partnerEmployeeExternalIdList: [],
            );
            onEmployeeSelect(partnerOfficeModel);
          },
        ),
        // Build All employees list
        ...List<Widget>.generate(
          controller.employees.length,
          (index) => _buildEmployees(controller, context, index),
        ),
      ],
    );
  }

  Widget _buildEmployees(
    PartnerOfficeDropdownController controller,
    BuildContext context,
    int index,
  ) {
    EmployeesModel employeeModel = controller.employees[index];

    bool isEmployeeSelected =
        controller.selectedEmployee?.externalId == employeeModel.externalId;

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

    return _buildEmployeesTile(
      context,
      isSelected: isEmployeeSelected,
      displayName: displayName,
      onSelect: () {
        controller.updateEmployeeSelected(employeeModel);
        final partnerOfficeModel = PartnerOfficeModel(
          partnerEmployeeSelected: employeeModel,
          partnerEmployeeExternalIdList: [],
        );
        onEmployeeSelect(partnerOfficeModel);
      },
    );
  }

  Widget _buildEmployeesTile(context,
      {required String displayName,
      required bool isSelected,
      required void Function() onSelect}) {
    return InkWell(
      onTap: () {
        onSelect();
        AutoRouter.of(context).popForced();
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
                color: isSelected
                    ? ColorConstants.primaryAppColor
                    : ColorConstants.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
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
                displayName,
                style:
                    Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                          fontSize: 16,
                          color: isSelected
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack,
                        ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
