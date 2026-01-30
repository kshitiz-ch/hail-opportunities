import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class OtpToast extends StatelessWidget {
  OtpToast(
      {Key? key,
      this.isSuccess = true,
      this.message,
      this.canShowToast = false})
      : super(key: key);

  final bool isSuccess;
  final String? message;
  final bool canShowToast;

  @override
  Widget build(BuildContext context) {
    if (!canShowToast) return SizedBox();

    Color toastColor = isSuccess
        ? ColorConstants.greenAccentColor
        : ColorConstants.redAccentColor;
    String toastText = isSuccess
        ? 'OTP successfully verified!'
        : message ?? 'You have entered a wrong OTP';
    IconData icon = isSuccess ? Icons.check_circle : Icons.cancel;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      padding: EdgeInsets.all(16.0),
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      color: toastColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: toastColor,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              toastText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: toastColor,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
