import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/screens/my_team/widgets/add_employee_bottomsheet.dart';
import 'package:app/src/screens/my_team/widgets/agent_card.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/new_search_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List designationTypes = ['Employees', 'Associates'];

class OwnerTeamSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyTeamController>(
      builder: (controller) {
        return Column(
          children: [
            IgnorePointer(
              ignoring: controller.fetchEmployeesResponse.state ==
                  NetworkState.loading,
              child: _buildTabs(context, controller),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
              child: NewSearchBar(
                searchController: controller.searchController,
                hintText:
                    'Search ${controller.isEmployeeTabActive ? "Employee" : "Assosciate"} by name, email and phone',
                onClear: () {
                  controller.clearSearchBar();
                },
                onChanged: (value) {
                  if (value != controller.searchQuery) {
                    controller.searchQuery = value;
                    controller.search(value);
                  }
                },
              ),
            ),
            Expanded(
              child: _buildTabBarView(context, controller),
            )
          ],
        );
      },
    );
  }

  Widget _buildTabs(BuildContext context, MyTeamController controller) {
    return Container(
      height: 54,
      color: Colors.white,
      child: TabBar(
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: controller.tabController,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle:
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: ColorConstants.black,
        labelStyle: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: ColorConstants.black, fontWeight: FontWeight.w600),
        tabs: List<Widget>.generate(
          controller.tabLength,
          (index) => Container(
            width: SizeConfig().screenWidth! / controller.tabLength,
            alignment: Alignment.center,
            child: GetBuilder<MyTeamController>(
              builder: (controller) {
                String tabText;
                late int count;

                MixPanelAnalytics.trackWithAgentId(
                  index == 0 ? "employees" : "associates",
                  screen: 'my_team',
                  screenLocation: 'wealthy_trial_office',
                );

                if (index == 0) {
                  count = controller.employees.length;
                } else if (index == 1) {
                  count = controller.members.length;
                }
                if (count > 0) {
                  tabText = '${designationTypes[index]} ($count)';
                } else {
                  tabText = designationTypes[index];
                }
                return Tab(
                  text: tabText,
                  iconMargin: EdgeInsets.zero,
                );
              },
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, MyTeamController controller) {
    if (controller.fetchEmployeesResponse.state == NetworkState.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.fetchEmployeesResponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          controller.fetchEmployeesResponse.message,
          onPressed: () {
            controller.getEmployees();
          },
        ),
      );
    }

    return _buildList(
      controller.tabController?.index == 0
          ? controller.employees
          : controller.members,
      context,
      isEmployee: controller.tabController?.index == 0,
      isSearching: controller.searchQuery.isNotEmpty,
    );
  }

  Widget _buildList(List<EmployeesModel> agents, BuildContext context,
      {bool isEmployee = true, bool isSearching = false}) {
    if (agents.isEmpty) {
      return _buildEmptyState(
        isEmployee: isEmployee,
        isSearching: isSearching,
        context: context,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: ClampingScrollPhysics(),
      itemCount: agents.length,
      itemBuilder: (BuildContext context, int index) {
        return AgentCard(
          agentData: agents[index],
          isEmployee: isEmployee,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return CommonUI.buildProfileDataSeperator(
          height: 1,
          width: double.infinity,
          color: ColorConstants.secondarySeparatorColor,
        );
      },
    );
  }

  Widget _buildEmptyState({
    bool? isEmployee,
    required bool isSearching,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AllImages().teamEmptyIcon,
            width: 70,
          ),
          SizedBox(height: 20),
          if (isSearching)
            Text('No ${isEmployee! ? 'employees' : 'associates'} found',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w500))
          else
            Text(
                'You dont have any ${isEmployee! ? 'employees' : 'associates'}',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w500)),
          SizedBox(height: 24),
          // removed add associates
          if (!isSearching && isEmployee)
            ActionButton(
              text: 'Add ${isEmployee ? 'Employee' : 'Associate'}',
              // margin: EdgeInsets.zero,
              onPressed: () {
                CommonUI.showBottomSheet(
                  context,
                  child: AddEmployeeBottomSheet(
                    designationType: isEmployee
                        ? DesignationType.Employee
                        : DesignationType.Member,
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
