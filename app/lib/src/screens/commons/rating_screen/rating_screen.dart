import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class RatingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64, bottom: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().ratingIcon,
            height: 120,
            width: 120,
            alignment: Alignment.center,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Enjoying Wealthy ?',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 68),
            child: Text(
              'How do you rate our wealthy experience ?\nThis will help us to serve you better!',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w400,
                    height: 18 / 12,
                  ),
            ),
          ),
          ActionButton(
            margin: EdgeInsets.symmetric(horizontal: 30),
            text: 'Give Rating',
            onPressed: () {
              openInAppReview(context);
            },
          )
        ],
      ),
    );
  }

  Future<void> openInAppReview(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;
    String storeUrl = await getStoreUrl();

    try {
      bool isInAppReviewPossible = await inAppReview.isAvailable();

      AutoRouter.of(context).popForced();

      if (isInAppReviewPossible) {
        // launch("https://onelink.to/wealthy-deeplink");
        // inAppReview.openStoreListing();

        // to open app in playstore/appstore
        // inAppReview.openStoreListing();

        // it won't work if user has already reviewed
        inAppReview.requestReview()
          ..then((value) {
            LogUtil.printLog('then');
          })
          ..whenComplete(() {
            LogUtil.printLog('complete');
          })
          ..catchError((error) {
            LogUtil.printLog('error==>${error.toString()}');
          });
      } else {
        launch(storeUrl);
      }
    } catch (e) {
      launch(storeUrl);
    }
  }
}
