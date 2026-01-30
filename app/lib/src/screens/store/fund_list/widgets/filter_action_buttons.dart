import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/show_case_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../controllers/store/mutual_fund/funds_controller.dart';
import 'fund_filters_bottomsheet.dart';

class FilterActionButtons extends StatefulWidget {
  const FilterActionButtons({
    Key? key,
    this.showCaseWrapperKey,
  }) : super(key: key);

  final Key? showCaseWrapperKey;

  @override
  State<FilterActionButtons> createState() => _FilterActionButtonsState();
}

class _FilterActionButtonsState extends State<FilterActionButtons> {
  void onShowCaseTap() {
    ShowCaseController? showCaseController;
    if (Get.isRegistered<ShowCaseController>()) {
      showCaseController = Get.find<ShowCaseController>();
    }

    if (showCaseController != null &&
        showCaseController.activeShowCaseId == showCaseIds.FilterFunds.id) {
      showCaseController.setActiveShowCase().then((value) {
        FundsController? controller;
        if (Get.isRegistered<FundsController>()) {
          controller = Get.find<FundsController>();
        }

        if (controller != null) {
          controller.update(['funds']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      id: 'funds',
      builder: (fundsController) {
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: () {
            ShowCaseController? showCaseController;
            if (Get.isRegistered<ShowCaseController>()) {
              showCaseController = Get.find<ShowCaseController>();
            }

            bool displayFilterShowCase = showCaseController != null &&
                showCaseController.activeShowCaseId ==
                    showCaseIds.FilterFunds.id;

            LogUtil.printLog(displayFilterShowCase);

            // if (showCaseController.activeShowCaseId ==
            //     showCaseIds.FilterFunds.id) {
            //   return FilterButtonShowCase(
            //       showCaseController: showCaseController,
            //       showCaseWrapperKey: widget.showCaseWrapperKey,
            //       onClickFinished: () {
            //         fundsController.update(['funds']);
            //       },
            //       onShowCaseTap: onShowCaseTap);
            // }

            return FilterButtons(
              showCaseController: showCaseController,
              displayFilterShowCase: displayFilterShowCase,
              fundsController: fundsController,
              onShowCaseTap: onShowCaseTap,
              showCaseWrapperKey: widget.showCaseWrapperKey,
            );
          }(),
        );
      },
    );
  }
}

class FilterButtons extends StatelessWidget {
  const FilterButtons({
    Key? key,
    this.showCaseWrapperKey,
    this.showCaseController,
    this.fundsController,
    this.displayFilterShowCase = false,
    this.onShowCaseTap,
  }) : super(key: key);

  final Key? showCaseWrapperKey;
  final ShowCaseController? showCaseController;
  final FundsController? fundsController;
  final bool displayFilterShowCase;
  final Function? onShowCaseTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (displayFilterShowCase)
          ShowCaseWidget(
            disableScaleAnimation: true,
            disableBarrierInteraction: false,
            onStart: (index, key) {},
            onFinish: () async {
              if (showCaseController!.activeShowCaseId ==
                  showCaseIds.FilterFunds.id) {
                //* calling it twice as to skip the step of sheet open (check showCaseList)
                await showCaseController!.setActiveShowCase();
                await showCaseController!.setActiveShowCase();
                fundsController!.update(['funds']);
              }
            },
            builder: (context) {
              return Container(
                // width: 75,
                child: ShowCaseWrapper(
                  key: showCaseWrapperKey,
                  currentShowCaseId: showCaseIds.FilterFunds.id,
                  minRadius: 5,
                  maxRadius: 5,
                  constraints: BoxConstraints(
                    maxHeight: 33,
                    minHeight: 30,
                    maxWidth: 73,
                    minWidth: 65,
                  ),
                  onTargetClick: () async {
                    if (showCaseController!.activeShowCaseId ==
                        showCaseIds.FilterFunds.id) {
                      await showCaseController!.setActiveShowCase();
                      // await onShowCaseTap();
                      // await onFilterTap();
                      fundsController!.update(['funds']);

                      CommonUI.showBottomSheet(
                        context,
                        borderRadius: 16.0,
                        isScrollControlled: true,
                        child: FundFiltersBottomSheet(),
                      ).then((value) async {
                        if (Get.isRegistered<FundsController>()) {
                          FundsController controller =
                              Get.find<FundsController>();
                          controller.removeNonSavedFilters();
                        }

                        if (showCaseController != null &&
                            showCaseController!.activeShowCaseId ==
                                showCaseIds.ApplyFilterButton.id) {
                          await showCaseController!.setActiveShowCase();

                          FundsController? controller;
                          if (Get.isRegistered<FundsController>()) {
                            controller = Get.find<FundsController>();
                          }

                          if (controller != null) {
                            controller.update(['funds']);
                          }
                        }
                      });
                    }
                  },
                  rippleExpandingHeight: 33,
                  rippleExpandingWidth: 73,
                  child: Container(
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(50)
                    // ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
                    child: _buildFilterButton(
                        context, onShowCaseTap, showCaseController),
                  ),
                ),
              );
            },
          )
        else
          _buildFilterButton(context, null, showCaseController),
        _buildSortButton(context)
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context, Function? onShowCaseTap,
      ShowCaseController? showCaseController) {
    void onFilterTap(ShowCaseController? showCaseController) {
      CommonUI.showBottomSheet(
        context,
        borderRadius: 16.0,
        isScrollControlled: true,
        child: FundFiltersBottomSheet(),
      ).then((value) async {
        if (Get.isRegistered<FundsController>()) {
          FundsController controller = Get.find<FundsController>();
          controller.removeNonSavedFilters();
        }

        if (showCaseController != null &&
            showCaseController.activeShowCaseId ==
                showCaseIds.ApplyFilterButton.id) {
          await showCaseController.setActiveShowCase();

          FundsController? controller;
          if (Get.isRegistered<FundsController>()) {
            controller = Get.find<FundsController>();
          }

          if (controller != null) {
            controller.update(['funds']);
          }
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: InkWell(
        onTap: () {
          if (onShowCaseTap != null) {
            onShowCaseTap();
          }

          onFilterTap(showCaseController);
        },
        child: Row(
          children: [
            Image.asset(
              AllImages().fundFilterIcon,
              height: 14,
              width: 14,
              // color: ColorConstants.primaryAppColor,
            ),
            SizedBox(
              width: 9,
            ),
            Text(
              'Filter',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: () {
          CommonUI.showBottomSheet(
            context,
            borderRadius: 16.0,
            isScrollControlled: true,
            child: FundFiltersBottomSheet(filterMode: FilterMode.sort),
          ).then((value) {
            if (Get.isRegistered<FundsController>()) {
              FundsController controller = Get.find<FundsController>();
              controller.removeNonSavedFilters();
            }
          });
        },
        child: Row(
          children: [
            Image.asset(AllImages().swapIcon, width: 13),
            SizedBox(
              width: 8,
            ),
            Text(
              'Sort',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
