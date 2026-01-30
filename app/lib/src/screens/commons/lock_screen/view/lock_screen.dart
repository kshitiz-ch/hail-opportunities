import 'dart:async';

import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/circle_input_button.dart';
import '../widgets/dot_screen_ui.dart';

Future showConfirmPasscode({
  required BuildContext context,
  String title = 'Set your New Passcode',
  String confirmTitle = 'Please Confirm Passcode.',
  String cancelText = 'CANCEL',
  String deleteText = 'DELETE',
  int digits = 4,
  DotSecretConfig dotSecretConfig = const DotSecretConfig(),
  void Function(BuildContext, String)? onCompleted,
  Color backgroundColor = Colors.white,
  double backgroundColorOpacity = 1,
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
          confirmMode: true,
          digits: digits,
          dotSecretConfig: dotSecretConfig,
          onCompleted: onCompleted,
          cancelText: cancelText,
          deleteText: deleteText,
          isSetNewPasscode: true,
          backgroundColor: backgroundColor,
          backgroundColorOpacity: backgroundColorOpacity,
          circleInputButtonConfig: circleInputButtonConfig,
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
  String cancelText = 'CANCEL',
  String deleteText = 'DELETE',
  int digits = 4,
  DotSecretConfig dotSecretConfig = const DotSecretConfig(),
  bool canCancel = true,
  void Function(BuildContext, String)? onCompleted,
  Widget biometricButton = const Icon(Icons.fingerprint),
  bool canBiometric = false,
  bool showBiometricFirst = false,
  @Deprecated('use biometricAuthenticate.')
  void Function(BuildContext)? biometricFunction,
  Future<bool> Function(BuildContext)? biometricAuthenticate,
  Color backgroundColor = Colors.white,
  double backgroundColorOpacity = 1,
  CircleInputButtonConfig circleInputButtonConfig =
      const CircleInputButtonConfig(),
  void Function()? onUnlocked,
}) {
  return AutoRouter.of(context).pushNativeRoute(
    PageRouteBuilder(
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
          canCancel: canCancel,
          cancelText: cancelText,
          deleteText: deleteText,
          biometricButton: biometricButton,
          canBiometric: canBiometric,
          showBiometricFirst: showBiometricFirst,
          isSetNewPasscode: false,
          showBiometricFirstController: _showBiometricFirstController,
          biometricFunction: biometricFunction,
          biometricAuthenticate: biometricAuthenticate,
          backgroundColor: backgroundColor,
          backgroundColorOpacity: backgroundColorOpacity,
          circleInputButtonConfig: circleInputButtonConfig,
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

class LockScreen extends StatefulWidget {
  final String? correctString;
  final String title;
  final String confirmTitle;
  final bool confirmMode;
  final Widget? rightSideButton;
  final int digits;
  final DotSecretConfig dotSecretConfig;
  final CircleInputButtonConfig circleInputButtonConfig;
  final bool canCancel;
  final String? cancelText;
  final String? deleteText;
  final Widget biometricButton;
  final void Function(BuildContext, String)? onCompleted;
  final bool canBiometric;
  final bool showBiometricFirst;
  final bool isSetNewPasscode;
  // @Deprecated('use biometricAuthenticate.')
  final void Function(BuildContext)? biometricFunction;
  final Future<bool> Function(BuildContext)? biometricAuthenticate;
  final StreamController<void>? showBiometricFirstController;
  final Color backgroundColor;
  final double backgroundColorOpacity;
  final void Function()? onUnlocked;

  LockScreen({
    this.correctString,
    this.title = 'Please Enter Passcode',
    this.confirmTitle = 'Please Enter Confirm Passcode',
    this.confirmMode = false,
    this.digits = 4,
    this.dotSecretConfig = const DotSecretConfig(),
    this.circleInputButtonConfig = const CircleInputButtonConfig(),
    this.rightSideButton,
    this.canCancel = true,
    this.cancelText,
    this.deleteText,
    this.biometricButton = const Icon(Icons.fingerprint),
    this.onCompleted,
    this.canBiometric = false,
    this.showBiometricFirst = false,
    this.isSetNewPasscode = false,
    this.biometricFunction,
    this.biometricAuthenticate,
    this.showBiometricFirstController,
    this.backgroundColor = Colors.white,
    this.backgroundColorOpacity = 1,
    this.onUnlocked,
  });

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  // receive from circle input button
  final StreamController<String> enteredStream = StreamController<String>();
  final StreamController<void> removedStreamController =
      StreamController<void>();
  final StreamController<int> enteredLengthStream =
      StreamController<int>.broadcast();
  final StreamController<bool> validateStreamController =
      StreamController<bool>();

  // control for Android back button
  bool _needClose = false;

  // confirm flag
  bool _isConfirmation = false;

  // confirm verify passcode
  String _verifyConfirmPasscode = '';

  List<String> enteredValues = <String>[];

  DateTime? backButtonPressedSince;

  /// flag to make sure biometric authentication is triggered only once
  bool isBiometricShown = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (widget.showBiometricFirst) {
      // Maintain compatibility.
      if (widget.biometricFunction != null) {
        // Set the listener if there is a stream option.
        if (widget.showBiometricFirstController != null) {
          widget.showBiometricFirstController!.stream.listen((_) {
            if (!isBiometricShown) {
              isBiometricShown = true;
              widget.biometricFunction!(context);
            }
          });
        } else {
          // It is executed by a certain time.
          Future.delayed(
            Duration(milliseconds: 350),
            () {
              if (!isBiometricShown) {
                isBiometricShown = true;
                widget.biometricFunction!(context);
              }
            },
          );
        }
      }

      if (widget.biometricAuthenticate != null) {
        // Set the listener if there is a stream option.
        if (widget.showBiometricFirstController != null) {
          widget.showBiometricFirstController!.stream.listen((_) {
            if (!isBiometricShown) {
              isBiometricShown = true;
              widget.biometricAuthenticate!(context).then((unlocked) {
                if (unlocked) {
                  if (widget.onUnlocked != null) {
                    widget.onUnlocked!();
                  }
                }
              });
            }
          });
        } else {
          // It is executed by a certain time.
          Future.delayed(
            Duration(milliseconds: 350),
            () {
              if (!isBiometricShown) {
                isBiometricShown = true;
                widget.biometricAuthenticate!(context).then((unlocked) {
                  if (unlocked) {
                    if (widget.onUnlocked != null) {
                      widget.onUnlocked!();
                    }
                  }
                });
              }
            },
          );
        }
      }
    }
  }

  void _removedStreamListener() {
    if (removedStreamController.hasListener) {
      return;
    }

    removedStreamController.stream.listen((_) {
      enteredValues.removeLast();
      enteredLengthStream.add(enteredValues.length);
    });
  }

  void _enteredStreamListener() {
    if (enteredStream.hasListener) {
      return;
    }

    enteredStream.stream.listen((value) {
      // add list entered value
      enteredValues.add(value);
      enteredLengthStream.add(enteredValues.length);

      // the same number of digits was entered.
      if (enteredValues.length == widget.digits) {
        var buffer = StringBuffer();
        enteredValues.forEach((value) {
          buffer.write(value);
        });
        _verifyCorrectString(buffer.toString());
      }
    });
  }

  // void _displayLockScreen(passcode) {
  //   showLockScreen(
  //     context: context,
  //     backgroundColorOpacity: 1,
  //     correctString: passcode,
  //     canBiometric: false,
  //     showBiometricFirst: false,
  //     onUnlocked: () async {
  //       LogUtil.printLog('Unlocked.');
  //       AutoRouter.of(context).push(BaseRoute());
  //     },
  //   );
  // }

  void _verifyCorrectString(String enteredValue) {
    Future.delayed(Duration(milliseconds: 150), () {
      var _verifyPasscode = widget.correctString;

      if (widget.confirmMode) {
        if (_isConfirmation == false) {
          _verifyConfirmPasscode = enteredValue;
          enteredValues.clear();
          enteredLengthStream.add(enteredValues.length);
          _isConfirmation = true;
          setState(() {});
          return;
        }
        _verifyPasscode = _verifyConfirmPasscode;
      }

      if (enteredValue == _verifyPasscode) {
        // send valid status to DotSecretUI
        validateStreamController.add(true);
        enteredValues.clear();
        enteredLengthStream.add(enteredValues.length);

        if (widget.onCompleted != null) {
          // call user function
          widget.onCompleted!(context, enteredValue);
        } else {
          _needClose = true;
        }

        if (widget.onUnlocked != null) {
          widget.onUnlocked!();
        }
      } else {
        // send invalid status to DotSecretUI
        validateStreamController.add(false);
        enteredValues.clear();
        enteredLengthStream.add(enteredValues.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _enteredStreamListener();
    _removedStreamListener();
    var _rowMarginSize = MediaQuery.of(context).size.width * 0.025;
    var _columnMarginSize = MediaQuery.of(context).size.width * 0.065;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          backButtonPressedSince =
              minimiseApplication(backButtonPressedSince, context);
        });
      },
      child: Scaffold(
        backgroundColor:
            widget.backgroundColor.withOpacity(widget.backgroundColorOpacity),
        body: SingleChildScrollView(
          // in iOS default scroll behaviour is BouncingScrollPhysics
          // in android its ClampingScrollPhysics Setting
          //ClampingScrollPhysics explicitly for both
          physics: ClampingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(bottom: 32, top: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                _buildTitle(),
                DotSecretUI(
                  validateStream: validateStreamController.stream,
                  dots: widget.digits,
                  config: widget.dotSecretConfig,
                  enteredLengthStream: enteredLengthStream.stream,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _columnMarginSize,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: _rowMarginSize),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildNumberTextButton(context, '1'),
                            _buildNumberTextButton(context, '2'),
                            _buildNumberTextButton(context, '3'),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: _rowMarginSize),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildNumberTextButton(context, '4'),
                            _buildNumberTextButton(context, '5'),
                            _buildNumberTextButton(context, '6'),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: _rowMarginSize),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildNumberTextButton(context, '7'),
                            _buildNumberTextButton(context, '8'),
                            _buildNumberTextButton(context, '9'),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: _rowMarginSize),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildBothSidesButton(context, _biometricButton()),
                            _buildNumberTextButton(context, '0'),
                            _buildBothSidesButton(context, _rightSideButton()),
                          ],
                        ),
                      ),
                      if ((widget.isSetNewPasscode && _isConfirmation) ||
                          !widget.isSetNewPasscode)
                        GestureDetector(
                          onTap: () async {
                            if (widget.isSetNewPasscode) {
                              enteredValues.clear();
                              enteredLengthStream.add(enteredValues.length);
                              setState(() {
                                _verifyConfirmPasscode = '';
                                _isConfirmation = false;
                              });
                            } else {
                              final SharedPreferences sharedPreferences =
                                  await prefs;
                              await sharedPreferences.clear();
                              AutoRouter.of(context)
                                  .navigate(GetStartedRoute());
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              widget.isSetNewPasscode
                                  ? 'RESET PASSCODE'
                                  : 'FORGOT PASSCODE?',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                            ),
                          ),
                        )
                      else
                        SizedBox.shrink()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberTextButton(
    BuildContext context,
    String number,
  ) {
    final buttonSize = MediaQuery.of(context).size.width * 0.215;
    return Container(
      width: buttonSize,
      height: buttonSize,
      child: CircleInputButton(
        enteredSink: enteredStream.sink,
        text: number,
        config: widget.circleInputButtonConfig,
      ),
    );
  }

  Widget _buildBothSidesButton(BuildContext context, Widget? button) {
    final buttonSize = MediaQuery.of(context).size.width * 0.215;
    return Container(
      width: buttonSize,
      height: buttonSize,
      child: button,
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        _isConfirmation ? widget.confirmTitle : widget.title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _biometricButton() {
    if (!widget.canBiometric) return Container();

    return TextButton(
      // padding: EdgeInsets.all(0.0),
      child: widget.biometricButton,
      onPressed: () {
        // Maintain compatibility
        if (widget.biometricFunction == null &&
            widget.biometricAuthenticate == null) {
          throw Exception(
              'specify biometricFunction or biometricAuthenticate.');
        } else {
          if (widget.biometricFunction != null) {
            widget.biometricFunction!(context);
          }

          if (widget.biometricAuthenticate != null) {
            widget.biometricAuthenticate!(context).then((unlocked) {
              if (unlocked) {
                if (widget.onUnlocked != null) {
                  widget.onUnlocked!();
                }
              }
            });
          }
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0.0),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.transparent,
            style: BorderStyle.solid,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget? _rightSideButton() {
    if (widget.rightSideButton != null) return widget.rightSideButton;

    return StreamBuilder<int>(
        stream: enteredLengthStream.stream,
        builder: (context, snapshot) {
          String? buttonText;
          if (snapshot.hasData && snapshot.data! > 0) {
            buttonText = widget.deleteText;
          } else if (widget.canCancel) {
            buttonText = '';
          } else {
            return Container();
          }

          return TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.solid,
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: Text(
              buttonText!,
              style: TextStyle(fontSize: 14, color: Colors.black),
              softWrap: false,
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              if (snapshot.hasData && snapshot.data! > 0) {
                removedStreamController.sink.add(null);
              } else {
                if (widget.canCancel) {
                  //_needClose = true;
                  // Navigator.of(context).maybePop();
                }
              }
            },
          );
        });
  }

  @override
  void dispose() {
    enteredStream.close();
    enteredLengthStream.close();
    validateStreamController.close();
    removedStreamController.close();
    if (widget.showBiometricFirstController != null) {
      widget.showBiometricFirstController!.close();
    }

    // restore orientation.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }
}
