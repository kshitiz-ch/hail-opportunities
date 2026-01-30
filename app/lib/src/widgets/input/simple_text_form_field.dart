import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleTextFormField extends StatelessWidget {
  // Fields
  final String? label;
  final bool? enabled;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextStyle? style;
  final EdgeInsetsGeometry contentPadding;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final Widget? prefixIcon;
  final EdgeInsets scrollPadding;
  final bool readOnly;
  final void Function()? onTap;
  final bool autofocus;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final int? maxLength;
  final String? helperText;
  final Color? borderColor;
  final Size prefixIconSize;
  final Size suffixIconSize;
  final bool useLabelAsHint;
  final bool obscureText;
  final TextStyle? helperStyle;
  final bool hideCounterText;

  // Constructor
  const SimpleTextFormField({
    Key? key,
    this.label,
    this.useLabelAsHint = false,
    this.obscureText = false,
    this.helperStyle,
    this.enabled,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onChanged,
    this.style,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.hintText,
    this.inputFormatters,
    this.suffixIcon,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.scrollPadding = const EdgeInsets.only(bottom: 100.0),
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.labelStyle,
    this.hintStyle,
    this.maxLength,
    this.helperText,
    this.borderColor,
    this.hideCounterText = false,
    this.prefixIconSize = const Size(62, 36),
    this.suffixIconSize = const Size(36, 36),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && !useLabelAsHint)
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text(
              label!,
              style: labelStyle ??
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      color: ColorConstants.tertiaryBlack, fontSize: 12),
            ),
          ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          autofocus: autofocus,
          focusNode: focusNode,
          maxLength: maxLength,
          style: style ?? Theme.of(context).primaryTextTheme.headlineSmall,
          autovalidateMode: autovalidateMode,
          textInputAction: textInputAction,
          readOnly: readOnly,
          scrollPadding: scrollPadding,
          decoration: InputDecoration(
            isDense: true,
            counter: hideCounterText
                ? Text(
                    '',
                    style: TextStyle(height: 0),
                  )
                : null,
            helperText: helperText,
            helperStyle: helperStyle ??
                Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                      color: Color(0xFFBEBEBE),
                    ),
            errorStyle: Theme.of(context)
                .primaryTextTheme
                .bodyMedium!
                .copyWith(color: ColorConstants.errorTextColor, fontSize: 12),
            disabledBorder: borderColor != null
                ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor!,
                    ),
                  )
                : null,
            enabledBorder: borderColor != null
                ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor!,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorConstants.lightGrey,
                    ),
                  ),
            errorMaxLines: 2,
            contentPadding: contentPadding,
            suffixIcon: suffixIcon,
            hintText: useLabelAsHint ? null : hintText,
            focusedBorder: borderColor != null
                ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorConstants.primaryAppColor,
                    ),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorConstants.primaryAppColor,
                    ),
                  ),
            labelStyle: labelStyle ??
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack, fontSize: 12),
            labelText: useLabelAsHint ? label : null,
            hintStyle: hintStyle ??
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.darkGrey,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
            prefixIcon: prefixIcon,
            prefixIconConstraints: BoxConstraints.loose(prefixIconSize),
            suffixIconConstraints: BoxConstraints.loose(suffixIconSize),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          onTap: onTap,
        ),
      ],
    );
  }
}
