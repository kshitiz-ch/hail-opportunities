import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'resources_filter_sort_bottomsheet.dart';

/// Horizontal scrollable category chips with multi-select support
/// Shows: Category1 ✓ | Category2 ✓ | Category3 | ... | Filter Icon
class CategoryChipsRow extends StatefulWidget {
  const CategoryChipsRow({Key? key}) : super(key: key);

  @override
  State<CategoryChipsRow> createState() => _CategoryChipsRowState();
}

class _CategoryChipsRowState extends State<CategoryChipsRow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      builder: (controller) {
        // Prepare categories: Filter out 'all' and sort by selection status
        final categories = controller.activeCategories
            .where((c) => c.tag?.toLowerCase() != 'all')
            .toList();

        categories.sort((a, b) {
          final isASelected =
              controller.selectedCategories.any((cat) => cat.tag == a.tag);
          final isBSelected =
              controller.selectedCategories.any((cat) => cat.tag == b.tag);

          if (isASelected && !isBSelected) return -1;
          if (!isASelected && isBSelected) return 1;
          return 0;
        });

        return Container(
          decoration: BoxDecoration(
            color: ColorConstants.black,
            borderRadius: BorderRadius.circular(20),
          ),
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    // Check if category is in selected categories list
                    final isSelected = controller.selectedCategories
                        .any((cat) => cat.tag == category.tag);

                    return _buildCategoryChip(
                      context,
                      controller,
                      category,
                      isSelected,
                    );
                  },
                ),
              ),
              _buildFilterIconChip(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    AppResourcesController controller,
    TagModel category,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        // Single tap for quick select/deselect
        if (controller.selectedCategories
            .any((cat) => cat.tag == category.tag)) {
          controller.selectedCategories
              .removeWhere((cat) => cat.tag == category.tag);
        } else {
          if (!controller.selectedCategories.contains(category)) {
            controller.selectedCategories.add(category);

            // Scroll to start using the local controller
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            });
          }
        }
        controller.getData();
        // controller.update();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 6),
            ],
            Text(
              category.text ?? '',
              style: context.titleLarge?.copyWith(
                color: isSelected ? ColorConstants.white : Color(0xff949494),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIconChip(
    BuildContext context,
    AppResourcesController controller,
  ) {
    final hasActiveFilters = controller.selectedCategories.isNotEmpty;

    return InkWell(
      onTap: () {
        _showFilterBottomSheet(context, controller);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Color(0xff292929),
          border: Border(
            left: BorderSide(color: Color(0xff292929), width: 1),
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune,
              color: Colors.white,
              size: 20,
            ),
            if (hasActiveFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: hexToColor("#FF7262"),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '+${controller.selectedCategories.length}',
                      style: context.titleSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, AppResourcesController controller) {
    // Initialize temp selection with current selections
    controller.tempCategoriesSelected.clear();
    if (controller.selectedCategories.isNotEmpty) {
      controller.tempCategoriesSelected.addAll(controller.selectedCategories);
    }
    controller.currentFilterMode = FilterMode.filter;
    controller.update();

    CommonUI.showBottomSheet(
      context,
      child: ResourcesFilterSortBottomSheet(),
    );
  }
}
