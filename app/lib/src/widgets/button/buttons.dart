import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

enum _ButtonType { primary, secondary, text }

Widget _loadingIcon({Color? color, double? size}) {
  return CircularProgressIndicator();
  // return SpinKitThreeBounce(
  //   color: color ?? Colors.white,
  //   size: size ?? 20.0,
  // );
}

class Button extends StatelessWidget {
  const Button({
    Key? key,
    this.type = _ButtonType.primary,
    required this.label,
    required this.onPressed,
    this.fontSize = 16,
    this.height,
    this.width,
    this.color = Colors.white,
    this.backgroundColor,
    this.borderRadius = 8,
    this.elevation = 0,
    this.enabled = true,
    this.isLoading = false,
    this.fontWeight = FontWeight.w500,
    this.borderWidth,
  }) : super(key: key);

  factory Button.text({
    required String label,
    required VoidCallback onPressed,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    bool? enabled,
  }) {
    return Button(
      type: _ButtonType.text,
      label: label,
      onPressed: onPressed,
      fontSize: fontSize ?? 14,
      color: color ?? ColorConstants.primaryAppColor,
      fontWeight: fontWeight ?? FontWeight.bold,
      enabled: enabled ?? true,
    );
  }

  factory Button.secondary({
    required String label,
    required VoidCallback onPressed,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? width,
    Color? color,
    Color? backgroundColor,
    double? borderRadius,
    double? elevation,
    bool? enabled,
    double? borderWidth,
    bool? isLoading,
  }) {
    return Button(
      type: _ButtonType.secondary,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading ?? false,
      fontSize: fontSize ?? 16,
      height: height,
      width: width,
      color: color ?? ColorConstants.primaryAppColor,
      backgroundColor: backgroundColor ?? Colors.white,
      borderRadius: borderRadius ?? 8,
      elevation: elevation ?? 0,
      enabled: enabled ?? true,
      borderWidth: borderWidth ?? 2,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  final _ButtonType type;
  final String label;
  final VoidCallback onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final double elevation;
  final bool enabled;
  final bool isLoading;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _ButtonType.text:
        return _buildTextButton();
      case _ButtonType.secondary:
        return _buildSecondaryButton();

      case _ButtonType.primary:
      default:
        return _buildPrimaryButton();
    }
  }

  // TextButton
  Widget _buildTextButton() {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: enabled ? color : Colors.grey,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Material(
      color: (backgroundColor ?? ColorConstants.primaryAppColor).withOpacity(
        (enabled && !isLoading) ? 1 : 0.5,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height ?? 40,
        width: width ?? double.infinity,
        child: InkWell(
          onTap: (enabled && !isLoading) ? onPressed : null,
          child: Center(
            child: isLoading
                ? _loadingIcon()
                : Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Material(
      color: backgroundColor ?? Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height ?? 40,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
              color: color.withOpacity((enabled && !isLoading) ? 1 : 0.5),
              width: borderWidth!),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          onTap: (enabled && !isLoading) ? onPressed : null,
          child: Center(
            child: isLoading
                ? _loadingIcon(color: color)
                : Text(
                    label,
                    style: TextStyle(
                      color:
                          color.withOpacity((enabled && !isLoading) ? 1 : 0.5),
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
