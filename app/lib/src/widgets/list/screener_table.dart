import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/screens/home/widgets/indicators.dart';
import 'package:flutter/material.dart';

import '../input/screener_return_dropdown.dart';
import 'screener_scheme_list.dart';

class ScreenerTable extends StatelessWidget {
  const ScreenerTable({
    Key? key,
    this.onTapViewAll,
    required this.controller,
    this.fromListScreen = false,
    this.showMfRating = true,
  }) : super(key: key);

  final Function()? onTapViewAll;
  final ScreenerController controller;
  final bool fromListScreen;
  final bool showMfRating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: fromListScreen ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.borderColor),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                if (controller.schemes.isNotEmpty)
                  _buildTableHeader(context, controller),

                // Scheme List
                if (controller.schemes.isNotEmpty)
                  ScreenerSchemeList(
                    controller: controller,
                    fromListScreen: fromListScreen,
                    showMfRating: showMfRating,
                  )
                else
                  Align(
                    child: GestureDetector(
                      onPanEnd: controller.handleSchemeTableSwipe,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 40, horizontal: 50),
                        child: Text(
                          'No Scheme Found',
                          style:
                              Theme.of(context).primaryTextTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),

                // Infinite loader (List Screen)
                if (controller.isPaginating && fromListScreen)
                  _buildInfiniteLoader(),
              ],
            ),
          ),
        ),

        // View All Button Redirecting to List Screen
        // if (!fromListScreen)
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: CarouselIndicators(
            itemsLength:
                (controller.screener?.categoryParams?.choices ?? []).length,
            currentIndex: controller.categorySelectedIndex,
            primaryColor: ColorConstants.primaryAppColor,
            secondaryColor: ColorConstants.lightGrey,
          ),
        ),
        if (onTapViewAll != null) _buildViewAllButton(context)
      ],
    );
  }

  Widget _buildTableHeader(
      BuildContext context, ScreenerController controller) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(
            color: ColorConstants.tertiaryBlack,
            fontWeight: FontWeight.w600,
            height: 1.5);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Scheme Name',
            style: textStyle,
          ),
          Spacer(),
          Row(
            children: [
              Text(
                'Return',
                style: textStyle,
              ),
              SizedBox(width: 3),
              ScreenerReturnDropdown(controller: controller)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        InkWell(
          onTap: onTapViewAll,
          child: Row(
            children: [
              Text(
                'View All Funds',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineLarge!
                    .copyWith(
                        color: ColorConstants.primaryAppColor, fontSize: 14),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  color: ColorConstants.primaryAppColor)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInfiniteLoader() {
    return Container(
      height: 30,
      margin: EdgeInsets.only(bottom: 10, top: 10),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
