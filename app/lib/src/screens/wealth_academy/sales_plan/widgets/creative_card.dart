import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/video_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';

class CreativeCard extends StatelessWidget {
  final CreativeNewModel? creativeModel;
  final Function? onTap;

  const CreativeCard({Key? key, this.creativeModel, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    child: CachedNetworkImage(
                      imageUrl: creativeModel!.type == "video"
                          ? creativeModel!.url!.youtubeThumbnailUrl
                          : creativeModel!.url!,
                      fit: SizeConfig().isTabletDevice
                          ? BoxFit.contain
                          : BoxFit.fitHeight,
                      height: 130,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                if (creativeModel!.type == "video")
                  Positioned.fill(
                    child: Center(
                      child: Image.asset(
                        AllImages().playIcon,
                        height: 45,
                        width: 45,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      creativeModel!.type == 'video'
                          ? AllImages().videoPlaceHolderIcon
                          : AllImages().imagePlaceholderIcon,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    creativeModel!.title ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          color: ColorConstants.black,
                        ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: InkWell(
                onTap: () {
                  shareImage(
                    context: context,
                    creativeUrl: creativeModel!.url,
                    disableDownload: creativeModel!.type != "image",
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share,
                      color: ColorConstants.primaryAppColor,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Share',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.primaryAppColor,
                          ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
