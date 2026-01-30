import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/home/partner_nominee_controller.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PartnerNomineeForm extends StatelessWidget {
  const PartnerNomineeForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerNomineeController>(builder: (controller) {
      return Column(
        children: [
          _buildTextField(
            labelText: 'Nominee Name',
            keyboardType: TextInputType.name,
            context: context,
            controller: controller.nameController,
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Name is required.';
              }

              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(
                  "[a-zA-Z ]",
                ),
              ),
              NoLeadingSpaceFormatter()
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildDobInputField(context, controller),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildRelationshipDropdown(context, controller),
              )
            ],
          ),
          _buildTextField(
            labelText: 'Nominee Address',
            keyboardType: TextInputType.name,
            context: context,
            controller: controller.addressController,
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'Address is required.';
              }

              return null;
            },
            inputFormatters: [NoLeadingSpaceFormatter()],
          ),
          if (controller.isGuardianRequired)
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: ColorConstants.tertiaryBlack,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          'As Nominee is below 18 years, Legal Guardian is required',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                      )
                    ],
                  ),
                ),
                _buildTextField(
                  labelText: 'Guardian Name',
                  keyboardType: TextInputType.name,
                  context: context,
                  controller: controller.guardianNameController,
                  validator: (value) {
                    if (value.isNullOrEmpty) {
                      return 'Guardian Name is required.';
                    }

                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        "[a-zA-Z ]",
                      ),
                    ),
                    NoLeadingSpaceFormatter()
                  ],
                ),
                _buildTextField(
                  labelText: 'Guardian Address',
                  keyboardType: TextInputType.name,
                  context: context,
                  controller: controller.guardianAddressController,
                  validator: (value) {
                    if (value.isNullOrEmpty) {
                      return 'Guardian Address is required.';
                    }

                    return null;
                  },
                  inputFormatters: [NoLeadingSpaceFormatter()],
                )
              ],
            )
        ],
      );
    });
  }

  Widget _buildRelationshipDropdown(
      BuildContext context, PartnerNomineeController controller) {
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

    return SimpleDropdownFormField<Choice>(
      hintText: 'Relationship',
      label: 'Relationship',
      dropdownMaxHeight: 200,
      customText: (value) {
        return (value as Choice).displayName;
      },
      items: controller.nomineeRelatinoShips,
      value: controller.nomineeRelationShip,
      borderRadius: 15,
      borderColor: ColorConstants.lightGrey,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      onChanged: (val) {
        if (val != null) {
          controller.updateNomineeRelationship(val);
        }
      },
      validator: (val) {
        if (val == null) {
          return 'Field is required';
        }
        return null;
      },
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

  Widget _buildDobInputField(
      BuildContext context, PartnerNomineeController controller) {
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
        label: "Nominee DOB",
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

          // if (!isAdult(controller.pickedDob!)) {
          //   return 'Age should be greater than 18.';
          // }

          return null;
        },
      ),
    );
  }
}
