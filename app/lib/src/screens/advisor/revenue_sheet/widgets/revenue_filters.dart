import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/advisor/revenue_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RevenueDetailController>(
      builder: (controller) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.revenueFilterList.keys.map(
              (filterType) {
                return _buildFilterTypeCard(context, filterType, controller);
              },
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilterTypeCard(
    BuildContext context,
    String filterText,
    RevenueDetailController controller,
  ) {
    bool isSelected = filterText == controller.currentSelectedFilterType;

    return InkWell(
      onTap: () {
        controller.updateSelectedFilterType(filterText);
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  filterText,
                  textAlign: TextAlign.left,
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
