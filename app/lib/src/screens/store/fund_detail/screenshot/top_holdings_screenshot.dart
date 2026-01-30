import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/stock_holding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TopHoldingsScreenshot {
  Widget getTopHoldingScreenshotWidget(
      BuildContext context, FundScoreController controller) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {},
      title: 'Top Holdings',
      subtitle: 'List of underlying securities ranked as per allocation',
      child: Container(
        padding: EdgeInsets.only(top: 20),
        child: (controller.fetchStockHoldingState == NetworkState.loading &&
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
                                      color: ColorConstants.tertiaryBlack),
                            ),
                            Spacer(),
                            Text(
                              'Percentage',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                      color: ColorConstants.tertiaryBlack),
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
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: ColorConstants.secondarySeparatorColor,
                                );
                              },
                              itemBuilder: (context, index) {
                                return _buildHoldingTile(
                                  context,
                                  controller.stockHoldings[index],
                                );
                              },
                            ),
                          ],
                        )
                    ],
                  ),
      ),
    );
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

class TopCategoryFundsScreenshot {
  Widget getTopCategoryFundsWidget(
      BuildContext context, FundScoreController controller) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {},
      title: 'Peer Comparison',
      subtitle: 'Comparison with other top funds in the same category',
      expandByDefault: true,
      child: Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    'Fund Details',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                  Spacer(),
                  _buildReturnDropdown(context, controller)
                ],
              ),
            ),
            SizedBox(height: 10),
            if (controller.fetchTopCategoryFundState == NetworkState.loading)
              ListView.separated(
                padding: EdgeInsets.only(bottom: 20),
                itemCount: 6,
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
                itemBuilder: (context, index) {
                  return SkeltonLoaderCard(
                    height: 60,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    radius: 5,
                  );
                },
              )
            else if (controller.fetchTopCategoryFundState == NetworkState.error)
              RetryWidget(
                'Failed to load Funds. Please try again',
                onPressed: controller.getTopCategoryFunds,
              )
            else if (controller.topCategoryFunds.isEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'No Funds Found',
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
              )
            else
              ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: controller.topCategoryFunds.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return Divider(
                    color: ColorConstants.secondarySeparatorColor,
                  );
                },
                itemBuilder: (context, index) {
                  SchemeMetaModel scheme = controller.topCategoryFunds[index];
                  return _buildFundTile(context, scheme, controller);
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildReturnDropdown(
      BuildContext context, FundScoreController controller) {
    return Container(
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConstants.primaryAppColor,
            size: 12,
          ),
          Text(
            '${controller.topCategoryFundReturnYearSelected} Y Return',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.primaryAppColor),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: ColorConstants.primaryAppColor,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildFundTile(BuildContext context, SchemeMetaModel scheme,
      FundScoreController controller) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Container(
            //   margin: EdgeInsets.only(right: 12),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: ColorConstants.lightGrey),
            //     borderRadius: BorderRadius.circular(50),
            //   ),
            //   child: CommonUI.buildRoundedFullAMCLogo(
            //     radius: 16,
            //     amcName: scheme.displayName,
            //     disableScrollAware: true,
            //   ),
            // ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.displayName ?? '-',
                    maxLines: 3,
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                  SizedBox(height: 6),
                  CommonMfUI.buildMfRating(
                    context,
                    scheme,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              getPercentageText(
                getSchemeReturnByYear(
                  scheme,
                  controller.topCategoryFundReturnYearSelected,
                ),
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  double? getSchemeReturnByYear(
      SchemeMetaModel scheme, int returnYearSelected) {
    switch (returnYearSelected) {
      case 1:
        return scheme.returns?.oneYrRtrns;
      case 3:
        return scheme.returns?.threeYrRtrns;
      case 5:
        return scheme.returns?.fiveYrRtrns;
      default:
        return null;
    }
  }
}
