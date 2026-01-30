import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/wealthy_score.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class WealthyScoreScreenshot {
  Widget getWealthyScoreWidget(
      BuildContext context, FundScoreController controller) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {
        // Get.find<FundDetailController>()
        //     .updateNavigationSection(FundNavigationTab.WealthyScore);
      },
      title: 'Wealthy Score',
      trailingWidget: controller.schemeData?.wRating != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.star,
                      color: ColorConstants.primaryAppColor,
                      size: 14,
                    ),
                  ),
                  Text(
                    '${controller.schemeData!.wRating!} / 5',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          : null,
      subtitle:
          'Indicator of fund quality measured using key parameters across returns, risk, valaution and credit quality',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreExpansionTile(
              forScreenshot: true,
              title: 'Return Score',
              description: _getReturnScoreDescription(controller.schemeData!),
              score: controller.schemeData?.wReturnScore,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.getReturnScoreSubFields().map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _buildRowLabelValue(context,
                              label: e.keys.first,
                              value: e.values.first,
                              description: controller
                                  .subfieldsDescription[e.keys.first]),
                        ),
                      ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ScoreExpansionTile(
              forScreenshot: true,
              title: 'Risk Score',
              description: _getRiskScoreDescription(controller.schemeData!),
              score: controller.schemeData?.wRiskScore,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.getRiskScoreSubFields().map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _buildRowLabelValue(context,
                              label: e.keys.first,
                              value: e.values.first,
                              description: controller
                                  .subfieldsDescription[e.keys.first]),
                        ),
                      ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ScoreExpansionTile(
              forScreenshot: true,
              title: fundTypeDescription(controller.schemeData?.fundType) ==
                      FundType.Debt.name
                  ? 'Credit Quality Score'
                  : 'Valuation/Earnings Score',
              description: _getEarningScoreDescription(controller.schemeData!),
              score: fundTypeDescription(controller.schemeData?.fundType) ==
                      FundType.Debt.name
                  ? controller.schemeData?.wCreditQualityScore
                  : controller.schemeData?.wValuationScore,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.getEarningsScoreSubFields().map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _buildRowLabelValue(
                            context,
                            label: e.keys.first,
                            value: e.values.first,
                            description:
                                controller.subfieldsDescription[e.keys.first],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            // PE
            // PF
          ],
        ),
      ),
    );
  }

  Widget _buildRowLabelValue(
    BuildContext context, {
    required String label,
    required String? description,
    required String? value,
  }) {
    TextStyle textStyle = Theme.of(context).primaryTextTheme.titleLarge!;
    return Row(
      children: [
        Text(
          label,
          style: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
        ),
        Spacer(),
        Text(
          value ?? 'NA',
          style: textStyle,
        )
      ],
    );
  }

  String _getReturnScoreDescription(SchemeMetaModel scheme) {
    String fundDescription = fundTypeDescription(scheme.fundType);

    if (fundDescription == FundType.Equity.name) {
      return 'Consistence outperformance measured using rolling returns, alpha etc';
    }
    if (fundDescription == FundType.Debt.name) {
      return 'Consistent fund outperformance measured using historical return, YTM etc';
    }
    if (fundDescription == FundType.Hybrid.name) {
      return 'Consistence outperformance measured using rolling returns, alpha, YTM etc';
    }

    return '';
  }

  String _getRiskScoreDescription(SchemeMetaModel scheme) {
    String fundDescription = fundTypeDescription(scheme.fundType);

    if (fundDescription == FundType.Equity.name) {
      return 'Lower risk relative to broader equity market measured using Std Dev, Beta, etc';
    }
    if (fundDescription == FundType.Debt.name) {
      return 'Lower risk during adverse interest rate movement';
    }
    if (fundDescription == FundType.Hybrid.name) {
      return 'Lower risk relative to the benchmark measured using Std Dev, Beta, modified duration etc';
    }

    return '';
  }

  String _getEarningScoreDescription(SchemeMetaModel scheme) {
    String fundDescription = fundTypeDescription(scheme.fundType);

    if (fundDescription == FundType.Equity.name) {
      return 'Valuation and earnings growth of the underlying portfolio measured using PE, PB, ROE';
    }
    if (fundDescription == FundType.Debt.name) {
      return 'Lower default and concentration risk';
    }
    if (fundDescription == FundType.Hybrid.name) {
      return 'Valuation and earnings growth of the underlying portfolio measured using PE, PB, ROE';
    }

    return '';
  }
}
