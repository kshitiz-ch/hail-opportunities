import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/goal/goal_controller.dart';
import 'package:app/src/controllers/client/goal/swp_detail_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_card.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_detail_view.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/swp_summary_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/base_swp_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SwpDetailScreen extends StatelessWidget {
  final BaseSwpModel selectedBaseSwp;
  final controller = Get.find<GoalController>();

  SwpDetailScreen({Key? key, required this.selectedBaseSwp})
      : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwpDetailController>(
      id: GetxId.goalSwpOrders,
      init: SwpDetailController(
        selectedSwp: selectedBaseSwp,
        goal: controller.goal!,
        client: controller.client,
        goalId: controller.goalId,
      ),
      builder: (controller) {
        final isInactive =
            selectedBaseSwp.endDate?.isBefore(DateTime.now()) ?? false;

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: getSWPDisplayName(selectedBaseSwp),
            maxLine: 2,
            trailingWidgets: [
              Align(
                alignment: Alignment.centerRight,
                child: ClickableText(
                  text: 'Edit SWP',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  onClick: () {
                    AutoRouter.of(context).push(EditSwpRoute());
                  },
                ),
              )
            ],
          ),
          body: Builder(
            builder: (context) {
              if (controller.swpDetailResponse.state == NetworkState.loading &&
                  !controller.isPaginating) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (controller.swpDetailResponse.state == NetworkState.error) {
                return Center(
                  child: RetryWidget(
                    controller.swpDetailResponse.message,
                    onPressed: () {
                      controller
                          .getClientSWPDetails(selectedBaseSwp.externalId!);
                    },
                  ),
                );
              }
              if (controller.swpDetailResponse.state == NetworkState.loaded ||
                  controller.isPaginating) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SWPSummaryCard(),
                    _buildSchemeDetails(context),
                    Expanded(
                      child: SWPDetailView(),
                    ),
                    if (controller.isPaginating) _buildInfiniteLoader()
                  ],
                );
              }
              return SizedBox();
            },
          ),
        );
      },
    );
  }

  Widget _buildInfiniteLoader() {
    return Container(
      height: 30,
      margin: EdgeInsets.only(bottom: 10, top: 10),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Details',
            style: Theme.of(context).primaryTextTheme.headlineMedium,
          ),
          SizedBox(height: 15),
          SchemeFolioCard(
            displayName: selectedBaseSwp.swpFunds!.first.schemeName,
            folioNumber: selectedBaseSwp.swpFunds!.first.folioNumber,
          )
        ],
      ),
    );
  }
}
