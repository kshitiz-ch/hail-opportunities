import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class FundSearchSection extends StatelessWidget {
  const FundSearchSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GetBuilder<ClientTrackerSwitchController>(
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
              textEditingController: controller.switchFundSearchController,
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: ColorConstants.tertiaryGrey,
              ),
              suffixIcon: controller.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20.0,
                      ),
                      onPressed: controller.clearSearchBar,
                    ),
              labelText: 'Search by fund name',
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
              labelStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        height: 1.4,
                        color: ColorConstants.secondaryBlack,
                      ),
              onChanged: (text) {
                if (text != controller.searchQuery) {
                  controller.onFundSearch(text);
                }
              },
              onSubmitted: (text) {
                if (text.isEmpty) controller.clearSearchBar();
              },
            ),
          );
        },
      ),
    );
  }
}
