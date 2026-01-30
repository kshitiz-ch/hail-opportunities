import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;

class ResponsiveCardContainer extends StatelessWidget {
  const ResponsiveCardContainer(
      {Key? key, this.child, this.constraints, this.width})
      : super(key: key);

  final Widget? child;

  final BoxConstraints? constraints;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Responsive.ResponsiveVisibility(
      hiddenConditions: const [
        Responsive.Condition.largerThan(name: Responsive.TABLET),
      ], // alignment: Alignment.center,
      child: Container(width: width, child: child),
      replacement:
          Container(width: width, constraints: constraints, child: child),
    );
  }
}
