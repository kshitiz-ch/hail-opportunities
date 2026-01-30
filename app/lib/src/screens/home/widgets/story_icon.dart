import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/story_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class StoryIcon extends StatefulWidget {
  StoryIcon({Key? key, required this.controller}) : super(key: key);

  final StoryListController controller;

  @override
  State<StoryIcon> createState() => _StoryIconState();
}

class _StoryIconState extends State<StoryIcon>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    if (widget.controller.animationController == null) {
      widget.controller.animationController = AnimationController(
        duration: Duration(milliseconds: 5000),
        vsync: this,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryListController>(
      builder: (controller) {
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ColorConstants.secondaryWhite,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () {
              MixPanelAnalytics.trackWithAgentId("stories", properties: {
                "screen_location": "home_header",
                "screen": "Home"
              });
              AutoRouter.of(context).push(StoryRoute());
            },
            child: Stack(
              children: [
                if (controller.animationController != null)
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(controller.animationController!),
                    // turns: shouldResetAnimation
                    //     ? Tween(begin: 0.0, end: 0.0).animate(_animationController)
                    //     : Tween(begin: 0.0, end: 1.0).animate(_animationController),
                    child: Container(
                      child: SvgPicture.asset(
                        AllImages().storyIconBorder,
                      ),
                    ),
                  )
                else
                  Container(
                    child: SvgPicture.asset(
                      AllImages().storyIconBorder,
                    ),
                  ),
                Center(
                  child: Image.asset(
                    AllImages().storyIcon,
                    height: 20,
                    width: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
