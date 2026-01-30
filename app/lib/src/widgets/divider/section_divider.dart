import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 8.0,
      thickness: 7.5,
      color: ColorConstants.lightBackgroundColor,
    );
  }
}
