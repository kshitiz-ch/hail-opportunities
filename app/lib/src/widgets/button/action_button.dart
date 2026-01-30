import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/responsive_button.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  // Fields
  final String? text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final EdgeInsets margin;
  final double height;
  final double? borderRadius;
  final bool showProgressIndicator;
  final bool? isDisabled;
  final Color? bgColor;
  final Color? disabledColor;
  final String? heroTag;
  final bool showBorder;
  final Color? borderColor;
  final Widget? customLoader;
  final Color? progressIndicatorColor;
  final double? responsiveButtonMaxWidthRatio;
  final Widget? prefixWidget;
  final Widget? suffixWidget;

  // Constructor
  const ActionButton({
    Key? key,
    required this.text,
    this.showBorder = false,
    this.borderColor,
    this.textStyle,
    this.onPressed,
    this.margin = const EdgeInsets.symmetric(horizontal: 34.0, vertical: 8.0),
    this.borderRadius,
    this.bgColor,
    this.disabledColor,
    this.height = 54.0,
    this.showProgressIndicator = false,
    this.isDisabled = false,
    this.heroTag,
    this.customLoader,
    this.progressIndicatorColor,
    this.responsiveButtonMaxWidthRatio,
    this.prefixWidget,
    this.suffixWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveButton(
      maxWidthRatio: responsiveButtonMaxWidthRatio ?? 0.5,
      isExpaned: responsiveButtonMaxWidthRatio != null,
      isCentreAlign: true,
      child: Container(
        height: height,
        // for tablet width is decided by maxWidthRatio
        margin: SizeConfig().isTabletDevice
            ? margin.copyWith(left: 0, right: 0)
            : margin,
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: heroTag,
          label: _buildChild(context),
          elevation: 0,
          backgroundColor: isDisabled!
              ? disabledColor ?? ColorConstants.secondaryWhite
              : bgColor ?? ColorConstants.primaryAppColor,
          shape: RoundedRectangleBorder(
            side: showBorder
                ? BorderSide(
                    color: borderColor ?? ColorConstants.primaryAppColor)
                : BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius ?? height / 2),
            ),
          ),
          onPressed: showProgressIndicator || isDisabled! ? null : onPressed,
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (showProgressIndicator) {
      return customLoader ??
          CircularProgressIndicator(
            color: progressIndicatorColor ?? ColorConstants.white,
          );
    }
    Widget textWidget = Text(
      text!,
      style: textStyle ??
          Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
              color: isDisabled!
                  ? ColorConstants.tertiaryBlack
                  : ColorConstants.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w700),
    );
    if (prefixWidget != null || suffixWidget != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixWidget != null) prefixWidget!,
          textWidget,
          if (suffixWidget != null) suffixWidget!,
        ],
      );
    }
    if (text.isNotNullOrEmpty) {
      return textWidget;
    }
    return SizedBox();
  }
}
