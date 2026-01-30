import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_list_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_list/widgets/mf_portfolios_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class MfPortfolioListScreen extends StatelessWidget {
  // Fields
  final List<MFProductModel>? products;
  final Client? client;

  // Constructor
  const MfPortfolioListScreen({Key? key, this.products, this.client})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MfPortfoliosListController>(
      init: MfPortfoliosListController(),
      dispose: (_) {
        if (Get.isRegistered<MfPortfoliosListController>()) {
          Get.delete<MfPortfoliosListController>();
        }
      },
      builder: (controller) {
        final countText = '4 Portfolios';
        // final countText = (controller.mutualFundsState == NetworkState.loaded &&
        //         controller.mutualFundsResult.products!.isNotEmpty)
        //     ? '${controller.mutualFundsResult.products!.length} Portfolios'
        //     : '';

        return Scaffold(
          backgroundColor: ColorConstants.white,
          // App Bar
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Curated Mutual Fund Basket',
            subtitleText: countText,
          ),
          body: MFPortfoliosSection(client: client, products: products),
        );
      },
    );
  }
}
