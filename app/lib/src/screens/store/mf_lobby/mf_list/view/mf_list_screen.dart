import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_search_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/basket_icon.dart';
import 'package:app/src/screens/store/mf_lobby/mf_list/widgets/filter_sort_bottomsheet.dart';
import 'package:app/src/screens/store/mf_lobby/widgets/search_result.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/list/screener_table.dart';
import 'package:app/src/widgets/loader/screener_table_skelton.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/lazy_indexed_stack.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/category_section.dart';
import '../../widgets/search_bar_section.dart';
import '../widgets/filter_sort_button.dart';

@RoutePage()
class MfListScreen extends StatelessWidget {
  MfListScreen({
    Key? key,
    this.screener,
    this.categorySelected,
    this.categorySelectedIndex = 0,
    this.openFiltersByDefault = false,
    @queryParam this.amc = '',
    this.showAllAmcFunds = false,
    this.isCustomPortfoliosScreen = false,
  }) : super(key: key) {
    showAllAmcFunds = this.screener == null;
  }

  ScreenerModel? screener;
  final List<Choice>? categorySelected;
  final int categorySelectedIndex;
  final String? amc;
  bool showAllAmcFunds;
  final bool openFiltersByDefault;
  final bool isCustomPortfoliosScreen;

  final String searchControllerTag = 'mf-list';

  @override
  Widget build(BuildContext context) {
    if (showAllAmcFunds || isCustomPortfoliosScreen) {
      screener = ScreenerModel.fromJson({
        "uri": '/v0/schemes/',
        "wpc": 'all-funds',
        "name": 'Funds List',
      });
    }

    String controllerTag = '${screener?.wpc}-list';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          if (Get.isRegistered<MfSearchController>(tag: searchControllerTag)) {
            MfSearchController mfSearchController =
                Get.find<MfSearchController>(tag: searchControllerTag);

            if (mfSearchController.showSearchView) {
              mfSearchController.hideSearchView();
            } else {
              AutoRouter.of(context).popForced();
            }
          } else {
            AutoRouter.of(context).popForced();
          }
        });
      },
      child: GetBuilder<ScreenerController>(
        tag: controllerTag,
        init: ScreenerController(
          screener: screener,
          fromListScreen: true,
          categorySelected: categorySelected,
          categorySelectedIndex: categorySelectedIndex,
          isCustomPortfoliosScreen: isCustomPortfoliosScreen,
          amcSelected: amc.isNotNullOrEmpty
              ? [
                  Choice(
                    value: amc!.toUpperCase(),
                    displayName: getAmcDisplayName(amc!.toUpperCase()),
                  )
                ]
              : null,
        ),
        dispose: (_) {
          Get.delete<MfSearchController>(tag: searchControllerTag);
        },
        initState: (_) {
          Get.put(MfSearchController(), tag: searchControllerTag);
          if (openFiltersByDefault) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              ScreenerController controller =
                  Get.find<ScreenerController>(tag: controllerTag);

              if (controller.categoryOptions.isEmpty) {
                controller.getCategoryOptions();
              }

              CommonUI.showBottomSheet(
                context,
                child: FilterSortBottomSheet(tag: controllerTag),
              );
            });
          }
        },
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorConstants.white,
            appBar: CustomAppBar(
              titleText: screener?.name,
              maxLine: 2,
              trailingWidgets: [
                BasketIcon(
                  fromCustomPortfolios: isCustomPortfoliosScreen,
                  onTap: () {
                    AutoRouter.of(context).push(
                      BasketOverViewRoute(
                        fromCustomPortfolios: isCustomPortfoliosScreen,
                      ),
                    );
                  },
                )
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (!showAllAmcFunds)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchBarSection(tag: searchControllerTag),
                      ),
                      SizedBox(width: 12),
                      FilterSortButtons(
                        tag: "${screener?.wpc}-list",
                        // Don't show filter button for AMC specific Listing
                        showFilterButton: amc.isNullOrEmpty,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GetBuilder<MfSearchController>(
                    tag: searchControllerTag,
                    builder: (searchController) {
                      return LazyIndexedStack(
                        sizing: StackFit.loose,
                        index: searchController.showSearchView ? 1 : 0,
                        children: [
                          _buildListSection(context),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: SearchResult(
                              tag: searchControllerTag,
                              fromListScreen: true,
                              isCustomPortfolioScreen: isCustomPortfoliosScreen,
                            ),
                          )
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
            bottomNavigationBar: CommonMfUI.buildMfLobbyBottomNavigationBar(
              fromCustomPortfolios: isCustomPortfoliosScreen,
            ),
          );
        },
      ),
    );
  }

  Widget _buildListSection(BuildContext context) {
    return GetBuilder<ScreenerController>(
      tag: "${screener?.wpc}-list",
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildLimitedCategories(),
              if (screener?.categoryParams?.choices.isNotNullOrEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: CategorySection(
                    choices: screener?.categoryParams?.choices ?? [],
                    controller: controller,
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
                    controller.getReturnValue(
                      controller.categoryAvgReturns,
                    ),
                    category: controller.categorySelected!.first.displayName,
                  ),
                ),
              if (controller.screenerResponse.state == NetworkState.loading)
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ScreenerTableSkelton(
                      itemCount: 20,
                      fromScreenerList: true,
                    ),
                  ),
                )
              else if (controller.screenerResponse.state == NetworkState.loaded)
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ScreenerTable(
                      controller: controller,
                      fromListScreen: true,
                    ),
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
