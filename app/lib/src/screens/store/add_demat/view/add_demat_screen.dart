import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/demat/add_demat_controller.dart';
import 'package:app/src/screens/store/add_demat/widgets/attach_screenshot_section.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class AddDematScreen extends StatelessWidget {
  // Fields
  final Client? client;

  /// Handle Navigation when the Add Account
  /// button is pressed
  // final void Function(BuildContext) navigateTo;
  final VoidCallback? navigateTo;

  // Cnostructor
  const AddDematScreen({
    Key? key,
    required this.client,
    required this.navigateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,

      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Add Demat Details',
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GetBuilder<AddDematController>(
          init: AddDematController(),
          initState: (_) {},
          builder: (controller) {
            return Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DP ID Number
                  GetBuilder<AddDematController>(
                      id: 'add-demat-dp',
                      builder: (controller) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: SimpleTextFormField(
                            label: 'DP ID Number',
                            labelStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                    fontWeight: FontWeight.w500, fontSize: 12),
                            enabled: true,
                            controller: controller.dpIdController,
                            hintText: 'Eg. 12400023',
                            hintStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                    color: ColorConstants.darkGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                  "[0-9a-zA-Z]",
                                ),
                              ),
                              LengthLimitingTextInputFormatter(8),
                            ],
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            suffixIcon: controller.dpIdController!.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 21.0,
                                      color: Color(0xFF979797),
                                    ),
                                    onPressed: () {
                                      controller.dpIdController!.clear();
                                      controller.update(['add-demat-dp']);
                                    },
                                  ),
                            onChanged: (val) {
                              controller.update(['add-demat-dp']);
                            },
                            onSubmitted: (_) {
                              controller.clientIdFocusNode!.requestFocus();
                            },
                            validator: (value) {
                              if (value.isNullOrEmpty) {
                                return 'DP ID is required';
                              }

                              if (value!.length < 8) {
                                return 'DP ID should be 8 characters long';
                              }

                              return null;
                            },
                          ),
                        );
                      }),

                  // Client Number
                  GetBuilder<AddDematController>(
                    id: 'add-demat-client',
                    builder: (controller) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30)
                            .copyWith(top: 40),
                        child: SimpleTextFormField(
                          label: 'Client Number',
                          labelStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                          controller: controller.clientIdController,
                          keyboardType: TextInputType.number,
                          hintText: '12345678',
                          hintStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color: ColorConstants.darkGrey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12),
                          enabled: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          focusNode: controller.clientIdFocusNode,
                          suffixIcon:
                              controller.clientIdController!.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        size: 21.0,
                                        color: Color(0xFF979797),
                                      ),
                                      onPressed: () {
                                        controller.clientIdController!.clear();
                                        controller.update(['add-demat-client']);
                                      },
                                    ),
                          onChanged: (val) {
                            controller.update(['add-demat-client']);
                          },
                          validator: (value) {
                            if (value.isNullOrEmpty) {
                              return 'Client id is required';
                            }

                            if (value!.length < 8) {
                              return 'Client id should be 8 digits long';
                            }

                            return null;
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32),

                  // Attach Screenshot Section
                  AttachScreenshotSection(client: client),
                ],
              ),
            );
          },
        ),
      ),

      floatingActionButtonLocation: FixedCenterDockedFabLocation(),

      floatingActionButton: GetBuilder<AddDematController>(
        id: 'add-demat',
        builder: (controller) {
          return KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
              return ActionButton(
                heroTag: kDefaultHeroTag,
                text: 'Add DEMAT Account',
                showProgressIndicator:
                    controller.addDematState == NetworkState.loading,
                margin: EdgeInsets.symmetric(
                  vertical: isKeyboardVisible ? 0 : 24.0,
                  horizontal: isKeyboardVisible ? 0 : 18.0,
                ),
                borderRadius: isKeyboardVisible ? 0.0 : 30.0,
                onPressed: () async {
                  await controller.addDematAccount(client);
                  if (controller.addDematState == NetworkState.loaded) {
                    navigateTo!();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
