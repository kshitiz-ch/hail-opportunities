import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class FDAdvantage extends StatelessWidget {
  final List<Map<String, String>> fdAdvantages = [
    {
      'image': AllImages().fdInvestmentIcon,
      'title': 'Minimum Investment',
      'description':
          'Invest a minimum amount of Rs.5,000 only and watch your money grow'
    },
    {
      'image': AllImages().fdTenureIcon,
      'title': 'Flexible Tenures',
      'description':
          'Select the FD tenure so that it matches the time frame required for your various needs'
    },
    {
      'image': AllImages().fdTransferIcon,
      'title': 'Seamless Transfers',
      'description': 'Transfer your funds seamlessly in less than 5 minutes'
    },
    {
      'image': AllImages().fdReturnIcon,
      'title': 'Guaranteed Returns',
      'description':
          'Get steady and assured returns irrespective of market fluctuations'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.07),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              offset: Offset(0, 3),
              blurRadius: 10,
            )
          ],
          // border: Border.all(
          //   width: 0.5,
          //   color: ColorConstants.tertiaryBlack.withOpacity(0.5),
          // ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // fd advantages list
            ...List<Widget>.generate(
              fdAdvantages.length,
              (index) {
                return _buildAdvantageCard(index, context);
              },
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantageCard(int index, BuildContext context) {
    // for last element bottom padding not reqd
    double bottomPadding = index < (fdAdvantages.length - 1) ? 36 : 0;
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
      ),
      child: Row(
        children: [
          Image.asset(
            fdAdvantages[index]['image']!,
            height: 48,
            width: 48,
          ),
          SizedBox(width: 16),
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: fdAdvantages[index]['title']!,
              subtitle: fdAdvantages[index]['description']!,
              subtitleMaxLength: 3,
              titleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                        overflow: TextOverflow.ellipsis,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.tertiaryBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
