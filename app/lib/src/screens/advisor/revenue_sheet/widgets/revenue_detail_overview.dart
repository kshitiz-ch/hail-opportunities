import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/advisor/revenue_detail_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/donut_chart.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueDetailOverView extends StatelessWidget {
  final controller = Get.find<RevenueDetailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildClientInfo(context),
          ),
          _buildRevenueGraph(),
          _buildRevenueDetail(context)
        ],
      ),
    );
  }

  Widget _buildClientInfo(BuildContext context) {
    return Row(
      children: [
        _buildClientLogo(
          context,
          controller.selectedClientRevenue.clientDetails?.name ?? '',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildClientDetails(
              context,
              controller.selectedClientRevenue.clientDetails?.name ?? '',
              controller.selectedClientRevenue.clientDetails?.crn ?? '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientDetails(BuildContext context, String? name, String? crn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name?.toTitleCase() ?? notAvailableText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          'CRN: ${crn ?? 'N/A'}',
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.tertiaryBlack,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  Widget _buildClientLogo(BuildContext context, String? name) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: getRandomBgColor(0),
      child: Center(
        child: Text(
          name!.initials,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: getRandomTextColor(0),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
        ),
      ),
    );
  }

  Widget _buildRevenueGraph() {
    final productList =
        controller.selectedClientRevenue.productRevenueUIData?.graphData ?? [];
    return Column(
      children: [
        CommonUI.buildProfileDataSeperator(
          color: ColorConstants.borderColor,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: DonutChart(
            productWiseRevenue: productList,
            radius: 62,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 10),
          child: DonutChartLabel(productWiseRevenue: productList),
        )
      ],
    );
  }

  Widget _buildRevenueDetail(BuildContext context) {
    // TODO: update when locked/unlocked detail coming from api
    // final isLocked = false;
    // final color = isLocked
    //     ? ColorConstants.redAccentColor
    //     : ColorConstants.greenAccentColor;
    final textStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.tertiaryBlack,
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: ColorConstants.greenAccentColor.withOpacity(0.15),
      child: Row(
        children: [
          Text('Total Revenue', style: textStyle),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 4),
          //   child: Text(
          //     isLocked ? 'Locked' : 'Unlocked',
          //     style: textStyle?.copyWith(color: color),
          //   ),
          // ),
          Expanded(
            child: Text(
              WealthyAmount.currencyFormat(
                controller.selectedClientRevenue.totalRevenue,
                2,
              ),
              textAlign: TextAlign.right,
              style: textStyle?.copyWith(
                fontSize: 14,
                color: ColorConstants.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
