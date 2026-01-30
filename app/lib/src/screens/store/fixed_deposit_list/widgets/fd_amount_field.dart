import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FDAmountField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Amount',
          style: context.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorConstants.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 20),
          child: Text(
            'Enter Investment Amount',
            style: context.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.tertiaryBlack,
            ),
          ),
        ),
        _buildAmountTextField(context),
      ],
    );
  }

  Widget _buildAmountTextField(BuildContext context) {
    return GetBuilder<FixedDepositsController>(
      builder: (controller) {
        final style = context.headlineMedium!.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w700,
        );
        return Form(
          key: controller.amountFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: BorderedTextFormField(
            helperText: '',
            useLabelAsHint: true,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderColor: ColorConstants.primaryAppColor,
            label: 'Amount',
            labelStyle: style.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w500,
            ),
            style: style,
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              NoLeadingSpaceFormatter(),
              NoLeadingZeroFormatter(),
            ],
            prefixIconConstraint: BoxConstraints(maxWidth: 30),
            prefixIcon: Center(
              child: Text(
                "\₹ ",
                style: style.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            validator: (value) {
              return controller.validateAmount(value);
            },
            onChanged: (value) {
              controller.updateAmount(value);
            },
          ),
        );
      },
    );
  }
}
