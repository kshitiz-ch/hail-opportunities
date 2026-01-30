import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/my_business/business_graph_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_bar_graph.dart';
import 'package:app/src/widgets/misc/common_bar_graph_label.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueGraphView extends StatelessWidget {
  final String tag;

  const RevenueGraphView({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessGraphController>(
      tag: tag,
      builder: (controller) {
        if (controller.revenueGraphResponse.state == NetworkState.loading) {
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
          child: (controller.revenueGraphResponse.state == NetworkState.loaded)
              ? Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Column(
                    children: [
                      _buildTotalAmount(
                        context,
                        controller.totalSumRevenue,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 20,
                        ),
                        child: SizedBox(
                          height: 200,
                          child: CommonBarGraph(
                            showMaxLeftTitle: false,
                            totalBar: controller.revenueGraphData.length,
                            getBarHeight: (index) {
                              return controller.revenueGraphData[index].value;
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
                                  controller.revenueGraphData[index.toInt()]
                                      .date.month,
                                ),
                                enableShortText: true,
                              );
                            },
                            getToolTipText: (index) {
                              return WealthyAmount.currencyFormat(
                                controller
                                    .revenueGraphData[index.toInt()].value,
                                2,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10)
                            .copyWith(bottom: 20),
                        child: CommonBarGraphLabel(
                          barGraphLabels: controller.revenueTypeData.map(
                            (revenueType) {
                              String? labelText;
                              if ((revenueType.productType ?? '')
                                      .toLowerCase() ==
                                  InvestmentProductType.unlistedStock) {
                                labelText = "Pre IPO";
                              } else {
                                labelText =
                                    revenueType.productType?.toUpperCase();
                              }

                              return BarGraphLabel(
                                percentage: revenueType.percentage ?? 0,
                                value: revenueType.revenue ?? 0,
                                labelText: labelText ?? '',
                              );
                            },
                          ).toList(),
                        ),
                      )
                    ],
                  ),
                )
              : RetryWidget(
                  'Failed to load Revenue. Please try again',
                  onPressed: () {
                    controller.getRevenueGraphData();
                  },
                ),
        );
      },
    );
  }

  Widget _buildTotalAmount(BuildContext context, double totalRevenue) {
    return Column(
      children: [
        Text(
          'Total Revenue',
          style: Theme.of(context)
              .primaryTextTheme
              .bodySmall!
              .copyWith(fontSize: 14, color: ColorConstants.tertiaryBlack),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          WealthyAmount.currencyFormat(totalRevenue, 1),
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w600, fontSize: 18),
        )
      ],
    );
  }
}
