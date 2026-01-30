import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/nominee_validation_utils.dart';
import 'package:app/src/controllers/client/nominee_form_controller.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NomineePersonalDetails extends StatelessWidget {
  final controller = Get.find<ClientNomineeFormController>();
  @override
  Widget build(BuildContext context) {
    final relationshipOptions =
        nomineeRelationships.keys.toList().map((e) => e.toString()).toList();
    final hintStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.tertiaryBlack,
      height: 0.7,
    );
    final textStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nominee's Name
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: CommonClientUI.borderTextFormField(
            context,
            isCompulsory: true,
            controller: controller.nameController,
            hintText: 'Nominee\'s Name',
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  "[a-zA-Z ]",
                ),
              ),
              NoLeadingSpaceFormatter()
            ],
            validator: (value) {
              if (value?.trim().isNullOrEmpty ?? true) {
                return 'Nominee name is required';
              }
              if (value!.trim().length < 2) {
                return 'Nominee name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),

        // Nominee's DOB
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: InkWell(
            onTap: () async {
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
                controller: controller.dobController,
                isCompulsory: true,
                hintText: 'Nominee\'s DOB',
                prefixIcon: Icon(Icons.calendar_month),
                validator: (value) {
                  if (value.isNullOrEmpty) {
                    return 'Date of birth is required';
                  }
                  if (controller.dob != null) {
                    final ageError =
                        NomineeValidationUtils.validateAge(controller.dob);
                    if (ageError != null) return ageError;

                    // Check for duplicate DOB with account holder
                    final duplicateError = NomineeValidationUtils
                        .validateNomineeNotDuplicateOfAccountHolder(
                      accountHolder: controller.client,
                      nomineePan: null,
                      nomineeAadhaar: null,
                      nomineeDob: controller.dob,
                    );
                    if (duplicateError != null) return duplicateError;
                  }
                  return null;
                },
              ),
            ),
          ),
        ),

        // Nominee's Mobile Number
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: CommonClientUI.borderTextFormField(
            context,
            controller: controller.mobileController,
            isCompulsory: true,
            hintText: 'Nominee\'s Mobile Number',
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  "[0-9]",
                ),
              ),
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ),
        // // Nominee's Email ID
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: CommonClientUI.borderTextFormField(
            context,
            controller: controller.emailController,
            hintText: 'Nominee\'s Email ID',
            isCompulsory: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  "[0-9a-zA-Z@._-]",
                ),
              ),
            ],
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Email ID is required.';
              }

              if (!isEmailValid(value!)) {
                return 'Please enter a valid email ID.';
              }

              return null;
            },
          ),
        ),
        // Nominee's Relationship with Client
        SimpleDropdownFormField<String>(
          hintText: 'Select Relationship',
          items: relationshipOptions,
          customText: (value) {
            // if (value)  {

            // }
            return nomineeRelationships[(WealthyCast.toInt(value))];
            // if (value != null && (value < (relationships.length - 1))) {
            //   return '';
            // }
            // return ;
          },
          value: controller.selectedRelationship,
          contentPadding: EdgeInsets.only(bottom: 8),
          borderColor: ColorConstants.lightGrey,
          style: textStyle,
          labelStyle: hintStyle,
          useLabelAsHint: true,
          isCompulsory: true,
          hintStyle: hintStyle,
          label: 'Relationship with client',
          onChanged: (val) {
            controller.selectedRelationship = val;
          },
          validator: (val) {
            if (val == null) {
              return 'Relationship with client is required.';
            }

            return null;
          },
        ),
      ],
    );
  }
}
