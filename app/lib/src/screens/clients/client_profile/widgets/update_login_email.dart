import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_login_details_controller.dart';
import 'package:app/src/controllers/client/client_profile_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'details_update_success.dart';
import 'show_update_link.dart';
import 'update_form_header.dart';

class UpdateLoginEmail extends StatelessWidget {
  final Client client;
  final UserDetailsPrefillModel? userDetailsPrefill;
  final bool isVerified;

  UpdateLoginEmail({
    required this.client,
    this.userDetailsPrefill,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    bool isEmpty = userDetailsPrefill?.email.isNullOrEmpty ?? true;

    return GetBuilder<ClientLoginDetailsController>(
      init: ClientLoginDetailsController(
        client,
        userDetailsPrefill: userDetailsPrefill,
      ),
      builder: (controller) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Wrap(
              children: [
                if (controller.showUpdateSuccessScreen)
                  DetailsUpdateSuccess(
                    text: isVerified
                        ? controller.updateLink.isNotNullOrEmpty
                            ? 'You can copy the link below and share it with the client'
                            : 'The link has been sent to the client successfully'
                        : 'Email Id has been successfully updated',
                    childWidget: isVerified ? LinkExpiryText() : SizedBox(),
                    copyLink: controller.updateLink,
                  )
                else
                  Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        UpdateFormHeader(
                          header:
                              isVerified ? 'Send Link' : 'Update Login Email',
                          isVerified: isVerified,
                          textController: controller.emailController,
                          description:
                              'This email is used by the client to log into Wealthy.',
                          currentValue: userDetailsPrefill?.email,
                          label: 'Current Login Email',
                        ),
                        SizedBox(height: 20),
                        if (isVerified)
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: ColorConstants.lightOrangeColor,
                            ),
                            child: Text(
                              'The client will receive a link to update login email.',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium,
                            ),
                          ),
                        SizedBox(
                          height: 50,
                        ),
                        ActionButton(
                          text: isVerified ? 'Send Link' : 'Update Login Email',
                          margin: EdgeInsets.zero,
                          showProgressIndicator:
                              controller.clientDetailChangeRequestState ==
                                  NetworkState.loading,
                          onPressed: () async {
                            await onCTATap(controller);
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

  Future<void> onCTATap(ClientLoginDetailsController controller) async {
    MixPanelAnalytics.trackWithAgentId(
      'update_login_email',
      screen: 'user_profile_details',
      screenLocation: 'update_profile_email',
    );

    if (isVerified) {
      await controller.requestVerifiedProfileUpdate();
    } else {
      await controller.requestProfileUpdate(
          emailId: controller.emailController.text);
    }

    if (controller.clientDetailChangeRequestState == NetworkState.loaded) {
      controller.setShowUpdateSuccessScreen();
      if (Get.isRegistered<ClientDetailController>()) {
        final clientDetailController = Get.find<ClientDetailController>();
        await clientDetailController.getClientProfileDetails();
        Get.find<ClientProfileController>().update();
      }
    }

    if (controller.clientDetailChangeRequestState == NetworkState.error) {
      showToast(text: controller.clientDetailChangeRequestErrorMessage);
    }
  }
}
