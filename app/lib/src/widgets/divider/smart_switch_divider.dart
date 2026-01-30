import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';

class SmartSwitchDivider extends StatelessWidget {
  // Fields
  final double indent;
  final double endIndent;
  final Color color;
  final double thickness;
  final double centerPadding;

  // Constructor
  const SmartSwitchDivider({
    Key? key,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color = const Color(0xFFCCB4EC),
    this.thickness = 0.5,
    this.centerPadding = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: thickness,
            color: Color(0xFFCCB4EC),
            indent: indent,
            endIndent: centerPadding,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: ColorConstants.primaryAppColor.withOpacity(0.15),
            border: Border.all(
              color: Color(0xFFCCB4EC),
              width: thickness,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Image.asset(
            AllImages().upAndDownArrow,
            height: 13,
          ),
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            color: Color(0xFFCCB4EC),
            indent: centerPadding,
            endIndent: endIndent,
          ),
        ),
      ],
    );
  }
}
