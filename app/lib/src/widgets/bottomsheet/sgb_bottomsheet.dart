import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/profile/kyc/kyc_browser.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../config/routes/router.gr.dart';

class SgbBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCloseButton(context),
              Container(
                color: hexToColor("#7B59C1"),
                child: Image.asset(AllImages().sgbIntroBanner),
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     fit: BoxFit.contain,
                //     image: AssetImage(
                //       AllImages().sgbIntroBanner,
                //     ),
                //   ),
                // ),
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     colors: [
                //       hexToColor("#7B59C1"),
                //       hexToColor("#F6DEFF"),
                //     ],
                //     begin: Alignment.centerLeft,
                //     end: Alignment.centerRight,
                //   ),
                // ),
                // child: Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       // Column(
                //       //   crossAxisAlignment: CrossAxisAlignment.start,
                //       //   children: [
                //       //     Text(
                //       //       'Introducing',
                //       //       style: Theme.of(context)
                //       //           .primaryTextTheme
                //       //           .headlineSmall!
                //       //           .copyWith(color: ColorConstants.white),
                //       //     ),
                //       //     Text(
                //       //       'Sovereign\nGold bonds',
                //       //       style: Theme.of(context)
                //       //           .primaryTextTheme
                //       //           .displaySmall!
                //       //           .copyWith(
                //       //             color: ColorConstants.white,
                //       //             fontWeight: FontWeight.w500,
                //       //             fontSize: 28,
                //       //           ),
                //       //     ),
                //       //   ],
                //       // ),
                //       // Padding(
                //       //   padding: EdgeInsets.only(right: 10),
                //       //   child: SvgPicture.asset(
                //       //     AllImages().sgbGoldIcon,
                //       //     width: 90,
                //       //   ),
                //       // )
                //       // SvgPicture.asset(
                //       //   AllImages().bankIcon,
                //       //   width: 90,
                //       //   height: 90,
                //       // ),
                //       // Image.asset(
                //       //   AllImages().creditCardIcon,
                //       //   width: 80,
                //       //   height: 80,
                //       // ),
                //     ],
                //   ),
                // ),
              ),
              Container(
                color: ColorConstants.white,
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoints(
                          context,
                          title: 'Government backed gold bonds',
                          subtitle:
                              'Government securities denominated in grams of gold',
                        ),
                        SizedBox(height: 30),
                        _buildBulletPoints(
                          context,
                          title: 'Save tax, hold till maturity',
                          subtitle: 'Zero capital gains tax on maturity',
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                    SizedBox(height: 24),
                    ActionButton(
                      text: 'Share Now',
                      margin: EdgeInsets.zero,
                      onPressed: () {
                        AutoRouter.of(context).popForced();
                        AutoRouter.of(context).push(SgbRoute());
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.transparent,
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          AutoRouter.of(context).popForced();
        },
        child: Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: ColorConstants.darkScaffoldBackgroundColor,
              shape: BoxShape.circle),
          child: Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBulletPoints(BuildContext context,
      {required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Image.asset(
            AllImages().starBulletPointIcon,
            width: 8,
            height: 8,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .primaryTextTheme
                    .displayLarge!
                    .copyWith(fontSize: 18),
              ),
              if (subtitle.isNotNullOrEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    subtitle,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          letterSpacing: 0.5,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
