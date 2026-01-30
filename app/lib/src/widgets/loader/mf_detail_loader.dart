import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class MfDetailLoader extends StatelessWidget {
  const MfDetailLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 24),
                height: 24,
                width: 24,
                color: ColorConstants.lightBackgroundColor,
              ).toShimmer(
                baseColor: ColorConstants.lightBackgroundColor,
                highlightColor: ColorConstants.white,
              ),
            ),
            const SizedBox(height: 40),
            // Title
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 42),
                height: 22,
                width: 180,
                color: ColorConstants.lightBackgroundColor,
              ).toShimmer(
                baseColor: ColorConstants.lightBackgroundColor,
                highlightColor: ColorConstants.white,
              ),
            ),

            // Subtitle
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 6, left: 42),
                height: 18,
                width: 150,
                color: ColorConstants.lightBackgroundColor,
              ).toShimmer(
                baseColor: ColorConstants.lightBackgroundColor,
                highlightColor: ColorConstants.white,
              ),
            ),
            const SizedBox(height: 24),

            // Overview Card
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.86,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: [
                  for (int i = 0; i < 6; i++)
                    Container(
                      height: 45,
                      width: 120,
                      color: ColorConstants.lightBackgroundColor,
                    ).toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Chart Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 50,
              width: 200,
              alignment: Alignment.center,
              color: ColorConstants.lightBackgroundColor,
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            const SizedBox(height: 20),

            // Return
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 50,
              width: 150,
              alignment: Alignment.center,
              color: ColorConstants.lightBackgroundColor,
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            const SizedBox(height: 20),

            // Charts
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 200,
              // width: 100,
              color: ColorConstants.lightBackgroundColor,
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
          ],
        ),
      ),
    );
  }
}
