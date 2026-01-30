import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/screens/clients/client_list/widgets/filter_list.dart';
import 'package:app/src/screens/clients/client_list/widgets/sort_list.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterSortBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GetBuilder<ClientListController>(
        id: 'filter',
        builder: (controller) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSortTabs(
                  context,
                  controller,
                ),

                _buildClearAllButton(context, controller),

                if (controller.currentFilterMode == FilterMode.filter)
                  FilterList()
                else
                  SortList(),

                // Filter action buttons
                _buildActionButtons(context, controller)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSortTabs(
      BuildContext context, ClientListController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 10),
      child: Row(
        children: [
          _buildHeaderTab(
            context,
            controller: controller,
            fundFilterMode: FilterMode.filter,
            isActive: controller.currentFilterMode == FilterMode.filter,
          ),
          _buildHeaderTab(
            context,
            controller: controller,
            fundFilterMode: FilterMode.sort,
            isActive: controller.currentFilterMode == FilterMode.sort,
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllButton(
      BuildContext context, ClientListController controller) {
    final isEnabled = controller.currentFilterMode == FilterMode.filter
        ? controller.tempFilterListMap.isNotEmpty
        : controller.currentFilterMode == FilterMode.sort
            ? controller.tempSortSelected.isNotNullOrEmpty
            : false;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 30, bottom: 7, top: 10),
        child: InkWell(
          onTap: () {
            controller.clearFilterAndSort();
            AutoRouter.of(context).popForced();
          },
          child: isEnabled
              ? Text(
                  'Clear',
                  style: context.titleLarge!.copyWith(
                    color: ColorConstants.salmonTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : SizedBox(height: 12),
        ),
      ),
    );
  }

  Widget _buildHeaderTab(
    BuildContext context, {
    required ClientListController controller,
    required FilterMode fundFilterMode,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.changeFilterMode(fundFilterMode);
        },
        child: Container(
          padding: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
                color: isActive
                    ? ColorConstants.primaryAppColor
                    : Colors.transparent),
          )),
          child: Text(
            fundFilterMode.name.toTitleCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: isActive
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ClientListController controller) {
    final isEnabled = controller.currentFilterMode == FilterMode.sort
        ? controller.tempSortSelected.isNotNullOrEmpty
        : controller.currentFilterMode == FilterMode.filter
            ? controller.tempFilterListMap.isNotEmpty &&
                controller.tempFilterListMap.entries
                    .every((entry) => entry.value.inputValue.isNotNullOrEmpty)
            : true;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            context,
            text: "Cancel",
            isPrimaryButton: false,
            onPressed: () async {
              AutoRouter.of(context).popForced();
            },
          ),
          SizedBox(
            width: 12,
          ),
          _buildActionButton(
            context,
            text: "Apply",
            isPrimaryButton: true,
            isDisabled: !isEnabled,
            onPressed: () async {
              bool isFieldValueValid = true;
              final isFormFieldMounted =
                  controller.filterFormKey.currentState?.mounted == true;
              if (isFormFieldMounted) {
                isFieldValueValid =
                    controller.filterFormKey.currentState?.validate() == true;
              }
              if (isFieldValueValid) {
                controller.saveFilterAndSort();
                AutoRouter.of(context).popForced();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(
    context, {
    String? text,
    bool isPrimaryButton = false,
    Function? onPressed,
    bool isDisabled = false,
  }) {
    return ActionButton(
      responsiveButtonMaxWidthRatio: 0.4,
      text: text,
      bgColor: isPrimaryButton
          ? ColorConstants.primaryAppColor
          : ColorConstants.secondaryAppColor,
      margin: EdgeInsets.zero,
      isDisabled: isDisabled,
      onPressed: () async {
        onPressed!();
      },
      textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
            color: isDisabled
                ? ColorConstants.tertiaryBlack
                : !isPrimaryButton
                    ? ColorConstants.primaryAppColor
                    : ColorConstants.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
