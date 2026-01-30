import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/pms/pms_product_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/screens/store/pms_product/allocation_card.dart';
import 'package:app/src/screens/store/pms_product/risk_valuation_metrics.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class PmsPortfolioSection extends StatelessWidget {
  final PMSVariantModel product;
  const PmsPortfolioSection({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PMSProductController>(
      id: 'navigation',
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BreakdownHeader(
                key: controller.navigationKeys[PMSNavigationTab.Holdings.name],
                isExpanded: controller.activeNavigationSection ==
                    PMSNavigationTab.Holdings,
                onToggleExpand: () {
                  controller.updateNavigationSection(PMSNavigationTab.Holdings);
                },
                title: 'Holding Analysis',
                subtitle: 'Sector allocation and Equity/Cash/Debt Split',
                borderColor: ColorConstants.secondarySeparatorColor,
                borderWidth: 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AllocationCard(
                      title: 'Holdings',
                      items: product.holdingsPie ?? [],
                    ),
                    CommonUI.buildProfileDataSeperator(
                        color: ColorConstants.secondarySeparatorColor),
                    AllocationCard(
                      title: 'Market Cap Weightage',
                      items: product.marketCapPie ?? [],
                    ),
                    CommonUI.buildProfileDataSeperator(
                        color: ColorConstants.secondarySeparatorColor),
                    AllocationCard(
                      title: 'Sector Allocation',
                      items: product.sectorAllocationPie ?? [],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              BreakdownHeader(
                key: controller.navigationKeys[PMSNavigationTab.Risk.name],
                isExpanded:
                    controller.activeNavigationSection == PMSNavigationTab.Risk,
                onToggleExpand: () {
                  controller.updateNavigationSection(PMSNavigationTab.Risk);
                },
                title: 'Risk & Valuation Metrics',
                borderColor: ColorConstants.secondarySeparatorColor,
                borderWidth: 0.5,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: RiskValuationMetrics(product: product),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
