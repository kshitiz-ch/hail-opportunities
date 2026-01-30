import 'dart:async';

import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/commons/lock_screen/widgets/circle_input_button.dart';
import 'package:app/src/screens/commons/lock_screen/widgets/dot_screen_ui.dart';
import 'package:app/src/screens/commons/lock_screen_new/view/widgets/biometric_authentication.dart';
import 'package:app/src/screens/commons/lock_screen_new/view/widgets/text_form.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../config/constants/enums.dart';
import '../../../../utils/auth_util.dart';
import 'widgets/change_passcode.dart';

class LockScreen extends StatefulWidget {
  const LockScreen(
      {Key? key,
      this.title,
      this.correctString,
      this.confirmTitle,
      this.digits,
      this.onCompleted,
      this.backgroundColor,
      this.backgroundColorOpacity,
      this.onUnlocked,
      this.dotSecretConfig,
      this.circleInputButtonConfig,
      this.cancelText,
      this.deleteText,
      this.biometricButton = const Icon(Icons.fingerprint),
      this.canBiometric = false,
      this.showBiometricFirst = false,
      this.biometricFunction,
      this.biometricAuthenticate,
      this.lockScreenMode = LockScreenMode.currentPassCodeMode
      // this.showBiometricFirstController
      })
      : super(key: key);

  final String? title;
  final String? correctString;
  final String? confirmTitle;
  final LockScreenMode lockScreenMode;

  final int? digits;
  final void Function(BuildContext, String)? onCompleted;
  final Color? backgroundColor;
  final double? backgroundColorOpacity;
  final void Function()? onUnlocked;
  final DotSecretConfig? dotSecretConfig;
  final CircleInputButtonConfig? circleInputButtonConfig;
  final String? cancelText;
  final String? deleteText;
  final Widget biometricButton;
  final bool canBiometric;
  final bool showBiometricFirst;
// @Deprecated('use biometricAuthenticate.')
  final void Function(BuildContext)? biometricFunction;
  final Future<bool> Function(BuildContext, {bool? fromAppLoad})?
      biometricAuthenticate;

  // final StreamController<void> showBiometricFirstController;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  TextEditingController passcodeInputController = TextEditingController();
  FocusNode pinFocusNode = FocusNode();
  DateTime? backButtonPressedSince;
  List<BiometricType> bioMetricList = [];

  bool _isConfirmation = false;
  String _verifyConfirmPasscode = '';
  bool _needClose = false;

  @override
  void initState() {
    super.initState();
    getBioMetricList();
  }

  void getBioMetricList() async {
    bioMetricList = await getListOfBiometricTypes();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _verifyCorrectString(String enteredValue) {
    // Future.delayed(Duration(milliseconds: 150), () {
    var _verifyPasscode = widget.correctString;

    if (widget.lockScreenMode == LockScreenMode.newPassCodeMode) {
      if (_isConfirmation == false) {
        _verifyConfirmPasscode = enteredValue;
        _isConfirmation = true;
        passcodeInputController.clear();
        setState(() {});
        return;
      }
      _verifyPasscode = _verifyConfirmPasscode;
    }

    if (enteredValue == _verifyPasscode) {
      if (widget.onCompleted != null) {
        // call user function
        widget.onCompleted!(context, enteredValue);
      } else {
        _needClose = true;
      }
      if (widget.onUnlocked != null) {
        widget.onUnlocked!();
      }
    }
    // });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          backButtonPressedSince =
              minimiseApplication(backButtonPressedSince, context);
        });
      },
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            //* in iOS default scroll behaviour is BouncingScrollPhysics
            //* in android its ClampingScrollPhysics Setting
            //* ClampingScrollPhysics explicitly for both
            physics: ClampingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    constraints:
                        BoxConstraints(minHeight: screenHeight * (135 / 720)),
                  ),
                  Text(
                    _isConfirmation ? widget.confirmTitle! : widget.title!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displaySmall!
                        .copyWith(fontSize: 20.0),
                  ),
                  SizedBox(
                    height: screenHeight * (20 / 720),
                  ),
                  TextForm(
                    passcodeInputController: passcodeInputController,
                    digits: widget.digits,
                    pinFocusNode: pinFocusNode,
                    correctString: widget.correctString,
                    lockScreenMode: widget.lockScreenMode,
                    onChange: (value) {
                      setState(() {});
                      if (value.length == 5) {
                        pinFocusNode.unfocus();
                      }
                      if (value.length == widget.digits) {
                        _verifyCorrectString(value);
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * (90 / 720)),
                  BioMetricAuthentication(
                      biometricList: bioMetricList,
                      screenWidth: screenWidth,
                      canBiometric: widget.canBiometric,
                      showBiometricFirst: widget.canBiometric,
                      biometricFunction: widget.biometricFunction,
                      biometricAuthenticate: widget.biometricAuthenticate,
                      onUnlocked: widget.onUnlocked),
                  if ((widget.lockScreenMode ==
                          LockScreenMode.currentPassCodeMode) ||
                      (widget.lockScreenMode ==
                              LockScreenMode.newPassCodeMode &&
                          _isConfirmation))
                    ChangePassCode(
                        verifyConfirmPasscode: _verifyConfirmPasscode,
                        lockScreenMode: widget.lockScreenMode,
                        onTap: () async {
                          if (widget.lockScreenMode ==
                              LockScreenMode.newPassCodeMode) {
                            setState(() {
                              _verifyConfirmPasscode = '';
                              _isConfirmation = false;
                            });
                          } else {
                            AuthenticationBlocController()
                                .authenticationBloc
                                .add(UserLogOut());
                          }
                        })
                  // await ChangePasscode(context),
                  else
                    SizedBox.shrink()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
