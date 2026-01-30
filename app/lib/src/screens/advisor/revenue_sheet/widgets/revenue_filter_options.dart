import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/advisor/revenue_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueFilterOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: _buildFilterOptions(context),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    return GetBuilder<RevenueDetailController>(
      builder: (controller) {
        final currentFilterOptions = controller
                .revenueFilterList[controller.currentSelectedFilterType] ??
            {};
        final filteredValue = controller
            .selectedRevenueFilter[controller.currentSelectedFilterType];
        if (currentFilterOptions.isEmpty) {
          return SizedBox();
        }

        return ListView.builder(
          physics: ClampingScrollPhysics(),
          // controller: controller.filterScrollController,
          // shrinkWrap: true,
          itemCount: currentFilterOptions.entries.length,
          itemBuilder: (BuildContext context, int index) {
            final currentOption = currentFilterOptions.entries.elementAt(index);
            final isSelected = filteredValue == currentOption.key;

            return InkWell(
              onTap: () {
                controller.updateFilterValues(
                  value: currentOption.key,
                  isAdding: !isSelected,
                );
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
                        currentOption.value,
                        maxLines: 3,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
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
      },
    );
  }
}
