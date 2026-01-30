import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NewFeatureDemoScreen extends StatefulWidget {
  const NewFeatureDemoScreen({Key? key}) : super(key: key);

  @override
  State<NewFeatureDemoScreen> createState() => _NewFeatureDemoScreenState();
}

class _NewFeatureDemoScreenState extends State<NewFeatureDemoScreen> {
  late PageController _pageViewController;
  int _currentPageIndex = 0;
  List newFeatureDetails = [];

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(50)),
                  child: Text(
                    '${_currentPageIndex + 1} / ${newFeatureDetails.length}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: () {
                    AutoRouter.of(context).popForced();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.5),
                      size: 24,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: Colors.white, height: 2),
                ),
                SizedBox(width: 10),
                Image.asset(
                  AllImages().newFeatureTag,
                  width: 42,
                )
              ],
            ),
            // Expanded(
            //   // child: Text('Hello'),
            //   child: PageView(
            //     controller: _pageViewController,
            //     onPageChanged: _handlePageViewChanged,
            //     children: newFeatureDetails.map((Map<String, String> feature) {
            //       return _buildDemo(
            //         context,
            //         feature['title']!,
            //         feature['description']!,
            //         feature['gif']!,
            //       );
            //     }).toList(),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: SmoothPageIndicator(
                controller: _pageViewController,
                count: newFeatureDetails.length,
                effect: ExpandingDotsEffect(
                  dotWidth: 4,
                  dotHeight: 4,
                  activeDotColor: ColorConstants.white,
                  dotColor: ColorConstants.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10).copyWith(top: 20),
              child: Row(
                children: [
                  if (_currentPageIndex != 0)
                    Expanded(
                      flex: 1,
                      child: ActionButton(
                        text: '< Go Back',
                        bgColor: ColorConstants.secondaryAppColor,
                        textStyle: Theme.of(context)
                            .primaryTextTheme
                            .headlineLarge!
                            .copyWith(
                                fontSize: 16,
                                color: ColorConstants.primaryAppColor,
                                fontWeight: FontWeight.w600),
                        margin: EdgeInsets.zero,
                        onPressed: () {
                          _pageViewController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear,
                          );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: SizedBox(),
                    ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: ActionButton(
                      text: _currentPageIndex == (newFeatureDetails.length - 1)
                          ? 'Got it!'
                          : 'Next >',
                      margin: EdgeInsets.zero,
                      onPressed: () {
                        if (_currentPageIndex ==
                            (newFeatureDetails.length - 1)) {
                          AutoRouter.of(context).popForced();
                        } else {
                          _pageViewController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear,
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  Widget _buildDemo(
      BuildContext context, String title, String description, String image) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontSize: 20, color: Colors.white),
            ),
          ),
          Text(
            description,
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: Colors.white, height: 1.5),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(image),
              ),
            ),
          )
        ],
      ),
    );
  }
}
