import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicobTransactionFilters extends StatelessWidget {
  final controller = Get.find<TicobController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.allTransactionFilter.keys.map(
          (filterType) {
            return _buildFilterTypeCard(context, filterType);
          },
        ).toList(),
      ),
    );
  }

  Widget _buildFilterTypeCard(
    BuildContext context,
    String filterType,
  ) {
    final isSelected = filterType == controller.selectedFilterType;
    final optionsSelectedCount =
        controller.tempTransactionFilter[filterType]?.length ?? 0;

    String filterText = filterType;
    if (optionsSelectedCount.isNotNullOrZero) {
      filterText += ' ($optionsSelectedCount)';
    }

    return InkWell(
      onTap: () {
        if (!isSelected) {
          controller.updateSelectedFilterType(filterType);
        }
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
                  filterText,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
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
