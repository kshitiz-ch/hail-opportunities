import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class InputContainer extends StatelessWidget {
  const InputContainer({Key? key, this.child, this.showBorder = false})
      : super(key: key);

  final Widget? child;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: child,
      ),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(color: ColorConstants.borderColor),
              )
            : null,
      ),
    );
  }
}
