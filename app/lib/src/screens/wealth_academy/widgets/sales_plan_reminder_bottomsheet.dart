import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class SalesPlanReminderBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 24),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Access your sales guide anytime',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 10),
          Text(
            'Access your custom made sales guide by selecting "Sales Guide" from the "More" menu',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: ColorConstants.tertiaryBlack, height: 1.5),
          ),
          SizedBox(height: 50),
          ActionButton(
            text: 'Got it',
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
