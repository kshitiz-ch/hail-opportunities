import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:flutter/material.dart';

class FilterSortSelected extends StatelessWidget {
  const FilterSortSelected({
    Key? key,
    required this.controller,
    this.showAllAmcFunds = false,
  }) : super(key: key);

  final ScreenerController controller;
  final bool showAllAmcFunds;

  @override
  Widget build(BuildContext context) {
    if (controller.categorySelected == null &&
        controller.amcSelected == null &&
        controller.sortSelected == null) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          // spacing: 10,
          // runSpacing: 10,
          children: [
            // if (controller.categorySelected != null)
            //   _buildFilterSelectTab(
            //     context,
            //     text: controller.categorySelected!.displayName!,
            //     onTap: controller.removeCategorySelected,
            //   ),
            // if (controller.amcSelected != null)
            //   _buildFilterSelectTab(
            //     context,
            //     text: controller.amcSelected!.displayName!,
            //     // In AMC Funds List, Selected Amc option cannot be removed
            //     onTap: showAllAmcFunds ? null : controller.removeAmcSelected,
            //   ),
            if (controller.sortSelected != null)
              _buildFilterSelectTab(
                context,
                text: controller.sortSelected!.displayName!,
                onTap: controller.removeSortSelected,
                isSort: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSelectTab(BuildContext context,
      {required String text,
      required void Function()? onTap,
      bool isSort = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      constraints: BoxConstraints(minWidth: 50),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: ColorConstants.secondaryAppColor,
        border: Border.all(
          color: ColorConstants.primaryAppColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSort)
            Text(
              'Sort By: ',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.primaryAppColor,
                  fontStyle: FontStyle.italic),
            ),
          Text(
            text,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.primaryAppColor),
          ),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.close,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
            )
        ],
      ),
    );
  }
}
