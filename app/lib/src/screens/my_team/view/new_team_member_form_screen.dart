import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/my_team/add_team_member_controller.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class NewTeamMemberFormScreen extends StatelessWidget {
  NewTeamMemberFormScreen({Key? key, required this.controller})
      : super(key: key);

  TextStyle? hintStyle;
  TextStyle? textStyle;
  AddTeamMemberController? controller;

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          if (Get.isRegistered<AddTeamMemberController>()) {
            Get.find<AddTeamMemberController>().resetMemberAddForm();
          }
          AutoRouter.of(context).popForced();
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          showBackButton: true,
          onBackPress: () {
            if (Get.isRegistered<AddTeamMemberController>()) {
              Get.find<AddTeamMemberController>().resetMemberAddForm();
            }
            AutoRouter.of(context).popForced();
          },
          titleText: 'Enter Member Details',
          subtitleText:
              'Add details of the member to create and add as an ${controller?.designation == "Member" ? "Associate" : controller?.designation}',
        ),
        body: GetBuilder<AddTeamMemberController>(
          builder: (controller) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              physics: ClampingScrollPhysics(),
              child: Form(
                key: controller.newMemberFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameInput(context, isFirstName: true),
                    _buildNameInput(context, isFirstName: false),
                    _buildPhoneNumberInput(context),
                    _buildEmailInput(context),
                    SizedBox(height: 150),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FixedCenterDockedFabLocation(),
        floatingActionButton: _buildActionButton(context),
      ),
    );
  }

  Widget _buildNameInput(BuildContext context, {bool? isFirstName}) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: GetBuilder<AddTeamMemberController>(
        builder: (controller) {
          TextEditingController textController = isFirstName!
              ? controller.firstNameController
              : controller.lastNameController;
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: textController,
            label: isFirstName ? 'First Name' : 'Last Name',
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
            suffixIcon: textController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      textController.clear();
                      controller.update();
                    },
                  ),
            onChanged: (val) {
              controller.update();
            },
            validator: (value) {
              if (value.isNullOrEmpty) {
                return '${isFirstName ? 'First' : 'Last'} Name is required.';
              }

              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildEmailInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: GetBuilder<AddTeamMemberController>(
        builder: (controller) {
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: controller.emailController,
            label: 'Email Address',
            style: textStyle,
            useLabelAsHint: true,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            textInputAction: TextInputAction.done,
            borderColor: ColorConstants.lightGrey,
            inputFormatters: <TextInputFormatter>[],
            keyboardType: TextInputType.emailAddress,
            suffixIcon: controller.emailController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      controller.emailController.clear();
                      controller.update();
                    },
                  ),
            onChanged: (val) {
              controller.update();
            },
            validator: (value) {
              if (value.isNotNullOrEmpty && !isEmailValid(value)) {
                return 'Please enter valid email ID.';
              }

              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildPhoneNumberInput(BuildContext context) {
    //
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: GetBuilder<AddTeamMemberController>(
        id: GetxId.phoneNumberInput,
        builder: (controller) {
          return SimpleTextFormField(
            contentPadding: EdgeInsets.only(bottom: 8),
            enabled: true,
            controller: controller.phoneNumberController,
            label: 'Phone Number',
            // style: textStyle,
            useLabelAsHint: true,
            // labelStyle: hintStyle,
            // hintStyle: hintStyle,
            textInputAction: TextInputAction.next,
            borderColor: ColorConstants.lightGrey,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                  getPhoneNumberLimitByCountry(controller.countryCode)),
            ],
            prefixIconSize: Size(100, 36),
            prefixIcon: CountryCodePicker(
              padding: EdgeInsets.only(right: 8),
              initialSelection: controller.countryCode,
              flagWidth: 20.0,
              showFlag: true,
              showFlagDialog: true,
              textStyle:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
              onChanged: (CountryCode countryCode) {
                controller.countryCode = countryCode.dialCode;
                controller.newMemberFormKey.currentState!.validate();
                controller.update([GetxId.phoneNumberInput]);
              },
            ),
            suffixIcon: controller.phoneNumberController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 21.0,
                      color: Color(0xFF979797),
                    ),
                    onPressed: () {
                      controller.phoneNumberController.clear();
                      controller.update();
                    },
                  ),
            onChanged: (val) {
              // controller.update();
            },
            validator: (value) {
              return phoneNumberInputValidation(value, controller.countryCode);
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<AddTeamMemberController>(
      builder: (controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return ActionButton(
              heroTag: kDefaultHeroTag,
              text: 'Send OTP',
              showProgressIndicator:
                  controller.saveMemberDetailsResponse.state ==
                      NetworkState.loading,
              margin: EdgeInsets.symmetric(
                vertical: isKeyboardVisible ? 0 : 24.0,
                horizontal: isKeyboardVisible ? 0 : 30.0,
              ),
              borderRadius: isKeyboardVisible ? 0.0 : 51.0,
              onPressed: () async {
                if (controller.newMemberFormKey.currentState!.validate()) {
                  await controller.addPartnerOfficeEmployee();

                  if (controller.saveMemberDetailsResponse.state ==
                      NetworkState.loaded) {
                    AutoRouter.of(context).push(VerifyTeamMemberOtpRoute());
                  } else if (controller.saveMemberDetailsResponse.state ==
                      NetworkState.error) {
                    showToast(
                        text: controller.saveMemberDetailsResponse.message);
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}
