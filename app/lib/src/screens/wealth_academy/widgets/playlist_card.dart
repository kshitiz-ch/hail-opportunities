import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/video_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayListCard extends StatelessWidget {
  PlayListCard({
    this.playList,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  final VideoPlayListModel? playList;

  @override
  Widget build(BuildContext context) {
    String? thumbnailUrl = '';
    if (playList!.thumbnail.isNotNullOrEmpty) {
      thumbnailUrl = playList!.thumbnail;
    } else {
      thumbnailUrl = playList!.videos!.first.link!.youtubeThumbnailUrl;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorConstants.primaryCardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 90,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl!,
                    fit: BoxFit.fill,
                    placeholder: (_, __) {
                      return SvgPicture.asset(
                        AllImages().youtubePlaceholderIcon,
                        fit: BoxFit.fill,
                      );
                    },
                    errorWidget: (_, __, ___) {
                      return SvgPicture.asset(
                        AllImages().youtubePlaceholderIcon,
                        fit: BoxFit.fill,
                      );
                    },
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      height: 90,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Text(
                              playList!.videos!.length.toString(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.playlist_play,
                            size: 14,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playList!.title!,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.w500, height: 1.4),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset(AllImages().videoOutlineIcon),
                          SizedBox(width: 3),
                          Text(
                            '${playList!.videos!.length} Videos',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                    fontSize: 12,
                                    color: ColorConstants.tertiaryBlack),
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      if (playList!.duration != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SvgPicture.asset(AllImages().clockOutlineIcon),
                            SizedBox(width: 3),
                            Text(
                              '${playList!.duration} min',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      fontSize: 12,
                                      color: ColorConstants.tertiaryBlack),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Text(
                  //   advisorVideo.description,
                  //   maxLines: 3,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.w400,
                  //     fontSize: 16,
                  //     color: Colors.black54,
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
