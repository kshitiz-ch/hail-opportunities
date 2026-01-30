import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:flutter/material.dart';

class ScreenerTableSkelton extends StatelessWidget {
  const ScreenerTableSkelton({
    Key? key,
    this.itemCount = 5,
    this.fromScreenerList = false,
  }) : super(key: key);

  final int itemCount;
  final bool fromScreenerList;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 100,
                  color: ColorConstants.lightBackgroundColor,
                ).toShimmer(
                  baseColor: ColorConstants.lightBackgroundColor,
                  highlightColor: ColorConstants.white,
                ),
                Container(
                  height: 22,
                  width: 100,
                  color: ColorConstants.lightBackgroundColor,
                ).toShimmer(
                  baseColor: ColorConstants.lightBackgroundColor,
                  highlightColor: ColorConstants.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Flexible(
            flex: fromScreenerList ? 1 : 0,
            child: ListView.separated(
              itemCount: itemCount,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding:
                  EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
              separatorBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: ColorConstants.borderColor),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                ColorConstants.lightBackgroundColor,
                          ).toShimmer(
                            baseColor: ColorConstants.lightBackgroundColor,
                            highlightColor: ColorConstants.white,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 17,
                              color: ColorConstants.lightBackgroundColor,
                            ).toShimmer(
                              baseColor: ColorConstants.lightBackgroundColor,
                              highlightColor: ColorConstants.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 17,
                        color: ColorConstants.lightBackgroundColor,
                      ).toShimmer(
                        baseColor: ColorConstants.lightBackgroundColor,
                        highlightColor: ColorConstants.white,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 17,
                        color: ColorConstants.lightBackgroundColor,
                      ).toShimmer(
                        baseColor: ColorConstants.lightBackgroundColor,
                        highlightColor: ColorConstants.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
