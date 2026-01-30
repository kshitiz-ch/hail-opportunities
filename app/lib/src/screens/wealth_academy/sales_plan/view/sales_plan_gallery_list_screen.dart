import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/wealth_academy/sales_plan_controller.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/sales_plan_gallery.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SalesPlanGalleryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Sales Plan Gallery',
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GetBuilder<SalesPlanController>(
          builder: (controller) {
            if (controller.creativesListState == NetworkState.loading) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (controller.creativesListState == NetworkState.error) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: RetryWidget(
                    genericErrorMessage,
                    onPressed: () {
                      controller.getCreatives();
                    },
                  ),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30)
                      .copyWith(top: 8),
                  child: Text(
                    'Share images with your clients for more sales',
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.secondaryBlack,
                            ),
                  ),
                ),
                Expanded(child: SalesPlanGallery())
              ],
            );
          },
        ),
      ),
    );
  }
}
