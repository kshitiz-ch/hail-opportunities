import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/micro_sip_basket_fund_list_tile.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MicroSipBasketView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GetBuilder<MFPortfolioDetailController>(
        id: 'micro-sip',
        builder: (controller) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorConstants.borderColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: _buildBasketList(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBasketList(
      BuildContext context, MFPortfolioDetailController controller) {
    final fundList = controller.microSIPBasket.values.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(
        controller.microSIPBasket.length,
        (index) {
          bool isLastItem = index == controller.microSIPBasket.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MicroSipBasketFundListTile(
                isLastItem: isLastItem,
                fund: fundList[index],
                index: index,
              ),
              if (!isLastItem)
                CommonUI.buildProfileDataSeperator(
                  width: double.infinity,
                  height: 1,
                  color: ColorConstants.borderColor,
                )
            ],
          );
        },
      ),
    );
  }
}
