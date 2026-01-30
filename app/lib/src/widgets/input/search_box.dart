import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBox extends StatelessWidget {
  // Fields
  final TextEditingController? textEditingController;

  final String? labelText;

  /// A widget to display as the label. If null, [labelText] is used.
  /// This allows for complex labels like [AnimatedSwitcher].
  final Widget? label;

  final String? hintText;

  final Widget? prefixIcon;

  final Widget? suffixIcon;

  final Color fillColor;

  final Color textColor;

  /// This sets the [height] of the SearchBar.
  /// Maximum allowed height is 48px.
  final double height;

  final EdgeInsetsGeometry? contentPadding;

  final ValueChanged<String>? onSubmitted;

  final ValueChanged<String>? onChanged;
  final Function? onTap;

  final FocusNode? focusNode;

  final InputBorder? customBorder;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  // Constructor
  const SearchBox({
    Key? key,
    this.labelText,
    this.label,
    this.hintText,
    this.textEditingController,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.onSubmitted,
    this.fillColor = Colors.transparent,
    this.height = 42.0,
    this.textColor = Colors.black87,
    this.onChanged,
    this.labelStyle,
    this.hintStyle,
    this.customBorder,
    this.focusNode,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      onSubmitted: onSubmitted,
      autofocus: false,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(
            "[0-9a-zA-Z ]",
          ),
        ),
        NoLeadingSpaceFormatter()
      ],
      focusNode: focusNode,
      style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
      decoration: InputDecoration(
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        // to make label text don't go beyond container
        floatingLabelBehavior:
            labelStyle != null ? FloatingLabelBehavior.never : null,
        labelText: label != null ? null : labelText,
        label: label,
        labelStyle: labelStyle ??
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryGrey,
                  fontWeight: FontWeight.w300,
                ),
        hintStyle: labelStyle ??
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryGrey,
                  fontWeight: FontWeight.w300,
                ),
        constraints: BoxConstraints.loose(Size.fromHeight(height)),
        border: customBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(height / 2),
              borderSide: BorderSide(
                  width: 0.5, color: Color(0xFF818181)..withOpacity(0.5)),
            ),
        focusedBorder: customBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(height / 2),
              borderSide: BorderSide(
                  width: 1, color: Color(0xFF818181)..withOpacity(0.5)),
            ),
        enabledBorder: customBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(height / 2),
              borderSide: BorderSide(
                  width: 0.5, color: Color(0xFF818181)..withOpacity(0.5)),
            ),
      ),
      onChanged: onChanged,
    );
  }
}
