import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/nominee_validation_utils.dart';
import 'package:app/src/controllers/client/nominee_form_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NomineeIdDetail extends StatelessWidget {
  final controller = Get.find<ClientNomineeFormController>();

  late TextStyle hintStyle;
  late TextStyle textStyle;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nominee NRI Checkbox
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          child: Row(
            children: [
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                value: controller.nomineeIdType.isPassport,
                onChanged: (value) {
                  controller.nomineeIdType = value == true
                      ? PersonIDType.Passport
                      : PersonIDType.Aadhaar;
                  controller.nomineeIdController.clear();
                  controller.update();
                },
              ),
              Text(
                'My Nominee is NRI',
                style: textStyle.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (controller.nomineeIdType.isPassport)
          // Nominee's Passport Number
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: CommonClientUI.borderTextFormField(
              context,
              controller: controller.nomineeIdController,
              isCompulsory: true,
              hintText: 'Nominee\'s Passport Number',
              inputFormatters: [NoLeadingSpaceFormatter()],
              validator: (value) {
                if (value?.trim().isNullOrEmpty ?? true) {
                  return 'Passport number is required for NRI nominees';
                }
                final formatError =
                    NomineeValidationUtils.validatePassportNumber(
                        value!.trim());
                if (formatError != null) return formatError;
                return null;
              },
            ),
          )
        else
          _buildChooseNomineeId(context),
      ],
    );
  }

  Widget _buildChooseNomineeId(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Nominee ID', style: textStyle),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 30),
          child: RadioButtons(
            textStyle: textStyle.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
            items: [PersonIDType.Aadhaar, PersonIDType.Pan]
                .map((e) => e.description)
                .toList(),
            selectedValue: controller.nomineeIdType.description,
            onTap: (value) {
              final selectedType = PersonIDType.values.firstWhere(
                (e) => e.description == value,
                orElse: () => PersonIDType.Aadhaar,
              );
              if (selectedType == controller.nomineeIdType) return;

              controller.nomineeIdType = selectedType;
              controller.nomineeIdController.clear();
              controller.update();
            },
          ),
        ),
        // Nominee's Aadhaar or PAN Number based on nomineeIdType
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: CommonClientUI.borderTextFormField(
            context,
            isCompulsory: true,
            controller: controller.nomineeIdController,
            hintText: controller.nomineeIdType.isAadhaar
                ? 'Last 4 digits of Nominee\'s Aadhaar Number'
                : 'Nominee\'s PAN Number',
            inputFormatters: controller.nomineeIdType.isAadhaar
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
              if (val?.trim().isNullOrEmpty ?? true) {
                // Check if this is required based on age and guardian ID
                final isMinor =
                    controller.dob != null && !isAdult(controller.dob!);
                final hasGuardianId = controller.guardianIdController.text
                    .trim()
                    .isNotNullOrEmpty;

                if (!isMinor) {
                  return 'ID is required for adult nominees';
                } else if (isMinor && !hasGuardianId) {
                  return 'Either nominee ID or guardian ID is required for minor nominees';
                }
                return null;
              }

              // Validate format based on ID type
              String? formatError;
              if (controller.nomineeIdType.isAadhaar) {
                formatError =
                    NomineeValidationUtils.validateAadhaarLastFour(val!.trim());
              } else if (controller.nomineeIdType.isPan) {
                formatError =
                    NomineeValidationUtils.validatePanNumber(val!.trim());

                // Check for duplicate PAN with account holder
                if (formatError == null) {
                  final duplicateError = NomineeValidationUtils
                      .validateNomineeNotDuplicateOfAccountHolder(
                    accountHolder: controller.client,
                    nomineePan: val.trim(),
                    nomineeAadhaar: null,
                    nomineeDob: null,
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
