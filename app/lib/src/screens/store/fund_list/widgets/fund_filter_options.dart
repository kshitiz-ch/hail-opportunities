import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/min_amount_filter.dart';
import 'package:core/modules/store/models/fund_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FundFilterOptions extends StatelessWidget {
  const FundFilterOptions({
    Key? key,
    this.tag,
  }) : super(key: key);

  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
        id: 'search',
        builder: (controller) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Column(
              children: [
                Expanded(
                  child: _buildFilterOptions(context, controller),
                )
              ],
            ),
          );
        });
  }

  Widget _buildFilterOptions(context, FundsController controller) {
    if (controller.currentSelectedFilter == "min_deposit_amount") {
      return MinAmountFilter();
    }

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
}
