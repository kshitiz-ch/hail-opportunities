import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/apply_button_show_case.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/fund_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/showcase/showcase_controller.dart';

class FundListFilter extends StatelessWidget {
  FundListFilter({this.tag});

  final String? tag;
  ShowCaseController? showCaseController;
  final Key showCaseWrapperKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      id: 'search',
      builder: (controller) {
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
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterListContainer(context, controller),
                    _buildFilterOptionsContainer(context, controller)
                  ],
                ),
              ),
              Container(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BottomSheetActionButton(
                          text: "Close",
                          isPrimaryButton: false,
                          onPressed: () async {
                            AutoRouter.of(context).popForced();
                          }),
                      SizedBox(
                        width: 12,
                      ),
                      showCaseController!.activeShowCaseId ==
                                  showCaseIds.ApplyFilterButton.id &&
                              controller.filtersSelected.isNotEmpty
                          ? ApplyButtonShowCase(
                              showCaseController: showCaseController,
                              showCaseWrapperKey: showCaseWrapperKey,
                              onClickFinished: () {},
                              onTap: () async {
                                controller.saveFiltersAndSorting();

                                AutoRouter.of(context).popForced();
                              })
                          : BottomSheetActionButton(
                              // context: context,
                              text: "Apply",
                              isPrimaryButton: true,
                              onPressed: () async {
                                controller.saveFiltersAndSorting();

                                AutoRouter.of(context).popForced();
                              })
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterListContainer(context, FundsController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 36.0, top: 36.0, bottom: 24),
            child: Text(
              'Filter',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
          ...controller.fundFilters.map((fundFilter) {
            return _buildFilterTypeCard(context, controller, fundFilter);
          }).toList(),
          // InkWell(
          //   onTap: () {
          //     controller.updateFilterSelected("min_deposit_amt");
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     height: 45,
          //     decoration: BoxDecoration(
          //       color: "min_deposit_amt" != controller.currentSelectedFilter
          //           ? Colors.white
          //           : ColorConstants.secondaryAppColor,
          //     ),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: Center(
          //             child: Text(
          //               'Min Amount',
          //               style: Theme.of(context)
          //                   .primaryTextTheme
          //                   .subtitle1
          //                   .copyWith(
          //                     color: ColorConstants.black,
          //                     fontWeight: FontWeight.w500,
          //                     overflow: TextOverflow.ellipsis,
          //                   ),
          //             ),
          //           ),
          //         ),
          //         "min_deposit_amt" == controller.currentSelectedFilter
          //             ? Container(
          //                 width: 1,
          //                 height: double.infinity,
          //                 color: ColorConstants.primaryAppColor,
          //               )
          //             : SizedBox()
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildFilterOptionsContainer(context, FundsController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () async {
                controller.clearFilters();
                AutoRouter.of(context).popForced();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 36.0, right: 30.0, left: 20, bottom: 24),
                child: Text(
                  'Clear All',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.redAccentColor.withOpacity(0.6),
                      ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildFilterOptions(context, controller),
          )
        ],
      ),
    );
  }

  Widget _buildFilterOptions(context, FundsController controller) {
    // if (controller.currentSelectedFilter == "min_deposit_amt") {
    //   return MinAmountFilter();
    // }

    List<FundFilterModel> currentFilter = controller.fundFilters
        .where((FundFilterModel filter) =>
            filter.name == controller.currentSelectedFilter)
        .toList();

    if (currentFilter.isEmpty) {
      return SizedBox();
    }

    List options = currentFilter[0].options!;
    List? filteredValues =
        controller.filtersSelected[controller.currentSelectedFilter];

    return ListView.builder(
      // in iOS default scroll behaviour is BouncingScrollPhysics
      // in android its ClampingScrollPhysics Setting
      //ClampingScrollPhysics explicitly for both
      physics: ClampingScrollPhysics(),
      controller: controller.filterScrollController,
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        var filterOption = options[index];

        String? optionText;
        String? optionValue;
        if (filterOption is Map) {
          var entries = filterOption.entries.toList()[0];
          optionValue = entries.key;
          optionText = entries.value;
        } else {
          optionText = filterOption;
          optionValue = filterOption;
        }

        bool isSelected = false;
        if (filteredValues != null) {
          isSelected = filteredValues.contains(optionValue);
        }

        return InkWell(
          onTap: () {
            controller.updateFilterValues(
                filterValue: optionValue, isAdding: !isSelected);
          },
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              right: 30.0,
              bottom: 12,
              top: 12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.done,
                  color: isSelected ? ColorConstants.black : Colors.white,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    optionText!,
                    maxLines: 3,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              // overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? ColorConstants.black
                                  : ColorConstants.tertiaryBlack,
                            ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTypeCard(
    context,
    FundsController controller,
    FundFilterModel fundFilter,
  ) {
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
}

class BottomSheetActionButton extends StatelessWidget {
  const BottomSheetActionButton({
    Key? key,
    // @required this.context,
    required this.text,
    required this.isPrimaryButton,
    required this.onPressed,
  }) : super(key: key);

  // final BuildContext context;
  final String text;
  final bool isPrimaryButton;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      responsiveButtonMaxWidthRatio: 0.4,
      text: text,
      bgColor: isPrimaryButton
          ? ColorConstants.primaryAppColor
          : ColorConstants.secondaryAppColor,
      margin: EdgeInsets.zero,
      onPressed: () async {
        onPressed();
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
