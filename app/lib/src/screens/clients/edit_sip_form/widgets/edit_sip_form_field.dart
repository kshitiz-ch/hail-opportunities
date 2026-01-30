import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/select_mandate.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/goal_inputs/goal_date_input.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditSIPFormField extends StatelessWidget {
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
    return GetBuilder<ClientEditSipController>(
      builder: (ClientEditSipController controller) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.fundSelection == FundSelection.automatic)
                _buildAmountTextField(
                  context: context,
                  controller: controller,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: SelectMandate(),
              ),

              // Start Date
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: InkWell(
                  onTap: () {
                    // if (controller
                    //     .selectedSip.completedOrderCount.isNotNullOrZero) {
                    //   showToast(
                    //       text:
                    //           'SIP is already started. So Start Date cannot be changed now');
                    // }
                  },
                  child: IgnorePointer(
                    // Check This
                    ignoring: false,
                    // ignoring: controller
                    //     .selectedSip.completedOrderCount.isNotNullOrZero,
                    child: GoalDateInput(
                      controller: controller.startDateController,
                      label: 'Start Date',
                      onDateSelect: controller.updateStartDate,
                    ),
                  ),
                ),
              ),

              // End Date
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GoalDateInput(
                  controller: controller.endDateController,
                  label: 'End Date',
                  onDateSelect: controller.updateEndDate,
                  startDate: controller.pickedStartDate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountTextField({
    required ClientEditSipController controller,
    required BuildContext context,
  }) {
    return SimpleTextFormField(
      controller: controller.amountEditController,
      keyboardType: TextInputType.number,
      label: 'Amount',
      useLabelAsHint: true,
      contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.borderColor,
      style: textStyle,
      prefixIconSize: Size(20, 30),
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      prefixIcon: Align(
        alignment: Alignment.bottomLeft,
        child: Text("\₹ "),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onSubmitted: (value) {},
      onChanged: (value) {
        if (value.isEmpty) {
        } else {
          if (value[0] == '₹') {
            value = value.substring(2);
          }

          if (value.length > 1 && double.parse(value) > 999) {
            value = '${WealthyAmount.formatNumber(value)}';
          }
          controller.amountEditController.value =
              controller.amountEditController.value.copyWith(
            text: '$value',
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
        controller.update();
      },
      validator: (value) {
        if (value.isNullOrEmpty) {
          return 'Amount is required.';
        }

        return null;
      },
    );
  }
}
