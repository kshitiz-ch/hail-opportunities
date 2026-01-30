import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/advisor/models/newsletter_model.dart';
import 'package:flutter/material.dart';

class NewsLetterCommonUI {
  static Widget buildTabCard({
    required String image,
    required String title,
    required String subtitle,
    required BuildContext context,
    bool showNewTag = false,
    Function? onSubscribe,
    Function()? onTap,
  }) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w700,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            );
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFAF5F5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Color(0xffF5EBEB)),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  width: 64,
                  height: 64,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                    title: title,
                    subtitle: subtitle,
                    titleStyle: titleStyle,
                    subtitleStyle: subtitleStyle,
                    gap: 6,
                    subtitleMaxLength: 2,
                    titleSuffixIcon: showNewTag
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: CommonUI.buildNewTag(context),
                          )
                        : null,
                  ),
                )
              ],
            ),
            if (onSubscribe != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CommonUI.buildProfileDataSeperator(
                  color: Color(0xffF5EBEB),
                  width: double.infinity,
                ),
              ),
            if (onSubscribe != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscribe to get this in your email',
                    style: subtitleStyle,
                  ),
                  ClickableText(
                    text: 'Subscribe now',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    textColor: ColorConstants.primaryAppColor,
                    onClick: onSubscribe,
                    suffixIcon: Icon(
                      Icons.notifications,
                      size: 16,
                      color: ColorConstants.primaryAppColor,
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  static Widget buildNewsLetterCard({
    required NewsLetterModel newsLetterModel,
    required BuildContext context,
  }) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w700,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            );
    final placeHolderIcon = Image.asset(
      AllImages().newsletterPlaceholderIcon,
      height: 100,
      width: 120,
      fit: BoxFit.cover,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // news overview
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: CachedNetworkImage(
                imageUrl: newsLetterModel.imageUrl ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => placeHolderIcon,
                placeholder: (_, __) => placeHolderIcon,
                height: 100,
                width: 120,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    newsLetterModel.title ?? '',
                    style: titleStyle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Text(
                      newsLetterModel.description ?? '',
                      style: subtitleStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 14),
        // additional detail
        Row(
          children: [
            SizedBox(
              width: 120,
              // align with image
              child: Row(
                children: [
                  Image.asset(
                    AllImages().newsletterReadIcon,
                    height: 16,
                    width: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${newsLetterModel.readTime} Mins',
                    style: subtitleStyle,
                  ),
                  Center(
                    child: Container(
                      height: 2,
                      width: 2,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstants.tertiaryBlack),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                    ),
                  ),
                  if (newsLetterModel.publishedAt != null)
                    Text(
                      '${newsLetterModel.publishedAt?.day} ${getMonthAbbreviation(newsLetterModel.publishedAt!.month)}',
                      style: subtitleStyle,
                    ),
                ],
              ),
            ),
            SizedBox(width: 16),
            InkWell(
              onTap: () {
                if (newsLetterModel.slug.isNullOrEmpty) {
                  showToast(text: 'This article is not available to share');
                } else {
                  shareText(getNewsLetterShareUrl(newsLetterModel));
                }
              },
              child: Image.asset(
                AllImages().newsletterShareIcon,
                height: 24,
                width: 24,
              ),
            ),
          ],
        )
      ],
    );
  }
}
