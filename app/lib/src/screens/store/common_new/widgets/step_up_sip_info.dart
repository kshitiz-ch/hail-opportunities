import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class StepUpSipInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              alignment: Alignment.topRight,
              padding: EdgeInsets.zero,
              onPressed: () {
                AutoRouter.of(context).popForced();
              },
              icon: Icon(
                Icons.close,
                size: 24,
                color: ColorConstants.black,
              ),
            ),
          ),
          Image.asset(
            AllImages().stepUpSipIcon,
            height: 80,
            width: 144,
            alignment: Alignment.center,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 12),
            child: Text(
              'What is Step-up SIP',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                      ),
            ),
          ),
          Text(
            'The Step-up SIP feature allows users to automatically increase the SIP amount after the selected time interval (either 6 months or 12 months).',
            style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.tertiaryBlack,
                  height: 1.4,
                ),
          ),
          ActionButton(
            text: 'Got it',
            margin: EdgeInsets.only(top: 50),
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
          ),
        ],
      ),
    );
  }
}
