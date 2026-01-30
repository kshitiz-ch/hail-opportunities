import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_transaction_filter_bottomsheet.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TicobSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.searchBarBorderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.darkBlack.withOpacity(0.1),
            offset: Offset(0.0, 4.0),
            spreadRadius: 0.0,
            blurRadius: 10.0,
          ),
        ],
      ),
      child: _buildSearchBar(context),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GetBuilder<TicobController>(
      builder: (controller) {
        return SearchBox(
          // focusNode: controller.searchBarFocusNode,
          textEditingController: controller.searchController,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: SvgPicture.asset(
              AllImages().searchIcon,
              width: 20,
              height: 20,
            ),
          ),
          suffixIcon: _buildSuffixButtons(context, controller),
          labelText: 'Search by Name & CRN',
          textColor: ColorConstants.secondaryBlack,
          customBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 1,
              color: ColorConstants.searchBarBorderColor,
            ),
          ),
          height: 48,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          labelStyle:
              Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    height: 1.4,
                    color: ColorConstants.secondaryBlack,
                  ),
          onChanged: (text) {
            if (text != controller.searchText) {
              controller.searchText = text;
              controller.update();
              controller.search();
            }
          },
          onSubmitted: (text) {},
        );
      },
    );
  }

  Widget _buildSuffixButtons(BuildContext context, TicobController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.searchText.isNotNullOrEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              size: 20.0,
            ),
            onPressed: () {
              controller.clearSearchBar();
              controller.fetchData();
            },
          ),
        if (controller.isTransactionTabSelected)
          CommonUI.buildProfileDataSeperator(
            height: 20,
            width: 1,
            color: ColorConstants.borderColor,
          ),
        if (controller.isTransactionTabSelected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () {
                controller.tempTransactionFilter =
                    Map.from(controller.savedTransactionFilter);
                controller.filteredAmcList = List.from(controller.amcList);
                CommonUI.showBottomSheet(
                  context,
                  child: TicobTransactionFilterBottomSheet(),
                  isScrollControlled: true,
                );
              },
              child: Stack(
                children: [
                  Image.asset(
                    AllImages().fundFilterIcon,
                    height: 14,
                    width: 14,
                    color: ColorConstants.primaryAppColor,
                  ),
                  GetBuilder<TicobController>(
                    builder: (controller) {
                      final isFilterApplied = controller
                          .savedTransactionFilter.values
                          .any((element) => element.isNotNullOrEmpty);
                      if (isFilterApplied) {
                        return CommonUI.buildRedDot(rightOffset: 0);
                      }
                      return SizedBox();
                    },
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}
