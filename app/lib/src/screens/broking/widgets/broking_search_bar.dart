import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/controllers/broking/broking_search_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BrokingSearchBar extends StatelessWidget {
  final Function onClearText;
  final Function? onFilterTap;

  BrokingSearchBar({
    Key? key,
    required this.onClearText,
    this.onFilterTap,
  }) : super(key: key);

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
    return GetBuilder<BrokingSearchController>(
      builder: (controller) {
        return SearchBox(
          focusNode: controller.searchBarFocusNode,
          textEditingController: controller.clientSearchController,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: SvgPicture.asset(
              AllImages().searchIcon,
              width: 20,
              height: 20,
            ),
          ),
          suffixIcon: _buildSuffixButtons(context, controller),
          labelText: 'Search for a Client',
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
            if (text != controller.searchClientText) {
              controller.searchClientText = text;
              controller.search();
            }
          },
          onSubmitted: (text) {
            if (text.isEmpty) {
              controller.clearSearchBar();
              onClearText();
            }
          },
        );
      },
    );
  }

  Widget _buildSuffixButtons(
      BuildContext context, BrokingSearchController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.searchClientText.isNotNullOrEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              size: 20.0,
            ),
            onPressed: () {
              controller.clearSearchBar();
              onClearText();
            },
          ),
        if (onFilterTap != null)
          CommonUI.buildProfileDataSeperator(
            height: 20,
            width: 1,
            color: ColorConstants.borderColor,
          ),
        if (onFilterTap != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () {
                onFilterTap!();
              },
              child: Stack(
                children: [
                  Image.asset(
                    AllImages().fundFilterIcon,
                    height: 14,
                    width: 14,
                    color: ColorConstants.primaryAppColor,
                  ),
                  GetBuilder<BrokingController>(
                    id: GetxId.filter,
                    builder: (controller) {
                      if (controller.savedFilter.isNotNullOrEmpty) {
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
