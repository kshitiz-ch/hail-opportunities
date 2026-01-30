import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarSection extends StatefulWidget {
  final Client? lastSelectedClient;

  SearchBarSection({Key? key, this.lastSelectedClient}) : super(key: key);

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
    return GetBuilder<SelectClientController>(
      id: GetxId.searchClient,
      init:
          SelectClientController(lastSelectedClient: widget.lastSelectedClient),
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
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
            focusNode: focusNode,
            textEditingController: controller.searchController,
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
            labelText: 'Search by number, name, email or CRN',
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
            onChanged: (query) {
              bool isQueryChanged = query != controller.searchQuery;

              if (isQueryChanged) {
                controller.onClientSearch(query);
              }
            },
          ),
        );
      },
    );
  }
}
