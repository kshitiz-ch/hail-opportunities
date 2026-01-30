import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SortList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<ClientListController>(
        id: 'filter',
        builder: (controller) {
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
                    textStyle: context.headlineSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                    itemBuilder: (context, value, index) {
                      return Text(
                        value,
                        style: context.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: controller.tempSortSelected == value
                                ? ColorConstants.black
                                : ColorConstants.tertiaryBlack),
                      );
                    },
                    items: controller.sortingMap.keys.toList(),
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

  Widget _buildSortOrder(
      BuildContext context, ClientListController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Text(
            'Sort By',
            style: context.headlineSmall!.copyWith(
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
                  style: context.headlineSmall!.copyWith(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
