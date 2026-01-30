import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/material.dart';

class CommonAdvisorUI {
  static Widget buildWealthyArnDetails(BuildContext context) {
    Widget labelValueText(String label, String value) {
      return Transform.scale(
        scale: getScaleValue(context: context, customScaleValue: 1.2),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 9,
                    ),
              ),
              TextSpan(
                text: value,
                style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 9,
                    ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: labelValueText(
              "WealthyIN Customer Services Pvt Limited",
              " AMFI Registered Mutual Fund Distributor (ARN-106846)",
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: labelValueText(
              "ARN Valid from",
              " 20 Nov 2024",
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: labelValueText(
              "ARN Valid Till",
              " 20 Nov 2027",
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: labelValueText(
              'Build Wealth Technologies Pvt Ltd ',
              ' IRDAI Corporate Insurance Agent',
            ),
          )
        ],
      ),
    );
  }
}
