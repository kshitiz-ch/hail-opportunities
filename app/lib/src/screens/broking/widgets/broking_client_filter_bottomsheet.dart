import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrokingClientFilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingController>(
      id: GetxId.filter,
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Clients By',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                  ),
                  CommonUI.bottomsheetCloseIcon(context)
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: RadioButtons(
                  spacing: 30,
                  runSpacing: 80,
                  direction: Axis.vertical,
                  items: controller.clientFilterPayload.keys.toList(),
                  selectedValue: controller.selectedFilter,
                  onTap: (filterSelected) {
                    controller.updateClientFilter(filterSelected);
                  },
                  itemBuilder: (context, value, index) {
                    return Text(
                      '$value',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .displayMedium!
                          .copyWith(
                            fontSize: 16,
                            color: controller.selectedFilter == value
                                ? ColorConstants.black
                                : ColorConstants.tertiaryBlack,
                          ),
                    );
                  },
                ),
              ),
            ),
            _buildFilterCTA(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildFilterCTA(BuildContext context, BrokingController controller) {
    final style = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: ColorConstants.primaryAppColor,
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              text: 'Clear All',
              margin: EdgeInsets.zero,
              bgColor: ColorConstants.secondaryButtonColor,
              textStyle: style,
              onPressed: () {
                if (controller.savedFilter.isNotNullOrEmpty) {
                  controller.clearClientFilter();
                  controller.getBrokingOnboardingData();
                }
                AutoRouter.of(context).popForced();
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ActionButton(
              margin: EdgeInsets.zero,
              text: 'Apply',
              textStyle: style?.copyWith(color: ColorConstants.white),
              onPressed: () {
                if (controller.savedFilter != controller.selectedFilter) {
                  controller.applyClientFilter();
                  controller.getBrokingOnboardingData();
                }
                AutoRouter.of(context).popForced();
              },
            ),
          ),
        ],
      ),
    );
  }
}
