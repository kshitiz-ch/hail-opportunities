import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class BorderedButton extends StatelessWidget {
  // Fields
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? borderColor;
  final Color? textColor;
  final Color backgroundColor;
  final double height;
  final double? borderRadius;

  // Constructor
  const BorderedButton({
    Key? key,
    required this.text,
    this.textStyle,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 17.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
    this.borderColor,
    this.textColor,
    this.backgroundColor = Colors.white,
    this.height = 54.0,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: OutlinedButton(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            textStyle ??
                Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w900,
                    ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              width: 1.0,
              color: borderColor ?? ColorConstants.primaryAppColor,
            ),
          ),
          overlayColor: MaterialStateProperty.all<Color>(
            borderColor ?? ColorConstants.primaryAppColor.withOpacity(0.1),
          ),
          foregroundColor:
              MaterialStateProperty.all<Color?>(textColor ?? borderColor),
          elevation: MaterialStateProperty.all(0.0),
          fixedSize: MaterialStateProperty.all<Size>(
            Size.fromHeight(height),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? height / 2),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
          backgroundColor: MaterialStateProperty.all<Color>(
            backgroundColor,
          ),
        ),
        child: Text(text, style: textStyle ?? null),
        onPressed: onPressed,
      ),
    );
  }
}
