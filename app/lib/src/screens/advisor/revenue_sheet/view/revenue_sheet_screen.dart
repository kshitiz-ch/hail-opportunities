import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/revenue_sheet_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/client_wise_revenue.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/product_wise_revenue.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/unauthorised_access_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/revenue_sheet_overview.dart';

@RoutePage()
class RevenueSheetScreen extends StatelessWidget {
  final String? payoutId;

  const RevenueSheetScreen({Key? key, this.payoutId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool hideRevenue = false;
    bool isUnauthorised = false;
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      hideRevenue = homeController.hideRevenue;
      isUnauthorised = homeController.hasLimitedAccess ||
          (homeController.advisorOverviewModel?.isEmployee ?? false);
    }
    if (isUnauthorised) {
      return UnauthorisedAccessScreen(title: 'Revenue Sheet');
    }

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: payoutId.isNotNullOrEmpty
          ? CustomAppBar(titleText: 'Revenue Sheet')
          : null,
      body: hideRevenue
          ? _buildHideRevenueText(context)
          : GetBuilder<RevenueSheetController>(
              init: RevenueSheetController(payoutId: payoutId),
              builder: (RevenueSheetController controller) {
                return SingleChildScrollView(
                  controller: controller.scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (payoutId.isNullOrEmpty) RevenueSheetOverview(),
                      if (payoutId.isNullOrEmpty) ProductWiseRevenue(),
                      ClientWiseRevenue(enableDownload: payoutId.isNullOrEmpty),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHideRevenueText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Text(
          'You don\'t have access to view Revenue Sheet.\nAsk your team owner to provide access',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(height: 1.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
