import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_search_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'filter_sort_bottomsheet.dart';

class FilterSortButtons extends StatelessWidget {
  const FilterSortButtons(
      {Key? key, required this.tag, this.showFilterButton = true})
      : super(key: key);

  final String tag;
  final bool showFilterButton;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScreenerController>(
      id: 'funds',
      tag: tag,
      global: true,
      builder: (controller) {
        bool isFiltersApplied = controller.categorySelected.isNotNullOrEmpty ||
            controller.amcSelected.isNotNullOrEmpty;
        bool isSortingApplied = controller.sortSelected != null;

        return Row(
          children: [
            if (showFilterButton)
              _buildIconButton(
                context,
                image: AllImages().fundFilterIcon,
                isFilterOrSortApplied: isFiltersApplied,
                controller: controller,
              ),
            SizedBox(width: 10),
            _buildIconButton(
              context,
              image: AllImages().swapIcon,
              isFilterOrSortApplied: isSortingApplied,
              controller: controller,
              isSorting: true,
            ),
          ],
        );
      },
    );
  }

  void _unFocusSearchBar(ScreenerController controller) {
    if (Get.isRegistered<MfSearchController>(
        tag: controller.searchControllerTag)) {
      MfSearchController searchController =
          Get.find<MfSearchController>(tag: controller.searchControllerTag);
      if (searchController.showSearchView) {
        searchController.focusNode.unfocus();
      }
    }
  }

  Widget _buildIconButton(
    BuildContext context, {
    required String image,
    required ScreenerController controller,
    bool isSorting = false,
    bool isFilterOrSortApplied = false,
  }) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            _unFocusSearchBar(controller);

            controller.getSavedFilterAndSort();
            if (isSorting) {
              controller.changeFilterMode(FilterMode.sort);
            } else {
              controller.changeFilterMode(FilterMode.filter);
            }

            if (controller.categoryOptions.isEmpty) {
              controller.getCategoryOptions();
            }

            CommonUI.showBottomSheet(
              context,
              child: FilterSortBottomSheet(
                tag: tag,
                hideFilters: !showFilterButton,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Image.asset(
              image,
              height: 14,
              width: 14,
            ),
          ),
        ),
        if (isFilterOrSortApplied) _buildRedDot(rightOffset: 5)
      ],
    );
  }

  Widget _buildRedDot({double? rightOffset}) {
    return Positioned(
      top: 0,
      right: rightOffset,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      ),
    );
  }
}
