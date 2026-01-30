import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/pms/pms_product_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarSectionPMS extends StatelessWidget {
  SearchBarSectionPMS({
    Key? key,
  }) : super(key: key);

  final PMSProductController pmsProductController =
      Get.find<PMSProductController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(19.0, 0.0, 20.0, 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GetBuilder<PMSProductController>(
              // id: 'search',
              init: pmsProductController,
              builder: (controller) {
                return SearchBox(
                  textEditingController: controller.textEditingController,
                  labelText: "Search for Products & Companies",
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: ColorConstants.black,
                  ),
                  suffixIcon: controller.textEditingController!.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20.0,
                          ),
                          onPressed: () {
                            controller.textEditingController!.clear();
                          }),
                  onChanged: (text) {
                    // controller.searchText = text;
                    // controller.search(text);
                  },
                  onSubmitted: (text) {
                    // if (text.isEmpty) controller.clearSearchBar();
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
