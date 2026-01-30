import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/advisor/models/amc_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AmcSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w400,
        );
    return GetBuilder<TicobController>(
      builder: (controller) {
        return DropdownButtonFormField2<AmcModel>(
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: ColorConstants.tertiaryBlack,
            ),
          ),
          buttonStyleData: ButtonStyleData(
            elevation: 0,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: ColorConstants.lightGrey,
              ),
            ),
            padding: EdgeInsets.only(right: 10),
          ),
          dropdownStyleData: DropdownStyleData(
            padding: EdgeInsets.zero,
            // width: maxWidth,
            offset: Offset.zero,
            elevation: 0,
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: MaterialStateProperty.all<bool>(true),
              radius: Radius.circular(8),
              thickness: MaterialStateProperty.all<double>(5.0),
            ),
            maxHeight: 200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.black.withOpacity(0.3),
                  offset: Offset(0.0, 1.0),
                  spreadRadius: 0.0,
                  blurRadius: 7.0,
                ),
              ],
              color: ColorConstants.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          style: style,
          value: controller.selectedAmc,
          items: controller.amcList.map(
            (value) {
              return DropdownMenuItem(
                value: value,
                child: GetBuilder<TicobController>(
                  builder: (controller) {
                    final isSelected =
                        controller.selectedAmc?.amcCode == value.amcCode;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: ColorConstants.borderColor),
                        ),
                      ),
                      child: Row(
                        children: [
                          CommonUI.buildCheckbox(
                            onChanged: (isChecked) {
                              if (isChecked == true) {
                                controller.selectedAmc = value;
                              } else {
                                controller.selectedAmc = null;
                              }
                              controller.update();
                            },
                            value: isSelected,
                          ),
                          Text(
                            (value.amc ?? '').toTitleCase(),
                            style: style.copyWith(
                              color: isSelected
                                  ? ColorConstants.black
                                  : ColorConstants.tertiaryBlack,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ).toList(),
          selectedItemBuilder: (BuildContext context) {
            return controller.amcList.map(
              (value) {
                return Text(
                  (value.amc ?? '').toTitleCase(),
                  style: style,
                );
              },
            ).toList();
          },
          hint: Text('Choose AMC', style: style),
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            // isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ColorConstants.lightGrey),
              borderRadius: BorderRadius.circular(16),
            ),
            labelText: 'Choose AMC',
            labelStyle: style,
            hintStyle: style,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorStyle: Theme.of(context)
                .primaryTextTheme
                .bodyMedium!
                .copyWith(color: ColorConstants.errorTextColor, fontSize: 12),
            errorMaxLines: 2,
          ),
          onChanged: (value) {
            controller.selectedAmc = value;
            controller.update();
          },
        );
      },
    );
  }
}
