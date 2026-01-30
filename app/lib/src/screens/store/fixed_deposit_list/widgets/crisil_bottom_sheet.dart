import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CrisilBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crisil Rating',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
              ),
              Image.asset(AllImages().crisilIcon, height: 20, width: 48),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            child: Text(
              'Crisil Rating indicates how safe your investment is. AAA denotes the highest level of safety, followed by AA+,AA,AA-,A+,A,A- and so on.',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    height: 20 / 12,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          ActionButton(
            text: 'Okay',
            margin: EdgeInsets.zero,
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
          )
        ],
      ),
    );
  }
}
