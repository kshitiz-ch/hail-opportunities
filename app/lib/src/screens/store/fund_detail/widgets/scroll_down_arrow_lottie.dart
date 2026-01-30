import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ScrollDownArrowLottie extends StatefulWidget {
  const ScrollDownArrowLottie({Key? key}) : super(key: key);

  @override
  State<ScrollDownArrowLottie> createState() => _ScrollDownArrowLottieState();
}

class _ScrollDownArrowLottieState extends State<ScrollDownArrowLottie>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundDetailController>(
        id: 'bottom-arrow',
        builder: (controller) {
          if (!controller.showBottomArrowIndicator) {
            return SizedBox();
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10, right: 10),
                width: 70,
                height: 70,
                // padding: const EdgeInsets.symmetric(horizontal: 24.0),
                // child: AnimatedIcon(icon: AnimatedIconData.arrow, progress: progress),
                child: Lottie.asset(
                  AllImages().arrowDownLottie,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward()
                      ..repeat();
                  },
                ),
              ),
            ],
          );
        });
  }
}
