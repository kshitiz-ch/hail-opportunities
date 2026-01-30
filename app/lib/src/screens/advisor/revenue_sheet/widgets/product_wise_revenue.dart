import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/revenue_sheet_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/donut_chart.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWiseRevenue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RevenueSheetController>(
      id: GetxId.productWiseRevenue,
      builder: (controller) {
        if (controller.productWiseRevenueResponse.state ==
            NetworkState.loading) {
          return SkeltonLoaderCard(
            height: 300,
            margin: EdgeInsets.all(16),
          );
        }

        if (controller.productWiseRevenueResponse.state == NetworkState.error) {
          return SizedBox(
            height: 300,
            child: Center(
              child: RetryWidget(
                controller.productWiseRevenueResponse.message,
                onPressed: () {
                  controller.getProductWiseRevenue();
                },
              ),
            ),
          );
        }
        if (controller.productWiseRevenueResponse.state ==
            NetworkState.loaded) {
          if (controller.productRevenueUIData.sortedProducts.isNotNullOrEmpty) {
            return Container(
              color: ColorConstants.aliceBlueColor,
              padding: EdgeInsets.all(16),
              child: _buildProductRevenueUI(controller, context),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: EmptyScreen(
                message: 'No Data Available',
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildProductRevenueUI(
    RevenueSheetController controller,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(20).copyWith(right: 0),
      child: Column(
        children: [
          DonutChart(
            productWiseRevenue: controller.productRevenueUIData.graphData,
            radius: 82,
          ),
          SizedBox(height: 30),
          DonutChartLabel(
            productWiseRevenue: controller.productRevenueUIData.sortedProducts,
          )
        ],
      ),
    );
  }
}
