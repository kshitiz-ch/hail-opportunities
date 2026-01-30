import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class WealthyRatingDescriptionBottomSheet extends StatelessWidget {
  const WealthyRatingDescriptionBottomSheet({Key? key, required this.fund})
      : super(key: key);

  final SchemeMetaModel fund;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildTitleAndDescription(context),

            // Wealthy Return Score, Risk Score & Valuation Score
            ..._buildDescription(context),

            CommonMfUI.buildDisclaimerText(context),

            Padding(
              padding: EdgeInsets.only(top: 40),
              child: ActionButton(
                text: 'Close',
                margin: EdgeInsets.zero,
                onPressed: () {
                  AutoRouter.of(context).popForced();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wealthy Rating',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6, bottom: 25),
          child: Text(
            'Indicator of funds quality measured using key paramters across Return, Risk, Valuation and Credit Quality',
            style: Theme.of(context).primaryTextTheme.headlineSmall!,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDescription(BuildContext context) {
    List<String> descriptionList = getDescriptionList();

    List titleList = ['Return Score', 'Risk Score', 'Credit Quality Score'];

    return descriptionList
        .mapIndexed(
          (description, index) => _buildBulletPoints(
            context,
            title: titleList[index],
            subtitle: description,
          ),
        )
        .toList();
  }

  List<String> getDescriptionList() {
    String fundDescription = fundTypeDescription(fund.fundType);

    if (fundDescription == FundType.Debt.name) {
      return [
        'Consistent fund outperformance measured using Historical Returns, Yield to Maturity etc',
        'Lower risk during adverse interest movement using Modified Duration, Avg Maturity etc',
        'Lower default and concentration risk measured using avg credit quality and portfolio diversification'
      ];
    }

    if (fundDescription == FundType.Hybrid.name) {
      return [
        'Consistent fund outperformance measured using Rolling Returns, Information Ratio, YTM etc',
        'Lower risk relative to market measured using Std Dev, Beta, Downcapture Ratio, Modified Duration etc.',
        'Valuation and Earnings Growth of the underlying portfolio measured using PE, PB and EPS Growth'
      ];
    }

    return [
      'Consistent fund outperformance measured using Rolling Returns, Information Ratio etc',
      'Lower risk relative to market measured using Std Dev, Beta, Downcapture Ratio etc.',
      'Valuation and Earnings Growth of the underlying portfolio measured using PE, PB and ROE Growth'
    ];
  }

  Widget _buildBulletPoints(BuildContext context,
      {required String title, required String subtitle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7),
            child: Image.asset(
              AllImages().starBulletPointIcon,
              width: 8,
              height: 8,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displayLarge!
                      .copyWith(fontSize: 16),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
