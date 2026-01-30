import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BorderedTextFormField extends StatelessWidget {
  // Fields
  final String? label;
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
  final BorderRadius borderRadius;
  final double borderWidth;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final Widget? prefixIcon;
  final bool enabled;
  final bool autocorrect;
  final int? maxLength;
  final Color? fillColor;
  final bool showCounter;
  final EdgeInsets scrollPadding;
  final TextStyle? hintStyle;
  final bool obscureText;
  final String? errorText;
  final TextStyle? labelStyle;
  final bool autoFocus;
  final bool useLabelAsHint;
  final String? helperText;
  final Color? borderColor;
  final BoxConstraints? prefixIconConstraint;

  // Constructor
  const BorderedTextFormField({
    Key? key,
    this.label,
    this.borderColor,
    this.obscureText = false,
    this.errorText,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onChanged,
    this.labelStyle,
    this.style,
    this.contentPadding = const EdgeInsets.all(12),
    this.hintText,
    this.inputFormatters,
    this.suffixIcon,
    this.borderWidth = 1.0,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.hintStyle,
    this.prefixIcon,
    this.prefixIconConstraint,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autocorrect = true,
    this.maxLength,
    this.fillColor,
    this.showCounter = true,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.autoFocus = false,
    this.useLabelAsHint = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.5)),
    this.helperText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && !useLabelAsHint)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              label!,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: Color(0xFF808080),
                    letterSpacing: -0.47,
                  ),
            ),
          ),
        TextFormField(
          enabled: enabled,
          obscureText: obscureText,
          autocorrect: autocorrect,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          autofocus: autoFocus,
          focusNode: focusNode,
          style: style ?? Theme.of(context).primaryTextTheme.headlineSmall,
          autovalidateMode: autovalidateMode,
          textInputAction: textInputAction,
          maxLength: maxLength,
          scrollPadding: scrollPadding,
          decoration: InputDecoration(
            filled: fillColor != null,
            fillColor: fillColor,
            errorText: errorText,
            helperText: helperText,
            counterStyle: showCounter
                ? Theme.of(context)
                    .primaryTextTheme
                    .bodySmall!
                    .copyWith(color: Color(0xFF818181)..withOpacity(0.5))
                : TextStyle(color: Colors.transparent),
            errorStyle: Theme.of(context)
                .primaryTextTheme
                .bodyMedium!
                .copyWith(color: ColorConstants.errorTextColor, fontSize: 12),
            errorMaxLines: 2,
            contentPadding: contentPadding,
            suffixIcon: suffixIcon,
            hintText: useLabelAsHint ? null : hintText,
            labelText: useLabelAsHint ? label : null,
            labelStyle: labelStyle ??
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      color: Color(0xFF818181)..withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                    ),
            hintStyle: hintStyle ??
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      color: Color(0xFFBEBEBE),
                      letterSpacing: -0.47,
                      fontWeight: FontWeight.w400,
                    ),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                width: borderWidth,
                color: borderColor ?? Color(0xFFEAEAEA)
                  ..withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                width: borderWidth,
                color: borderColor ?? Color(0xFFEAEAEA)
                  ..withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                width: borderWidth,
                color: borderColor ?? Color(0xFFEAEAEA)
                  ..withOpacity(0.5),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                width: borderWidth,
                color: Color(0xFFFF0000),
              ),
            ),
            prefixIcon: prefixIcon ?? null,
            prefixIconConstraints: prefixIconConstraint,
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
        ),
      ],
    );
  }
}
