import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/family_mobile_text_field.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberDetailForm extends StatelessWidget {
  TextStyle? hintStyle;
  TextStyle? textStyle;

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
    return GetBuilder<ClientFamilyController>(
      builder: (controller) {
        return Form(
          key: controller.memberDetailFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First name Field
              _buildTextField(
                controller: controller,
                label: 'First Name ',
                textEditingController: controller.firstNameController,
              ),
              // Last name Field
              _buildTextField(
                controller: controller,
                label: 'Last name',
                textEditingController: controller.lastNameController,
              ),
              // Mobile Number Field
              FamilyMobileTextField(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10)
                    .copyWith(bottom: 40),
                child: _builderHelperText(context),
              ),
              // RelationShip Field
              SimpleDropdownFormField<String>(
                hintText: 'Select Relationship',
                dropdownMaxHeight: 200,
                customText: (value) {
                  return clientFamilyRelationshipMapping[value]!['relation'];
                },
                items: clientFamilyRelationshipMapping.keys.toList(),
                value: controller.relationship,
                borderRadius: 15,
                contentPadding: EdgeInsets.only(bottom: 8),
                borderColor: ColorConstants.lightGrey,
                style: textStyle,
                labelStyle: hintStyle,
                hintStyle: hintStyle,
                label: 'Relationship with user',
                onChanged: (val) {
                  if (val.isNotNullOrEmpty) {
                    controller.updateRelationShip(val!);
                  }
                },
                validator: (val) {
                  if (val == null) {
                    return 'Relationship with user is required.';
                  }
                  return null;
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    TextEditingController? textEditingController,
    TextInputType keyboardType = TextInputType.name,
    String? label,
    ClientFamilyController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SimpleTextFormField(
        controller: textEditingController,
        keyboardType: keyboardType,
        label: label,
        useLabelAsHint: true,
        contentPadding: EdgeInsets.only(bottom: 8),
        borderColor: ColorConstants.lightGrey,
        style: textStyle,
        prefixIconSize: Size(100, 36),
        labelStyle: hintStyle,
        hintStyle: hintStyle,
        inputFormatters: [
          NoLeadingSpaceFormatter(),
        ],
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          controller!.update();
        },
        validator: (value) {
          if (value.isNullOrEmpty) {
            return '$label is required.';
          }
          if (keyboardType == TextInputType.phone && value!.length < 10) {
            return 'Mobile Number should be at least 10 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _builderHelperText(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: ColorConstants.tertiaryBlack,
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Access code will be received on this number',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w400,
                  height: 18 / 12,
                ),
          ),
        ),
      ],
    );
  }
}
