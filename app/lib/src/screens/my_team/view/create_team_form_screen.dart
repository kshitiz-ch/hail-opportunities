import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/my_team/my_team_controller.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class CreateTeamFormScreen extends StatelessWidget {
  CreateTeamFormScreen({Key? key}) : super(key: key);

  TextStyle? hintStyle;
  TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    hintStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    textStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Name your team',
        subtitleText: 'Create a name for your team eg. John Associates',
      ),
      body: GetBuilder<MyTeamController>(
          id: 'new-team',
          builder: (controller) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameInput(context),
                ],
              ),
            );
          }),
      floatingActionButtonLocation: FixedCenterDockedFabLocation(),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildNameInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: GetBuilder<MyTeamController>(
        id: 'new-team',
        builder: (controller) {
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: controller.newTeamNameController,
            label: 'Team Name',
            style: textStyle,
            useLabelAsHint: true,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            textInputAction: TextInputAction.next,
            borderColor: ColorConstants.lightGrey,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(
                  "[a-zA-Z ]",
                ),
              ),
              NoLeadingSpaceFormatter()
            ],
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            suffixIcon: controller.newTeamNameController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      controller.newTeamNameController.clear();
                      controller.update(['new-team']);
                    },
                  ),
            onChanged: (val) {
              controller.update(['new-team']);
            },
            validator: (value) {
              if (value!.trim().isEmpty) {
                return 'Name is required.';
              }

              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<MyTeamController>(
      id: 'new-team',
      builder: (controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return ActionButton(
              heroTag: kDefaultHeroTag,
              text: 'Create Team',
              showProgressIndicator:
                  controller.createTeamResponse.state == NetworkState.loading,
              margin: EdgeInsets.symmetric(
                vertical: isKeyboardVisible ? 0 : 24.0,
                horizontal: isKeyboardVisible ? 0 : 30.0,
              ),
              borderRadius: isKeyboardVisible ? 0.0 : 51.0,
              onPressed: () async {
                if (controller.newTeamNameController.text.isEmpty) {
                  return showToast(text: 'Please enter a valid name');
                }

                await controller.createPartnerOffice();

                if (controller.createTeamResponse.state ==
                    NetworkState.loaded) {
                  if (Get.isRegistered<MyTeamController>()) {
                    Get.find<MyTeamController>().getAgentDesignation();
                  }
                  AutoRouter.of(context)
                      .popUntilRouteWithName(MyTeamRoute.name);
                } else if (controller.createTeamResponse.state ==
                    NetworkState.error) {
                  showToast(text: controller.createTeamResponse.message);
                }
              },
            );
          },
        );
      },
    );
  }
}
