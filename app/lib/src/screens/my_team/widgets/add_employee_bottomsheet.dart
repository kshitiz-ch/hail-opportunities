import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/my_team/add_team_member_controller.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEmployeeBottomSheet extends StatelessWidget {
  List<List<String>> options = [
    [
      'Existing Wealthy User',
      'If the person you are trying to add already has an\n account with Wealthy'
    ],
    ['Add New User', 'Enter details to add a new user'],
  ];

  AddEmployeeBottomSheet({
    Key? key,
    this.designationType,
  }) : super(key: key);

  DesignationType? designationType;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddTeamMemberController>(
      init: AddTeamMemberController(designation: designationType!.name),
      // dispose: (_) => {
      //   if (Get.isRegistered<GstController>()) {Get.delete<GstController>()}
      // },
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 30),
                child: Text(
                  'Choose method to add ${designationType == DesignationType.Employee ? 'Employee' : 'Associate'}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                      ),
                ),
              ),
              RadioButtons(
                items: [
                  NewMemberAdditionMethod.EXISTING_USER,
                  NewMemberAdditionMethod.NEW_USER
                ],
                selectedValue: controller.selectedMethod,
                spacing: 30,
                itemBuilder: (context, value, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          options[index][0],
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Text(
                            options[index][1],
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: ColorConstants.tertiaryGrey),
                          ),
                        ),
                      ],
                    ),
                    // child: CommonUI.buildColumnTextInfo(
                    //   title: options[index][0],
                    //   subtitle: options[index][1],
                    //   gap: 8,
                    //   subtitleMaxLength: 2,
                    //   titleStyle:
                    //       Theme.of(context).primaryTextTheme.headlineSmall.copyWith(
                    //             fontWeight: FontWeight.w600,
                    //             color: Colors.black,
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //   subtitleStyle:
                    //       Theme.of(context).primaryTextTheme.titleLarge.copyWith(
                    //             fontWeight: FontWeight.w400,
                    //             color: ColorConstants.tertiaryGrey,
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    // ),
                  );
                },
                direction: Axis.vertical,
                onTap: (value) {
                  MixPanelAnalytics.trackWithAgentId(
                    designationType == DesignationType.Employee
                        ? "option_selection_employee"
                        : "option_selection_associate",
                    screen: 'my_team',
                    screenLocation: 'add_employee',
                    properties: {"option": value},
                  );

                  controller.updateAdditionMethod(value);
                },
              ),
              SizedBox(height: 80),
              ActionButton(
                text: 'Continue',
                margin: EdgeInsets.zero,
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.white,
                        ),
                onPressed: () {
                  MixPanelAnalytics.trackWithAgentId(
                    "continue",
                    screen: 'my_team',
                    screenLocation: designationType == DesignationType.Employee
                        ? 'add_employee'
                        : 'add_associate',
                  );

                  if (controller.selectedMethod ==
                      NewMemberAdditionMethod.EXISTING_USER) {
                    // controller.initCRNForm();
                    AutoRouter.of(context).push(
                        ExistingTeamMemberFormRoute(controller: controller));
                  } else if (controller.selectedMethod ==
                      NewMemberAdditionMethod.NEW_USER) {
                    // controller.initDetailForm();
                    AutoRouter.of(context)
                        .push(NewTeamMemberFormRoute(controller: controller));
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }
}
