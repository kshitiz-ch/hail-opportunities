import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/mutual_funds/models/returns_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PeerComparison extends StatelessWidget {
  const PeerComparison({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
      id: 'benchmark-return',
      initState: (_) {
        FundScoreController controller = Get.find<FundScoreController>();
        if (controller.fetchBenchmarkReturnState != NetworkState.loaded) {
          controller.getBenchmarkReturn();
        }
      },
      builder: (controller) {
        return BreakdownHeader(
          isExpanded:
              Get.find<FundDetailController>().activeNavigationSection ==
                  FundNavigationTab.Benchmark,
          onToggleExpand: () {
            Get.find<FundDetailController>()
                .updateNavigationSection(FundNavigationTab.Benchmark);
          },
          title: 'Benchmark Comparison',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                if (controller.fetchBenchmarkReturnState ==
                    NetworkState.loading)
                  Container(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (controller.fetchBenchmarkReturnState ==
                    NetworkState.error)
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
      },
    );
  }

  Widget _buildFundReturn(BuildContext context, SchemeMetaModel scheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 30, right: 30),
      child: Column(
        children: [
          Row(
            children: [
              CommonUI.buildRoundedFullAMCLogo(
                radius: 16,
                amcName: scheme.displayName,
                amcCode: scheme.amc,
              ),
              SizedBox(width: 5),
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
