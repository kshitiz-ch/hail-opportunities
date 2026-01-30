import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';

class HoldingAnalysisScreenshot {
  Widget getHoldingAnalysisWidget(
    BuildContext context,
    FundScoreController controller,
  ) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {},
      title: 'Holding Analysis',
      subtitle:
          'Analyisis of underlying securities with respect to asset class, sectors, marketcap, credit rating etc.',
      expandByDefault: true,
      child: _buildHoldingAnalysis(context, controller),
    );
  }

  Widget _buildEquityDebtBreakup(
    BuildContext context,
    FundScoreController controller,
  ) {
    List<Color> graphColors = [
      hexToColor("#02CEC9"),
      hexToColor("#9CDCFF"),
      hexToColor("#FF82D5")
    ];

    return _buildBreakdownContainer(
      context,
      "Asset Allocation",
      children: [
        if (controller.fetchFundBreakupState == NetworkState.loading)
          Center(
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (controller.fetchFundBreakupState == NetworkState.error)
          RetryWidget(
            'Failed to load. Please try again',
            // onPressed: controller.getSchemeFundBreakup,
          )
        else
          ..._buildBreakupList(
            context,
            controller.fundBreakup,
            graphColors,
          )
      ],
    );
  }

  List<Widget> _buildBreakupList(
      BuildContext context, List<List> breakups, List<Color> graphColors) {
    if (breakups.isEmpty) {
      return [
        Center(
          child: Text(
            'No Data Found',
            style: Theme.of(context).primaryTextTheme.headlineSmall,
          ),
        )
      ];
    }
    return breakups.mapIndexed<Widget>(
      (List e, index) {
        Color color = graphColors[index % graphColors.length];
        return _buildBarGraphTile(
          context,
          e.first,
          e.length > 1 ? e[1] : 0,
          color,
        );
      },
    ).toList();
  }

  Widget _buildBarGraphTile(
      BuildContext context, String title, double value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
              Text(
                '${value.toStringAsFixed(2)} %',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              )
            ],
          ),
          SizedBox(height: 5),
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
                      double width = constraints.maxWidth * (value / 100);

                      return FittedBox(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: width,
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBreakdownContainer(BuildContext context, String title,
      {required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 20),
          ...children
        ],
      ),
    );
  }

  Widget _buildMarketCapBreakup(
      BuildContext context, FundScoreController controller) {
    List<Color> graphColors = [
      hexToColor("#02CEC9"),
      hexToColor("#9CDCFF"),
      hexToColor("#FF82D5"),
      hexToColor("#FFBE82"),
    ];

    return _buildBreakdownContainer(
      context,
      'Market Cap Weightage',
      children: [
        if (controller.fetchCategoryBreakupState == NetworkState.loading)
          Center(
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (controller.fetchCategoryBreakupState == NetworkState.error)
          RetryWidget(
            'Failed to load. Please try again',
            onPressed: controller.getSchemeCategoryBreakup,
          )
        else
          ..._buildBreakupList(
            context,
            controller.categoryBreakup,
            graphColors,
          )
      ],
    );
  }

  Widget _buildCreditRateBreakup(
      BuildContext context, FundScoreController controller) {
    List<Color> graphColors = [
      hexToColor("#02CEC9"),
      hexToColor("#9CDCFF"),
      hexToColor("#FF82D5"),
      hexToColor("#FFBE82"),
    ];

    return _buildBreakdownContainer(
      context,
      'Credit Rating Breakup',
      children: [
        if (controller.fetchCreditRatingBreakupState == NetworkState.loading)
          Center(
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (controller.fetchCreditRatingBreakupState == NetworkState.error)
          RetryWidget(
            'Failed to load. Please try again',
            onPressed: controller.getCreditRatingBreakup,
          )
        else
          ..._buildBreakupList(
            context,
            controller.creditRatingBreakup,
            graphColors,
          )
      ],
    );
  }

  Widget _buildSectorAllocation(
      BuildContext context, FundScoreController controller) {
    List<Color> graphColors = [
      hexToColor("#02CEC9"),
      hexToColor("#9CDCFF"),
      hexToColor("#FF82D5"),
      hexToColor("#FFBE82"),
      hexToColor("#6B5DE7"),
      hexToColor("#A9E29B"),
      hexToColor("#FFACA1"),
      hexToColor("#B4A7FF"),
      hexToColor("#C9C1FA"),
      hexToColor("#9AAAC3"),
      hexToColor("#C3D7C9"),
      hexToColor("#E39BA3"),
      hexToColor("#E6C050"),
      hexToColor("#DDFF8F"),
      hexToColor("#DD94FF"),
      hexToColor("#DDC3B7"),
    ];

    return _buildBreakdownContainer(
      context,
      'Sector Allocation',
      children: [
        if (controller.fetchSectorBreakupState == NetworkState.loading)
          Center(
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (controller.fetchSectorBreakupState == NetworkState.error)
          RetryWidget(
            'Failed to load. Please try again',
            onPressed: controller.getSchemeSectorBreakup,
          )
        else
          Column(
            children: [
              ..._buildBreakupList(
                context,
                controller.sectorBreakup,
                graphColors,
              ),
            ],
          )
      ],
    );
  }

  Widget _buildHoldingAnalysis(
      BuildContext context, FundScoreController controller) {
    String fundDescription =
        fundTypeDescription(controller.schemeData?.fundType);
    if (fundDescription == FundType.Equity.name) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEquityDebtBreakup(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          ),
          _buildMarketCapBreakup(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          ),
          _buildSectorAllocation(context, controller),
        ],
      );
    }

    if (fundDescription == FundType.Hybrid.name) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEquityDebtBreakup(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          ),
          _buildMarketCapBreakup(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          ),
          _buildCreditRateBreakup(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          ),
          _buildSectorAllocation(context, controller),
        ],
      );
    }

    if (fundDescription == FundType.Debt.name) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectorAllocation(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          ),
          _buildCreditRateBreakup(context, controller),
          Divider(
            color: ColorConstants.secondarySeparatorColor,
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEquityDebtBreakup(context, controller),
      ],
    );
  }
}
