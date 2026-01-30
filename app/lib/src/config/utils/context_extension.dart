import 'package:flutter/material.dart';

extension BuildContextEntension<T> on BuildContext {
  // Text Styles
  // ===========

  TextStyle? get displayMedium => Theme.of(this).primaryTextTheme.displayMedium;

  TextStyle? get displaySmall => Theme.of(this).primaryTextTheme.displaySmall;

  TextStyle? get headlineLarge => Theme.of(this).primaryTextTheme.headlineLarge;

  TextStyle? get headlineMedium =>
      Theme.of(this).primaryTextTheme.headlineMedium;

  TextStyle? get headlineSmall => Theme.of(this).primaryTextTheme.headlineSmall;

  TextStyle? get titleLarge => Theme.of(this).primaryTextTheme.titleLarge;

  TextStyle? get titleMedium => Theme.of(this).primaryTextTheme.titleMedium;

  TextStyle? get titleSmall => Theme.of(this).primaryTextTheme.titleSmall;

  TextStyle? get labelLarge => Theme.of(this).primaryTextTheme.labelLarge;

  TextStyle? get bodySmall => Theme.of(this).primaryTextTheme.bodySmall;

  TextStyle? get titleTextStyle => Theme.of(this).appBarTheme.titleTextStyle;

  TextStyle? get bodyLarge => Theme.of(this).primaryTextTheme.bodyLarge;

  // Device Sizes
  // ============
  bool get isMobile => MediaQuery.of(this).size.width <= 500.0;

  bool get isTablet =>
      MediaQuery.of(this).size.width < 1024.0 &&
      MediaQuery.of(this).size.width >= 650.0;

  double get width => MediaQuery.of(this).size.width;

  double get height => MediaQuery.of(this).size.height;

  Size get size => MediaQuery.of(this).size;

  Size get panda => MediaQuery.of(this).size;

  double get insetsBottom => MediaQuery.of(this).viewInsets.bottom;
}
