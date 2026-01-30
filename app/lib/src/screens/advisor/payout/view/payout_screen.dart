import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/payout_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/advisor/payout/widgets/payout_bank_detail.dart';
import 'package:app/src/screens/advisor/payout/widgets/payout_tabs.dart';
import 'package:app/src/screens/advisor/payout/widgets/payout_transactions.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/unauthorised_access_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class PayoutScreen extends StatelessWidget {
  PayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUnauthorised = false;
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      isUnauthorised = homeController.hasLimitedAccess ||
          (homeController.advisorOverviewModel?.isEmployee ?? false);
    }
    if (isUnauthorised) {
      return UnauthorisedAccessScreen(title: 'Payouts');
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(titleText: 'Payouts'),
      body: GetBuilder<PayoutController>(
        init: PayoutController(),
        builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PayoutBankDetail(),
              PayoutTabs(),
              SizedBox(height: 10),
              Expanded(child: _buildPayoutListing(controller)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPayoutListing(PayoutController controller) {
    if (controller.payoutsResponse.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.payoutsResponse.isError) {
      return Center(
        child: RetryWidget(
          controller.payoutsResponse.message,
          onPressed: () {
            controller.getPayouts();
          },
        ),
      );
    }
    if (controller.payoutsResponse.isLoaded) {
      if (controller.payoutList.isNullOrEmpty) {
        return Center(
          child: EmptyScreen(message: 'No Payouts available'),
        );
      }
      return PayoutTransactions();
    }
    return SizedBox();
  }
}
