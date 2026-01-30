import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:core/modules/store/models/fund_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<String> sortingOptions = [
  "1 Year Returns",
  "3 Year Returns",
  "5 Year Returns",
  "Expense Ratio",
  "Exit Load"
];

class FundSortingOptions extends StatelessWidget {
  const FundSortingOptions({Key? key, this.tag}) : super(key: key);

  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      id: 'search',
      builder: (controller) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Sort By',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        controller.changeSortByMode();
                      },
                      child: Row(
                        children: [
                          Text(
                            controller.sortBy == SortBy.ascending
                                ? 'Low to High'
                                : 'High to Low',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                    color: ColorConstants.primaryAppColor,
                                    fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            controller.sortBy == SortBy.ascending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: ColorConstants.primaryAppColor,
                          ),
                          // Image.asset(AllImages().swapIcon, width: 13)
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: RadioButtons(
                    spacing: 25,
                    runSpacing: 0,
                    direction: Axis.vertical,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                    itemBuilder: (BuildContext context, value, index) {
                      return Text(
                        '${controller.fundSortingOptions[index].displayName}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                                fontWeight: FontWeight.w500,
                                color:
                                    controller.currentSelectedSorting == value
                                        ? ColorConstants.black
                                        : ColorConstants.tertiaryBlack),
                      );
                    },
                    items: controller.fundSortingOptions
                        .map((FundSortModel x) => x.name)
                        .toList(),
                    selectedValue: controller.currentSelectedSorting,
                    onTap: (value) {
                      // FocusScope.of(context).unfocus();
                      controller.updateSortingSelected(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
