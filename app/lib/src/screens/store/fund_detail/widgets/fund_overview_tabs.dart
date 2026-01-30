import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class FundOverviewTabs extends StatelessWidget {
  const FundOverviewTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabs(context, FundNavigationTab.Overview),
          _buildTabs(context, FundNavigationTab.Portfolio),
          _buildTabs(context, FundNavigationTab.Peers),
          _buildTabs(context, FundNavigationTab.Scheme_Details)
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, FundNavigationTab tab) {
    return GetBuilder<FundDetailController>(
      id: 'navigation',
      builder: (controller) {
        bool isSelected = controller.selectedTab == tab;
        return Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: isSelected
                      ? ColorConstants.primaryAppColor
                      : Colors.transparent),
            ),
          ),
          child: InkWell(
            onTap: () {
              if (Get.isRegistered<FundScoreController>() &&
                  Get.find<FundScoreController>().fetchSchemeDataState !=
                      NetworkState.loading) {
                controller.updateNavigationTab(tab);
              }
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: MarqueeWidget(
                child: Text(
                  tab.name.replaceAll("_", " "),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
