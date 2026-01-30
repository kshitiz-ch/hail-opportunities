import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class SkeltonLoaderCard extends StatelessWidget {
  const SkeltonLoaderCard({
    Key? key,
    required this.height,
    this.margin,
    this.radius = 12,
  }) : super(key: key);

  final double height;
  final EdgeInsets? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: ColorConstants.lightBackgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).toShimmer(
      baseColor: ColorConstants.lightBackgroundColor,
      highlightColor: ColorConstants.white,
    );
  }
}
