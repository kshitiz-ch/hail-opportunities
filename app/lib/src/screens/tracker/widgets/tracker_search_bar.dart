import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/tracker/tracker_list_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackerSearchBar extends StatelessWidget {
  const TrackerSearchBar(
      {Key? key, this.onClear, this.onSubmitted, this.onChanged})
      : super(key: key);
  final Function? onClear;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackerListController>(
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
            textEditingController: controller.searchController,
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: ColorConstants.tertiaryGrey,
            ),
            suffixIcon: controller.searchController!.text.isNullOrEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20.0,
                    ),
                    onPressed: onClear as void Function()?,
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
            onTap: () {},
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        );
      },
    );
  }
}
