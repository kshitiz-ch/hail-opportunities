import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'new_feature_demo_screen.dart';

class NewFeatureListBottomSheet extends StatelessWidget {
  const NewFeatureListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: 40),
      color: hexToColor("#ede8e4"),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 56, bottom: 24),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AllImages().newFeatureBackground),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        AllImages().wealthyLogoSquared,
                        width: 64,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 1,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.orangeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: ColorConstants.orangeColor,
                            ),
                          ),
                          child: Text(
                            "New",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodySmall!
                                .copyWith(color: ColorConstants.orangeColor),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Wealthy Partner ',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(fontSize: 18),
                        ),
                        Text(
                          'v4.0',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Explore the cool new features on this version',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(color: ColorConstants.tertiaryBlack),
                    )
                  ],
                ),
              ),
              Positioned(
                right: 20,
                top: 10,
                child: CommonUI.bottomsheetCloseIcon(context),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: ListView.separated(
                itemCount: 0,
                // itemCount: newFeatureDetails.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 30);
                },
                itemBuilder: (context, index) {
                  return;
                  // Map<String, String> feature = newFeatureDetails[index];
                  // return _buildTile(
                  //   context,
                  //   title: feature['title']!,
                  //   description: feature['description']!,
                  //   image: feature['icon']!,
                  // );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 10),
            child: ActionButton(
              text: 'Take a Quick Tour',
              onPressed: () {
                AutoRouter.of(context).popForced();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false, // set to false
                    pageBuilder: (_, __, ___) => NewFeatureDemoScreen(),
                  ),
                );
                // CommonUI.showBottomSheet(
                //   context,
                //   child: NewFeatureDemoBottomSheet(),
                // );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required String title,
      required String description,
      required String image}) {
    return Row(
      children: [
        Image.asset(image, width: 42, height: 42),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).primaryTextTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
        )
      ],
    );
  }
}
