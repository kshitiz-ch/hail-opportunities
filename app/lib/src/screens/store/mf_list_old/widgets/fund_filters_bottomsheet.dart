import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/mf_list_old/widgets/fund_filter_options.dart';
import 'package:app/src/screens/store/mf_list_old/widgets/fund_sorting_options.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/fund_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class FundFiltersBottomSheet extends StatelessWidget {
  FilterMode filterMode;
  final String? tag;
  final Key showCaseWrapperKey = UniqueKey();

  FundFiltersBottomSheet({this.filterMode = FilterMode.filter, this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      tag: tag,
      global: tag != null,
      id: 'search',
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (Get.isRegistered<FundsController>(tag: tag)) {
            Get.find<FundsController>(tag: tag).changeFilterMode(filterMode);
          }
        });
      },
      builder: (controller) {
        ShowCaseController? showCaseController;
        if (Get.isRegistered<ShowCaseController>()) {
          showCaseController = Get.find<ShowCaseController>();
        }

        if (controller.fundFilterState != NetworkState.loaded) {
          return SizedBox();
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(50),
            ),
            color: ColorConstants.white,
          ),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottomsheet top section
              _buildHeader(context, controller),

              // Filter list and its respective options
              if (controller.currentFilterMode == FilterMode.filter)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterListContainer(context, controller),
                      FundFilterOptions(tag: tag)
                    ],
                  ),
                )
              else
                FundSortingOptions(tag: tag),

              // Filter action buttons
              _buildFooterButtons(context, controller, showCaseController)
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FundsController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 30),
      child: Row(
        children: [
          _buildHeaderTab(
            context,
            controller: controller,
            text: 'Filter',
            isActive: controller.currentFilterMode == FilterMode.filter,
          ),
          _buildHeaderTab(
            context,
            controller: controller,
            text: 'Sort',
            isActive: controller.currentFilterMode == FilterMode.sort,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab(BuildContext context,
      {FundsController? controller,
      required String text,
      required bool isActive}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isActive) {
            controller!.changeFilterMode(
                controller.currentFilterMode == FilterMode.filter
                    ? FilterMode.sort
                    : FilterMode.filter);
          }
        },
        child: Container(
          padding: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
                color: isActive
                    ? ColorConstants.primaryAppColor
                    : Colors.transparent),
          )),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: isActive
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterListContainer(context, FundsController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.fundFilters.map((fundFilter) {
            return _buildFilterTypeCard(context, controller, fundFilter);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterTypeCard(
    context,
    FundsController controller,
    FundFilterModel fundFilter,
  ) {
    if (fundFilter.isCustom! && fundFilter.name != "min_deposit_amount") {
      return SizedBox();
    }

    bool isSelected = fundFilter.name == controller.currentSelectedFilter;
    return InkWell(
      onTap: () {
        controller.updateFilterSelected(fundFilter.name);
      },
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: !isSelected ? Colors.white : ColorConstants.secondaryAppColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  '${fundFilter.displayName} ${(controller.filtersSelected[fundFilter.name] != null && controller.filtersSelected[fundFilter.name]!.length > 0) ? '(${controller.filtersSelected[fundFilter.name]!.length})' : ''}',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                ),
              ),
            ),
            isSelected
                ? Container(
                    width: 1,
                    height: double.infinity,
                    color: ColorConstants.primaryAppColor,
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context, FundsController controller,
      ShowCaseController? showCaseController) {
    bool displayShowCaseWidget = showCaseController != null &&
        showCaseController.activeShowCaseId ==
            showCaseIds.ApplyFilterButton.id &&
        controller.filtersSelected.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            context,
            text: "Clear All",
            isPrimaryButton: false,
            onPressed: () async {
              controller.clearFilters();
              AutoRouter.of(context).popForced();
            },
          ),
          SizedBox(
            width: 12,
          ),
          displayShowCaseWidget
              ? ShowCaseWidget(
                  disableScaleAnimation: true,
                  disableBarrierInteraction: false,
                  onStart: (index, key) {},
                  onFinish: () async {
                    if (showCaseController.activeShowCaseId ==
                        showCaseIds.ApplyFilterButton.id) {
                      await showCaseController.setActiveShowCase();
                      controller.update(['search', 'funds']);
                    }
                  },
                  builder: (context) {
                    return ShowCaseWrapper(
                      key: showCaseWrapperKey,
                      currentShowCaseId: showCaseIds.ApplyFilterButton.id,
                      minRadius: 8,
                      maxRadius: 24,
                      constraints: BoxConstraints(
                        maxHeight: 64,
                        minHeight: 24,
                        maxWidth: MediaQuery.of(context).size.width * 0.4,
                        minWidth: MediaQuery.of(context).size.width * 0.4 - 20,
                      ),
                      onTargetClick: () async {
                        await showCaseController.setActiveShowCase();
                        controller.saveFiltersAndSorting();

                        AutoRouter.of(context).popForced();
                        controller.update(['search', 'funds']);
                      },
                      rippleExpandingHeight: 64,
                      rippleExpandingWidth:
                          MediaQuery.of(context).size.width * 0.4 + 10,
                      child: Container(
                        constraints: BoxConstraints(
                            maxHeight: 44,
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.4 - 10),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            _buildActionButton(
                              context,
                              text: "Apply",
                              isPrimaryButton: true,
                              onPressed: () async {
                                controller.saveFiltersAndSorting();

                                AutoRouter.of(context).popForced();
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              : _buildActionButton(
                  context,
                  text: "Apply",
                  isPrimaryButton: true,
                  onPressed: () async {
                    controller.saveFiltersAndSorting();

                    AutoRouter.of(context).popForced();
                  },
                )
        ],
      ),
    );
  }

  Widget _buildActionButton(context,
      {String? text, bool isPrimaryButton = false, Function? onPressed}) {
    return ActionButton(
      responsiveButtonMaxWidthRatio: 0.4,
      text: text,
      bgColor: isPrimaryButton
          ? ColorConstants.primaryAppColor
          : ColorConstants.secondaryAppColor,
      margin: EdgeInsets.zero,
      onPressed: () async {
        onPressed!();
      },
      textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
            color: !isPrimaryButton
                ? ColorConstants.primaryAppColor
                : ColorConstants.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
