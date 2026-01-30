import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/soa_download_controller.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SoaAmcSearchBar extends StatelessWidget {
  final String? tag;

  const SoaAmcSearchBar({Key? key, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SOADownloadController>(
      tag: tag,
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
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
            // focusNode: controller.searchBarFocusNode,
            textEditingController: controller.amcSearchController,
            prefixIcon: Padding(
              padding: EdgeInsets.all(10),
              child: SvgPicture.asset(
                AllImages().searchIcon,
                width: 24,
                height: 24,
              ),
            ),
            suffixIcon: _buildSuffixButtons(controller),
            labelText: 'Search for a AMC',
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
            onChanged: (text) {
              controller.searchAmc(text);
            },
          ),
        );
      },
    );
  }

  Widget _buildSuffixButtons(SOADownloadController controller) {
    if (controller.amcSearchController.text.isNotNullOrEmpty) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          size: 20.0,
        ),
        onPressed: () {
          controller.clearSearchBar();
        },
      );
    }
    return SizedBox.shrink();
  }
}
