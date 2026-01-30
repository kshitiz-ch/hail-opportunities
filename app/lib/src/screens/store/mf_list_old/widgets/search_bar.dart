import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({Key? key, this.tag, this.hint}) : super(key: key);

  final String? tag;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundsController>(
      tag: tag,
      global: true,
      id: 'search',
      builder: (controller) {
        // int noOfFilterSaved = controller.filtersSaved.entries.length +
        //     (controller.minAmountFilter > 0 ? 1 : 0);
        // bool isFiltersSaved = noOfFilterSaved > 0;
        // bool isSortingApplied =
        //     controller.sortingSaved.isNotNullOrEmpty;

        return FocusScope(
          child: Focus(
            onFocusChange: (focus) {
              if (focus) {}
            },
            child: Container(
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
                labelText: hint ?? "Search from 1000+ funds",
                textColor: ColorConstants.secondaryBlack,
                customBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    width: 1,
                    color: ColorConstants.searchBarBorderColor,
                  ),
                ),
                height: 56,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 18, horizontal: 6),
                labelStyle:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          height: 1.4,
                          color: ColorConstants.secondaryBlack,
                        ),
                prefixIcon: new IconButton(
                  icon: SvgPicture.asset(
                    AllImages().searchIcon,
                    width: 24,
                    height: 24,
                  ),
                  onPressed: null,
                ),
                suffixIcon: controller.searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20.0,
                        ),
                        onPressed: controller.clearSearchBar,
                      ),
                onChanged: (text) {
                  if (text != controller.searchText) {
                    controller.onFundSearch(text);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
