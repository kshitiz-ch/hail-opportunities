import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/portfolio_return_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class PortfolioReturnCard extends StatelessWidget {
  const PortfolioReturnCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioReturnController>(
      builder: (controller) {
        if (controller.portfolioReturnResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 400);
        }

        if (controller.portfolioReturnResponse.state == NetworkState.error) {
          return Center(
            child: RetryWidget(
              'Something went wrong. Please try after sometime',
              onPressed: () {
                controller.getPortfolioReturn();
              },
            ),
          );
        }

        if (controller.portfolioReturnResponse.state == NetworkState.loaded) {
          if (controller.portfolioReturn == null) {
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
            ],
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildReturnOverview(
    BuildContext context,
    PortfolioReturnController controller,
  ) {
    final currentValue = WealthyAmount.currencyFormat(
        controller.portfolioReturn?.currentValue, 0);
    final investedValue = WealthyAmount.currencyFormat(
        controller.portfolioReturn?.investedValue, 0);
    String irr = '-';
    if (controller.portfolioReturn!.xirrPercentage != null) {
      irr =
          '${controller.portfolioReturn!.xirrPercentage?.toStringAsFixed(1)}%';
    }
    String absoluteGain = '-';
    if (controller.portfolioReturn!.absoluteGain != null) {
      absoluteGain = WealthyAmount.currencyFormat(
        controller.portfolioReturn!.absoluteGain,
        0,
      );
      if (controller.portfolioReturn!.absoluteGainPercentage != null) {
        absoluteGain += ' (${WealthyAmount.formatNumber(
          controller.portfolioReturn!.absoluteGainPercentage!
              .toStringAsFixed(1),
        )}%)';
      }
    }

    // String fundLaunchDate = controller.fund.launchDate != null
    //     ? '(${DateFormat('yyyy-MM-dd').format(controller.fund.launchDate!)})'
    //     : '';

    final data = [
      ['Invested Amount', investedValue],
      ['Calculated Value', currentValue],
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
        ],
      ),
    );
  }
}
