import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/my_business/business_graph_controller.dart';
import 'package:app/src/screens/my_business/widgets/aum_graph_view.dart';
import 'package:app/src/screens/my_business/widgets/revenue_graph_view.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessGraphSection extends StatelessWidget {
  // added tag to fix data inconsistency
  // issue b/w home & my business screen for graph section
  final String tag;

  const BusinessGraphSection({Key? key, required this.tag}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessGraphController>(
      tag: tag,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20).copyWith(top: 15),
              child: _buildTabs(controller, context),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: _getTabBarViewUI(
                controller.tabs[controller.tabController.index],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs(BusinessGraphController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.tertiaryCardColor,
            ColorConstants.tertiaryCardColor.withOpacity(0),
          ],
        ),
      ),
      height: 40,
      child: TabBar(
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: controller.tabController,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle:
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: ColorConstants.black,
        labelStyle: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: ColorConstants.black, fontWeight: FontWeight.w600),
        tabs: List<Widget>.generate(
          controller.tabs.length,
          (index) => Container(
            width: SizeConfig().screenWidth! / controller.tabs.length,
            alignment: Alignment.center,
            child: Tab(
              text: controller.tabs[index],
              iconMargin: EdgeInsets.zero,
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _getTabBarViewUI(String selectedTab) {
    switch (selectedTab) {
      case 'AUM':
        return AumGraphView(tag: tag);
      case 'Revenue':
        return RevenueGraphView(tag: tag);
      default:
        return AumGraphView(tag: tag);
    }
  }
}
