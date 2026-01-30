import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/screens/resources/widgets/app_resources_tags.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';

/// Card widget displaying SIP vs Inflation style poster with image on top and content below
class PosterCard extends StatelessWidget {
  final CreativeNewModel model;
  final VoidCallback? onTap;

  const PosterCard({
    Key? key,
    required this.model,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section - Image with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    child: model.blur == true
                        ? Image.asset(
                            AllImages().blurPoster,
                            fit: BoxFit.contain,
                            height: 130,
                          )
                        : CachedNetworkImage(
                            imageUrl: 'https://${model.url}',
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF64B5F6),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              );
                            },
                            placeholder: (context, url) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF64B5F6),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                // Optional gradient overlay for better text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom section - Content
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  AppResourcesTags(
                    allTags: model.allTags,
                    isImage: model.isImage,
                  ),

                  SizedBox(height: 12),

                  // Title
                  Text(
                    model.title ?? '',
                    style: context.titleLarge?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  // Description
                  Text(
                    model.description ?? '',
                    style: context.titleSmall?.copyWith(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
