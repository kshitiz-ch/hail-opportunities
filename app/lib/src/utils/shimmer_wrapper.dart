import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

extension ShimmerEx on Widget {
  /// make any widget to shimmery effect
  /// call [toShimmer()] method on any type of widget.
  /// to use toShimmer() method on particular widget make sure that widget has fixed constraints.
  Widget toShimmer({
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey,
      highlightColor: highlightColor ?? Colors.grey[200]!,
      child: this,
    );
  }
}
