import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/screens/my_team/widgets/add_employee_bottomsheet.dart';
import 'package:app/src/screens/my_team/widgets/edit_team_name_bottomsheet.dart';
import 'package:app/src/screens/my_team/widgets/owner_team_section.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class MyTeamScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyTeamController>(
      init: MyTeamController(),
      builder: (controller) {
        if (controller.fetchAgentDesignationResponse.state ==
            NetworkState.loading) {
          return _buildScreenLoader();
        }

        if (controller.fetchAgentDesignationResponse.state ==
            NetworkState.error) {
          return _buildScreenError(
            controller.fetchAgentDesignationResponse.message,
            () {
              controller.getAgentDesignation();
            },
          );
        }

        late String titleText = '';
        late Widget body;
        bool isOwner = false;

        if (controller.agentDesignationModel.designation == "agent" &&
            !controller.isAgentPartOfTeam) {
          body = _buildNoTeamSection(context);
          titleText = 'My Team';
        } else if (controller.agentDesignationModel.designation != "owner" &&
            controller.isAgentPartOfTeam) {
          body = _buildAgentPartOfTeamSection(
            controller.agentDesignationModel.partnerOfficeName ?? 'My Team',
            context,
          );
          titleText = 'My Team';
        } else {
          body = OwnerTeamSection();
          titleText =
              "${controller.agentDesignationModel.partnerOfficeName ?? 'My Team'}'s Team";
          isOwner = true;
        }

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            backgroundColor: ColorConstants.aliceBlueColor,
            customTitleWidget:
                isOwner ? _buildOwnerTitleWidget(titleText, context) : null,
            titleText: isOwner ? '' : titleText,
            trailingWidgets: [
              // removed add associates
              if (isOwner && controller.isEmployeeTabActive)
                _buildAddEmployeeCTA(
                  context,
                  controller.isEmployeeTabActive,
                )
            ],
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildScreenLoader() {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        backgroundColor: ColorConstants.aliceBlueColor,
        titleText: 'My Team',
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildScreenError(String errorMessage, Function onRetry) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        backgroundColor: ColorConstants.aliceBlueColor,
        titleText: 'My Team',
      ),
      body: Center(
        child: RetryWidget(
          errorMessage,
          onPressed: () {
            onRetry();
          },
        ),
      ),
    );
  }

  Widget _buildAgentPartOfTeamSection(
      String partnerOfficeName, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AllImages().teamEmptyIcon,
              width: 90,
            ),
            SizedBox(height: 40),
            Text(
              "You are part of $partnerOfficeName's team",
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTeamSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AllImages().teamEmptyIcon,
              width: 90,
            ),
            SizedBox(height: 40),
            Text('You haven\'t created your Team yet',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w500)),
            SizedBox(height: 6),
            Text(
                'Create your team to add your employees and associates and to monitor them in one place',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack)),
            SizedBox(height: 34),
            ActionButton(
              text: 'Create Team',
              margin: EdgeInsets.zero,
              onPressed: () {
                AutoRouter.of(context).push(CreateTeamFormRoute());
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddEmployeeCTA(BuildContext context, bool isEmployee) {
    return SizedBox(
      width: 120,
      child: ActionButton(
        height: 32,
        text: isEmployee ? 'Add Employee' : 'Add Associates',
        bgColor: ColorConstants.aliceBlueColor,
        showBorder: true,
        borderColor: ColorConstants.primaryAppColor,
        margin: EdgeInsets.all(5),
        textStyle: context.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.primaryAppColor,
        ),
        onPressed: () {
          MixPanelAnalytics.trackWithAgentId(
            isEmployee ? "add_new_employee" : "add_new_associate",
            screen: 'my_team',
            screenLocation: 'wealthy_trial_office',
          );

          CommonUI.showBottomSheet(
            context,
            child: AddEmployeeBottomSheet(
              designationType: isEmployee
                  ? DesignationType.Employee
                  : DesignationType.Member,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOwnerTitleWidget(String titleText, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: MarqueeWidget(
            child: Text(
              titleText,
              style: context.headlineMedium!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            CommonUI.showBottomSheet(
              context,
              child: EditTeamNameBottomsheet(),
              isScrollControlled: true,
              isDismissible: false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              Icons.edit,
              color: ColorConstants.primaryAppColor,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
