import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FundManagerDetails extends StatelessWidget {
  const FundManagerDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
      builder: (controller) {
        return BreakdownHeader(
          title: 'Fund Management',
          isExpanded:
              Get.find<FundDetailController>().activeNavigationSection ==
                  FundNavigationTab.FundManagement,
          onToggleExpand: () {
            Get.find<FundDetailController>()
                .updateNavigationSection(FundNavigationTab.FundManagement);
          },
          // onToggleExpand: ,
          // subtitle: '',
          child: Container(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      AllImages().clientProfile,
                      width: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      controller.schemeData?.fundManager ?? '-',
                      style: Theme.of(context).primaryTextTheme.headlineSmall,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (controller.schemeData?.fundManagerProfile != null)
                  Padding(
                    padding: EdgeInsets.only(left: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).primaryTextTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          controller.schemeData!.fundManagerProfile!,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleMedium!
                              .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  height: 1.5),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
