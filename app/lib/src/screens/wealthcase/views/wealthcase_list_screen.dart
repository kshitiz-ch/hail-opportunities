import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/wealthcase/widgets/wealthcase_card.dart';
import 'package:app/src/screens/wealthcase/widgets/wealthcase_info_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class WealthcaseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: 'Wealthcase'),
      body: GetBuilder<WealthcaseController>(
        init: WealthcaseController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WealthcaseInfoCard(),
                const SizedBox(height: 16),
                Expanded(child: _buildWealthcaseList(controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWealthcaseList(WealthcaseController controller) {
    if (controller.wealthcaseListResponse.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (controller.wealthcaseListResponse.isError) {
      return Center(
        child: RetryWidget(
          controller.wealthcaseListResponse.message,
          onPressed: () {
            controller.getWealthcaseList();
          },
        ),
      );
    }
    if (controller.wealthcaseList.isEmpty) {
      return const Center(
        child: EmptyScreen(message: 'No wealthcases available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 20),
      itemCount: controller.wealthcaseList.length,
      itemBuilder: (context, index) {
        final basket = controller.wealthcaseList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              controller.selectedBenchmark = null;
              controller.showBenchmarkComparison = false;
              controller.selectedWealthcase = basket;
              controller.basketDetailResponse.state = NetworkState.loaded;
              AutoRouter.of(context).push(WealthcaseDetailRoute());
            },
            child: WealthcaseCard(model: basket),
          ),
        );
      },
    );
  }
}
