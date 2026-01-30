import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'resources_filter_list.dart';
import 'resources_sort_list.dart';

class ResourcesFilterSortBottomSheet extends StatelessWidget {
  const ResourcesFilterSortBottomSheet({
    Key? key,
    this.hideFilters = false,
  }) : super(key: key);

  final bool hideFilters;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppResourcesController>(
      builder: (controller) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hideFilters)
                _buildSortTitle(context)
              else
                _buildFilterSortTabs(
                  context,
                  controller,
                ),

              _buildClearAllButton(context, controller),

              if (!hideFilters &&
                  controller.currentFilterMode == FilterMode.filter)
                ResourcesFilterList()
              else
                ResourcesSortList(),

              // Filter action buttons
              _buildActionButtons(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 10, left: 30),
      child: Text(
        'Sort By',
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildFilterSortTabs(
      BuildContext context, AppResourcesController controller) {
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
      BuildContext context, AppResourcesController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 30, bottom: 7, top: 10),
        child: InkWell(
          onTap: () {
            controller.clearFilterAndSort();
            AutoRouter.of(context).popForced();
          },
          child: Text(
            'Clear all',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.primaryAppColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTab(BuildContext context,
      {required AppResourcesController controller,
      required FilterMode fundFilterMode,
      required bool isActive}) {
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
      BuildContext context, AppResourcesController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            context,
            text: "Clear",
            isPrimaryButton: false,
            onPressed: () async {
              controller.clearFilterAndSort();
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
            onPressed: () async {
              controller.applyFilterAndSort();
              AutoRouter.of(context).popForced();
            },
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(context,
      {String? text, bool isPrimaryButton = false, Function? onPressed}) {
    return ActionButton(
      responsiveButtonMaxWidthRatio: 0.4,
      text: text,
      bgColor: isPrimaryButton
          ? ColorConstants.primaryAppColor
          : ColorConstants.secondaryAppColor,
      margin: EdgeInsets.zero,
      onPressed: () async {
        onPressed!();
      },
      textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
            color: !isPrimaryButton
                ? ColorConstants.primaryAppColor
                : ColorConstants.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
