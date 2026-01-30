import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/wealth_academy/sales_plan_controller.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/sales_plan_gallery.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/video_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SalesPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put<SalesPlanController>(SalesPlanController());

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Your Sales Guide',
      ),
      body: GetBuilder<SalesPlanController>(
        dispose: (_) => Get.delete<SalesPlanController>(),
        builder: (controller) {
          if (controller.creativesListState == NetworkState.error &&
              !controller.isSalesPlanIdExists) {
            return Center(
              child: Text(
                'No Sales Guide found',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VideoSection(),
              Expanded(child: SalesPlanGallery()),
            ],
          );
        },
      ),
    );
  }
}
