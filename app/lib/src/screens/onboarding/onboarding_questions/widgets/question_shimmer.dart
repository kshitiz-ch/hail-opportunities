import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class QuestionShimmer extends StatelessWidget {
  const QuestionShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            height: 50,
            color: ColorConstants.lightBackgroundColor,
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 40),
            physics: ClampingScrollPhysics(),
            itemCount: 2,
            itemBuilder: (BuildContext context, int index) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorConstants.lightBackgroundColor,
                      ),
                    ).toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ColorConstants.lightBackgroundColor,
                      ),
                    ).toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
