import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/demat_select_client_controller.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:app/src/controllers/showcase/showcase_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarSection extends StatelessWidget {
  SearchBarSection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematSelectClientController>(builder: (controller) {
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
                  onPressed: controller.refetchRecentClients,
                ),
          labelText: 'Search by number, name or email',
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
    });
  }
}
