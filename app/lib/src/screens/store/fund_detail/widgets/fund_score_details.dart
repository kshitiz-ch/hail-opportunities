import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'fund_breakdown/fund_manager_details.dart';
import 'fund_breakdown/holding_analysis.dart';
import 'fund_breakdown/investment_objective.dart';
import 'fund_breakdown/peer_comparison.dart';
import 'fund_breakdown/return_and_ratings.dart';
import 'fund_breakdown/risk_meter.dart';
import 'fund_breakdown/tax_implication.dart';
import 'fund_breakdown/top_category_funds.dart';
import 'fund_breakdown/top_holdings.dart';
import 'fund_breakdown/wealthy_score.dart';

class FundScoreDetails extends StatelessWidget {
  const FundScoreDetails({
    Key? key,
    required this.scheme,
    required this.navigationKeys,
    required this.fundDetailController,
  }) : super(key: key);

  final FundDetailController fundDetailController;
  final SchemeMetaModel scheme;
  final Map<String, GlobalKey> navigationKeys;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 30),
      child: GetBuilder<FundDetailController>(
        id: 'navigation',
        builder: (_controller) {
          return GetBuilder<FundScoreController>(
            init: FundScoreController(
              scheme: scheme,
            ),
            builder: (controller) {
              if (controller.fetchSchemeDataState == NetworkState.loading) {
                return ListView.separated(
                  itemCount: 5,
                  shrinkWrap: true,
                  separatorBuilder: (context, int) {
                    return SizedBox(height: 12);
                  },
                  itemBuilder: (context, int) {
                    return SkeltonLoaderCard(height: 90);
                  },
                );
              }

              if (controller.fetchSchemeDataState == NetworkState.error) {
                return RetryWidget(
                  'Failed to load details. Please try again',
                  onPressed: controller.getSchemeAdditionalData,
                );
              }

              return Column(
                children: [
                  // Return and Ratings
                  ReturnAndRatings(
                    key: fundDetailController
                        .navigationKeys[FundNavigationTab.ReturnRatings.name],
                  ),
                  SizedBox(height: 12),

                  // Wealthy Score
                  WealthyScore(
                    key: fundDetailController
                        .navigationKeys[FundNavigationTab.WealthyScore.name],
                  ),
                  SizedBox(height: 12),

                  // // Holding Analysis
                  _buildHoldingAnalysis(context),
                  SizedBox(height: 12),

                  // // Top Holdings
                  TopHoldings(
                    key: fundDetailController
                        .navigationKeys[FundNavigationTab.TopHoldings.name],
                  ),
                  SizedBox(height: 12),

                  // // Top Category Funds
                  _buildTopCategoryFunds(context),
                  SizedBox(height: 12),

                  // Benchmark Comparison
                  if (controller.schemeData?.benchmarkTpid.isNotNullOrEmpty ??
                      false)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: PeerComparison(
                        key: fundDetailController
                            .navigationKeys[FundNavigationTab.Benchmark.name],
                      ),
                    ),

                  // // // Investment Objective
                  _buildSchemeDetails(context),
                  SizedBox(height: 12),

                  // Fund Manager Details
                  if (controller.schemeData?.fundManager != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: FundManagerDetails(
                        key: fundDetailController.navigationKeys[
                            FundNavigationTab.FundManagement.name],
                      ),
                    ),

                  // RiskMeter
                  RiskMeter(
                    key: fundDetailController
                        .navigationKeys[FundNavigationTab.RiskMeter.name],
                  ),

                  // Tax Implication Details
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: TaxImplication(
                      key: fundDetailController
                          .navigationKeys[FundNavigationTab.Tax.name],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHoldingAnalysis(BuildContext context) {
    return _buildWidgetWithVisibilityDetector(
      FundNavigationTab.Portfolio,
      HoldingAnalysis(
        key: fundDetailController
            .navigationKeys[FundNavigationTab.Portfolio.name],
      ),
      (FundDetailController controller, double percentage) {
        bool isPeersNotExpanded =
            controller.activeNavigationSection != FundNavigationTab.Peers;
        double peersPercentage = controller
                .navigationVisibilityPercentage[FundNavigationTab.Peers.name] ??
            0;
        double schemeDetailsPercentage =
            controller.navigationVisibilityPercentage[
                    FundNavigationTab.Scheme_Details.name] ??
                0;

        if (isPeersNotExpanded &&
            schemeDetailsPercentage < 50 &&
            peersPercentage < 50 &&
            percentage >= 80) {
          return true;
        }
        return false;
      },
    );
  }

  Widget _buildTopCategoryFunds(BuildContext context) {
    return _buildWidgetWithVisibilityDetector(
      FundNavigationTab.Peers,
      TopCategoryFunds(
        key: fundDetailController.navigationKeys[FundNavigationTab.Peers.name],
      ),
      (FundDetailController controller, double percentage) {
        double portfolioPercentage = controller.navigationVisibilityPercentage[
                FundNavigationTab.Portfolio.name] ??
            0;
        double schemeDetailsPercentage =
            controller.navigationVisibilityPercentage[
                    FundNavigationTab.Scheme_Details.name] ??
                0;
        bool isPortfolioNotExpanded =
            controller.activeNavigationSection != FundNavigationTab.Portfolio;

        if (isPortfolioNotExpanded &&
            schemeDetailsPercentage < 90 &&
            percentage >= 80) {
          return true;
        }
        return false;
      },
    );
  }

  Widget _buildSchemeDetails(BuildContext context) {
    return _buildWidgetWithVisibilityDetector(
      FundNavigationTab.Scheme_Details,
      InvestmentObjective(
        key: fundDetailController
            .navigationKeys[FundNavigationTab.Scheme_Details.name],
      ),
      (FundDetailController controller, double percentage) {
        bool isPeersNotExpanded =
            controller.activeNavigationSection != FundNavigationTab.Peers;
        double peersPercentage = controller
                .navigationVisibilityPercentage[FundNavigationTab.Peers.name] ??
            0;
        LogUtil.printLog("scheme details $percentage");
        if (isPeersNotExpanded && peersPercentage < 90 && percentage >= 90) {
          return true;
        }
        return false;
      },
    );
  }

  Widget _buildWidgetWithVisibilityDetector(
    FundNavigationTab tab,
    Widget child,
    bool Function(FundDetailController controller, double percentage)
        isWidgetVisibile,
  ) {
    return GetBuilder<FundDetailController>(
      id: 'navigation-visibility',
      builder: (controller) {
        return VisibilityDetector(
          key: Key(tab.name),
          onVisibilityChanged: (visibilityInfo) {
            // var visiblePercentage = visibilityInfo.visibleFraction * 100;
            // LogUtil.printLog("${tab.name} visiblePercentage ===> $visiblePercentage");
            // controller.updateNavigationVisibility(tab, visiblePercentage);
            // if (isWidgetVisibile(controller, visiblePercentage)) {
            //   fundDetailController.updateNavigationTab(
            //     tab,
            //     disableScrolling: true,
            //   );
            // }
          },
          child: new Container(
            child: child,
          ),
        );
      },
    );
  }
}
