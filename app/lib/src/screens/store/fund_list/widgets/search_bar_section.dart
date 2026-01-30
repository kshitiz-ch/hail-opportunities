import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/fund_filters_bottomsheet.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GetBuilder<FundsController>(
              id: 'search',
              builder: (controller) {
                int noOfFilterSaved = controller.filtersSaved.entries.length +
                    (controller.minAmountFilter! > 0 ? 1 : 0);
                bool isFiltersSaved = noOfFilterSaved > 0;
                bool isSortingApplied =
                    controller.sortingSaved.isNotNullOrEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        if (isFiltersSaved)
                          InkWell(
                            onTap: () {
                              CommonUI.showBottomSheet(
                                context,
                                borderRadius: 16.0,
                                isScrollControlled: true,
                                child: FundFiltersBottomSheet(),
                              ).then((value) {
                                controller.removeNonSavedFilters();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 12),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                  color: ColorConstants.primaryAppColor
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                '$noOfFilterSaved Filter${noOfFilterSaved > 1 ? 's' : ''} Applied',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: ColorConstants.primaryAppColor,
                                    ),
                              ),
                            ),
                          ),
                        if (isSortingApplied)
                          InkWell(
                            onTap: () {
                              CommonUI.showBottomSheet(
                                context,
                                borderRadius: 16.0,
                                isScrollControlled: true,
                                child: FundFiltersBottomSheet(
                                    filterMode: FilterMode.sort),
                              ).then((value) {
                                controller.removeNonSavedFilters();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 12, left: 12),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                  color: ColorConstants.primaryAppColor
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    controller.sortBy == SortBy.ascending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: ColorConstants.primaryAppColor,
                                  ),
                                  SizedBox(width: 6),
                                  // Icon(Icons.arrow, color: ColorConstants.primaryAppColor),
                                  Text(
                                    '${controller.sortingSaved.split("_").join(" ")}'
                                        .toTitleCase(),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: ColorConstants.primaryAppColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    FocusScope(
                      child: Focus(
                        onFocusChange: (focus) {},
                        child: Container(
                          margin: const EdgeInsets.only(top: 15.0),
                          decoration: BoxDecoration(
                            color: ColorConstants.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorConstants.searchBarBorderColor,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    ColorConstants.darkBlack.withOpacity(0.1),
                                offset: Offset(0.0, 4.0),
                                spreadRadius: 0.0,
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: SearchBox(
                            textEditingController: controller.searchController,
                            labelText: "Search from 1000+ funds",
                            textColor: ColorConstants.secondaryBlack,
                            customBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 1,
                                color: ColorConstants.searchBarBorderColor,
                              ),
                            ),
                            height: 56,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 6),
                            labelStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  height: 1.4,
                                  color: ColorConstants.secondaryBlack,
                                ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 24,
                              color: ColorConstants.black,
                            ),
                            suffixIcon: controller.searchText.isEmpty
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 20.0,
                                    ),
                                    onPressed: controller.clearSearchBar,
                                  ),
                            onChanged: (text) {
                              if (text != controller.searchText) {
                                controller.onFundSearch(text);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
