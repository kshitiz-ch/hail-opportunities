import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'filter_options.dart';

class FilterList extends StatelessWidget {
  const FilterList({
    Key? key,
    required this.tag,
  }) : super(key: key);

  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScreenerController>(
      tag: tag,
      id: 'filter',
      builder: (controller) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterList(context, controller),
              _buildFilterOptions(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterList(BuildContext context, ScreenerController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...[FilterType.category, FilterType.amc]
              .map((FilterType e) => _buildFilterName(context, controller, e))
              .toList()
        ],
      ),
    );
  }

  Widget _buildFilterName(
    context,
    ScreenerController controller,
    FilterType filterType,
  ) {
    bool isSelected = filterType == controller.filterTypeSelected;

    return InkWell(
      onTap: () {
        if (controller.categoryResponse.state == NetworkState.loading ||
            controller.amcResponse.state == NetworkState.loading) {
          return;
        }

        controller.updateFilterTypeSelected(filterType);
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
                  // amc -> AMC
                  // category -> Category
                  "${filterType == FilterType.amc ? filterType.name.toUpperCase() : filterType.name.toTitleCase()}",
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

  Widget _buildFilterOptions(
      BuildContext context, ScreenerController controller) {
    List<Choice>? currentSelectedOptions;
    ApiResponse? apiResponse;
    List<Choice> options = [];

    bool showFundTypeOptions = false;

    if (controller.filterTypeSelected == FilterType.category) {
      currentSelectedOptions = controller.tempCategorySelected;
      showFundTypeOptions = controller.isCustomPortfoliosScreen;
      apiResponse = controller.categoryResponse;
      options = controller.categoryOptions;
    } else if (controller.filterTypeSelected == FilterType.amc) {
      currentSelectedOptions = controller.tempAmcSelected;
      apiResponse = controller.amcResponse;
      options = controller.amcOptions;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Column(
        children: [
          if (showFundTypeOptions)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: RadioButtons(
                spacing: 20,
                direction: Axis.horizontal,
                items: controller.fundTypes,
                selectedValue: controller.tempFundTypeSelected,
                onTap: (filterSelected) {
                  controller.updateTempFundTypeSelected(filterSelected);
                },
                itemBuilder: (context, value, index) {
                  value = value as FundType;
                  return Text(
                    value.name,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.black,
                            ),
                  );
                },
              ),
            ),
          Expanded(
            child: FilterOptions(
              currentSelectedOptions: currentSelectedOptions,
              apiResponse: apiResponse,
              options: options,
              onOptionSelect: (Choice choice) {
                controller.updateTempFilter(choice);
              },
              onRetry: () {
                if (controller.filterTypeSelected == FilterType.category) {
                  controller.getCategoryOptions();
                }
                if (controller.filterTypeSelected == FilterType.category) {
                  controller.getAmcOptions();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
