import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/home/universal_search_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SearchBarSection extends StatelessWidget {
  SearchBarSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UniversalSearchController>(
      dispose: (_) {
        if (Get.isRegistered<UniversalSearchController>()) {
          UniversalSearchController universalSearchController =
              Get.find<UniversalSearchController>();
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              universalSearchController.clearSearchBar();
            },
          );
        }
      },
      builder: (controller) {
        return SearchBarContainer(
          focusNode: controller.searchBarFocusNode,
          controller: controller,
        );
      },
    );
  }
}

class SearchBarContainer extends StatelessWidget {
  const SearchBarContainer({
    Key? key,
    required this.focusNode,
    this.controller,
  }) : super(key: key);

  final FocusNode? focusNode;
  final UniversalSearchController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
        focusNode: focusNode,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 6),
        labelStyle: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              height: 1.4,
              color: ColorConstants.tertiaryBlack,
            ),
        height: 56,
        textEditingController: controller!.searchController,
        fillColor: ColorConstants.white,
        labelText: 'Tap to Search',
        textColor: ColorConstants.secondaryBlack,
        customBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 1,
            color: Color(0xFFEEE7FF),
          ),
        ),
        prefixIcon: new IconButton(
          icon: SvgPicture.asset(
            AllImages().searchIcon,
            width: 24,
            height: 24,
          ),
          onPressed: null,
        ),
        suffixIcon: controller!.searchController!.text.isNullOrEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20.0,
                ),
                onPressed: controller!.clearSearchBar,
              ),
        onChanged: (text) {
          if (text != controller!.searchText) {
            controller!.searchText = text;
            controller!.universalSearch(text);
          }
        },
        onTap: () {
          MixPanelAnalytics.trackWithAgentId(
            "search_clicked",
            screen: 'universal_search',
            screenLocation: 'universal_search',
          );
        },
        onSubmitted: (text) {
          if (text.isEmpty) controller!.clearSearchBar();
        },
      ),
    );
  }
}
