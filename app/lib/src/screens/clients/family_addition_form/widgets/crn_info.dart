import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class CRNInfo extends StatefulWidget {
  @override
  State<CRNInfo> createState() => _CRNInfoState();
}

class _CRNInfoState extends State<CRNInfo> {
  bool isExpaned = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: ColorConstants.secondaryAppColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpaned = !isExpaned;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ColorConstants.primaryAppColor,
                  size: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'What is a CRN number?',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontWeight: FontWeight.w400,
                          height: 18 / 12,
                        ),
                  ),
                ),
                Icon(
                  isExpaned
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  size: 20,
                  color: ColorConstants.primaryAppColor,
                )
              ],
            ),
          ),
          if (isExpaned)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'CRN is the unique identification number for your client’s account with Wealthy. Every investor with Wealthy has a different CRN. The CRN for an account does not change.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: ColorConstants.tertiaryGrey, height: 1.3),
              ),
            )
        ],
      ),
    );
  }
}
