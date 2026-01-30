import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WealthyScore extends StatelessWidget {
  const WealthyScore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
      builder: (controller) {
        return BreakdownHeader(
          isExpanded:
              Get.find<FundDetailController>().activeNavigationSection ==
                  FundNavigationTab.WealthyScore,
          onToggleExpand: () {
            Get.find<FundDetailController>()
                .updateNavigationSection(FundNavigationTab.WealthyScore);
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
                  title: 'Return Score',
                  description:
                      _getReturnScoreDescription(controller.schemeData!),
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
                  title: fundTypeDescription(controller.schemeData?.fundType) ==
                          FundType.Debt.name
                      ? 'Credit Quality Score'
                      : 'Valuation/Earnings Score',
                  description:
                      _getEarningScoreDescription(controller.schemeData!),
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
                                description: controller
                                    .subfieldsDescription[e.keys.first],
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
      },
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
        if (description.isNotNullOrEmpty)
          Tooltip(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 20),
            showDuration: Duration(seconds: 3),
            decoration: BoxDecoration(
                color: ColorConstants.black,
                borderRadius: BorderRadius.circular(6)),
            triggerMode: TooltipTriggerMode.tap,
            textStyle: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
            message: description ?? '',
            child: Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                Icons.info_outline,
                color: ColorConstants.tertiaryBlack,
                size: 16,
              ),
            ),
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

class ScoreExpansionTile extends StatefulWidget {
  const ScoreExpansionTile({
    Key? key,
    required this.title,
    required this.score,
    required this.child,
    required this.description,
    this.forScreenshot = false,
  }) : super(key: key);

  final String title;
  final String description;
  final double? score;
  final Widget child;
  final bool forScreenshot;

  @override
  State<ScoreExpansionTile> createState() => _ScoreExpansionTileState();
}

class _ScoreExpansionTileState extends State<ScoreExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  bool isExpanded = false;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns =
        _controller.drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));

    isExpanded = widget.forScreenshot;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).primaryTextTheme.headlineSmall,
            ),
            if (!widget.forScreenshot)
              Tooltip(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 20),
                showDuration: Duration(seconds: 3),
                decoration: BoxDecoration(
                    color: ColorConstants.black,
                    borderRadius: BorderRadius.circular(6)),
                triggerMode: TooltipTriggerMode.tap,
                textStyle:
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                message: widget.description,
                child: Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.info_outline,
                    color: ColorConstants.tertiaryBlack,
                    size: 16,
                  ),
                ),
              ),
            Spacer(),
            // if (widget.score != null)
            //   Padding(
            //     padding: EdgeInsets.only(right: 30),
            //     child: Text(
            //       '${widget.score.toString()}/5',
            //       style: Theme.of(context).primaryTextTheme.headlineSmall,
            //     ),
            //   ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryAppColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double width = 0;
                    if (widget.score != null) {
                      width = constraints.maxWidth *
                          (((widget.score! / 5) * 100) / 100);
                    }

                    return FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: width,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: LinearGradient(
                            colors: getGraphColors(widget.score),
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
                isExpanded ? _controller.forward() : _controller.reverse();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: ColorConstants.tertiaryBlack,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isExpanded)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: widget.child,
          )
      ],
    );
  }

  List<Color> getGraphColors(score) {
    List<Color> graphColors = [
      hexToColor("#EF6A5B"),
      hexToColor("#FFAA5C"),
      hexToColor("#ECDD5B"),
      hexToColor("#42CA79"),
      hexToColor("#14B195"),
    ];

    if (score <= 1) {
      return [graphColors.first];
    }

    if (score <= 2) {
      return [graphColors.first, graphColors[1]];
    }

    if (score <= 3) {
      return [graphColors.first, graphColors[1], graphColors[2]];
    }

    if (score <= 4) {
      return [
        graphColors.first,
        graphColors[1],
        graphColors[2],
        graphColors[3]
      ];
    }

    return graphColors;
  }
}
