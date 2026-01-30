import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class SortList extends StatelessWidget {
  const SortList({Key? key, required this.tag}) : super(key: key);

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<ScreenerController>(
        id: 'filter',
        tag: tag,
        builder: (controller) {
          if (controller.screener?.orderingParams?.choices.isNullOrEmpty ??
              false) {
            return EmptyScreen(
              message: 'No options found',
            );
          }

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By Option
                  _buildSortOrder(context, controller),

                  RadioButtons(
                    spacing: 30,
                    runSpacing: 0,
                    direction: Axis.vertical,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                    itemBuilder: (BuildContext context, value, index) {
                      return Text(
                        value.displayName,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                                fontWeight: FontWeight.w500,
                                color: controller.tempSortSelected == value
                                    ? ColorConstants.black
                                    : ColorConstants.tertiaryBlack),
                      );
                    },
                    items: controller.screener!.orderingParams!.choices!
                        .map((Choice x) => x)
                        .toList(),
                    selectedValue: controller.tempSortSelected,
                    onTap: (value) {
                      controller.updateTempSorting(value);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOrder(BuildContext context, ScreenerController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Text(
            'Sort By',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
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
                  controller.tempSortBy == SortOrder.ascending
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
                  controller.tempSortBy == SortOrder.ascending
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
    );
  }
}
