import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:app/src/screens/commons/choose_client/view/choose_client_screen_new.dart';
import 'package:app/src/screens/wealthcase/widgets/performance_chart.dart';
import 'package:app/src/screens/wealthcase/widgets/performance_comparison_table.dart';
import 'package:app/src/screens/wealthcase/widgets/rebalance_schedule_card.dart';
import 'package:app/src/screens/wealthcase/widgets/returns_comparison_card.dart';
import 'package:app/src/screens/wealthcase/widgets/time_period_selector.dart';
import 'package:app/src/screens/wealthcase/widgets/wealthcase_card.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class WealthcaseDetailScreen extends StatelessWidget {
  final String? basketId;

  WealthcaseDetailScreen({
    Key? key,
    @PathParam('basketId') this.basketId,
  }) : super(key: key) {
    if (basketId.isNotNullOrEmpty) {
      late WealthcaseController controller;
      if (Get.isRegistered<WealthcaseController>()) {
        controller = Get.find<WealthcaseController>();
      } else {
        controller = Get.put(WealthcaseController());
      }

      // Fetch wealthcase basket detail
      controller.getWealthcaseBasketDetail(basketId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(),
      body: GetBuilder<WealthcaseController>(
        builder: (controller) {
          // Show loading state
          if (controller.basketDetailResponse.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error state
          if (controller.basketDetailResponse.isError) {
            return Center(
              child: Text(
                controller.basketDetailResponse.message.isNotEmpty
                    ? controller.basketDetailResponse.message
                    : 'Something went wrong',
                style: context.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            );
          }

          // Show content when data is loaded
          final model = controller.selectedWealthcase;
          if (model == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final cagrData = getWealthCaseCagrRow(model);

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // SmartValues logo
                    CachedNetworkImage(
                      imageUrl: getWealthCaseLogo(model.riaName),
                      fit: BoxFit.contain,
                      height: 20,
                      width: 100,
                    ),
                    const Spacer(),

                    // Risk level
                    buildRiskLevel(model.riskProfile ?? '-', context),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Text(
                    (model.viewName ?? '').toTitleCase(),
                    style: context.headlineLarge?.copyWith(
                      fontSize: 22,
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: buildStatItem(
                        cagrData.keys.first,
                        cagrData.values.first,
                        context,
                      ),
                    ),
                    Expanded(
                      child: buildStatItem(
                        'Min. Investment amount',
                        WealthyAmount.currencyFormat(
                            model.minInvestment?.round(), 0),
                        context,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Padding(
                //   padding: const EdgeInsets.only(top: 20, bottom: 12),
                //   child: buildCategoryTag(model.sectors ?? '-', context),
                // ),
                Text(
                  model.description ?? '',
                  style: context.titleLarge?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                _buildPerformanceSection(),
                SizedBox(height: 20),
                RebalanceScheduleCard(
                  onHelpTap: () {},
                  onWealthcaseInfoTap: () {
                    AutoRouter.of(context).push(AboutWealthcasesRoute());
                  },
                  wealthcaseModel: model,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildFloatingActionButton(context),
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReturnsComparisonCard(),
        PerformanceChart(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: TimePeriodSelector(),
        ),
        PerformanceComparisonTable(),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return GetBuilder<WealthcaseController>(
      builder: (controller) {
        final model = controller.selectedWealthcase;

        if (model == null) {
          return SizedBox.shrink();
        }

        return ColoredBox(
          color: Color(0xffF7F9FF),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AllImages().wealthCaseMousePointerIcon,
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        model.subscription?.remarks?.percentageText ?? '-',
                        style: context.titleLarge?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    model.subscription?.remarks?.monthlyText ?? '-',
                    style: context.titleLarge?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ActionButton(
                  text: 'Select Client',
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  onPressed: () {
                    AutoRouter.of(context).push(
                      ChooseClientRoute(
                        targetScreenType: TargetScreenType.WealthCaseProposal,
                        onClientSelected: (
                          client, {
                          List<String>? agentExternalIds,
                        }) async {
                          await onClientSelected(
                            client,
                            context,
                            controller,
                            agentExternalIds: agentExternalIds,
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onClientSelected(
    NewClientModel client,
    BuildContext context,
    WealthcaseController controller, {
    List<String>? agentExternalIds,
  }) async {
    // initiate screen loader
    AutoRouter.of(context).pushNativeRoute(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
      ),
    );
    // send wealthcase proposal
    final proposalUrl = await controller.sendWealthcaseProposal(
      controller.selectedWealthcase?.basketId ?? '',
      client.userId ?? '',
      agentExternalIds: agentExternalIds,
    );
    if (controller.sendProposalResponse.isError) {
      // pop screen loader
      AutoRouter.of(context).pop();
      // show error snackbar
      showToast(text: controller.sendProposalResponse.message);
    }
    if (controller.sendProposalResponse.isLoaded) {
      // pop screen loader
      AutoRouter.of(context).pop();
      // pop to previous screen
      AutoRouter.of(context).pop();
      // show success snackbar
      showToast(text: controller.sendProposalResponse.message);
      // // push to proposals success screen
      AutoRouter.of(context).push(
        ProposalSuccessRoute(
          client: client.getHydraClientModel(),
          productName: 'Wealthcase',
          proposalUrl: proposalUrl,
          enablePopScope: true,
        ),
      );
    }
  }
}
