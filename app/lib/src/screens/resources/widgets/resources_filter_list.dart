import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResourcesFilterList extends StatelessWidget {
  const ResourcesFilterList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      builder: (controller) {
        if (controller.getFiltersResponse.isLoading) {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.activeCategories
                    .where((category) =>
                        category.tag != controller.allCategory.tag)
                    .map((category) => _buildFilterOption(
                          context,
                          controller,
                          category,
                        ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    AppResourcesController controller,
    TagModel category,
  ) {
    bool isSelected = controller.tempCategoriesSelected.contains(category);

    return InkWell(
      onTap: () {
        controller.toggleTempCategory(category);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorConstants.tertiaryBlack.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.tertiaryBlack.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isSelected
                    ? ColorConstants.primaryAppColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                category.text ?? '',
                style: context.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
