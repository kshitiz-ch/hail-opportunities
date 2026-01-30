import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppResourcesTags extends StatelessWidget {
  final List<CreativeTagModel>? allTags;
  final bool isImage;
  final bool isRecentlyAdded;

  AppResourcesTags({
    Key? key,
    this.allTags,
    required this.isImage,
    this.isRecentlyAdded = false,
  }) : super(key: key) {
    final appResourceController = Get.find<AppResourcesController>();
    final languageList = isImage
        ? appResourceController.languages
        : appResourceController.salesKitLanguages;
    final languagesTags = languageList.map((lang) => lang.tag ?? '').toList();
    excludedTags.addAll(languagesTags);
  }

  List<String?> excludedTags = [unempanelledTag.tag, salesKitAllTag.tag];

  @override
  Widget build(BuildContext context) {
    if (allTags.isNullOrEmpty) {
      return SizedBox();
    }

    // Filter out excluded tags first
    final filteredTags =
        allTags!.where((tag) => !excludedTags.contains(tag.id)).toList();

    if (filteredTags.isEmpty) {
      return SizedBox();
    }

    List<CreativeTagModel> displayTags = filteredTags;
    int remainingCount = 0;

    if (isRecentlyAdded && filteredTags.length > 2) {
      displayTags = [filteredTags.first];
      remainingCount = filteredTags.length - 1;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayTags.map((tag) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag.name ?? '',
              style: context.titleSmall?.copyWith(
                color: Color(0xFF7C4DFF),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          );
        }),
        if (remainingCount > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+$remainingCount more',
              style: context.titleSmall?.copyWith(
                color: Color(0xFF7C4DFF),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
