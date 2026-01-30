import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/family_addition_form/widgets/crn_info.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberCRNForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              height: 0.7,
            );
    return GetBuilder<ClientFamilyController>(builder: (controller) {
      return Form(
        key: controller.memberCRNFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CRN Field
            _buildTextField(controller, context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CRNInfo(),
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
    });
  }

  // Its just a placeholder widget
  // onTap opens overlay with this textfield and result section

  Widget _buildTextField(
    ClientFamilyController controller,
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Family Member',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ),
        //TextField Placeholder
        InkWell(
          onTap: () {
            if (!controller.isCRNClientSelected) {
              AutoRouter.of(context).push(AddFamilyCrnSearchRoute());
            }
          },
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
              border: Border.all(
                color: ColorConstants.textFieldBorderColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Prefix Icon
                controller.isCRNClientSelected
                    ? Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${controller.CRNSelectedClient?.name?.toTitleCase() ?? ''} | ${controller.CRNSelectedClient?.crn?.toUpperCase() ?? ''} ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  color: ColorConstants.black,
                                ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        size: 24,
                        color: ColorConstants.primaryAppColor,
                      ),
                // Hint text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      controller.isCRNClientSelected
                          ? ''
                          : 'Search Family Member for CRN Number',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.textFieldHintColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ),
                ),
                // Suffix Icon
                controller.isCRNClientSelected
                    ? InkWell(
                        onTap: () {
                          if (controller.isCRNClientSelected) {
                            AutoRouter.of(context)
                                .push(AddFamilyCrnSearchRoute());
                          }
                        },
                        child: Icon(
                          Icons.edit,
                          size: 24,
                          color: ColorConstants.primaryAppColor,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
