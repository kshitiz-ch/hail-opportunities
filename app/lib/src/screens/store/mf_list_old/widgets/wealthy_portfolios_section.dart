import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_list_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_list/widgets/mf_portfolios_section.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WealthyPortfoliosSection extends StatelessWidget {
  const WealthyPortfoliosSection({Key? key, this.client}) : super(key: key);

  final Client? client;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MfPortfoliosListController>()) {
      Get.put(MfPortfoliosListController());
    }

    return GetBuilder<MfPortfoliosListController>(builder: (controller) {
      return MFPortfoliosSection(
        client: client,
        products: controller.mutualFundsState == NetworkState.loaded
            ? controller.mutualFundsResult.products
            : null,
        showProductVideo: false,
        showTitle: false,
      );
    });
  }
}
