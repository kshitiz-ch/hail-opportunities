import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;

class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    Key? key,
    this.child,
    this.isCentreAlign = false,
    this.isExpaned = false,
    this.maxWidthRatio = 0.5,
  }) : assert(maxWidthRatio < 1);
  final Widget? child;
  final bool isExpaned;
  final double maxWidthRatio;
  final bool isCentreAlign;

  @override
  Widget build(BuildContext context) {
    return Responsive.ResponsiveVisibility(
      hiddenConditions: const [
        Responsive.Condition.largerThan(name: Responsive.TABLET),
      ], // alignment: Alignment.center,
      child: isExpaned ? Expanded(child: child!) : child!,
      replacement: isCentreAlign
          ? Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: SizeConfig().screenWidth! * maxWidthRatio,
                ),
                child: child,
              ),
            )
          : Container(
              constraints: BoxConstraints(
                maxWidth: SizeConfig().screenWidth! * maxWidthRatio,
              ),
              child: child),
    );
  }
}
