import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  // Fields
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final String trailingText;
  final Function? onTraiClick;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? trailingTextStyle;

  // Constructor
  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailingText = 'View All',
    this.onTraiClick,
    this.padding = const EdgeInsets.fromLTRB(24.0, 16.0, 19.0, 0.0),
    this.titleStyle,
    this.trailingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading Widget
              leading != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0.0,
                        0.0,
                        8.0,
                        0.0,
                      ),
                      child: SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: leading,
                      ),
                    )
                  : SizedBox(),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        title ?? '',
                        style: titleStyle ??
                            Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing Widget
              if (onTraiClick != null)
                InkWell(
                  onTap: onTraiClick as void Function()?,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      trailingText,
                      style: trailingTextStyle ??
                          Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                color: ColorConstants.primaryAppColor,
                                fontWeight: FontWeight.w400,
                              ),
                    ),
                  ),
                )
            ],
          ),

          // Subtitle
          subtitle != null
              ? Padding(
                  padding: leading != null
                      ? const EdgeInsets.only(left: 30.0, right: 26.0)
                      : const EdgeInsets.only(right: 26.0),
                  child: Text(
                    subtitle ?? '',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontSize: 12.0,
                          color: ColorConstants.secondaryBlack,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
