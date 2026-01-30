import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/nominee_validation_utils.dart';
import 'package:app/src/controllers/client/nominee_form_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NomineeGuardianDetail extends StatelessWidget {
  final controller = Get.find<ClientNomineeFormController>();

  late TextStyle hintStyle;
  late TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final relationshipOptions =
        nomineeRelationships.keys.toList().map((e) => e.toString()).toList();

    List.generate(
        nomineeRelationships.length, (index) => (index + 1).toString());

    hintStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.tertiaryBlack,
      height: 0.7,
    );
    textStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    final isMinor = controller.dob != null &&
        controller.dobController.text.isNotEmpty &&
        !isAdult(controller.dob!);

    if (!isMinor) {
      return SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guardian Required Information Banner
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.primaryAppv3Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ColorConstants.primaryAppColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'As nominee is below 18yrs, Legal Guardian is required',
                    style: textStyle.copyWith(
                      color: ColorConstants.primaryAppColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Guardian Name
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: CommonClientUI.borderTextFormField(
            context,
            controller: controller.guardianNameController,
            isCompulsory: true,
            hintText: 'Guardian\'s Name',
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
                return 'Guardian name is required for minor nominees';
              }
              if (value!.trim().length < 2) {
                return 'Guardian name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),
        // Guardian DOB
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
                controller.guardianDob = pickedDate;
                controller.guardianDobController.text =
                    DateFormat('dd/MM/yyyy').format(pickedDate);
                controller.update();
              }
            },
            child: IgnorePointer(
              ignoring: true,
              child: CommonClientUI.borderTextFormField(
                context,
                controller: controller.guardianDobController,
                hintText: 'Guardian\'s DOB',
                isCompulsory: true,
                prefixIcon: Icon(Icons.calendar_month),
                validator: (value) {
                  if (value.isNullOrEmpty) {
                    return 'Guardian date of birth is required';
                  }
                  if (controller.guardianDob != null) {
                    final ageError = NomineeValidationUtils.validateGuardianAge(
                        controller.guardianDob);
                    if (ageError != null) return ageError;

                    // Check for duplicate DOB with account holder
                    final duplicateError = NomineeValidationUtils
                        .validateGuardianNotDuplicateOfAccountHolder(
                      accountHolder: controller.client,
                      guardianPan: null,
                      guardianAadhaar: null,
                      guardianDob: controller.guardianDob,
                    );
                    if (duplicateError != null) return duplicateError;
                  }
                  return null;
                },
              ),
            ),
          ),
        ),

        // Nominee's Relationship with Guardian
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: SimpleDropdownFormField<String>(
            hintText: 'Select Relationship',
            items: relationshipOptions,
            useLabelAsHint: true,
            isCompulsory: true,
            customText: (value) {
              // if (value)  {

              // }
              return nomineeRelationships[(WealthyCast.toInt(value))];
              // if (value != null && (value < (relationships.length - 1))) {
              //   return '';
              // }
              // return ;
            },
            value: controller.selectedGuardianRelationship,
            contentPadding: EdgeInsets.only(bottom: 8),
            borderColor: ColorConstants.lightGrey,
            style: textStyle,
            labelStyle: hintStyle,
            hintStyle: hintStyle,
            label: 'Relationship with Guardian',
            onChanged: (val) {
              controller.selectedGuardianRelationship = val;
            },
            validator: (val) {
              if (val == null) {
                return 'Relationship with guardian is required.';
              }

              return null;
            },
          ),
        ),
        // Choose Guardian ID
        _buildChooseGuardianId(context),
        // Note about contact details
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: ColorConstants.primaryAppColor,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contact details and address will be considered as guardian\'s for minor nominee',
                style: textStyle.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChooseGuardianId(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Guardian ID', style: textStyle),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 30),
          child: RadioButtons(
            items: [PersonIDType.Aadhaar, PersonIDType.Pan]
                .map((e) => e.description)
                .toList(),
            textStyle: textStyle.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
            selectedValue: controller.guardianIdType.description,
            onTap: (value) {
              final selectedType = PersonIDType.values.firstWhere(
                (e) => e.description == value,
                orElse: () => PersonIDType.Aadhaar,
              );
              if (selectedType == controller.guardianIdType) return;

              controller.guardianIdType = selectedType;
              controller.guardianIdController.clear();
              controller.update();
            },
          ),
        ),
        // Guardian's Aadhaar or PAN Number based on guardianIdType
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: CommonClientUI.borderTextFormField(
            context,
            controller: controller.guardianIdController,
            isCompulsory: true,
            hintText: controller.guardianIdType.isAadhaar
                ? 'Last 4 digits of Guardian\'s Aadhaar Number'
                : 'Guardian\'s PAN Number',
            inputFormatters: controller.guardianIdType.isAadhaar
                ? [
                    NoLeadingSpaceFormatter(),
                    // Aadhaar: Only allow digits for last 4 digits
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(4),
                  ]
                : [
                    NoLeadingSpaceFormatter(),
                    // PAN Validator
                    FilteringTextInputFormatter.allow(
                      RegExp('[0-9a-zA-Z]'),
                    ),
                    LengthLimitingTextInputFormatter(10),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        );
                      },
                    ),
                  ],
            validator: (val) {
              // Guardian ID is optional if nominee has ID, but if provided must be valid
              if (val?.trim().isNullOrEmpty ?? true) {
                final hasNomineeId =
                    controller.nomineeIdController.text.trim().isNotNullOrEmpty;
                if (!hasNomineeId) {
                  return 'Either nominee ID or guardian ID is required for minor nominees';
                }
                return null;
              }

              // Validate format based on ID type
              String? formatError;
              if (controller.guardianIdType.isAadhaar) {
                formatError =
                    NomineeValidationUtils.validateAadhaarLastFour(val!.trim());
              } else if (controller.guardianIdType.isPan) {
                formatError =
                    NomineeValidationUtils.validatePanNumber(val!.trim());

                // Check for duplicate PAN with account holder
                if (formatError == null) {
                  final duplicateError = NomineeValidationUtils
                      .validateGuardianNotDuplicateOfAccountHolder(
                    accountHolder: controller.client,
                    guardianPan: val.trim(),
                    guardianAadhaar: null,
                    guardianDob: null,
                  );
                  if (duplicateError != null) return duplicateError;
                }
              }

              if (formatError != null) return formatError;
              return null;
            },
          ),
        )
      ],
    );
  }
}
