import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(19.0, 0.0, 20.0, 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GetBuilder<MFPortfoliosController>(
              id: 'search',
              builder: (controller) {
                return SearchBox(
                  textEditingController: controller.searchController,
                  labelText: "Search for Products & Companies",
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: ColorConstants.black,
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
                      controller.searchText = text;
                      controller.search(text);
                    }
                  },
                  onSubmitted: (text) {
                    if (text.isEmpty) controller.clearSearchBar();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              iconSize: 32.0,
              color: ColorConstants.black,
              onPressed: () {},
              icon: Icon(Icons.filter_list_rounded),
            ),
          )
        ],
      ),
    );
  }
}
