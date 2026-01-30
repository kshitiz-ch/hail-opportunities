import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/my_business/business_graph_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_bar_graph.dart';
import 'package:app/src/widgets/misc/common_bar_graph_label.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/partner_metric_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';

class AumGraphView extends StatelessWidget {
  final String tag;

  final navBarList = [
    MarketType.All,
    MarketType.Equity,
    MarketType.Debt,
    MarketType.Alternative,
    MarketType.Commodity
  ];

  AumGraphView({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessGraphController>(
      tag: tag,
      builder: (controller) {
        if (controller.partnerAumApiResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(
            height: 200,
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          );
        }

        return Container(
          // margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: (controller.partnerAumApiResponse.state == NetworkState.loaded)
              ? Column(
                  children: [
                    Container(
                      height: 30,
                      // margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListView(
                        padding: EdgeInsets.only(left: 20),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...navBarList.map(
                            (MarketType type) {
                              return _buildMarketTypeTabs(
                                context,
                                controller,
                                isSelected:
                                    controller.marketTypeSelected == type,
                                marketType: type,
                              );
                            },
                          ).toList()
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTotalAmount(
                      context,
                      controller,
                    ),
                    _buildAsOndate(
                      context,
                      controller.currentMonthlyMetric?.date,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20)
                          .copyWith(top: 30, bottom: 15),
                      child: _buildAumBarGraph(controller.aumGraphData),
                    ),
                    _buildAumBarGraphLabel(controller.currentMonthlyMetric),
                  ],
                )
              : RetryWidget(
                  'Failed to load Aum. Please try again',
                  onPressed: () {
                    controller.getPartnerAumOverview();
                  },
                ),
        );
      },
    );
  }

  Widget _buildTotalAmount(
    BuildContext context,
    BusinessGraphController controller,
  ) {
    double? totalAum =
        controller.currentMonthlyMetric?.metricDataByType[MetricType.TotalAum];
    double? totalInvestedAmount = controller
        .currentMonthlyMetric?.metricDataByType[MetricType.TotalInvestedAmount];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              'Total AUM',
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodySmall!
                  .copyWith(fontSize: 14, color: ColorConstants.tertiaryBlack),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              totalAum != null
                  ? WealthyAmount.currencyFormat(totalAum, 1)
                  : 'N/A',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 18),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          width: 1,
          color: ColorConstants.tertiaryAppColor,
        ),
        Column(
          children: [
            Text(
              'Total Invested',
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodySmall!
                  .copyWith(fontSize: 14, color: ColorConstants.tertiaryBlack),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              totalInvestedAmount != null
                  ? WealthyAmount.currencyFormat(totalInvestedAmount, 0)
                  : 'N/A',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 18),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildAumBarGraph(List<BusinessGraphModel> aumGraphData) {
    return SizedBox(
      height: 200,
      child: CommonBarGraph(
        showMaxLeftTitle: false,
        totalBar: aumGraphData.length,
        getBarHeight: (index) {
          return aumGraphData[index].value;
        },
        getLeftTitle: (value) {
          return WealthyAmount.currencyFormat(
            value,
            1,
            showSuffix: true,
          );
        },
        getBottomTitle: (index) {
          return getMonthDescription(
            WealthyCast.toInt(
              aumGraphData[index.toInt()].date.month,
            ),
            enableShortText: true,
          );
        },
        getToolTipText: (index) {
          return WealthyAmount.currencyFormat(
            aumGraphData[index.toInt()].value,
            2,
          );
        },
      ),
    );
  }

  Widget _buildAumBarGraphLabel(PartnerMetricModel? currentMonthlyMetric) {
    if (currentMonthlyMetric == null) {
      return SizedBox();
    }
    final totalAum = currentMonthlyMetric.metricDataByType[MetricType.TotalAum];
    List<BarGraphLabel> barGraphLabels = [];
    currentMonthlyMetric.metricDataByType.entries.forEach(
      (entry) {
        final isInvalidLabel = entry.key == MetricType.TotalAum ||
            entry.key == MetricType.TotalInvestedAmount;
        if (!isInvalidLabel) {
          barGraphLabels.add(
            BarGraphLabel(
              labelText: MetricType.PreIpo == entry.key
                  ? 'Pre IPO'
                  : entry.key.name.toUpperCase(),
              percentage:
                  totalAum.isNullOrZero ? 0 : (entry.value / totalAum!) * 100,
              value: entry.value,
            ),
          );
        }
      },
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 20),
      child: CommonBarGraphLabel(barGraphLabels: barGraphLabels),
    );
  }

  Widget _buildMarketTypeTabs(
    BuildContext context,
    BusinessGraphController controller, {
    bool isSelected = false,
    MarketType marketType = MarketType.All,
  }) {
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          "aum_summary_${marketType.name}",
          properties: {
            "screen_location": "business_summary",
            "screen": isPageAtTopStack(context, MyBusinessRoute.name)
                ? "My Business"
                : "Home",
          },
        );
        controller.setMarketTypeSelected(marketType);
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.primaryAppColor.withOpacity(0.05)
              : ColorConstants.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
              color: isSelected
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.borderColor),
        ),
        child: Text(
          marketType.name,
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w500,
              height: 1,
              color: isSelected
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.tertiaryBlack),
        ),
      ),
    );
  }

  Widget _buildAsOndate(BuildContext context, DateTime? date) {
    String? dateAsOnFormatted;
    if (date != null) {
      dateAsOnFormatted = DateFormat('dd-MMM-yyyy').format(date);
    }

    if (dateAsOnFormatted != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          '**Data as on $dateAsOnFormatted',
          textAlign: TextAlign.right,
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
              ),
        ),
      );
    }

    return SizedBox();
  }
}
