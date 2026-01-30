import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/screens/my_team/widgets/team_actions_success_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class EditTeamNameBottomsheet extends StatelessWidget {
  final TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Padding(
          padding: const EdgeInsets.all(30).copyWith(
            bottom: isKeyboardVisible
                ? MediaQuery.of(context).viewInsets.bottom
                : 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Team Name',
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
                padding: const EdgeInsets.only(top: 30, bottom: 12),
                child: Text(
                  'Enter New Team Name',
                  style: context.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.black,
                  ),
                ),
              ),
              ColoredBox(
                color: ColorConstants.secondaryAppColor,
                child: BorderedTextFormField(
                  controller: textController,
                  useLabelAsHint: false,
                  borderRadius: BorderRadius.circular(4),
                  hintText: 'Enter New Team Name',
                  borderColor: ColorConstants.primaryAppColor,
                  onChanged: (val) {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 24),
                child: _buildCTA(context),
              )
            ],
          ),
        );
      },
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
            id: 'rename-office',
            builder: (controller) {
              return ActionButton(
                showProgressIndicator: controller.renameOfficeResponse.state ==
                    NetworkState.loading,
                margin: EdgeInsets.zero,
                height: 56,
                text: 'Update',
                onPressed: () async {
                  if (textController.text.isEmpty) {
                    showToast(text: "Name field is empty");
                    return;
                  }
                  await controller.renameOffice(textController.text);
                  if (controller.renameOfficeResponse.state ==
                      NetworkState.error) {
                    showToast(text: controller.renameOfficeResponse.message);
                  }
                  if (controller.renameOfficeResponse.state ==
                      NetworkState.loaded) {
                    CommonUI.showBottomSheet(
                      context,
                      child: TeamActionsSuccessBottomsheet(
                        titleText: controller.renameOfficeResponse.message,
                        onGotIt: () {
                          controller.getAgentDesignation();
                          AutoRouter.of(context)
                              .popUntilRouteWithName(MyTeamRoute.name);
                        },
                      ),
                      isDismissible: false,
                    );
                  }
                },
                bgColor: ColorConstants.primaryAppColor,
                textStyle: style?.copyWith(color: ColorConstants.white),
              );
            },
          ),
        ),
      ],
    );
  }
}
