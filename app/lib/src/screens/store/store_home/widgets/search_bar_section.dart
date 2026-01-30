import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/controllers/store/store_search_controller.dart';
import 'package:app/src/screens/store/store_home/widgets/search_bar_show_case.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SearchBarSection extends StatefulWidget {
  final String? placeholder;
  final String? tag;

  SearchBarSection({
    this.placeholder,
    Key? key,
    this.tag,
  }) : super(key: key);

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
  FocusNode? focusNode;
  Key showCaseWrapperKey = UniqueKey();

  void initState() {
    focusNode = new FocusNode();
    focusNode!.addListener(() => LogUtil.printLog(
        'focusNode updated: hasFocus: ${focusNode!.hasFocus}'));
    super.initState();
  }

  @override
  void dispose() {
    focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GetBuilder<StoreSearchController>(
            id: 'search',
            tag: widget.tag,
            global: widget.tag != null ? false : true,
            init: Get.find<StoreSearchController>(tag: widget.tag),
            dispose: (_) {
              if (Get.isRegistered<StoreSearchController>(tag: widget.tag)) {
                StoreSearchController storeSearchController =
                    Get.find<StoreSearchController>(tag: widget.tag);
                WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) {
                    storeSearchController.clearSearchBar();
                  },
                );
              }
            },
            builder: (storeSearchController) {
              ShowCaseController? showCaseController;
              if (Get.isRegistered<ShowCaseController>()) {
                showCaseController = Get.find<ShowCaseController>();
              }

              if (showCaseController != null &&
                  showCaseController.activeShowCaseId ==
                      showCaseIds.StoreSearchBar.id) {
                showCaseController.setShowCaseVisibleCurrently(true);
                return SearchBarShowCase(
                  showCaseWrapperKey: showCaseWrapperKey,
                  focusNode: focusNode,
                  showCaseController: showCaseController,
                  storeSearchController: storeSearchController,
                  onClickFinished: () {
                    storeSearchController.update(['search']);
                  },
                );
              } else {
                return SearchBarContainer(
                  focusNode: focusNode,
                  storeSearchController: storeSearchController,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class SearchBarContainer extends StatelessWidget {
  const SearchBarContainer({
    Key? key,
    required this.focusNode,
    this.storeSearchController,
  }) : super(key: key);

  final FocusNode? focusNode;
  final StoreSearchController? storeSearchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: ColorConstants.white,
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
              color: ColorConstants.secondaryBlack,
            ),
        height: 56,
        textEditingController: storeSearchController!.searchController,
        fillColor: ColorConstants.white,
        labelText: 'Search for Products & Companies',
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
        suffixIcon: storeSearchController!.searchController!.text.isNullOrEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20.0,
                ),
                onPressed: storeSearchController!.clearSearchBar,
              ),
        onChanged: (text) {
          if (text != storeSearchController!.searchText) {
            storeSearchController!.searchText = text;
            storeSearchController!.searchProducts(text);
          }
        },
        onSubmitted: (text) {
          if (text.isEmpty) storeSearchController!.clearSearchBar();
        },
      ),
    );
  }
}
