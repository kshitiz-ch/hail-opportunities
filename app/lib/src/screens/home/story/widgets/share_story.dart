import 'dart:async';
import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:story_view/story_view.dart';

class ShareStory extends StatelessWidget {
  final String? imageUrl;

  final StoryController? storyController;

  const ShareStory({
    Key? key,
    this.imageUrl,
    this.storyController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        storyController!.pause();

        shareImage(context: context, creativeUrl: imageUrl);
        // await _shareImage(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(
              Icons.share,
              color: Colors.black,
              size: 16,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Share',
              style: Theme.of(context)
                  .primaryTextTheme
                  .displaySmall!
                  .copyWith(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _shareImage(context) async {
    try {
      List splitBySlash = imageUrl!.split("/");
      final storyFileName = splitBySlash[splitBySlash.length - 1];

      final Directory temp = await getTemporaryDirectory();

      final File imageFile = File('${temp.path}/$storyFileName');

      bool isImageExists = await imageFile.exists();

      // if image doesn't exist in cache directory show loader

      if (!isImageExists) {
        CommonUI.showBottomSheet(
          context,
          child: SizedBox(
            height: 100,
            child: Center(
                child: CircularProgressIndicator(
              color: ColorConstants.primaryAppColor,
            )),
          ),
        );

        Timer(
          Duration(seconds: 3),
          () async {
            // close loader

            AutoRouter.of(context).pop();

            // if image exists in cache directory after 3 sec share it

            if (isImageExists) {
              await shareFiles(imageFile.path);
            }

            // if image is still not fetched share url only

            else {
              await shareText(imageUrl!);
            }
          },
        );

        // get image data from web while we are showing loader for 3 sec

        http.get(Uri.parse(imageUrl!)).then(
          (response) {
            imageFile.writeAsBytesSync(response.bodyBytes);

            isImageExists = true;
          },
        );
      }

      // if image exists in cache directory just share it without fetching it
      else {
        await shareFiles(imageFile.path);
      }
    } catch (error) {
      shareText(imageUrl!);
    }
  }
}
