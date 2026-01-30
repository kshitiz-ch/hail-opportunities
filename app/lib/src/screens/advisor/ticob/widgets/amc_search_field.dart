import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AmcSearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      builder: (controller) {
        final style =
            Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                );
        return SearchBox(
          hintText: 'Search AMCs (${controller.amcList.length})',
          labelStyle: style,
          contentPadding: EdgeInsets.all(8),
          textColor: ColorConstants.black,
          prefixIcon: IconButton(
            icon: SvgPicture.asset(
              AllImages().searchIcon,
              width: 20,
              height: 20,
            ),
            onPressed: null,
          ),
          customBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorConstants.borderColor),
          ),
          onChanged: (value) {
            controller.searchAmc(value);
          },
        );
      },
    );
  }
}
