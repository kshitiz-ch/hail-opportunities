import 'package:flutter/material.dart';

class CustomSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double
      disabledThumbRadius; // Optional: if you want a different size when disabled
  final Color thumbColor;
  final Color innerThumbColor;

  const CustomSliderThumbShape({
    this.enabledThumbRadius = 12.0,
    double? disabledThumbRadius,
    required this.thumbColor,
    this.innerThumbColor = Colors.white,
  }) : disabledThumbRadius = disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled ? enabledThumbRadius : disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer circle
    final Paint outerPaint = Paint()..color = thumbColor;
    canvas.drawCircle(center, enabledThumbRadius, outerPaint);

    // Inner circle
    final Paint innerPaint = Paint()..color = innerThumbColor;
    // Adjust the radius for the inner circle. For example, half of the outer radius.
    final double innerRadius = enabledThumbRadius / 2;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
}
