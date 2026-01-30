import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class FestiveProfileIcon extends StatefulWidget {
  const FestiveProfileIcon({Key? key}) : super(key: key);

  @override
  State<FestiveProfileIcon> createState() => _FestiveProfileIconState();
}

class _FestiveProfileIconState extends State<FestiveProfileIcon>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
    _lottieController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // InkWell(
        //   onTap: () {
        //     HomeController controller = Get.find<HomeController>();

        //     AutoRouter.of(context).push(
        //       ProfileRoute(
        //         advisorOverview: controller.advisorOverviewModel,
        //       ),
        //     );
        //   },
        //   child: Image.asset(
        //     AllImages().festiveAvatarIcon,
        //     height: 54,
        //     width: 54,
        //     // fit: BoxFit.contain,
        //   ),
        // ),
        // Positioned(
        //   left: 10,
        //   top: 0,
        //   child: Lottie.asset(
        //     AllImages().snowLottie,
        //     repeat: true,
        //     controller: _lottieController,
        //     onLoaded: (composition) {
        //       _lottieController
        //         ..duration = composition.duration
        //         ..forward();
        //     },
        //   ),
        // ),
        InkWell(
          onTap: () {
            HomeController controller = Get.find<HomeController>();

            AutoRouter.of(context).push(
              ProfileRoute(
                advisorOverview: controller.advisorOverviewModel,
              ),
            );
          },
          child: Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AllImages().festiveAvatarIcon),
                fit: BoxFit.cover,
              ),
            ),
            child: Lottie.asset(
              AllImages().snowLottie,
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController
                  ..duration = composition.duration
                  ..forward();
                _lottieController.repeat();
              },
            ),
          ),
        ),
        // Positioned(
        //   left: 0,
        //   top: 0,
        //   child: InkWell(
        //     onTap: () {
        //       HomeController controller = Get.find<HomeController>();

        //       AutoRouter.of(context).push(
        //         ProfileRoute(
        //           advisorOverview: controller.advisorOverviewModel,
        //         ),
        //       );
        //     },
        //     child: Image.asset(
        //       AllImages().festiveAvatarIcon,
        //       height: 54,
        //       width: 54,
        //       // fit: BoxFit.contain,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
