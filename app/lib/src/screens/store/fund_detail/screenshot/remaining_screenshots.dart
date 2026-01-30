import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/mutual_funds/models/returns_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PeerComparisonScreenshot {
  Widget getPeerComparisonScreenshotWidget(
    BuildContext context,
    FundScoreController controller,
  ) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {
        // Get.find<FundDetailController>()
        //     .updateNavigationSection(FundNavigationTab.Benchmark);
      },
      title: 'Benchmark Comparison',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            if (controller.fetchBenchmarkReturnState == NetworkState.loading)
              Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (controller.fetchBenchmarkReturnState == NetworkState.error)
              RetryWidget(
                'Failed to load details',
                onPressed: controller.getBenchmarkReturn,
              )
            else
              Column(
                children: [
                  _buildFundReturn(context, controller.schemeData!),
                  _buildDivider(context),
                  _buildBenchmarkReturn(
                    context,
                    controller.schemeData?.benchmark,
                    controller.benchmarkReturn,
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildFundReturn(BuildContext context, SchemeMetaModel scheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 30, right: 30),
      child: Column(
        children: [
          Row(
            children: [
              // CommonUI.buildRoundedFullAMCLogo(
              //   radius: 16,
              //   amcName: scheme.displayName,
              //   disableScrollAware: true,
              // ),
              // SizedBox(width: 5),
              Expanded(
                child: Text(
                  scheme.displayName ?? '-',
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonUI.buildColumnText(
                context,
                label: '1 Y Return',
                value: getReturnPercentageText(scheme.returns?.oneYrRtrns),
              ),
              CommonUI.buildColumnText(
                context,
                label: '3 Y Return',
                value: getReturnPercentageText(scheme.returns?.threeYrRtrns),
              ),
              CommonUI.buildColumnText(
                context,
                label: '5 Y Return',
                value: getReturnPercentageText(scheme.returns?.fiveYrRtrns),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBenchmarkReturn(
      BuildContext context, String? benchmark, ReturnsModel? benchmarkReturn) {
    return Padding(
      padding: EdgeInsets.only(top: 15, left: 30, right: 30),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: ColorConstants.tertiaryWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(AllImages().storePreIpoIcon),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  benchmark ?? '-',
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonUI.buildColumnText(
                context,
                label: '1 Y Return',
                value: getReturnPercentageText(benchmarkReturn?.oneYrRtrns),
              ),
              CommonUI.buildColumnText(
                context,
                label: '3 Y Return',
                value: getReturnPercentageText(benchmarkReturn?.threeYrRtrns),
              ),
              CommonUI.buildColumnText(
                context,
                label: '5 Y Return',
                value: getReturnPercentageText(benchmarkReturn?.fiveYrRtrns),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: ColorConstants.borderColor,
          ),
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstants.primaryAppv3Color,
          ),
          child: Text(
            'vs',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.primaryAppColor),
          ),
        ),
        Expanded(
          child: Divider(
            color: ColorConstants.borderColor,
          ),
        ),
      ],
    );
  }
}

class InvestmentObjectiveScreenshot {
  Widget getInvestmentObjectiveScreenshotWidget(
    BuildContext context,
    FundScoreController controller,
  ) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {},
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
                  .copyWith(color: ColorConstants.tertiaryBlack, height: 1.5),
            ),
            SizedBox(height: 14),
            _buildFundBenchMarkDetails(context, controller)
          ],
        ),
      ),
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
            (controller.schemeData!.aum.isNotNullOrZero ?? false)
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

class FundManagerDetailsScreenshot {
  Widget getFundManagerDetailsScreenshotWidget(
    BuildContext context,
    FundScoreController controller,
  ) {
    return BreakdownHeader(
      title: 'Fund Management',
      isExpanded: true,
      onToggleExpand: () {},
      // onToggleExpand: ,
      // subtitle: '',
      child: Container(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AllImages().clientProfile,
                  width: 24,
                ),
                SizedBox(width: 10),
                Text(
                  controller.schemeData?.fundManager ?? '-',
                  style: Theme.of(context).primaryTextTheme.headlineSmall,
                ),
              ],
            ),
            SizedBox(height: 10),
            if (controller.schemeData?.fundManagerProfile != null)
              Padding(
                padding: EdgeInsets.only(left: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).primaryTextTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      controller.schemeData!.fundManagerProfile!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleMedium!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack, height: 1.5),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class TaxImplicationScreenshot {
  Widget getTaxImplicationScreenshotWidget(
    BuildContext context,
    FundScoreController controller,
  ) {
    return BreakdownHeader(
      isExpanded: true,
      onToggleExpand: () {},
      title: 'Tax Implications',
      // subtitle: '',
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              controller.schemeData?.taxationTypeRemarks ?? 'NA',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleLarge!
                  .copyWith(color: ColorConstants.tertiaryBlack),
            ),
            SizedBox(height: 15),
            Text(
                '* Investors are advised to consult their Legal / Tax advisors in regard to tax/legal implications relating to their investments in the scheme',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleMedium!
                    .copyWith(color: ColorConstants.tertiaryBlack))
          ],
        ),
      ),
    );
  }
}
