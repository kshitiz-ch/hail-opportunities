import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:flutter/material.dart';

class ReturnRatingScreenshot {
  Widget getReturnRatingWidget(
      BuildContext context, FundScoreController controller) {
    return BreakdownHeader(
      title: 'Returns & Rankings',
      subtitle: 'Historical return of the fund and ranking within its category',
      isExpanded: true,
      onToggleExpand: () {
        // Get.find<FundDetailController>()
        //     .updateNavigationSection(FundNavigationTab.ReturnRatings);
      },
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Column(
                children: [
                  _buildCategoryHeader(context, controller),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      // ..._buildAmcLogos(context),
                      // SizedBox(width: 6),
                      _buildNoOfCategoryFunds(context, controller),
                      Spacer(),
                      _buildReturnDropdown(context, controller)
                    ],
                  )
                ],
              ),
            ),
            _buildFundReturn(context, controller),
            _buildCategoryAverageReturn(context, controller),
            _buildRowLabelValue(context,
                label: 'Rank with Category', value: _getCategoryRank(controller)
                // value: '5 out of 10',
                ),
          ],
        ),
      ),
    );
  }

  String _getCategoryRank(FundScoreController controller) {
    if (controller.categoryReturnYearSelected == 1) {
      return '${controller.schemeData?.rankInCategory1Year ?? '-'} of ${controller.schemeData?.rankOutOfInCategory1Year ?? '-'}';
    }

    if (controller.categoryReturnYearSelected == 3) {
      return '${controller.schemeData?.rankInCategory3Year ?? '-'} of ${controller.schemeData?.rankOutOfInCategory3Year ?? '-'}';
    }

    if (controller.categoryReturnYearSelected == 5) {
      return '${controller.schemeData?.rankInCategory5Year ?? '-'} of ${controller.schemeData?.rankOutOfInCategory5Year ?? '-'}';
    }
    return 'NA';
  }

  Widget _buildRowLabelValue(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        border: Border(
          top: BorderSide(
            color: ColorConstants.secondarySeparatorColor,
          ),
        ),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).primaryTextTheme.titleLarge,
          ),
          Text(
            value,
            style: Theme.of(context).primaryTextTheme.titleLarge,
          )
        ],
      ),
    );
  }

  Widget _buildFundReturn(
      BuildContext context, FundScoreController controller) {
    double? schemeReturn;
    switch (controller.categoryReturnYearSelected) {
      case 1:
        schemeReturn = controller.schemeData?.returns?.oneYrRtrns;
        break;
      case 3:
        schemeReturn = controller.schemeData?.returns?.threeYrRtrns;
        break;
      case 5:
        schemeReturn = controller.schemeData?.returns?.fiveYrRtrns;
        break;
    }

    return _buildRowLabelValue(
      context,
      label: 'Fund Returns',
      value: getPercentageText(schemeReturn),
    );
  }

  Widget _buildCategoryAverageReturn(
      BuildContext context, FundScoreController controller) {
    double? categoryAverageReturn;
    switch (controller.categoryReturnYearSelected) {
      case 1:
        categoryAverageReturn = controller.categoryAvgReturns?.oneYrRtrns;
        break;
      case 3:
        categoryAverageReturn = controller.categoryAvgReturns?.threeYrRtrns;
        break;
      case 5:
        categoryAverageReturn = controller.categoryAvgReturns?.fiveYrRtrns;
        break;
    }

    return _buildRowLabelValue(
      context,
      label: 'Category Average',
      value: getPercentageText(categoryAverageReturn),
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
            '${controller.categoryReturnYearSelected} Y Return',
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

  Widget _buildNoOfCategoryFunds(
      BuildContext context, FundScoreController controller) {
    int? noOfFunds;
    if (controller.categoryReturnYearSelected == 1) {
      noOfFunds = controller.schemeData?.rankOutOfInCategory1Year;
    } else if (controller.categoryReturnYearSelected == 3) {
      noOfFunds = controller.schemeData?.rankOutOfInCategory3Year;
    } else if (controller.categoryReturnYearSelected == 5) {
      noOfFunds = controller.schemeData?.rankOutOfInCategory5Year;
    }
    if (noOfFunds.isNullOrZero) {
      return SizedBox();
    }
    return Text(
      '${noOfFunds} Products',
      style: Theme.of(context).primaryTextTheme.titleMedium,
    );
  }

  // List<Widget> _buildAmcLogos(BuildContext context) {
  //   List<Widget> data = <Widget>[];
  //   data.add(
  //     Align(
  //       alignment: Alignment.centerRight,
  //       child: OverflowView.flexible(
  //         spacing: -10,
  //         children: ["Axis", "Kotak", "SBI"]
  //             .map<Widget>(
  //               (fund) =>
  //                   CommonUI.buildRoundedFullAMCLogo(radius: 12, amcName: fund, disableScrollAware: true),
  //             )
  //             .toList(),
  //         builder: (_, remaining) => SizedBox(),
  //       ),
  //     ),
  //   );
  //   return data;
  // }

  Widget _buildCategoryHeader(
      BuildContext context, FundScoreController controller) {
    return Row(
      children: [
        Expanded(
          child: Text(
            controller.schemeData?.category ?? '',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        InkWell(
          onTap: () {
            controller.switchCategorySortOption();
          },
          child: Row(
            children: [
              Text(
                'Annualised Returns',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
        )
      ],
    );
  }
}
