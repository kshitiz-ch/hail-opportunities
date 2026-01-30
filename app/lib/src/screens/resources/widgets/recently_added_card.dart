import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/screens/resources/view/resources_screen.dart';
import 'package:app/src/screens/resources/widgets/app_resources_tags.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';

/// Poster card widget that displays image on left and content on right
class RecentlyAddedCard extends StatelessWidget {
  final CreativeNewModel model;
  final VoidCallback? onTap;
  final bool isRecentlyAdded;

  const RecentlyAddedCard({
    Key? key,
    required this.model,
    this.onTap,
    this.isRecentlyAdded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xffF7F4FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 120,
                height: 140,
                child: _buildIcon(),
              ),
            ),

            // Right side - Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    AppResourcesTags(
                      allTags: model.allTags,
                      isImage: model.isImage,
                      isRecentlyAdded: isRecentlyAdded,
                    ),

                    SizedBox(height: 8),

                    // Title
                    Text(
                      model.title ?? model.name ?? '',
                      style: context.titleLarge?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    // Description
                    Text(
                      model.description ?? '',
                      style: context.titleSmall?.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Spacer(),

                    // Bottom info (views, time, type) - Commented out for now
                    // Row(
                    //   children: [
                    //     Icon(
                    //       Icons.remove_red_eye_outlined,
                    //       size: 16,
                    //       color: Color(0xFF9CA3AF),
                    //     ),
                    //     SizedBox(width: 4),
                    //     Text(
                    //       _formatViews(model.views),
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Color(0xFF6B7280),
                    //       ),
                    //     ),
                    //     SizedBox(width: 8),
                    //     Text(
                    //       '• ${model.timeAgo}',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Color(0xFF9CA3AF),
                    //       ),
                    //     ),
                    //     SizedBox(width: 8),
                    //     Text(
                    //       '• ${model.type}',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Color(0xFF9CA3AF),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (model.blur == true) {
      return Image.asset(
        AllImages().blurPoster,
        fit: BoxFit.contain,
        height: 130,
      );
    }

    if (model.isImage) {
      return CachedNetworkImage(
        imageUrl: 'https://${model.url}?width=120&height=140',
        fit: BoxFit.cover,
        height: 130,
        errorWidget: (context, error, stackTrace) {
          return Container(
            color: Color(0xFFF0F0F0),
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
        placeholder: (context, url) {
          return Container(
            color: Color(0xFFF0F0F0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }
    final fileMetaData = getFileMetaData('https://${model.url!}');

    return SizedBox(
      height: 48,
      width: 48,
      child: CachedNetworkImage(
        imageUrl:
            model.thumbnailUrl != null ? 'https://${model.thumbnailUrl}' : '',
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) {
          return Image.asset(fileMetaData['fileIcon']!);
        },
        placeholder: (context, url) {
          return Container(
            color: Color(0xFFF0F0F0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
