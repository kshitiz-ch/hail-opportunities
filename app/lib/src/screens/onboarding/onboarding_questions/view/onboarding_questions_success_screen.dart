import 'dart:async';

import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class OnboardingQuestionsSuccessScreen extends StatefulWidget {
  const OnboardingQuestionsSuccessScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingQuestionsSuccessScreen> createState() =>
      _OnboardingQuestionsSuccessScreenState();
}

class _OnboardingQuestionsSuccessScreenState
    extends State<OnboardingQuestionsSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _lottieController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _controller);
    _animOffset =
        Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero).animate(curve);

    Timer(Duration(milliseconds: 1000), () {
      _controller.forward();
    });

    Timer(Duration(milliseconds: 3000), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigteToStoreOnboarding();
      });
    });
  }

  void _navigteToStoreOnboarding() {
    AutoRouter.of(context).push(BaseRoute());
    AutoRouter.of(context).push(StoreOnboardingRoute());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _lottieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: OverflowBox(
                minHeight: 300,
                maxHeight: 300,
                child: Lottie.asset(
                  AllImages().onboardingQuestionsSuccessLottie,
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),
            ),
            FadeTransition(
              child: SlideTransition(
                position: _animOffset,
                child: Text(
                  'Thanks for the Input!',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineLarge!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              opacity: _controller,
            ),
          ],
        ),
      ),
    );
  }
}
