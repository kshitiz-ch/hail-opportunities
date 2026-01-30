import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class SuccessScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? actionButtonText;
  final void Function()? onPressed;

  const SuccessScreen({
    required this.title,
    this.subtitle,
    this.onPressed,
    this.actionButtonText,
  });

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      child: Lottie.asset(
                        AllImages().verifiedIconLottie,
                        controller: _lottieController,
                        onLoaded: (composition) {
                          _lottieController
                            ..duration = composition.duration
                            ..forward();
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                if (widget.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                    ),
                  )
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FixedCenterDockedFabLocation(),
        floatingActionButton: widget.onPressed != null
            ? Container(
                margin: EdgeInsets.only(bottom: 30),
                child: ActionButton(
                  text: widget.actionButtonText ?? 'Go Back',
                  onPressed: widget.onPressed,
                ),
              )
            : null,
      ),
    );
  }
}
