import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_lobby_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_search_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({
    Key? key,
    required this.tag,
  }) : super(key: key);

  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MfSearchController>(
      init: MfSearchController(),
      tag: tag,
      builder: (controller) {
        return SearchBox(
          textEditingController: controller.searchController,
          focusNode: controller.focusNode,
          labelText: "Search Mutual Funds",
          textColor: ColorConstants.secondaryBlack,
          customBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 1,
              color: ColorConstants.searchBarBorderColor,
            ),
          ),
          height: 56,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          labelStyle:
              Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    height: 1.4,
                    color: ColorConstants.secondaryBlack,
                  ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(10),
            child: SvgPicture.asset(
              AllImages().searchIcon,
              width: 24,
              height: 24,
            ),
          ),
          suffixIcon: controller.searchText.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20.0,
                    color: ColorConstants.tertiaryBlack,
                  ),
                  onPressed: controller.clearSearchBar,
                ),
          onTap: () {
            MixPanelAnalytics.trackWithAgentId(
              "search_mutual_fund",
              screen: 'store',
              screenLocation: 'mutual_fund',
            );
          },
          onChanged: (text) {
            if (text != controller.searchText) {
              controller.onFundSearch(text);
            }
          },
        );
      },
    );
  }
}
