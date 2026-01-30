import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClientTextFormField extends StatelessWidget {
  const ClientTextFormField({
    Key? key,
    required this.textController,
    required this.label,
    this.capitalOnly = false,
    this.maxLength = 50,
    this.onChanged,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.inputFormatters = const [],
    this.enabled = true,
  }) : super(key: key);

  final TextEditingController textController;
  final bool capitalOnly;
  final int maxLength;
  final String label;
  final void Function()? onChanged;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(
            color: ColorConstants.tertiaryBlack, height: 0.9, fontSize: 14);
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            );

    return SimpleTextFormField(
      enabled: enabled,
      controller: textController,
      useLabelAsHint: true,
      contentPadding: EdgeInsets.only(bottom: enabled ? 10 : 0),
      borderColor: ColorConstants.borderColor,
      style: textStyle,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      keyboardType: keyboardType,
      label: label,
      inputFormatters: [
        NoLeadingSpaceFormatter(),
      ]..addAll(inputFormatters),
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
      suffixIcon: suffixIcon,
      onChanged: (_) async {
        if (onChanged != null) {
          onChanged!();
        }
        // if (controller.panController!.text.length == 10) {
        //   await controller.verifyPan();
        // }
      },
      // onSubmitted: (_) async {
      //   if (controller.panController!.text.length == 10) {
      //     await controller.verifyPan();
      //   }
      // },
      validator: validator,
    );
  }
}
