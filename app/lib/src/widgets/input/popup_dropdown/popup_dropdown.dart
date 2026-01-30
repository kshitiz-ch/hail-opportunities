import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'popup_dropdown_menu.dart';

class PopUpDropdown extends StatelessWidget {
  const PopUpDropdown({
    Key? key,
    this.items,
    this.selectedValue,
    this.searchController,
    this.hint,
    this.onChanged,
  }) : super(key: key);

  final List<String?>? items;
  final String? hint;
  final String? selectedValue;
  final void Function(String)? onChanged;
  final TextEditingController? searchController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // initiate screen loader
            if (searchController != null) {
              searchController!.text = '';
            }

            AutoRouter.of(context).pushNativeRoute(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => PopUpDropdownMenu(
                  items: items,
                  onChanged: (value, {index}) {
                    if (value.isNotNullOrEmpty) {
                      onChanged!(value!);
                    }
                  },
                  label: hint,
                  selectedValue: selectedValue,
                  searchController: searchController,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorConstants.borderColor,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Text(
                    selectedValue.isNotNullOrEmpty ? selectedValue! : hint!,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            fontSize: 13,
                            color: selectedValue.isNullOrEmpty
                                ? ColorConstants.secondaryBlack
                                : ColorConstants.black),
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.expand_more,
                  size: 20,
                  color: ColorConstants.borderColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
