import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/kyc_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';

class KycForm extends StatelessWidget {
  KycForm({Key? key}) : super(key: key);
  final PartnerKycController controller = Get.find<PartnerKycController>();

  @override
  Widget build(BuildContext context) {
    if (controller.dobController.text.isNullOrEmpty &&
        controller.agent?.dob != null) {
      controller.dobController.text =
          DateFormat('dd/MM/yyyy').format(controller.agent!.dob!);
      controller.pickedDob = controller.agent!.dob;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radio Button
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: RadioButtons(
              spacing: 30,
              runSpacing: 80,
              direction: Axis.horizontal,
              items: [
                KycPanUsageType.INDIVIDUAL,
                KycPanUsageType.NONINDIVIDUAL
              ],
              selectedValue: controller.panUsageType,
              onTap: (panUsageTypeSelected) {
                controller.switchPanUsageType(panUsageTypeSelected);
              },
              itemBuilder: (context, value, index) {
                value = value as KycPanUsageType;
                String text = value == KycPanUsageType.NONINDIVIDUAL
                    ? 'Non-Individual'
                    : value.name.toTitleCase();
                return Text(
                  text,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: controller.panUsageType == value
                            ? ColorConstants.black
                            : ColorConstants.tertiaryBlack,
                      ),
                );
              },
            ),
          ),

          // Pan Number Text Field
          _buildTextField(
            labelText: '10 Digit PAN Number',
            keyboardType: TextInputType.name,
            showCloseIcon: true,
            context: context,
            maxLength: 10,
            controller: controller.panNumberController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[0-9a-zA-Z]',
                ),
              ),
              TextInputFormatter.withFunction(
                (oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                  );
                },
              )
            ],
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Pan number is required.';
              }
              if (value!.length < 10) {
                return 'Enter a valid pan number.';
              }

              return null;
            },
          ),
          // Pan number description text
          _buildHelperText(
              context: context,
              text:
                  'ARN is detected from PAN. If you have an ARN,\nplease enter the respective PAN'),

          // Email address textField
          _buildTextField(
            labelText: 'Your Email Address',
            keyboardType: TextInputType.emailAddress,
            context: context,
            controller: controller.emailController,
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Email is required.';
              }

              if (!isEmailValid(value)) {
                return 'Email is invalid';
              }

              return null;
            },
          ),
          // Email description text
          _buildHelperText(
              context: context,
              text: 'All official Wealthy communication will be sent to this'),

          // GstDeclarationInput(),
          _buildDobInputField(context),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    TextEditingController? controller,
    String? labelText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    double paddingTop = 45.0,
    int? maxLength,
    bool showCloseIcon = false,
  }) {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    return Padding(
      padding: EdgeInsets.only(top: paddingTop),
      child: SimpleTextFormField(
        maxLength: maxLength,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        keyboardType: keyboardType,
        label: labelText,
        useLabelAsHint: true,
        contentPadding: EdgeInsets.only(bottom: 8),
        borderColor: ColorConstants.lightGrey,
        style: textStyle,
        labelStyle: hintStyle,
        hintStyle: hintStyle,
        inputFormatters: inputFormatters,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        validator: validator,
        suffixIcon: showCloseIcon && controller!.text.isNotNullOrEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 21.0,
                  color: ColorConstants.darkGrey,
                ),
                onPressed: () {
                  controller.clear();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildHelperText({
    required BuildContext context,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.tertiaryBlack,
            ),
      ),
    );
  }

  Widget _buildDobInputField(BuildContext context) {
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    return Padding(
      padding: EdgeInsets.only(top: 45),
      child: SimpleTextFormField(
        enabled: true,
        controller: controller.dobController,
        useLabelAsHint: true,
        contentPadding: EdgeInsets.only(bottom: 8),
        borderColor: ColorConstants.lightGrey,
        style: textStyle,
        labelStyle: hintStyle,
        hintStyle: hintStyle,
        label: "Date of Birth",
        readOnly: true,
        textInputAction: TextInputAction.next,
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          size: 16.0,
          color: ColorConstants.tertiaryGrey,
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            initialDatePickerMode: DatePickerMode.year,
            context: context,
            initialDate: controller.pickedDob ?? DateTime.now(),
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
            controller.pickedDob = pickedDate;
            controller.dobController.text =
                DateFormat('dd/MM/yyyy').format(pickedDate);
            controller.update();
          }
        },
        validator: (value) {
          if (value.isNullOrEmpty) {
            return 'Date of Birth is required.';
          }

          if (controller.panUsageType == KycPanUsageType.INDIVIDUAL &&
              !isAdult(controller.pickedDob!)) {
            return 'Please select Non-Individual if you are under 18 years old.';
          }

          // if (!isAdult(controller.pickedDob!)) {
          //   return 'Age should be greater than 18.';
          // }

          return null;
        },
      ),
    );
  }
}
