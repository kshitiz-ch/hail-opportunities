import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/story_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/home/story/widgets/share_story.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/widgets/story_view.dart';

@RoutePage()
class StoryScreen extends StatefulWidget {
  final String? storyIdToNavigate;
  final String? name;
  StoryScreen({
    this.storyIdToNavigate,
    // [name] is used in deeplink, serves the same purpose as storyIdToNavigate
    @queryParam this.name,
  });

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int? currentStoryIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GetBuilder<StoryListController>(
          initState: (_) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Get.find<StoryListController>().getStories(
                  storyIdToNavigate: widget.name ?? widget.storyIdToNavigate,
                  updateStoryItems: true);
            });
          },
          builder: (controller) {
            if (controller.storiesState == NetworkState.loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.storiesState == NetworkState.error ||
                controller.stories.isEmpty) {
              return EmptyScreen(
                message: 'Failed to load stories',
                actionButtonText: 'Go Back',
                onClick: () {
                  AutoRouter.of(context).popForced();
                },
                textStyle: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.white),
              );
            }

            return Stack(
              children: [
                if (controller.storyItems.isNotNullOrEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: StoryView(
                      inline: true,
                      storyItems: controller.storyItems,
                      onStoryShow: (storyItem, index) async {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            currentStoryIndex = index;
                          });
                          // // fix:
                          // //The widget which was currently being built
                          // //when the offending call was made was
                          // if (mounted) {
                          //   setState(() {});
                          // }
                        });
                      },
                      onComplete: () {
                        if (AutoRouter.of(context).stack.last.name ==
                            StoryRoute.name) {
                          AutoRouter.of(context).popForced();
                        }
                      },
                      progressPosition: ProgressPosition.top,
                      repeat: false,
                      controller: controller.storyController,
                    ),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                      ),
                      onPressed: () {
                        AutoRouter.of(context).popForced();
                      }),
                ),
                controller.stories.isNotNullOrEmpty
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // DownloadStory(
                              //   storyController: widget.storyController,
                              //   imageUrl:
                              //       widget.stories[currentStoryIndex ?? 0].image,
                              // ),
                              SizedBox(
                                width: 20,
                              ),
                              ShareStory(
                                  storyController: controller.storyController,
                                  imageUrl: controller
                                      .stories[currentStoryIndex ?? 0].image)
                            ],
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }
}
