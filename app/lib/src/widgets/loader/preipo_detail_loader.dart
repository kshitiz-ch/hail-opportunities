import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class PreIPODetailLoader extends StatelessWidget {
  // Fields
  final int overviewItemCount;

  // Constructor
  const PreIPODetailLoader({
    Key? key,
    this.overviewItemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 56),

            // Back Button
            Container(
              margin: const EdgeInsets.only(left: 25),
              height: 22,
              width: 22,
              color: ColorConstants.lightBackgroundColor,
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            const SizedBox(height: 30),

            // Title
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: ColorConstants.lightBackgroundColor,
                  ).toShimmer(
                    baseColor: ColorConstants.lightBackgroundColor,
                    highlightColor: ColorConstants.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 42),
                  height: 22,
                  width: 180,
                  color: ColorConstants.lightBackgroundColor,
                ).toShimmer(
                  baseColor: ColorConstants.lightBackgroundColor,
                  highlightColor: ColorConstants.white,
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Overview
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.86,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: [
                  for (int i = 0; i < overviewItemCount; i++)
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

            // Description
            Container(
              margin: const EdgeInsets.only(left: 42, bottom: 6),
              height: 20,
              width: 120,
              color: ColorConstants.lightBackgroundColor,
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            // Subtitle
            Container(
              margin: const EdgeInsets.only(top: 12, left: 30),
              height: 60,
              width: MediaQuery.of(context).size.width * 0.8,
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
