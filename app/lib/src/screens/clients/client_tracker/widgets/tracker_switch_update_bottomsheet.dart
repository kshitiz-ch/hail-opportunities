import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class TrackerSwitchUpdateBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Introducing Switch',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'A new feature that allows switching fund from \nExternal fund Managers to Wealthy',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          Image.asset(
            AllImages().introSalesPlanIcon,
            height: 180,
            width: 180,
          ),
          ActionButton(
            text: 'Got it',
            margin: EdgeInsets.symmetric(horizontal: 50).copyWith(top: 24),
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
          )
        ],
      ),
    );
  }
}
