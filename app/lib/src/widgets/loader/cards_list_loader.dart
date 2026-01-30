import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:flutter/material.dart';

class CardsListLoader extends StatelessWidget {
  const CardsListLoader({
    Key? key,
    this.appBarText,
    this.itemCount = 2,
  }) : super(key: key);

  final int itemCount;
  final String? appBarText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: appBarText ?? '',
        showBackButton: false,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            // Section Header
            child: SectionHeader(title: 'Loading...').toShimmer(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  height: 235,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: ProductCard().toShimmer(
                      baseColor: ColorConstants.lightBackgroundColor,
                      highlightColor: ColorConstants.white,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
