import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:flutter/material.dart';

class RiskMeterScreenshot {
  Widget getRiskMeterScreenshotWidget(
      BuildContext context, FundScoreController fundScoreController) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {},
      title: 'Riskometer',
      child: Container(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRiskOMeter(fundScoreController.schemeData?.riskOMeterValue),
            _buildRiskOMeterValue(context, fundScoreController),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskOMeter(String? riskDescription) {
    String image = getRiskOMeterImage(riskDescription);

    return Expanded(
      child: Image.asset(image),
    );
  }

  String getRiskOMeterImage(String? riskDescription) {
    // if (riskScore == null || riskScore <= 1)
    //   return AllImages().riskMeterModeratelyLow;

    // if (riskScore <= 2) return AllImages().riskMeterLow;
    // if (riskScore <= 3) return AllImages().riskMeterModerate;
    // if (riskScore <= 4) return AllImages().riskMeterHigh;
    // if (riskScore <= 5) return AllImages().riskMeterVeryHigh;

    if (riskDescription == null) return AllImages().riskMeterModeratelyLow;
    riskDescription = riskDescription.toLowerCase();

    if (riskDescription == RiskMeterDescription.low ||
        riskDescription == RiskMeterDescription.moderatelyLow)
      return AllImages().riskMeterModeratelyLow;

    if (riskDescription == RiskMeterDescription.moderate)
      return AllImages().riskMeterLow;
    if (riskDescription == RiskMeterDescription.moderatelyHigh)
      return AllImages().riskMeterModerate;
    if (riskDescription == RiskMeterDescription.high)
      return AllImages().riskMeterHigh;
    if (riskDescription == RiskMeterDescription.veryHigh)
      return AllImages().riskMeterVeryHigh;

    return AllImages().riskMeterModeratelyLow;
  }

  Widget _buildRiskOMeterValue(
      BuildContext context, FundScoreController controller) {
    Color meterColor = getMeterColor(controller.schemeData?.riskOMeterValue);

    return Expanded(
      child: Column(
        children: [
          Text(
            'Risk Level',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: meterColor.withOpacity(0.2),
            ),
            child: Text(
              controller.schemeData?.riskOMeterValue ?? 'NA',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: meterColor,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Color getMeterColor(String? riskDescription) {
    List<Color> meterColors = [
      hexToColor("#14B195"),
      hexToColor("#42CA79"),
      hexToColor("#ECDD5B"),
      hexToColor("#FFAA5C"),
      hexToColor("#EF6A5B"),
    ];

    if (riskDescription == null) return meterColors.first;

    riskDescription = riskDescription.toLowerCase();
    if (riskDescription == RiskMeterDescription.low ||
        riskDescription == RiskMeterDescription.moderatelyLow)
      return meterColors.first;

    if (riskDescription == RiskMeterDescription.moderate) return meterColors[1];
    if (riskDescription == RiskMeterDescription.moderatelyHigh)
      return meterColors[2];
    if (riskDescription == RiskMeterDescription.high) return meterColors[3];
    if (riskDescription == RiskMeterDescription.veryHigh) return meterColors[4];

    // if (riskScore == null || riskScore <= 1) return meterColors.first;

    // if (riskScore <= 2) return meterColors[1];
    // if (riskScore <= 3) return meterColors[2];
    // if (riskScore <= 4) return meterColors[3];
    // if (riskScore <= 5) return meterColors[4];

    return meterColors.first;
  }
}
