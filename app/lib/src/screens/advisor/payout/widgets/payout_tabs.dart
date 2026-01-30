import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/advisor/payout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayoutTabs extends StatelessWidget {
  final payoutController = Get.find<PayoutController>();

  @override
  Widget build(BuildContext context) {
    return _buildTabs(context);
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      height: 54,
      color: Colors.white,
      child: TabBar(
        onTap: (index) {},
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: payoutController.tabController,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle: context.headlineSmall!
            .copyWith(color: ColorConstants.tertiaryBlack),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: ColorConstants.black,
        labelStyle: context.headlineSmall!
            .copyWith(color: ColorConstants.black, fontWeight: FontWeight.w600),
        tabs: List<Widget>.generate(
          payoutController.tabs.length,
          (index) => Tab(
            text: payoutController.tabs[index],
            iconMargin: EdgeInsets.zero,
          ),
        ).toList(),
      ),
    );
  }
}
