import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:flutter/material.dart';

class GridData extends StatelessWidget {
  // Fields
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? customSubtitle;
  final double? gap;

  const GridData({
    Key? key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.customSubtitle,
    this.gap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleStyle ??
                Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(
            height: gap ?? 3,
          ),
          if (customSubtitle != null)
            customSubtitle!
          else
            Text(
              subtitle.isNotNullOrEmpty ? subtitle! : '-',
              style: subtitleStyle ??
                  Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
