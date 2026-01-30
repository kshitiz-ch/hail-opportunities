import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String)? onChanged;
  final String hintText;
  final Function onClear;

  const NewSearchBar({
    super.key,
    required this.searchController,
    this.onChanged,
    required this.hintText,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryGrey,
          fontWeight: FontWeight.w400,
          height: 1.4,
        );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ColorConstants.borderColor),
    );
    return TextField(
      controller: searchController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      autofocus: false,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(
            "[0-9a-zA-Z ]",
          ),
        ),
        NoLeadingSpaceFormatter()
      ],
      // focusNode: focusNode,
      style: style,
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: SvgPicture.asset(
            AllImages().searchIcon,
            width: 24,
            height: 24,
          ),
          onPressed: null,
        ),
        suffixIcon: searchController.text.isNullOrEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20.0,
                ),
                onPressed: () {
                  onClear();
                },
              ),
        filled: true,
        fillColor: ColorConstants.lotionColor,
        hintText: hintText,
        hintStyle: style,
        constraints: BoxConstraints.loose(Size.fromHeight(48)),
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
      ),
      onChanged: (text) {
        onChanged!(text);
      },
    );
  }
}
