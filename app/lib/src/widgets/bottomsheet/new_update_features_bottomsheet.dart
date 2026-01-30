import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class NewUpdateFeaturesBottomSheet extends StatelessWidget {
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      hexToColor("#EAF2FB"),
                      hexToColor("#F6DEFF"),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                padding: EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Introducing',
                          style:
                              Theme.of(context).primaryTextTheme.headlineSmall,
                        ),
                        Text(
                          'New Mutual\nFund Store',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displaySmall!
                              .copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 28),
                        ),
                      ],
                    ),
                    Image.asset(
                      AllImages().storeMfIcon,
                      width: 90,
                      height: 90,
                    ),
                  ],
                ),
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
                          title: 'Revamped MF Store',
                          subtitle:
                              'Enhanced design and functionality for a better investment experience.',
                        ),
                        SizedBox(height: 24),
                        _buildBulletPoints(
                          context,
                          title: 'SIP and Lumpsum Calculator',
                          subtitle:
                              'Tools to estimate returns and plan investments effectively.',
                        ),
                        SizedBox(height: 24),
                        _buildBulletPoints(
                          context,
                          title: 'Expanded Fund Details',
                          subtitle:
                              'In-depth information on funds for informed decision-making.',
                        ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Padding(
                        //       padding: EdgeInsets.only(top: 8),
                        //       child: Image.asset(
                        //         AllImages().starBulletPointIcon,
                        //         width: 8,
                        //         height: 8,
                        //       ),
                        //     ),
                        //     SizedBox(width: 12),
                        //     Expanded(
                        //       child: Text.rich(
                        //         TextSpan(
                        //           children: [
                        //             TextSpan(
                        //               text: 'This will be applicable from',
                        //               style: Theme.of(context)
                        //                   .primaryTextTheme
                        //                   .headlineSmall!
                        //                   .copyWith(height: 1.5),
                        //             ),
                        //             TextSpan(
                        //               text: ' August 30, 2023 ',
                        //               style: Theme.of(context)
                        //                   .primaryTextTheme
                        //                   .headlineSmall!
                        //                   .copyWith(
                        //                       height: 1.5,
                        //                       fontWeight: FontWeight.w700),
                        //             ),
                        //             TextSpan(
                        //               text: 'payout cycle.',
                        //               style: Theme.of(context)
                        //                   .primaryTextTheme
                        //                   .headlineSmall!
                        //                   .copyWith(height: 1.5),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 30),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Padding(
                        //       padding: EdgeInsets.only(top: 8),
                        //       child: Image.asset(
                        //         AllImages().starBulletPointIcon,
                        //         width: 8,
                        //         height: 8,
                        //       ),
                        //     ),
                        //     SizedBox(width: 12),
                        //     Expanded(
                        //       child: Text.rich(
                        //         TextSpan(
                        //           children: [
                        //             TextSpan(
                        //               text:
                        //                   'Update your bank details immediately to prevent any delays in your payouts',
                        //               style: Theme.of(context)
                        //                   .primaryTextTheme
                        //                   .headlineSmall!
                        //                   .copyWith(height: 1.5),
                        //             ),
                        //             // TextSpan(
                        //             //   text: ' August 26, 2023 ',
                        //             //   style: Theme.of(context)
                        //             //       .primaryTextTheme
                        //             //       .headlineSmall!
                        //             //       .copyWith(
                        //             //           height: 1.5,
                        //             //           fontWeight: FontWeight.w700),
                        //             // ),
                        //             // TextSpan(
                        //             //   text:
                        //             //       'to ensure you receive payouts on time directly in your account.',
                        //             //   style: Theme.of(context)
                        //             //       .primaryTextTheme
                        //             //       .headlineSmall!
                        //             //       .copyWith(height: 1.5),
                        //             // ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     // Expanded(
                        //     //   child: Text(
                        //     //     'Update your bank details on or before 20th Aug 2023 to facilitate direct payouts to your bank account. Else your payouts shall be on hold.',
                        //     //     style: Theme.of(context)
                        //     //         .primaryTextTheme
                        //     //         .headlineSmall!
                        //     //         .copyWith(height: 1.5),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                        // SizedBox(height: 30),
                        // _buildBulletPoints(context,
                        //     title: 'Download', subtitle: ''
                        //     // 'More than 55 credit cards from 8 major banks available',
                        //     ),
                        // SizedBox(height: 24),
                        // _buildBulletPoints(context, title: 'Share', subtitle: ''
                        //     // 'Real time update of the Card status in Proposal listing',
                        //     ),
                        // SizedBox(height: 24),
                        // _buildBulletPoints(
                        //   context,
                        //   title: 'Personalisation',
                        //   subtitle: 'Resume your journey at your convenience',
                        // ),
                        // SizedBox(height: 24)
                      ],
                    ),
                    SizedBox(height: 30),
                    ActionButton(
                      text: 'Explore',
                      margin: EdgeInsets.zero,
                      onPressed: () {
                        AutoRouter.of(context).popForced();
                        AutoRouter.of(context).push(MfLobbyRoute());
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
          padding: EdgeInsets.only(top: 7),
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
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
