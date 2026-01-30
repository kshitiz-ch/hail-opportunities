import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TeamActionsSuccessBottomsheet extends StatefulWidget {
  final String titleText;
  final Widget? subtitle;
  final Function onGotIt;

  TeamActionsSuccessBottomsheet({
    super.key,
    required this.titleText,
    this.subtitle,
    required this.onGotIt,
  });

  @override
  State<TeamActionsSuccessBottomsheet> createState() =>
      _TeamActionsSuccessBottomsheetState();
}

class _TeamActionsSuccessBottomsheetState
    extends State<TeamActionsSuccessBottomsheet> with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
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
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
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
          Center(
            child: Text(
              widget.titleText,
              textAlign: TextAlign.center,
              style: context.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
            ),
          ),
          SizedBox(height: 20),
          if (widget.subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: widget.subtitle!,
            ),
          ActionButton(
            margin: EdgeInsets.zero,
            text: 'Got It',
            onPressed: () {
              widget.onGotIt();
            },
          )
        ],
      ),
    );
  }
}
