import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class ClientListTileShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorConstants.lightBackgroundColor,
      ),
    ).toShimmer(
      baseColor: ColorConstants.lightBackgroundColor,
      highlightColor: ColorConstants.white,
    );
  }
}
