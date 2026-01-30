import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeConfig {
  static ThemeData createTheme({
    required Brightness brightness,
    required Color background,
    required Color primaryText,
    Color? secondaryText,
    required Color accentColor,
    Color? divider,
    Color? buttonBackground,
    required Color buttonText,
    Color? cardBackground,
    Color? disabled,
    required Color error,
  }) {
    final baseTextTheme = brightness == Brightness.dark
        ? Typography.blackMountainView
        : Typography.whiteMountainView;

    return ThemeData(
      useMaterial3: false,
      fontFamily: 'Lato',
      brightness: brightness,
      // buttonColor: buttonBackground,
      canvasColor: background,
      cardColor: background,
      dividerColor: divider,
      dividerTheme: DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      scaffoldBackgroundColor: background,
      primaryColor: accentColor,
      // accentColor: accentColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accentColor,
        secondary: accentColor,
        surface: background,
        background: background,
        error: error,
        onPrimary: buttonText,
        onSecondary: buttonText,
        onSurface: Colors.black.withOpacity(0.8),
        onBackground: buttonText,
        onError: buttonText,
      ),
      // textSelectionColor: accentColor,
      // textSelectionHandleColor: accentColor,
      // toggleableActiveColor: accentColor,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: getDarkStatusBar(),
        // brightness: brightness,
        color: cardBackground,
        // textTheme: TextTheme(
        //   bodyText1: baseTextTheme.bodyLarge!.copyWith(
        //     color: secondaryText,
        //     fontSize: 18,
        //   ),
        // ),
        iconTheme: IconThemeData(
          color: secondaryText,
        ),
      ),
      iconTheme: IconThemeData(
        color: secondaryText,
        size: 16.0,
      ),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: accentColor,
          secondary: accentColor,
          surface: background,
          error: error,
          onPrimary: buttonText,
          onSecondary: buttonText,
          onSurface: buttonText,
          onBackground: buttonText,
          onError: buttonText,
        ),
        padding: const EdgeInsets.all(16.0),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: accentColor,
      ),
      splashColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstants.primaryAppColor,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        errorStyle:
            TextStyle(color: error, fontSize: 12, fontWeight: FontWeight.bold),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
          color: primaryText.withOpacity(0.6),
        ),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
          color: primaryText.withOpacity(0.6),
        ),
      ),
      primaryTextTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge!.copyWith(
          color: primaryText,
          fontSize: 44.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Lato',
        ),
        displayMedium: baseTextTheme.displayMedium!.copyWith(
          color: primaryText,
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lato',
        ),
        displaySmall: baseTextTheme.displaySmall!.copyWith(
          color: primaryText,
          fontSize: 32.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lato',
        ),
        headlineLarge: baseTextTheme.headlineLarge!.copyWith(
          color: primaryText,
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
          fontFamily: 'Lato',
        ),
        headlineMedium: baseTextTheme.headlineMedium!.copyWith(
          color: primaryText,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        headlineSmall: baseTextTheme.headlineSmall!.copyWith(
          color: primaryText,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: primaryText,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: primaryText,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        labelLarge: baseTextTheme.labelLarge!.copyWith(
          color: secondaryText,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Lato',
        ),
        bodySmall: baseTextTheme.bodySmall!.copyWith(
          color: primaryText,
          fontSize: 10.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
        labelSmall: baseTextTheme.labelSmall!.copyWith(
          color: secondaryText,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          fontFamily: 'Lato',
        ),
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: primaryText,
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
          // letterSpacing: 0.25,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: primaryText,
          fontSize: 10.0,
          fontWeight: FontWeight.w400,
          fontFamily: 'Lato',
        ),
      ),
    );
  }

  static ThemeData get lightTheme => createTheme(
        brightness: Brightness.light,
        background: ColorConstants.lightScaffoldBackgroundColor,
        cardBackground: ColorConstants.primaryAppColor,
        primaryText: Colors.black,
        secondaryText: Colors.white,
        accentColor: ColorConstants.primaryAppColor,
        divider: ColorConstants.primaryAppColor,
        buttonBackground: ColorConstants.primaryAppColor,
        buttonText: ColorConstants.primaryAppColor,
        disabled: ColorConstants.primaryAppColor,
        error: ColorConstants.errorColor,
      );

  static ThemeData get darkTheme => createTheme(
        brightness: Brightness.dark,
        background: ColorConstants.darkScaffoldBackgroundColor,
        cardBackground: ColorConstants.primaryCardColor,
        primaryText: Colors.white,
        secondaryText: Colors.black,
        accentColor: ColorConstants.secondaryAppColor,
        divider: Colors.black45,
        buttonBackground: Colors.white,
        buttonText: ColorConstants.white,
        disabled: ColorConstants.lightGrey,
        error: ColorConstants.errorColor,
      );
}
