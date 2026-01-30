import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class HomeScreenLoader extends StatelessWidget {
  const HomeScreenLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Header
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 48, bottom: 32),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ).toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    ),
                    SizedBox(width: 14),
                    Container(
                      height: 22,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6)),
                    ).toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    )
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ).toShimmer(
                    baseColor: ColorConstants.lightBackgroundColor,
                    highlightColor: ColorConstants.white,
                  ),
                  SizedBox(width: 14),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ).toShimmer(
                    baseColor: ColorConstants.lightBackgroundColor,
                    highlightColor: ColorConstants.white,
                  ),
                ],
              )
            ],
          ),
        ),

        // Search Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ).toShimmer(
          baseColor: ColorConstants.lightBackgroundColor,
          highlightColor: ColorConstants.white,
        ),
        SizedBox(
          height: 40,
        ),

        // Earning Text
        Center(
          child: Container(
            // width: 120,
            height: 200,
            color: Colors.white,
          ),
        ).toShimmer(
          baseColor: ColorConstants.lightBackgroundColor,
          highlightColor: ColorConstants.white,
        ),

        SizedBox(
          height: 32,
        ),

        // Earning Value
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              width: 150,
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 20, right: 20),
              // width: 150,
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
          ],
        ),

        SizedBox(
          height: 32,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              width: 150,
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 20, right: 20),
              // width: 150,
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
          ],
        ),

        SizedBox(
          height: 32,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              width: 150,
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 20, right: 20),
              // width: 150,
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ).toShimmer(
              baseColor: ColorConstants.lightBackgroundColor,
              highlightColor: ColorConstants.white,
            ),
          ],
        )
      ],
    );
  }
}
