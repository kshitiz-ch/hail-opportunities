import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class Dashes extends StatelessWidget {
  const Dashes({Key? key, this.textController, this.totalDashes = 4})
      : super(key: key);
  final TextEditingController? textController;
  final int? totalDashes;
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalDashes!, (index) {
          return Dash(textController: textController, currentPosition: index);
        }).toList());
  }
}

class Dash extends StatelessWidget {
  const Dash({Key? key, this.textController, this.currentPosition = 1})
      : super(key: key);

  final TextEditingController? textController;
  final int currentPosition;

  @override
  Widget build(BuildContext context) {
    bool isActive = false;

    int length = textController!.text.length;
    if (currentPosition == length) {
      isActive = true;
    }
    return Container(
        color: isActive
            ? ColorConstants.primaryAppColor
            : ColorConstants.tertiaryBlack,
        height: 2,
        width: 48);
  }
}
