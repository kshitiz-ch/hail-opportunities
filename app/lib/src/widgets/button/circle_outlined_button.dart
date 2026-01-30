import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class CircleOutlinedButton extends StatelessWidget {
  // Fields
  final double radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isDisabled;

  // Constructor
  const CircleOutlinedButton({
    Key? key,
    this.radius = 10,
    this.borderColor,
    this.backgroundColor,
    this.child,
    this.onPressed,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: radius * 2,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          // primary: isDisabled
          //     ? Color(0xFFDDD5E8)
          //     : borderColor ?? ColorConstants.primaryAppColor,
          backgroundColor: backgroundColor ?? ColorConstants.white,
          fixedSize: Size(radius * 2, radius * 2),
          minimumSize: Size(10, 10),
          maximumSize: Size(radius * 2, radius * 2),
          side: BorderSide(
            color: isDisabled
                ? Color(0xFFDDD5E8)
                : borderColor ?? ColorConstants.primaryAppColor,
            width: 1,
          ),
          shape: CircleBorder(),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: child,
      ),
    );
  }
}
