import 'dart:async';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const RESEND_OTP_INTERVAL_IN_SEC = 10;

class OtpInputs extends StatefulWidget {
  OtpInputs({
    Key? key,
    required this.otpInputController,
    required this.resendOtp,
    this.showResendOtp = true,
    this.onChange,
    this.otpLength = 5,
    this.enable = true,
  }) : super(key: key);

  final TextEditingController? otpInputController;
  final Function resendOtp;
  final Function? onChange;
  final int otpLength;
  final bool showResendOtp;
  final bool enable;

  @override
  State<OtpInputs> createState() => _OtpInputsState();
}

class _OtpInputsState extends State<OtpInputs> {
  FocusNode pinFocusNode = FocusNode();

  late Timer _timer;
  int resendOtpTimeLeft = RESEND_OTP_INTERVAL_IN_SEC;
  bool canResendOtp = false;
  bool resendOtpLoading = false;
  bool showToast = false;

  @override
  void initState() {
    _startResendOtpTimer();

    super.initState();
  }

  void _startResendOtpTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (resendOtpTimeLeft == 0) {
          setState(() {
            timer.cancel();
            canResendOtp = true;
          });
        } else {
          setState(() {
            resendOtpTimeLeft--;
          });
        }
      },
    );
  }

  void _resetResendOtpTimer() {
    setState(() {
      canResendOtp = false;
      resendOtpTimeLeft = RESEND_OTP_INTERVAL_IN_SEC;
    });
    _startResendOtpTimer();
  }

  void _resendOtp() async {
    setState(() {
      resendOtpLoading = true;
    });

    try {
      bool? isResentSuccess = await widget.resendOtp();
      if (isResentSuccess == true) {
        _resetResendOtpTimer();
      }
    } finally {
      setState(() {
        resendOtpLoading = false;
      });
    }
  }

  @override
  void dispose() {
    pinFocusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: <Widget>[
            // Height of the entire otp input boxes
            SizedBox(
              height: 80,
            ),
            _buildHiddenTextForm(),
            _buildOtpBoxContainer()
          ],
        ),
        if (widget.showResendOtp) _buildResendOtp()
      ],
    );
  }

  Widget _buildHiddenTextForm() {
    // Hides the text field and instead show the otp boxes
    return AbsorbPointer(
      absorbing: true, // disable tap on the text field
      child: TextFormField(
        textInputAction: TextInputAction.done,
        controller: widget.otpInputController,
        focusNode: pinFocusNode,
        enabled: widget.enable,
        autofocus: true,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {});

          if (value.length == widget.otpLength) {
            pinFocusNode.unfocus();
          }
          if (widget.onChange != null) {
            widget.onChange!();
          }
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(
            widget.otpLength,
          ),
        ],
        showCursor: false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          border: InputBorder.none,
          fillColor: ColorConstants.lightGrey,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        style: TextStyle(
            color: Colors.transparent,
            height: .01,
            fontSize: kIsWeb ? 1 : 0.01),
      ),
    );
  }

  Widget _buildOtpBoxContainer() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: (() {
          if (pinFocusNode.hasFocus &&
              MediaQuery.of(context).viewInsets.bottom == 0) {
            pinFocusNode.unfocus();
            Future.delayed(
              const Duration(microseconds: 1),
              () => pinFocusNode.requestFocus(),
            );
          } else {
            pinFocusNode.requestFocus();
          }
        }),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildOtpBox(),
        ),
      ),
    );
  }

  List<Widget> _buildOtpBox() {
    List<Widget> boxWidgets = <Widget>[];
    List otpEntered = widget.otpInputController!.text.split("");

    for (int index = 0; index < widget.otpLength; index++) {
      String otpValue = '';
      if (otpEntered.length > index) {
        otpValue = otpEntered[index];
      }
      boxWidgets.add(
        Container(
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: otpValue.isNotEmpty
                  ? ColorConstants.secondaryWhite
                  : ColorConstants.lightGrey,
            ),
            color: otpValue.isNotEmpty
                ? ColorConstants.secondaryWhite
                : ColorConstants.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              otpValue.toString(),
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontSize: 18,
                      ),
            ),
          ),
        ),
      );
    }
    return boxWidgets;
  }

  Widget _buildResendOtp() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Haven\'t received the OTP?',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.darkGrey,
                ),
          ),
          InkWell(
            onTap: () {
              if (resendOtpTimeLeft > 0 || resendOtpLoading) {
                return;
              }

              _resendOtp();
            },
            child: Row(
              children: [
                Text(
                  ' Send Again',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                          color: ColorConstants.primaryAppColor.withOpacity(
                              (resendOtpTimeLeft > 0 || resendOtpLoading)
                                  ? 0.5
                                  : 1),
                          fontWeight: FontWeight.w600),
                ),
                if (resendOtpLoading)
                  Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.only(left: 8),
                    child: CircularProgressIndicator(
                      color: ColorConstants.primaryAppColor,
                      strokeWidth: 2,
                    ),
                  )
              ],
            ),
          ),
          if (resendOtpTimeLeft > 0)
            Text(
              ' in $resendOtpTimeLeft sec',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.darkGrey,
                  ),
            )
        ],
      ),
    );
  }
}
