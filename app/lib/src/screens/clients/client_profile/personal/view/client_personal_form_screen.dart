import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/personal_form_controller.dart';
import 'package:app/src/screens/clients/client_profile/personal/widgets/edit_warning_bottomsheet.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/edit_form.dart';

@RoutePage()
class ClientPersonalFormScreen extends StatelessWidget {
  const ClientPersonalFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserDetailsPrefillModel? userDetailsPrefill;
    ClientMfProfileModel? clientMfProfile;
    Client? client;
    if (Get.isRegistered<ClientDetailController>()) {
      clientMfProfile = Get.find<ClientDetailController>().clientMfProfile;
      userDetailsPrefill =
          Get.find<ClientDetailController>().userDetailsPrefill;
      client = Get.find<ClientDetailController>().client;
    }
    return GetBuilder<ClientPersonalFormController>(
      init: ClientPersonalFormController(
          clientMfProfile, client, userDetailsPrefill),
      builder: (controller) {
        final showEditCTA = !controller.isEditFlow;

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Personal Details',
            trailingWidgets: [
              if (showEditCTA)
                ClickableText(
                  padding: EdgeInsets.only(left: 20, top: 10, right: 10),
                  text: 'Edit',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  onClick: () {
                    if (controller.clientMfProfile?.isKycSubmittedOrApproved ??
                        false) {
                      CommonUI.showBottomSheet(
                        context,
                        child: EditWarningBottomSheet(),
                      );
                    } else {
                      controller.toggleEditFlow(true);
                    }
                  },
                )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20)
                .copyWith(bottom: 60, top: 20),
            child: SingleChildScrollView(
              child: controller.isEditFlow
                  ? EditForm()
                  : _buildPersonalDetails(context, controller),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildProceedButton(context, controller),
        );
      },
    );
  }

  Widget _buildPersonalDetails(
      BuildContext context, ClientPersonalFormController controller) {
    return Column(
      children: [
        // Tax status
        CommonClientUI.formLabelValue(
          context,
          label: 'Tax Status',
          value: controller.taxStatus,
        ),
        // Account Type
        CommonClientUI.formLabelValue(
          context,
          label: 'Account Type',
          value: controller.accountType,
        ),

        // Name
        CommonClientUI.formLabelValue(context,
            label: 'Name (as on PAN Card)',
            value: controller.nameController.text),

        // PAN
        CommonClientUI.formLabelValue(context,
            label: 'PAN',
            value: controller.panController.text,
            suffixWidget:
                controller.isPanVerified ? _buildVerifiedText(context) : null),

        // Phone Number
        CommonClientUI.formLabelValue(context,
            label: 'Phone Number',
            value:
                '(${controller.countryCode})${controller.phoneController.text}',
            suffixWidget: controller.isPhoneVerified
                ? _buildVerifiedText(context)
                : null),

        // Email
        CommonClientUI.formLabelValue(context,
            label: 'Email (For MF)',
            value: controller.emailController.text,
            suffixWidget: controller.isEmailVerified
                ? _buildVerifiedText(context)
                : null),

        // DOB
        CommonClientUI.formLabelValue(context,
            label: 'DOB', value: controller.dobController.text),

        // Gender
        CommonClientUI.formLabelValue(context,
            label: 'Gender', value: getGenderStatus(controller.gender)),

        // Marital Status
        CommonClientUI.formLabelValue(context,
            label: 'Marital Status',
            value: getMaritalStatus(controller.maritalStatus)),

        // Spouse Name
        CommonClientUI.formLabelValue(context,
            label: 'Spouse Name', value: controller.spouseNameController.text),

        // Father's Name
        CommonClientUI.formLabelValue(context,
            label: 'Father\'s Name',
            value: controller.fatherNameController.text),

        // Mother's Name
        CommonClientUI.formLabelValue(context,
            label: 'Mother\'s Name',
            value: controller.motherNameController.text),

        if (controller.addressResponse.state == NetworkState.loading)
          _buildAddressLoading()
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Permanent Address
              CommonClientUI.formLabelValue(context,
                  label: 'Permanent Address',
                  value: controller.permanentAddressController.text),

              // Correspondence Address
              CommonClientUI.formLabelValue(context,
                  label: 'Correspondence Address',
                  value: controller.correspondenceAddressController.text,
                  showBorder: false),
            ],
          )
      ],
    );
  }

  Widget _buildVerifiedText(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: ColorConstants.greenAccentColor,
        ),
        SizedBox(width: 2),
        Text(
          'Verified',
          style: Theme.of(context)
              .primaryTextTheme
              .titleLarge!
              .copyWith(color: ColorConstants.greenAccentColor),
        )
      ],
    );
  }

  Widget _buildProceedButton(
      BuildContext context, ClientPersonalFormController controller) {
    if (!controller.isEditFlow) {
      return SizedBox();
    }

    return ActionButton(
      text: controller.clientMfProfile?.id == null ? 'Create' : 'Update',
      showProgressIndicator:
          controller.updateResponse.state == NetworkState.loading,
      onPressed: () async {
        if (controller.formKey.currentState!.validate()) {
          await controller.updatePersonalDetails();

          if (controller.updateResponse.state == NetworkState.loaded) {
            await Get.find<ClientDetailController>().getClientProfileDetails();
            if (Get.isRegistered<ClientDetailController>()) {
              Get.find<ClientDetailController>().getClientInvestmentStatus();
            }

            showToast(
              text: 'Client Details Updated',
            );

            controller.toggleEditFlow(false);
          } else {
            showToast(text: controller.updateResponse.message);
          }
        }
      },
    );
  }

  Widget _buildAddressLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
