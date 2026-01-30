import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/amount_textfield.dart';
import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({
    Key? key,
    this.minAmount,
    this.validator,
    this.onChanged,
    this.enabled = true,
    required this.amountController,
  }) : super(key: key);

  final dynamic Function(String)? onChanged;
  final String? Function(String?)? validator;
  final double? minAmount;
  final TextEditingController amountController;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return AmountTextField(
      validator: validator,
      showAmountLabel: false,
      enabled: enabled,
      controller: amountController,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      minAmount: minAmount,
      labelStyle: Theme.of(context)
          .primaryTextTheme
          .headlineSmall!
          .copyWith(fontSize: 12, color: ColorConstants.primaryAppColor),
      scrollPadding: const EdgeInsets.only(bottom: 100),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      captionWidget: Text(
        'Minimum Amount ${WealthyAmount.currencyFormat(minAmount ?? 0, 0)}',
        style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.4,
              color: ColorConstants.tertiaryBlack,
            ),
      ),
    );
  }
}
