import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_bar_graph.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonthlySipGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SipBookController>(
      id: 'sip-graph',
      builder: (controller) {
        if (controller.sipGraphResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 200, radius: 0);
        }

        if (controller.sipGraphResponse.state == NetworkState.error) {
          return RetryWidget(
            controller.sipMetricResponse.message,
            onPressed: () {
              controller.getSipGraphData();
            },
          );
        }
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorConstants.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabs(controller, context),
              SizedBox(height: 10),
              _buildGraphView(controller),
              Text(
                '**There may be some delay in reflecting real-time changes',
                style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: ColorConstants.tertiaryBlack,
                    ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs(SipBookController controller, BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: ColorConstants.borderColor),
        ),
        child: ButtonBar(
          mainAxisSize: MainAxisSize.min,
          buttonPadding: EdgeInsets.zero,
          alignment: MainAxisAlignment.center,
          children: SipGraphType.values
              .map(
                (tab) => _buildTabButton(
                  context: context,
                  controller: controller,
                  tab: tab,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  InkWell _buildTabButton({
    required BuildContext context,
    required SipBookController controller,
    required SipGraphType tab,
  }) {
    final bool isSelected = controller.sipGraphSelected == tab;
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          tab == SipGraphType.SipBook
              ? 'sip_book_pill'
              : 'successful_sips_pill',
          screen: 'sip_book',
          screenLocation: 'sip_book_graph',
        );
        controller.updateSipGraphType(tab);
      },
      child: AnimatedContainer(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        // margin: const EdgeInsets.only(bottom: 4.0),
        duration: Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.secondaryAppColor
              : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(40) : null,
          border: isSelected
              ? Border.all(
                  width: 1,
                  color: ColorConstants.primaryAppColor,
                )
              : null,
        ),
        child: Center(
          child: Text(
            tab == SipGraphType.SipBook ? 'SIP Book' : 'Successfull SIP(s)',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphView(SipBookController controller) {
    List<MonthSipModel> graphData =
        (controller.sipGraphSelected == SipGraphType.SipBook
                ? controller.activeSipMonthlyData
                : controller.successfulSipMonthlyData)
            .reversed
            .toList();
    if (graphData.isNullOrEmpty) {
      final lastSixMonthsDate = getLastSixMonthsDate();
      graphData = List<MonthSipModel>.generate(
        lastSixMonthsDate.length,
        (index) {
          final month = lastSixMonthsDate[index].month;
          return MonthSipModel(amount: 0, month: month);
        },
      ).toList();
    }
    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: CommonBarGraph(
          totalBar: graphData.length,
          getLeftTitle: (value) {
            return WealthyAmount.currencyFormat(
              value,
              1,
              showSuffix: true,
            );
          },
          getBottomTitle: (index) {
            return getMonthDescription(
              WealthyCast.toInt(graphData[index.toInt()].month),
              enableShortText: true,
            );
          },
          isDailyGraph: false,
          getBarHeight: (index) {
            return graphData[index].amount ?? 0;
          },
          getToolTipText: (index) {
            return WealthyAmount.currencyFormat(graphData[index].amount, 1);
          },
        ),
      ),
    );
  }
}
