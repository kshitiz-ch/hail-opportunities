import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class ProductCardNew extends StatelessWidget {
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final String? title;
  final String? description;
  final Color? bgColor;
  final Function? onTap;
  final double borderRadius;
  final bool showSeparator;

  final TextStyle? titleStyle;
  final int titleMaxLines;
  final TextStyle? descriptionStyle;
  final int descriptionMaxLines;

  final int crossAxisCount;

  /// Typically a [BottomData] or [Spacer] widget
  /// It should be multiple of [crossAxisCount] having a specified flex value
  final List<Widget>? bottomData;
  final Widget? additionalBottomData;

  ProductCardNew({
    Key? key,
    this.leadingWidget,
    this.trailingWidget,
    this.title,
    this.description,
    this.bgColor,
    this.bottomData,
    this.onTap,
    this.borderRadius = 12,
    this.showSeparator = true,
    this.titleStyle,
    this.titleMaxLines = 1,
    this.descriptionStyle,
    this.descriptionMaxLines = 1,
    this.additionalBottomData,
    this.crossAxisCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split List into multiple list of crossAxisCount

    final bottomDataRowCount =
        bottomData != null ? (bottomData!.length / crossAxisCount).round() : 0;

    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        // its height is determined implicitly by its content or parent like CardList
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingWidget != null) leadingWidget!,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? '',
                            maxLines: titleMaxLines,
                            style: titleStyle ??
                                Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                          ),
                          if (description.isNotNullOrEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                description!,
                                maxLines: descriptionMaxLines,
                                style: descriptionStyle ??
                                    Theme.of(context)
                                        .primaryTextTheme
                                        .headlineSmall!
                                        .copyWith(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 12,
                                            color: ColorConstants.tertiaryBlack,
                                            height: 1.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (trailingWidget != null) trailingWidget!,
                ],
              ),
            ),
            if (showSeparator)
              CommonUI.buildProfileDataSeperator(
                width: double.infinity,
                color: ColorConstants.lightGrey,
              ),
            if (bottomData != null && bottomDataRowCount > 0)
              Container(
                margin: EdgeInsets.only(top: 24),
                child: Column(
                  children: List.generate(
                    bottomDataRowCount,
                    (index) => Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: bottomData!.length >= crossAxisCount
                            ? bottomData!.sublist(
                                index * crossAxisCount,
                                (index + 1) * crossAxisCount,
                              )
                            : bottomData!,
                      ),
                    ),
                  ),
                ),
              ),
            if (additionalBottomData != null) additionalBottomData!
          ],
        ),
      ),
    );
  }
}
