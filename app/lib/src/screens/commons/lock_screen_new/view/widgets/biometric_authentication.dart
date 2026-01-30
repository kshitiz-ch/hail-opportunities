import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BioMetricAuthentication extends StatefulWidget {
  const BioMetricAuthentication(
      {Key? key,
      this.screenWidth,
      this.canBiometric,
      this.showBiometricFirst,
      this.biometricFunction,
      this.biometricAuthenticate,
      this.onUnlocked,
      this.biometricList})
      : super(key: key);
  final double? screenWidth;
  final bool? canBiometric;
  final bool? showBiometricFirst;
  final List<BiometricType>? biometricList;

  final void Function(BuildContext)? biometricFunction;
  final Future<bool> Function(BuildContext, {bool? fromAppLoad})?
      biometricAuthenticate;
  final void Function()? onUnlocked;

  @override
  State<BioMetricAuthentication> createState() =>
      _BioMetricAuthenticationState();
}

class _BioMetricAuthenticationState extends State<BioMetricAuthentication> {
  @override
  void initState() {
    if (widget.canBiometric!) {
      if (widget.biometricFunction == null &&
          widget.biometricAuthenticate == null) {
        throw Exception('specify biometricFunction or biometricAuthenticate.');
      } else {
        if (widget.biometricFunction != null) {
          widget.biometricFunction!(context);
        }

        if (widget.biometricAuthenticate != null) {
          widget.biometricAuthenticate!(context, fromAppLoad: true).then(
            (unlocked) {
              if (unlocked) {
                if (widget.onUnlocked != null) {
                  widget.onUnlocked!();
                }
              }
            },
          ).catchError(print);
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canBiometric! || widget.biometricList!.isEmpty)
      return Container();

    return GestureDetector(
        onTap: () async {
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
              widget.biometricAuthenticate!(context).then(
                (unlocked) {
                  if (unlocked) {
                    if (widget.onUnlocked != null) {
                      widget.onUnlocked!();
                    }
                  }
                },
              ).catchError(print);
            }
          }
        },
        child: _buildBioMetricRow());
  }

  Widget _buildBioMetricRow() {
    double iconSize = deviceSpecificValue(context, 24, 28);
    String bioMetricText = "";
    String bioMetricIcon = "";

    if (widget.biometricList![0] == BiometricType.face) {
      bioMetricText = 'Tap to Unlock';
      bioMetricIcon = AllImages().userFaceIdIcon;
    } else if (widget.biometricList![0] == BiometricType.fingerprint) {
      bioMetricText = 'Tap to Unlock';
      bioMetricIcon = AllImages().fingerprintIcon;
    } else if (widget.biometricList![0] == BiometricType.strong ||
        widget.biometricList![0] == BiometricType.weak) {
      bioMetricText = 'Tap to Unlock';
      bioMetricIcon = AllImages().fingerPrintIcon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // margin: EdgeInsets.only(top: 20),
          height: iconSize,
          width: iconSize,
          color: ColorConstants.secondaryWhite,
          child: Image.asset(
            bioMetricIcon,
            // height: 12,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            // color: ColorConstants.primaryAppColor,
          ),
        ),
        SizedBox(width: widget.screenWidth! * (12 / 360)),
        Text(bioMetricText,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineLarge!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ColorConstants.primaryAppColor)),
      ],
    );
  }
}
