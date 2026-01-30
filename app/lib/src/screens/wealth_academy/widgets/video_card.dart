import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:app/src/utils/video_utils.dart';

class VideoCard extends StatelessWidget {
  VideoCard({
    this.advisorVideo,
    required this.onPressed,
    this.isCurrentVideo = false,
    this.isVideoPlaying = false,
    this.isVideoEnded = false,
  });

  final VoidCallback onPressed;
  final AdvisorVideoModel? advisorVideo;
  final bool isCurrentVideo;
  final bool isVideoPlaying;
  final bool isVideoEnded;

  @override
  Widget build(BuildContext context) {
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
                  Image.network(
                    advisorVideo!.thumbnail.isNotNullOrEmpty
                        ? advisorVideo!.thumbnail!
                        : advisorVideo!.link!.youtubeThumbnailUrl,
                    fit: BoxFit.fill,
                  ),
                  if (isCurrentVideo)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        child: Icon(
                          isVideoEnded
                              ? Icons.refresh
                              : isVideoPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                          size: 25,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 90,
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advisorVideo!.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.w500, height: 1.4),
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
