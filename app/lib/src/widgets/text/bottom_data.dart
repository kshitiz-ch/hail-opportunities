import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

enum BottomDataAlignment { left, center, right }

class BottomData extends StatelessWidget {
  final String? title;
  final Widget? customTitle;
  final Widget? customSubtitle;
  final String? subtitle;
  final int? flex;
  final BottomDataAlignment align;
  final double titleSize;
  final double subtitleSize;
  final bool isHighlight;
  final double verticalGap;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const BottomData({
    Key? key,
    this.title,
    this.customTitle,
    this.subtitle,
    this.customSubtitle,
    this.flex,
    this.align = BottomDataAlignment.center,
    this.titleSize = 14,
    this.subtitleSize = 12,
    this.isHighlight = false,
    this.verticalGap = 1,
    this.titleStyle,
    this.subtitleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = titleStyle ??
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontSize: titleSize,
              fontWeight: FontWeight.w500,
              color:
                  isHighlight ? ColorConstants.primaryAppColor : Colors.black,
            );
    final subtitleTextStyle = subtitleStyle ??
        subtitleStyle ??
        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.secondaryBlack,
              height: 1.4,
              fontSize: subtitleSize,
            );
    return Expanded(
      flex: flex ?? 1,
      child: Container(
        child: Column(
          crossAxisAlignment: align == BottomDataAlignment.left
              ? CrossAxisAlignment.start
              : align == BottomDataAlignment.right
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.center,
          children: [
            // Title
            Column(
              // TODO: Change this logic later
              crossAxisAlignment: customSubtitle != null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (customTitle != null)
                  customTitle!
                else
                  Text(
                    title ?? '-',
                    textAlign: align == BottomDataAlignment.left
                        ? TextAlign.start
                        : align == BottomDataAlignment.right
                            ? TextAlign.end
                            : TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: titleTextStyle,
                  ),

                SizedBox(
                  height: verticalGap,
                ),

                // Subtitle
                if (customSubtitle != null)
                  customSubtitle!
                else
                  Text(
                    subtitle ?? '-',
                    // textAlign: TextAlign.left,
                    textAlign: align == BottomDataAlignment.left
                        ? TextAlign.start
                        : align == BottomDataAlignment.right
                            ? TextAlign.end
                            : TextAlign.center,
                    style: subtitleTextStyle,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
