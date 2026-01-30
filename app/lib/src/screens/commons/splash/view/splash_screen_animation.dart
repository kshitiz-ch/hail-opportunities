import 'package:app/src/config/constants/image_constants.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenAnimation extends StatefulWidget {
  const SplashScreenAnimation({Key? key, required this.authenticationBloc})
      : super(key: key);

  final AuthenticationBloc authenticationBloc;

  @override
  State<SplashScreenAnimation> createState() => _SplashScreenAnimationState();
}

class _SplashScreenAnimationState extends State<SplashScreenAnimation>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
    _lottieController = AnimationController(vsync: this);
    _lottieController.addListener(() async {
      if (_lottieController.isCompleted) {
        final SharedPreferences sharedPreferences = await prefs;
        sharedPreferences.setBool("splash_animation_viewed", true);
        widget.authenticationBloc.add(AppLoadedup());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AllImages().splashScreenDiwaliLottie,
        controller: _lottieController,
        onLoaded: (composition) {
          _lottieController
            ..duration = composition.duration
            ..forward();
        },
      ),
    );
  }
}
