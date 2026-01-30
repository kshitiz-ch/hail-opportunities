import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:flutter/material.dart';

class ChangePassCode extends StatelessWidget {
  const ChangePassCode(
      {Key? key, this.verifyConfirmPasscode, this.onTap, this.lockScreenMode})
      : super(key: key);

  final String? verifyConfirmPasscode;
  final LockScreenMode? lockScreenMode;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        onTap!();
      },
      child: Container(
        margin: EdgeInsets.only(top: 32),
        child: Text(
          lockScreenMode == LockScreenMode.newPassCodeMode
              ? 'Reset Passcode'
              : 'Forgot Passcode?',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.displayLarge!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorConstants.primaryAppColor),
        ),
      ),
    );
  }
}
