import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasketAmountTextField extends StatelessWidget {
  final TextEditingController amountController;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const BasketAmountTextField({
    Key? key,
    required this.amountController,
    this.onChanged,
    this.validator,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Enter Amount',
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
          ),
        ),
        Spacer(),
        _buildAmountTextField(context: context)
      ],
    );
  }

  Widget _buildAmountTextField({
    required BuildContext context,
  }) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              height: 18 / 16,
            );
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: ColorConstants.primaryAppColor,
      ),
      borderRadius: BorderRadius.circular(4),
    );
    return SizedBox(
      width: SizeConfig().screenWidth! / 2,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textAlign: TextAlign.center,
        controller: amountController,
        keyboardType: TextInputType.number,
        style: textStyle,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
          NoLeadingZeroFormatter(),
        ],
        decoration: InputDecoration(
          errorMaxLines: 2,
          helperText: '',
          errorStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.errorTextColor,
              ),
          filled: true,
          fillColor: ColorConstants.primaryAppv3Color,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          focusedBorder: inputBorder,
          border: inputBorder,
          enabledBorder: inputBorder,
          constraints: BoxConstraints(maxHeight: 60, minHeight: 60),
        ),
        onChanged: (value) {
          onChanged!(value);
        },
        validator: (value) {
          return validator!(value);
        },
      ),
    );
  }
}
