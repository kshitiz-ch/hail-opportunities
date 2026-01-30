import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/advisor/revenue_sheet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class RevenueSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RevenueSheetController>(
      id: GetxId.clientWiseRevenue,
      builder: (controller) {
        final style = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.tertiaryGrey,
              fontWeight: FontWeight.w400,
              height: 1.4,
            );
        final inputBorder = OutlineInputBorder(
          borderSide: BorderSide(color: ColorConstants.borderColor),
        );
        return TextField(
          controller: controller.searchController,
          onTap: () {
            MixPanelAnalytics.trackWithAgentId(
              "search_bar",
              screen: 'revenue_sheet',
              screenLocation: 'revenue_listing',
            );
          },
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          autofocus: false,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(
                "[0-9a-zA-Z ]",
              ),
            ),
            NoLeadingSpaceFormatter()
          ],
          // focusNode: focusNode,
          style: style,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: SvgPicture.asset(
                AllImages().searchIcon,
                width: 24,
                height: 24,
              ),
              onPressed: null,
            ),
            suffixIcon: controller.searchController.text.isNullOrEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20.0,
                    ),
                    onPressed: () {
                      controller.clearSearchBar();
                      controller.getClientWiseRevenue();
                    },
                  ),
            filled: true,
            fillColor: ColorConstants.lotionColor,
            hintText: 'Search Revenue by Name or Email',
            hintStyle: style,
            constraints: BoxConstraints.loose(Size.fromHeight(48)),
            border: inputBorder,
            focusedBorder: inputBorder,
            enabledBorder: inputBorder,
          ),
          onChanged: (text) {
            if (text != controller.searchText) {
              controller.searchText = text;
              controller.searchRevenueSheet();
            }
          },
        );
      },
    );
  }
}
