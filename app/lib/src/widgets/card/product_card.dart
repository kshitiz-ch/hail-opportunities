import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

enum CardShadowSize { none, small, large }

class ProductCard extends StatelessWidget {
  // Fields
  final Widget? leading;
  final ImageProvider<Object>? leadingImage;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  final String? description;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final CardShadowSize shadowSize;
  final bool showBorder;
  final bool showNewTag;
  final bool isWealthyProduct;
  final VoidCallback? onPressed;
  final List<String>? middleData;

  /// Typically a [BottomData] or [Spacer] widget
  final List<Widget>? bottomData;

  // Constructor
  const ProductCard({
    Key? key,
    this.leading,
    this.leadingImage,
    this.trailing,
    this.title,
    this.subtitle,
    this.description,
    this.padding = const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 16.0),
    this.margin = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
    this.shadowSize = CardShadowSize.none,
    this.showBorder = true,
    this.showNewTag = false,
    this.isWealthyProduct = false,
    this.onPressed,
    this.middleData,
    this.bottomData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, shadowSize == CardShadowSize.none ? 0.0 : 3.0),
            spreadRadius: 0.0,
            blurRadius: shadowSize == CardShadowSize.none
                ? 0.0
                : shadowSize == CardShadowSize.small
                    ? 7.0
                    : 24.0,
          ),
        ],
      ),
      child: Card(
        elevation: 0.0,
        color: ColorConstants.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: showBorder
              ? BorderSide(color: Color(0xFFEEF0FD))
              : BorderSide.none,
        ),
        child: InkWell(
          splashColor: Color(0xFFEEF0FD),
          onTap: onPressed,
          child: Stack(
            children: [
              Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: subtitle == null && leading != null
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        // Leading Widget
                        if (leading != null || leadingImage != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              0.0,
                              2.0,
                              10.0,
                              2.0,
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 18.0,
                              foregroundImage: leadingImage,
                              child: leading,
                            ),
                          ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Padding(
                                padding: subtitle != null
                                    ? const EdgeInsets.symmetric(vertical: 4.0)
                                    : const EdgeInsets.all(0.0),
                                child: Text(
                                  title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineMedium!
                                      .copyWith(
                                        fontSize:
                                            subtitle == null ? 17.0 : 16.0,
                                        height: 1.2,
                                      ),
                                ),
                              ),

                              // Subtitle
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 26.0),
                                  child: Text(
                                    subtitle ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleMedium!
                                        .copyWith(
                                          fontSize: 11.5,
                                          color: Color(0xFF979797),
                                          fontWeight: FontWeight.w300,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Trailing Widget
                        trailing ?? SizedBox(),
                      ],
                    ),

                    // Description
                    if (description != null)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleMedium!
                                .copyWith(
                                  fontSize: 12,
                                  color: ColorConstants.tertiaryBlack,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                      ),

                    // Middle Data
                    if (middleData != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 80,
                          child: OverflowView.flexible(
                            spacing: -9,
                            children: <Widget>[
                              for (int i = 0; i < middleData!.length; i++)
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: NetworkImage(middleData![i]),
                                ),
                            ],
                            builder: (_, remaining) => Padding(
                              padding: const EdgeInsets.only(left: 14.0),
                              child: Text(
                                remaining > 0 ? '+$remaining' : '',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: ColorConstants.tertiaryBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bottom Data
                    // TODO: Try with assorted_layout_widgets package: https://pub.dev/packages/assorted_layout_widgets
                    if (bottomData != null)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: bottomData!.length > 3
                              ? bottomData!.sublist(0, 3)
                              : bottomData!),
                    if (bottomData != null && bottomData!.length > 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: bottomData!.sublist(3, 6),
                      )
                  ],
                ),
              ),

              // New Tag
              if (showNewTag)
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF532B8E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      "NEW",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                            color: ColorConstants.white,
                            height: 1.4,
                          ),
                    ),
                  ),
                ),
              if (isWealthyProduct)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          hexToColor("#FF35A4"),
                          hexToColor("#FDA18D"),
                        ],
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                        transform: GradientRotation(90),
                      ),
                      // color: Color(0xFF532B8E),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      "WEALTHY SELECT",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodySmall!
                          .copyWith(
                              color: ColorConstants.white,
                              height: 1.4,
                              fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
