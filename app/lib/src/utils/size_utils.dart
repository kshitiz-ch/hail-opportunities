import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;

class SizeConfig {
  SizeConfig._();
  static SizeConfig _instance = SizeConfig._();
  factory SizeConfig() => _instance;

  late MediaQueryData _mediaQueryData;
  double? screenWidth;
  late double screenHeight;
  late double blockSizeHorizontal;
  late double blockSizeVertical;
  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  late double safeBlockHorizontal;
  late double safeBlockVertical;
  double? profileDrawerWidth;
  late double refHeight;
  late double refWidth;
  bool isTabletDevice = false;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    refHeight = 812;
    refWidth = 375;

    if (screenHeight < 1200) {
      blockSizeHorizontal = screenWidth! / 100;
      blockSizeVertical = screenHeight / 100;

      _safeAreaHorizontal =
          _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical =
          _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
      safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal) / 100;
      safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    } else {
      blockSizeHorizontal = screenWidth! / 120;
      blockSizeVertical = screenHeight / 120;

      _safeAreaHorizontal =
          _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical =
          _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
      safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal) / 120;
      safeBlockVertical = (screenHeight - _safeAreaVertical) / 120;
    }
    updateScreenType(context);
  }

  double getWidthRatio(double val) {
    double res = (val / refWidth) * 100;
    double temp = res * blockSizeHorizontal;

    return temp;
  }

  void updateScreenType(BuildContext context) async {
    isTabletDevice = await isTablet(context);
  }

  double getHeightRatio(double val) {
    double res = (val / refHeight) * 100;
    double temp = res * blockSizeVertical;
    return temp;
  }

  double getFontRatio(double val) {
    double res = (val / refWidth) * 100;
    double temp = 0.0;
    if (screenWidth! < screenHeight) {
      temp = res * safeBlockHorizontal;
    } else {
      temp = res * safeBlockVertical;
    }

    return temp;
  }
}

extension SizeUtils on num {
  double get toWidth => SizeConfig().getWidthRatio(this.toDouble());
  double get toHeight => SizeConfig().getHeightRatio(this.toDouble());
  double get toFont => SizeConfig().getFontRatio(this.toDouble());
}

//* function which checks and returns value (fontSize or dimension) according to mobile or tablet
double deviceSpecificValue(
    BuildContext context, double defaultValue, double tabletValue) {
  return Responsive.ResponsiveValue(
    context,
    defaultValue: defaultValue,
    conditionalValues: [
      Responsive.Condition.smallerThan(
        name: Responsive.MOBILE,
        value: defaultValue,
      ),
      Responsive.Condition.largerThan(
        name: Responsive.TABLET,
        value: tabletValue,
      )
    ],
  ).value.toDouble();
}
