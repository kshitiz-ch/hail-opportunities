import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/broking_summary_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_bar_graph.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/broking/models/broking_detail_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrokingSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingController>(
      id: GetxId.detail,
      builder: (controller) {
        if (controller.brokingDetailResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 250);
        }
        if (controller.brokingDetailResponse.state == NetworkState.error) {
          return SizedBox(
            height: 250,
            child: Center(
              child: RetryWidget(
                controller.brokingDetailResponse.message,
                onPressed: () {
                  controller.getBrokingDetails();
                },
              ),
            ),
          );
        }
        if (controller.brokingDetailResponse.state == NetworkState.loaded) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(context, controller),
              _buildGraphView(controller),
              _buildSummarySection(context, controller),
            ],
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildGraphView(BrokingController controller) {
    List<BrokingMonthlyDataModel> getGraphData() {
      List<BrokingMonthlyDataModel> brokingGraphData = controller
              .brokingDetailModel
              ?.brokingGraphData[controller.selectedGraphDataType] ??
          [];
      if (brokingGraphData.isNullOrEmpty) {
        final lastSixMonthsDate = getLastSixMonthsDate();
        brokingGraphData = List<BrokingMonthlyDataModel>.generate(
          lastSixMonthsDate.length,
          (index) {
            final month = lastSixMonthsDate[index].month;
            return BrokingMonthlyDataModel(data: 0, month: month);
          },
        ).toList();
      }
      return brokingGraphData;
    }

    final graphData = getGraphData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40)
          .copyWith(top: 30, bottom: 24),
      child: SizedBox(
        height: 250,
        child: CommonBarGraph(
          totalBar: graphData.length,
          getLeftTitle: (value) {
            return controller.selectedGraphDataType == BrokingGraphType.trades
                ? WealthyAmount.formatNumber(value.toString())
                : WealthyAmount.currencyFormat(value, 1, showSuffix: true);
          },
          getBottomTitle: (index) {
            return getMonthDescription(
              WealthyCast.toInt(graphData[index.toInt()].month),
              enableShortText: true,
            );
          },
          isDailyGraph: false,
          showMaxLeftTitle: false,
          getBarHeight: (index) {
            return graphData[index].data ?? 0;
          },
          getToolTipText: (index) {
            return controller.selectedGraphDataType == BrokingGraphType.trades
                ? WealthyAmount.formatNumber(graphData[index].data.toString())
                : WealthyAmount.currencyFormat(
                    graphData[index].data.toString(), 1);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    BrokingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            'Broking Summary',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          Spacer(),
          SizedBox(
            width: 100,
            child: SimpleDropdownFormField<BrokingGraphType>(
              alignment: AlignmentDirectional.centerEnd,
              showBorder: false,
              maxWidth: 100,
              maxButtonHeight: 50,
              removePadding: true,
              dropdownTextStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w500,
                      ),
              selectedTextStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                        color: ColorConstants.primaryAppColor,
                        fontWeight: FontWeight.w600,
                      ),
              hintText: '',
              items: isEmployeeLoggedIn()
                  ? [BrokingGraphType.trades]
                  : BrokingGraphType.values,
              customText: (value) {
                return value!.name.toCapitalized();
              },
              value: controller.selectedGraphDataType,
              contentPadding: EdgeInsets.only(bottom: 8),
              borderColor: ColorConstants.lightGrey,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: ColorConstants.primaryAppColor,
                size: 24,
              ),
              onChanged: (val) {
                if (val != null) {
                  MixPanelAnalytics.trackWithAgentId(
                    "metric_selected",
                    screen: 'broking',
                    screenLocation: 'broking_graph',
                    properties: {
                      "metric": controller.selectedGraphDataType.name
                    },
                  );

                  controller.selectedGraphDataType = val;
                  controller.update([GetxId.detail]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    BrokingController controller,
  ) {
    final summaryData = _getBrokingSummaryData(controller);

    if (summaryData.isNullOrEmpty) {
      return EmptyScreen(message: 'Summary section data not available');
    }

    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        color: ColorConstants.primaryCardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        itemCount: summaryData.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return _buildSummaryRow(summaryData, index, context);
        },
        separatorBuilder: (context, index) {
          if (index == 0) {
            return SizedBox(height: 20);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CommonUI.buildProfileDataSeperator(
                  color: ColorConstants.platinumColor,
                  width: double.infinity,
                  height: 1,
                ),
              ),
              if (index == 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(bottom: 16),
                  child: Text(
                    'Clients',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(color: ColorConstants.black),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  List<BrokingSummaryData> _getBrokingSummaryData(
      BrokingController controller) {
    final model = controller.brokingDetailModel?.brokingSummaryModel;
    // if (model == null) {
    //   return [];
    // }
    final summaryData = [
      // headder
      BrokingSummaryData(
        displayName: '',
        monthly: 'This Month',
        yesterday: 'Yesterday',
      ),
      // data
      if (!isEmployeeLoggedIn())
        BrokingSummaryData(
          displayName: 'Pay In',
          monthly: WealthyAmount.currencyFormat(
            model?.monthlyPayin ?? 0,
            1,
          ),
          yesterday: WealthyAmount.currencyFormat(
            model?.yesterdayPayin ?? 0,
            1,
          ),
        ),
      if (!isEmployeeLoggedIn())
        BrokingSummaryData(
          displayName: 'Pay Out',
          monthly: WealthyAmount.currencyFormat(
            model?.monthlyPayout ?? 0,
            1,
          ),
          yesterday: WealthyAmount.currencyFormat(
            model?.yesterdayPayout ?? 0,
            1,
          ),
        ),
      if (!isEmployeeLoggedIn())
        BrokingSummaryData(
          displayName: 'Brokerage',
          monthly: WealthyAmount.currencyFormat(
            model?.monthlyBrokerage ?? 0,
            1,
          ),
          yesterday: WealthyAmount.currencyFormat(
            model?.yesterdayBrokerage ?? 0,
            1,
          ),
        ),
      BrokingSummaryData(
        displayName: 'No. of Trades',
        monthly: (model?.monthlyTrades ?? 0).toStringAsFixed(0),
        yesterday: (model?.yesterdayTrades ?? 0).toStringAsFixed(0),
      ),
      BrokingSummaryData(
        displayName: 'Trading Activated',
        monthly: (model?.monthlyTradingActivated ?? 0).toStringAsFixed(0),
        yesterday: (model?.yesterdayTradingActivated ?? 0).toStringAsFixed(0),
      ),
      BrokingSummaryData(
        displayName: 'F&O Activated',
        monthly: (model?.monthlyFNOActivated ?? 0).toStringAsFixed(0),
        yesterday: (model?.yesterdayFNOActivated ?? 0).toStringAsFixed(0),
      ),
    ];
    return summaryData;
  }

  Widget _buildSummaryRow(
    List<BrokingSummaryData> summaryData,
    int index,
    BuildContext context,
  ) {
    final style1 = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w400,
        );
    final style2 = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w400,
        );
    Widget _buildSummaryData(
      String value,
      TextAlign? textAlign,
      TextStyle? style,
    ) {
      return Expanded(
        child: Text(
          value,
          textAlign: textAlign,
          style: style,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSummaryData(
            summaryData[index].displayName,
            TextAlign.left,
            style1,
          ),
          _buildSummaryData(
            summaryData[index].yesterday,
            TextAlign.center,
            index == 0 ? style1 : style2,
          ),
          _buildSummaryData(
            summaryData[index].monthly,
            TextAlign.right,
            index == 0 ? style1 : style2,
          ),
        ],
      ),
    );
  }
}
