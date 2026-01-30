import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class AccessCodeInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryCardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ColorConstants.black,
                size: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Important',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w400,
                        height: 18 / 12,
                      ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Access code will be valid for 5 mins, so you may please contact your client and let him/her know that they will receive the code now",
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryGrey,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
