import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvestmentObjective extends StatelessWidget {
  const InvestmentObjective({Key? key, this.expandByDefault = false})
      : super(key: key);

  final bool expandByDefault;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
      builder: (controller) {
        return BreakdownHeader(
          isExpanded:
              Get.find<FundDetailController>().activeNavigationSection ==
                  FundNavigationTab.Scheme_Details,
          onToggleExpand: () {
            Get.find<FundDetailController>()
                .updateNavigationSection(FundNavigationTab.Scheme_Details);
          },
          title: "Investment objective and AUM",
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Text(
                  controller.schemeData?.objective ?? 'NA',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                          color: ColorConstants.tertiaryBlack, height: 1.5),
                ),
                SizedBox(height: 14),
                _buildFundBenchMarkDetails(context, controller)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFundBenchMarkDetails(
      BuildContext context, FundScoreController controller) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Benchmark',
            style: Theme.of(context)
                .primaryTextTheme
                .titleMedium!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 10),
          Text(
            controller.schemeData?.benchmark ?? 'NA',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              color: ColorConstants.borderColor,
            ),
          ),
          Text(
            'AUM',
            style: Theme.of(context)
                .primaryTextTheme
                .titleMedium!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(height: 10),
          Text(
            (controller.schemeData?.aum.isNotNullOrZero ?? false)
                ? '${WealthyAmount.currencyFormat(controller.schemeData?.aum, 2)} Cr'
                : '-',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
