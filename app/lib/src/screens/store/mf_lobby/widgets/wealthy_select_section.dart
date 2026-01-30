import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/widgets/list/screener_table.dart';
import 'package:app/src/widgets/loader/screener_table_skelton.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'category_section.dart';

class WealthySelectSection extends StatelessWidget {
  const WealthySelectSection(
      {Key? key,
      required this.screener,
      this.fromListScreen = false,
      this.fromCuratedFundsScreen = false,
      this.fromFundIdeasScreen = false})
      : super(key: key);

  final ScreenerModel screener;
  final bool fromListScreen;
  final bool fromCuratedFundsScreen;
  final bool fromFundIdeasScreen;

  @override
  Widget build(BuildContext context) {
    List<Choice> choices = screener.categoryParams?.choices ?? [];
    return GetBuilder<ScreenerController>(
      init: ScreenerController(
        screener: screener,
        fromListScreen: fromListScreen,
        fromFundIdeasScreen: fromFundIdeasScreen,
        fromCuratedFundsScreen: fromCuratedFundsScreen,
      ),
      tag: fromListScreen ? "${screener.wpc}-list" : screener.wpc,
      global: false,
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(top: fromCuratedFundsScreen ? 0 : 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!fromCuratedFundsScreen)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${screener.name}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineLarge!
                        .copyWith(fontSize: 16),
                  ),
                ),
              // if (screener.description.isNotNullOrEmpty)
              //   Padding(
              //     padding: EdgeInsets.only(top: 6, right: 30, bottom: 10),
              //     child: Text(
              //       '${screener.description}',
              //       style: Theme.of(context)
              //           .primaryTextTheme
              //           .titleLarge!
              //           .copyWith(
              //               color: ColorConstants.secondaryBlack, fontSize: 13),
              //     ),
              //   ),
              SizedBox(height: 16),
              if (!fromCuratedFundsScreen)
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CategorySection(
                    controller: controller,
                    choices: choices,
                  ),
                ),

              // Category Avg Return
              if (controller.screenerResponse.state == NetworkState.loaded &&
                  controller.categoryAvgReturns != null &&
                  (controller.categorySelected ?? []).length == 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CommonMfUI.buildCategoryAvgText(
                    context,
                    controller.returnTypeSelected?.displayName,
                    controller.getReturnValue(controller.categoryAvgReturns),
                    category: controller.categorySelected?.first.displayName,
                  ),
                ),

              if (controller.screenerResponse.state == NetworkState.loading)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: SkeltonLoaderCard(
                          height: 25,
                          radius: 0,
                        ),
                      ),
                      ScreenerTableSkelton(),
                    ],
                  ),
                )
              else if (controller.screenerResponse.state == NetworkState.loaded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ScreenerTable(
                    controller: controller,
                    showMfRating: !fromFundIdeasScreen,
                    onTapViewAll: !fromCuratedFundsScreen
                        ? () {
                            MixPanelAnalytics.trackWithAgentId(
                              "view_all_funds",
                              screen: 'mutual_fund_store',
                              screenLocation:
                                  controller.screener?.name?.toSnakeCase(),
                            );

                            AutoRouter.of(context).push(
                              MfListRoute(
                                screener: screener,
                                categorySelected: controller.categorySelected,
                                categorySelectedIndex:
                                    controller.categorySelectedIndex,
                              ),
                            );
                          }
                        : null,
                  ),
                )
              else if (controller.screenerResponse.state == NetworkState.error)
                _buildRetryWidget(controller)
              else
                SizedBox()
            ],
          ),
        );
      },
    );
  }

  Widget _buildRetryWidget(ScreenerController controller) {
    return RetryWidget(
      controller.screenerResponse.message,
      onPressed: () {
        controller.getSchemes();
      },
    );
  }
}
