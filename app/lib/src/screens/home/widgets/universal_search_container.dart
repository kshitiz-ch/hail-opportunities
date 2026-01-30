import 'dart:async';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UniversalSearchContainer extends StatefulWidget {
  @override
  State<UniversalSearchContainer> createState() =>
      _UniversalSearchContainerState();
}

class _UniversalSearchContainerState extends State<UniversalSearchContainer> {
  int _currentIndex = 0;
  // Timer to handle auto-rotation of placeholder texts
  Timer? _timer;

  // List of placeholder texts to cycle through
  final List<String> _placeholderTexts = [
    'Search for clients',
    'Search for Mutual Funds',
    'Search for IPOs',
    'Search for Fixed Deposits',
    'Search for Wealthcase',
    'Search for PMS',
    'Search for clients, products & quick actions',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Starts the timer to update the index every 3 seconds
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _placeholderTexts.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(UniversalSearchRoute(fromDeeplink: false));
        MixPanelAnalytics.trackWithAgentId(
          "page_viewed",
          properties: {"page_name": "SEARCH", "source": "Home"},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.darkBlack.withOpacity(0.1),
              offset: Offset(0.0, 4.0),
              spreadRadius: 0.0,
              blurRadius: 10.0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge, // Clip content that slides out
        child: IgnorePointer(
          child: SearchBox(
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 6),
            labelStyle:
                Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                      height: 1.4,
                      color: ColorConstants.tertiaryBlack,
                    ),
            height: 56,
            fillColor: ColorConstants.white,
            // labelText: 'Tap to Search', // Replaced by label widget
            // AnimatedSwitcher handles the transition between different labels
            label: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              // Slide transition: Text moves up from the bottom
              transitionBuilder: (Widget child, Animation<double> animation) {
                final inAnimation = Tween<Offset>(
                  begin: Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation);

                if (child.key ==
                    ValueKey<String>(_placeholderTexts[_currentIndex])) {
                  // Animate the incoming text sliding up
                  return SlideTransition(
                    position: inAnimation,
                    child: child,
                  );
                } else {
                  // Instantly hide the outgoing text to prevent overlap/two texts showing
                  return SizedBox.shrink();
                }
              },
              child: Text(
                _placeholderTexts[_currentIndex],
                key: ValueKey<String>(_placeholderTexts[_currentIndex]),
                maxLines: 1, // Ensure single line
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          height: 1.4,
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ),
            textColor: ColorConstants.secondaryBlack,
            customBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFFEEE7FF),
              ),
            ),
            prefixIcon: new IconButton(
              icon: SvgPicture.asset(
                AllImages().searchIcon,
                width: 24,
                height: 24,
              ),
              onPressed: null,
            ),
            onChanged: (text) {},
            onTap: () {},
            onSubmitted: (text) {},
          ),
        ),
      ),
    );
  }
}
