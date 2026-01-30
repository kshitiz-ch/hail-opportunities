import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/screens/clients/client_list/widgets/filter_sort_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterSortButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientListController>(
      builder: (controller) {
        final isFiltersApplied = controller.selectedFilterListMap.isNotEmpty;
        final isSortingApplied = controller.sortSelected != null;

        return Row(
          children: [
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

  Widget _buildIconButton(
    BuildContext context, {
    required String image,
    required ClientListController controller,
    bool isSorting = false,
    bool isFilterOrSortApplied = false,
  }) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            controller.getSavedFilterAndSort();
            if (isSorting) {
              controller.changeFilterMode(FilterMode.sort);
            } else {
              controller.changeFilterMode(FilterMode.filter);
            }

            CommonUI.showBottomSheet(
              context,
              child: FilterSortBottomSheet(),
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
