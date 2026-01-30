import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/mutual_funds/models/stock_holding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TopHoldings extends StatelessWidget {
  const TopHoldings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
        id: 'stock-holding',
        initState: (_) {
          FundScoreController controller = Get.find<FundScoreController>();
          if (controller.fetchStockHoldingState != NetworkState.loaded) {
            controller.getStockHolding();
          }
        },
        builder: (controller) {
          return BreakdownHeader(
            isExpanded:
                Get.find<FundDetailController>().activeNavigationSection ==
                    FundNavigationTab.TopHoldings,
            onToggleExpand: () {
              Get.find<FundDetailController>()
                  .updateNavigationSection(FundNavigationTab.TopHoldings);
            },
            title: 'Top Holdings',
            subtitle: 'List of underlying securities ranked as per allocation',
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: (controller.fetchStockHoldingState ==
                          NetworkState.loading &&
                      !controller.isPaginating)
                  ? Container(
                      height: 20,
                      width: 20,
                      margin: EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : controller.fetchStockHoldingState == NetworkState.error
                      ? RetryWidget(
                          'Failed to load details. Please try again',
                          onPressed: controller.getStockHolding,
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Text(
                                    'Holding Details',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                            color:
                                                ColorConstants.tertiaryBlack),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Percentage',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                            color:
                                                ColorConstants.tertiaryBlack),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            if (controller.stockHoldings.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'No Stocks Found',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall,
                                ),
                              )
                            else
                              Column(
                                children: [
                                  ListView.separated(
                                    itemCount: controller.stockHoldings.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        color: ColorConstants
                                            .secondarySeparatorColor,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return _buildHoldingTile(
                                        context,
                                        controller.stockHoldings[index],
                                      );
                                    },
                                  ),
                                  if (controller.isPaginating)
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 20),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  else if (controller
                                      .isStockHoldingCountRemaining)
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 20),
                                      child: ClickableText(
                                        text: 'More',
                                        onClick:
                                            controller.paginateStockHolding,
                                      ),
                                    )
                                ],
                              )
                          ],
                        ),
            ),
          );
        });
  }

  Widget _buildHoldingTile(
      BuildContext context, StockHoldingModel stockHolding) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.lightGrey),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              height: 12 * 2,
              width: 12 * 2,
              padding: EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: stockHolding.holdingTradingSymbol.isNotNullOrEmpty
                    ? SvgPicture.network(
                        getStockLogo(stockHolding.holdingTradingSymbol),
                        placeholderBuilder: (context) {
                          return _buildStockPlaceholderLogo(
                              context, stockHolding);
                        },
                        fit: BoxFit.contain,
                      )
                    : _buildStockPlaceholderLogo(context, stockHolding),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stockHolding.holdingName ?? '-',
                  maxLines: 3,
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
                SizedBox(height: 6),
                Text(
                  stockHolding.sectorName ?? '-',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            stockHolding.holdingPercentage != null
                ? '${stockHolding.holdingPercentage!.toStringAsFixed(2)} %'
                : 'NA',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStockPlaceholderLogo(
      BuildContext context, StockHoldingModel stockHolding) {
    String name = '';
    if (stockHolding.holdingTradingSymbol.isNotNullOrEmpty) {
      name = stockHolding.holdingTradingSymbol!;
    } else {
      name = stockHolding.holdingName ?? '-';
    }
    return CircleAvatar(
      radius: 12,
      backgroundColor: ColorConstants.lightGrey,
      child: Center(
        child: Text(
          name[0],
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.primaryAppColor,
              ),
        ),
      ),
    );
  }
}
