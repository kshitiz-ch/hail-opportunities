import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TransactionSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      builder: (controller) {
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
          child: SearchBox(
            textEditingController: controller.searchController,
            prefixIcon: Padding(
              padding: EdgeInsets.all(10),
              child: SvgPicture.asset(
                AllImages().searchIcon,
                width: 24,
                height: 24,
              ),
            ),
            suffixIcon: _buildSuffixButtons(controller),
            labelText: controller.isMfTabActive || controller.isPmsTabActive
                ? 'Search clients or schemes...'
                : 'Search clients or policies...',
            textColor: ColorConstants.secondaryBlack,
            customBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 1,
                color: ColorConstants.searchBarBorderColor,
              ),
            ),
            height: 50,
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 6),
            labelStyle: context.headlineSmall!.copyWith(
              height: 1.4,
              color: ColorConstants.secondaryBlack,
            ),
            onChanged: (text) {
              controller.onSearchChanged();
            },
            onTap: () {
              MixPanelAnalytics.trackWithAgentId(
                "search_bar_click",
                screen: 'transactions',
                screenLocation: 'transactions',
              );
            },
            onSubmitted: (text) {
              // if (text.isEmpty) {
              //   controller.clearSearchBar();
              //   controller.getTransactions();
              // }
            },
          ),
        );
      },
    );
  }

  Widget _buildSuffixButtons(TransactionController controller) {
    if (controller.searchController.text.isNotNullOrEmpty) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          size: 20.0,
        ),
        onPressed: () {
          controller.searchController.clear();
          controller.onSearchChanged();
        },
      );
    }

    return SizedBox.shrink();
  }
}
