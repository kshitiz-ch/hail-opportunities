import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/advisor/revenue_detail_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_filter_options.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_filters.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueFilterBottomSheet extends StatelessWidget {
  RevenueFilterBottomSheet() {
    final controller = Get.find<RevenueDetailController>();
    // reset the filter type
    controller.currentSelectedFilterType = 'Product Type';
    controller.selectedRevenueFilter = Map.from(controller.savedRevenueFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Revenue By',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              CommonUI.bottomsheetCloseIcon(context)
            ],
          ),
        ),
        Expanded(
          child: GetBuilder<RevenueDetailController>(
            builder: (controller) {
              if (controller.productTypeResponse.state ==
                  NetworkState.loading) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.productTypeResponse.state == NetworkState.error) {
                return Center(
                  child: RetryWidget(
                    'Something went wrong.\n Please try again',
                    onPressed: () {
                      controller.updateRevenueFilter();
                    },
                  ),
                );
              }

              return Row(
                children: [
                  RevenueFilters(),
                  RevenueFilterOptions(),
                ],
              );
            },
          ),
        ),
        _buildFilterCTA(context),
      ],
    );
  }

  Widget _buildFilterCTA(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: ColorConstants.primaryAppColor,
        );
    return GetBuilder<RevenueDetailController>(
      builder: (controller) {
        if (controller.productTypeResponse.state != NetworkState.loaded) {
          return SizedBox();
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          child: Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: 'Clear All',
                  margin: EdgeInsets.zero,
                  bgColor: ColorConstants.secondaryButtonColor,
                  textStyle: style,
                  onPressed: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "clear_all",
                      screen: 'revenue_details',
                      screenLocation: 'revenue_listing',
                    );
                    controller.clearFilter();
                    controller.getClientRevenueDetail();
                    AutoRouter.of(context).popForced();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  margin: EdgeInsets.zero,
                  text: 'Apply',
                  textStyle: style?.copyWith(color: ColorConstants.white),
                  onPressed: () {
                    MixPanelAnalytics.trackWithAgentId(
                      "apply",
                      screen: 'revenue_details',
                      screenLocation: 'revenue_listing',
                    );
                    controller.savedRevenueFilter =
                        Map.from(controller.selectedRevenueFilter);
                    controller.getClientRevenueDetail();
                    AutoRouter.of(context).popForced();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
