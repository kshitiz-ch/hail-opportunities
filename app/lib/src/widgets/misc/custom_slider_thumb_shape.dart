import 'dart:math' as math;

import 'package:app/src/config/utils/extension_utils.dart';
import 'package:flutter/material.dart';

class CustomSliderThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.
  const CustomSliderThumbShape({
    this.enabledInnerThumbRadius = 8.0,
    this.disabledThumbRadius,
    this.elevation = 2.0,
    this.pressedElevation = 3.0,
    this.enabledExternalThumbRadius = 16.0,
    this.circularBorder,
  });
  final double enabledExternalThumbRadius;
  final double enabledInnerThumbRadius;
  final double? circularBorder;
  final double? disabledThumbRadius;
  double get _disabledThumbRadius =>
      disabledThumbRadius ?? enabledInnerThumbRadius;
  final double elevation;
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledInnerThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledInnerThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(enableAnimation)!;
    final double radius = radiusTween.evaluate(enableAnimation);

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation =
        elevationTween.evaluate(activationAnimation);
    final Path path = Path()
      ..addArc(
        Rect.fromCenter(
          center: center,
          width: 2 * enabledExternalThumbRadius,
          height: 2 * enabledExternalThumbRadius,
        ),
        0,
        math.pi * 2,
      );
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.5),
      evaluatedElevation,
      true,
    );
    if (this.circularBorder.isNotNullOrZero) {
      canvas.drawCircle(
        center,
        this.enabledExternalThumbRadius + this.circularBorder!,
        Paint()..color = color,
      );
    }
    canvas.drawCircle(
      center,
      this.enabledExternalThumbRadius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color,
    );
  }
}
