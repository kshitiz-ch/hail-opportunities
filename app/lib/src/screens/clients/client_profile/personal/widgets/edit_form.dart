import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/personal_form_controller.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';

import 'account_type_inputs.dart';
import 'input_container.dart';

class EditForm extends StatelessWidget {
  const EditForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientPersonalFormController>(
      builder: (controller) {
        return Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                AccountTypeInputs(),

                // Name
                _buildNameInput(context, controller),

                // Phone
                _buildPhoneInput(context, controller),

                // Email
                _buildEmailInput(context, controller),

                // DOB
                _buildDobInput(context, controller),

                // Gender
                _buildGenderInput(context, controller),

                // Marital Status
                _buildMaritalStatusInput(context, controller)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameInput(context, ClientPersonalFormController controller) {
    return InputContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            labelText: 'Name (as on PAN Card)',
            hintText: 'Name',
            enabled: controller.isEditFlow && !controller.disableEditPanOrName,
            controller: controller.nameController,
          ),
          if (controller.isEditFlow && controller.disableEditPanOrName)
            CommonClientUI.disabledFieldInfo(context)
        ],
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildPhoneInput(context, ClientPersonalFormController controller) {
    return InputContainer(
      // padding: EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            enabled: controller.isEditFlow &&
                controller.clientMfProfile?.isKycSubmittedOrApproved != true,
            controller: controller.phoneController,
            hintText: 'Phone Number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                  controller.countryCode == indiaCountryCode ? 10 : 15),
            ],
            prefixIconConstraints:
                BoxConstraints(minWidth: 0, minHeight: 0, maxWidth: 70),
            prefixIcon: Container(
              child: CountryCodePicker(
                padding: EdgeInsets.all(0),
                initialSelection: controller.countryCode,
                alignLeft: true,
                showFlag: false,
                showFlagDialog: true,
                enabled: controller.clientMfProfile?.isKycSubmittedOrApproved !=
                    true,
                closeIcon: Icon(
                  Icons.close,
                  color: ColorConstants.tertiaryBlack,
                ),
                textStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.black,
                        ),
                onChanged: (CountryCode countryCode) {
                  controller.countryCode = countryCode.dialCode;
                  controller.update();
                },
              ),
            ),
            validator: (value) {
              return phoneNumberInputValidation(value, controller.countryCode);
            },
          ),
          if (controller.clientMfProfile?.isKycSubmittedOrApproved == true)
            CommonClientUI.disabledFieldInfo(context)
        ],
      ),
    );
  }

  Widget _buildEmailInput(context, ClientPersonalFormController controller) {
    return InputContainer(
      child: Column(
        children: [
          CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: 'Email',
            enabled:
                controller.clientMfProfile?.isKycSubmittedOrApproved != true,
            controller: controller.emailController,
            // keyboardType: TextInputType.emailAddress,
            validator: (String? value) {
              if (value.isNullOrEmpty) {
                return 'Email is required.';
              }

              if (!isEmailValid(value)) {
                return 'Please enter valid email ID.';
              }

              return null;
            },
          ),
          if (controller.clientMfProfile?.isKycSubmittedOrApproved == true)
            CommonClientUI.disabledFieldInfo(context)
        ],
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildDobInput(context, ClientPersonalFormController controller) {
    return InputContainer(
      child: InkWell(
        onTap: () async {
          if (!controller.isEditFlow) {
            return;
          }

          DateTime? pickedDate = await showDatePicker(
            initialDatePickerMode: DatePickerMode.year,
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(
              Duration(days: 365 * 110),
            ),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: ColorConstants.primaryAppColor,
                    onPrimary: ColorConstants.white,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            controller.dob = pickedDate;
            controller.dobController.text =
                DateFormat('dd/MM/yyyy').format(pickedDate);
            controller.update();
          }
        },
        child: IgnorePointer(
          ignoring: true,
          child: CommonClientUI.borderTextFormField(
            context,
            useLabelasHint: false,
            hintText: 'Date of Birth',
            controller: controller.dobController,
            prefixIcon: Icon(Icons.calendar_month),
          ),
        ),
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildGenderInput(context, ClientPersonalFormController controller) {
    return InputContainer(
      child: SimpleDropdownFormField<String>(
        hintText: 'Select Gender',
        items: ['M', 'F', 'O'],
        customText: (value) {
          if (value == null) {
            return '';
          }

          return getGenderStatus(value);
        },
        label: 'Gender',
        contentPadding: EdgeInsets.only(bottom: 8),
        // borderColor: ColorConstants.lightGrey,
        style: CommonClientUI.getTextStyle(context),
        labelStyle: CommonClientUI.getLabelStyle(context),
        hintStyle: CommonClientUI.getLabelStyle(context),
        value: controller.gender,
        onChanged: (val) {
          controller.gender = val!;
          controller.update();
        },
        validator: (value) {
          if (value == null) {
            return 'Gender is required.';
          }

          return null;
        },
      ),
      showBorder: !controller.isEditFlow,
    );
  }

  Widget _buildMaritalStatusInput(
      context, ClientPersonalFormController controller) {
    return InputContainer(
      child: SimpleDropdownFormField<String>(
        hintText: 'Select Marital Status',
        items: ['S', 'M'],
        customText: (value) {
          return getMaritalStatus(value);
        },
        contentPadding: EdgeInsets.only(bottom: 8),
        borderColor: ColorConstants.lightGrey,
        style: CommonClientUI.getTextStyle(context),
        labelStyle: CommonClientUI.getLabelStyle(context),
        hintStyle: CommonClientUI.getLabelStyle(context),
        value: controller.maritalStatus,
        label: 'Marital Status',
        onChanged: (val) {
          controller.maritalStatus = val;
          controller.update();
        },
        validator: (value) {
          if (value == null) {
            return 'Marital Status is required.';
          }

          return null;
        },
      ),
      showBorder: !controller.isEditFlow,
    );
  }
}
