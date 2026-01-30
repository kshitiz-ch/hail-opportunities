import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionTabs extends StatelessWidget {
  final transactionController = Get.find<TransactionController>();
  @override
  Widget build(BuildContext context) {
    return _buildTabs(context);
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      height: transactionController.screenContext.isTransactionView ? 54 : 40,
      color: Colors.white,
      child: TabBar(
        onTap: (index) {},
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: transactionController.tabController,
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
          transactionController.transactionTabList.length,
          (index) => Tab(
            text: transactionController.transactionTabList[index],
            iconMargin: EdgeInsets.zero,
          ),
        ).toList(),
      ),
    );
  }
}
