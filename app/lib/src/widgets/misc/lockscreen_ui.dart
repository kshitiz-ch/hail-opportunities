import 'dart:async';

import 'package:app/src/screens/commons/lock_screen/widgets/circle_input_button.dart';
import 'package:app/src/screens/commons/lock_screen/widgets/dot_screen_ui.dart';
import 'package:app/src/screens/commons/lock_screen_new/view/lock_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../config/constants/enums.dart';

Future showConfirmPasscode({
  required BuildContext context,
  String title = 'Please Enter New Passcode',
  String confirmTitle = 'Please Confirm Passcode.',
  String cancelText = 'CANCEL',
  String deleteText = 'DELETE',
  int digits = 4,
  DotSecretConfig dotSecretConfig = const DotSecretConfig(),
  void Function(BuildContext, String)? onCompleted,
  Color backgroundColor = Colors.white,
  double backgroundColorOpacity = 1,
  bool canBiometric = false,
  bool showBiometricFirst = false,
  Future<bool> Function(BuildContext, {bool? fromAppLoad})?
      biometricAuthenticate,
  void Function()? onUnlocked,
  CircleInputButtonConfig circleInputButtonConfig =
      const CircleInputButtonConfig(),
}) {
  return AutoRouter.of(context).pushNativeRoute(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secodaryAnimation,
      ) {
        return LockScreen(
          title: title,
          confirmTitle: confirmTitle,
          digits: digits,
          dotSecretConfig: dotSecretConfig,
          onCompleted: onCompleted,
          cancelText: cancelText,
          deleteText: deleteText,
          lockScreenMode: LockScreenMode.newPassCodeMode,
          backgroundColor: backgroundColor,
          backgroundColorOpacity: backgroundColorOpacity,
          circleInputButtonConfig: circleInputButtonConfig,
          canBiometric: canBiometric,
          showBiometricFirst: showBiometricFirst,
          biometricAuthenticate: biometricAuthenticate,
          onUnlocked: onUnlocked,
        );
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, 2.4),
            end: Offset.zero,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0.0, 2.4),
            ).animate(secondaryAnimation),
            child: child,
          ),
        );
      },
    ),
  );
}

Future showLockScreen({
  required BuildContext context,
  String? correctString,
  String title = 'Please Enter Passcode',
  String confirmTitle = 'Please Confirm Passcode.',
  // String cancelText = 'CANCEL',
  // String deleteText = 'DELETE',
  int digits = 4,
  DotSecretConfig dotSecretConfig = const DotSecretConfig(),
  // bool canCancel = true,
  void Function(BuildContext, String)? onCompleted,
  // Widget biometricButton = const Icon(Icons.fingerprint),
  bool canBiometric = false,
  bool showBiometricFirst = false,
  // @Deprecated('use biometricAuthenticate.')
  // void Function(BuildContext) biometricFunction,
  Future<bool> Function(BuildContext, {bool? fromAppLoad})?
      biometricAuthenticate,
  Color backgroundColor = Colors.white,
  double backgroundColorOpacity = 1,
  // CircleInputButtonConfig circleInputButtonConfig =
  //     const CircleInputButtonConfig(),

  void Function()? onUnlocked,
}) {
  PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
    opaque: false,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secodaryAnimation,
    ) {
      // ignore: close_sinks
      var _showBiometricFirstController = StreamController<void>();

      animation.addStatusListener((status) {
        // Calling the biometric on completion of the animation.
        if (status == AnimationStatus.completed) {
          _showBiometricFirstController.add(null);
        }
      });

      return LockScreen(
        correctString: correctString,
        title: title,
        digits: digits,
        dotSecretConfig: dotSecretConfig,
        onCompleted: onCompleted,
        // canCancel: canCancel,
        lockScreenMode: LockScreenMode.currentPassCodeMode,
        // cancelText: cancelText,
        // deleteText: deleteText,
        // biometricButton: biometricButton,
        canBiometric: canBiometric,
        showBiometricFirst: showBiometricFirst,
        // showBiometricFirstController: _showBiometricFirstController,
        // biometricFunction: biometricFunction,
        biometricAuthenticate: biometricAuthenticate,
        backgroundColor: backgroundColor,
        backgroundColorOpacity: backgroundColorOpacity,
        // circleInputButtonConfig: circleInputButtonConfig,
        onUnlocked: onUnlocked,
      );
    },
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, 2.4),
          end: Offset.zero,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(0.0, 2.4),
          ).animate(secondaryAnimation),
          child: child,
        ),
      );
    },
  );

  return AutoRouter.of(context).pushNativeRoute(pageRouteBuilder);
}
