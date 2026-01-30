import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyScreen extends StatelessWidget {
  final String? imagePath;
  final Widget? customWidget;
  final String? message;
  final String? actionButtonText;
  final Function? onClick;
  final double imageSize;
  final TextStyle? textStyle;
  final IconData? iconData;
  final Widget? customActionButton;
  final EdgeInsetsGeometry? textPadding;

  const EmptyScreen({
    Key? key,
    this.imagePath,
    this.customWidget,
    this.onClick,
    this.message,
    this.actionButtonText,
    this.imageSize = 120,
    this.textStyle,
    this.iconData,
    this.customActionButton,
    this.textPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath.isNotNullOrEmpty)
            if (imagePath!.endsWith("svg"))
              SvgPicture.asset(
                imagePath!,
                height: imageSize,
                width: imageSize,
              )
            else
              Image.asset(
                imagePath!,
                height: imageSize,
                width: imageSize,
              ),
          if (iconData != null)
            Icon(
              iconData,
              color: Colors.black.withOpacity(0.5),
              size: 40,
            ),
          if (customWidget != null) customWidget!,
          if (message.isNotNullOrEmpty)
            Padding(
              padding:
                  textPadding ?? const EdgeInsets.only(top: 10.0, bottom: 40),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: textStyle ??
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
              ),
            ),
          if (actionButtonText.isNotNullOrEmpty)
            ActionButton(
              margin: EdgeInsets.symmetric(horizontal: 50),
              height: 56,
              text: actionButtonText,
              onPressed: onClick as void Function()?,
            ),
          if (customActionButton != null) customActionButton!,
        ],
      ),
    );
  }
}
