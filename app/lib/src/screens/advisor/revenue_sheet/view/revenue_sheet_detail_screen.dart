import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/revenue_detail_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_detail_listing.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_detail_overview.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_filter_bottomsheet.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/client_revenue_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class RevenueSheetDetailScreen extends StatelessWidget {
  final ClientRevenueModel selectedClientRevenue;
  String? payoutId;
  final DateTime revenueDate;
  EmployeesModel? partnerEmployeeSelected;
  final List<String> agentExternalIdList;

  RevenueSheetDetailScreen({
    Key? key,
    required this.selectedClientRevenue,
    this.payoutId,
    this.partnerEmployeeSelected,
    required this.revenueDate,
    this.agentExternalIdList = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RevenueDetailController>(
      init: RevenueDetailController(
        selectedClientRevenue: selectedClientRevenue,
        payoutId: payoutId,
        revenueDate: revenueDate,
        partnerEmployeeSelected: partnerEmployeeSelected,
        agentExternalIdList: agentExternalIdList,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(titleText: 'Revenue Details'),
          body: SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RevenueDetailOverView(),
                _buildAgentDetails(context, controller),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CommonUI.buildProfileDataSeperator(
                    color: ColorConstants.borderColor,
                    width: double.infinity,
                    height: 1,
                  ),
                ),
                RevenueDetailListing(),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: _buildFilterFAB(context),
        );
      },
    );
  }

  Widget _buildAgentDetails(
      BuildContext context, RevenueDetailController controller) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
          overflow: TextOverflow.ellipsis,
        );

    Widget _buildContactDetails(String value, String imagePath) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            height: 12,
            width: 12,
            color: ColorConstants.black,
          ),
          SizedBox(width: 6),
          Text(
            value,
            style: style,
            maxLines: 2,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20).copyWith(bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Agent Details', style: style),
                SizedBox(height: 8),
                MarqueeWidget(
                  child: Text(
                    controller.selectedClientRevenue.agentDetails?.name ?? '-',
                    style: style?.copyWith(
                        fontSize: 14, color: ColorConstants.black),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContactDetails(
                  controller.selectedClientRevenue.agentDetails?.phoneNumber ??
                      '-',
                  AllImages().mobileIcon,
                ),
                SizedBox(height: 8),
                _buildContactDetails(
                  controller.selectedClientRevenue.agentDetails?.email ?? '-',
                  AllImages().emailOutlinedIcon,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFAB(BuildContext context) {
    return GetBuilder<RevenueDetailController>(
      id: GetxId.filter,
      builder: (detailController) {
        if (!detailController.enableFilterFab) {
          return SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            backgroundColor: ColorConstants.primaryAppColor,
            tooltip: 'Filter',
            onPressed: () {
              MixPanelAnalytics.trackWithAgentId(
                "filter",
                screen: 'revenue_details',
                screenLocation: 'revenue_listing',
              );
              CommonUI.showBottomSheet(
                context,
                isScrollControlled: false,
                child: RevenueFilterBottomSheet(),
              );
            },
            child: const Icon(
              Icons.filter_alt_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
