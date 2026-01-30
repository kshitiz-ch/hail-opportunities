import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class TradeDatePassed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Trade Date Passed',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Not able to Purchase this Debenture as\nthe Trade date has passed',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    height: 18 / 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
