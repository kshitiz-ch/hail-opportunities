import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_login_details_controller.dart';
import 'package:app/src/screens/clients/client_profile/widgets/update_form_header.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'details_update_success.dart';

class UpdateProfileName extends StatelessWidget {
  final Client? client;
  final UserDetailsPrefillModel? userDetailsPrefill;

  UpdateProfileName({
    this.client,
    this.userDetailsPrefill,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientLoginDetailsController>(
      init: ClientLoginDetailsController(client,
          userDetailsPrefill: userDetailsPrefill),
      builder: (controller) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Wrap(
              children: [
                if (controller.showUpdateSuccessScreen)
                  DetailsUpdateSuccess(
                    text: 'Profile name updated successfully',
                  )
                else
                  Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        UpdateFormHeader(
                          header: 'Update Profile Name',
                          description:
                              'Please enter the name to be updated which will appear on the client\'s profile',
                          currentValue: userDetailsPrefill?.name,
                          label: 'Current Profile Name',
                        ),
                        SizedBox(height: 40),
                        SimpleTextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                "[a-zA-Z ]",
                              ),
                            ),
                            NoLeadingSpaceFormatter()
                          ],
                          enabled: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          contentPadding: EdgeInsets.only(bottom: 8),
                          borderColor: ColorConstants.lightGrey,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall
                              ?.copyWith(
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                          useLabelAsHint: true,
                          labelStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall
                              ?.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 0.7,
                              ),
                          hintStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall
                              ?.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 0.7,
                              ),
                          label: 'New First Name',
                          controller: controller.firstNameController,
                          validator: (value) {
                            if (value.isNullOrEmpty) {
                              return 'First Name is required.';
                            }

                            return null;
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SimpleTextFormField(
                          enabled: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                "[a-zA-Z ]",
                              ),
                            ),
                            NoLeadingSpaceFormatter()
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          contentPadding: EdgeInsets.only(bottom: 8),
                          borderColor: ColorConstants.lightGrey,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                          useLabelAsHint: true,
                          labelStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall
                              ?.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 0.7,
                              ),
                          hintStyle: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall
                              ?.copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 0.7,
                              ),
                          label: 'New Last Name',
                          controller: controller.lastNameController,
                          validator: (value) {
                            if (value.isNullOrEmpty) {
                              return 'Last Name is required.';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 50),
                        ActionButton(
                          text: 'UPDATE PROFILE NAME'.toTitleCase(),
                          showProgressIndicator:
                              controller.updateClientNameState ==
                                  NetworkState.loading,
                          margin: EdgeInsets.zero,
                          onPressed: () async {
                            if (controller.formKey.currentState!.validate()) {
                              await controller.updateClientName();

                              if (controller.updateClientNameState ==
                                  NetworkState.loaded) {
                                if (Get.isRegistered<
                                    ClientDetailController>()) {
                                  await Get.find<ClientDetailController>()
                                      .getClientProfileDetails();
                                }
                                controller.setShowUpdateSuccessScreen();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
