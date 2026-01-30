import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_return_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_return_chart.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FundReturn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundReturnController>(
      builder: (controller) {
        if (controller.fundReturnResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 400);
        }

        if (controller.fundReturnResponse.state == NetworkState.error) {
          return Center(
            child: RetryWidget(
              'Something went wrong. Please try after sometime',
              onPressed: () {
                controller.getFundReturn();
              },
            ),
          );
        }

        if (controller.fundReturnResponse.state == NetworkState.loaded) {
          if (controller.fundReturnModel == null) {
            return Center(
              child: Text(
                'No Data available',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReturnOverview(context, controller),
              ),
              FundReturnChart(),
            ],
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildReturnOverview(
    BuildContext context,
    FundReturnController controller,
  ) {
    final currentValue = WealthyAmount.currencyFormat(
        controller.fundReturnModel!.currentValue, 0);
    final investedValue = WealthyAmount.currencyFormat(
        controller.fundReturnModel!.investedValue, 0);
    String irr = '-';
    if (controller.fundReturnModel!.xirrPercentage != null) {
      irr =
          '${controller.fundReturnModel!.xirrPercentage?.toStringAsFixed(1)}%';
    }
    String absoluteGain = '-';
    if (controller.fundReturnModel!.absoluteGain != null) {
      absoluteGain = WealthyAmount.currencyFormat(
        controller.fundReturnModel!.absoluteGain,
        0,
      );
      if (controller.fundReturnModel!.absoluteGainPercentage != null) {
        absoluteGain += ' (${WealthyAmount.formatNumber(
          controller.fundReturnModel!.absoluteGainPercentage!
              .toStringAsFixed(1),
        )}%)';
      }
    }

    String fundLaunchDate = controller.fund.launchDate != null
        ? '(${DateFormat('yyyy-MM-dd').format(controller.fund.launchDate!)})'
        : '';

    final data = [
      ['Invested Amount', investedValue],
      ['Current Value', currentValue],
      ['IRR ', irr],
      ['Absolute Gain', absoluteGain]
    ];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            2,
            (col) {
              return Padding(
                padding: EdgeInsets.only(bottom: col == 0 ? 15 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<Widget>.generate(
                    2,
                    (row) {
                      final item = data[2 * col + row];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: CommonUI.buildColumnTextInfo(
                            title: item.first,
                            subtitle: item.last,
                            subtitleMaxLength: 2,
                            gap: 5,
                            titleStyle: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.tertiaryBlack,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            subtitleStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '*Calculations are as on ${DateFormat('dd MMM yyyy').format(controller.fund.navDate!)}',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  fontSize: 10,
                  color: ColorConstants.tertiaryBlack,
                  fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }
}
