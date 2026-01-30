import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'anyfund_sip_card.dart';
import 'basket_amount_section_new.dart';
import 'delete_fund_bottom_sheet.dart';

class BasketFundTileNew extends StatelessWidget {
  final String? tag;
  final int index;
  late BasketController controller;
  final SchemeMetaModel fund;
  final bool isLastItem;
  final GlobalKey<AnimatedListState>? listKey;

  BasketFundTileNew({
    Key? key,
    this.tag,
    required this.index,
    required this.fund,
    this.isLastItem = false,
    this.listKey,
  }) : super(key: key) {
    controller = Get.find<BasketController>(tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.investmentType == InvestmentType.SIP &&
        !controller.isCustomPortfolio) {
      return AnyFundSipCard(
        controller: controller,
        fund: fund,
        index: index,
      );
    } else {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorConstants.borderColor,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonMfUI.buildFundLogo(context, fund),
                CommonMfUI.buildFundName(context, fund),
                CommonMfUI.buildBasketDeleteWidget(controller, fund, index),
              ],
            ),
            SizedBox(height: 16),
            InkWell(
              splashColor: ColorConstants.white,
              focusColor: ColorConstants.white,
              onTap: () {
                if (controller.selectedClient == null) {
                  showToast(text: "Please select a client first");
                }
              },
              child: IgnorePointer(
                ignoring: controller.selectedClient == null,
                child: _buildAmountTextField(context),
              ),
            )
          ],
        ),
      );
    }
  }

  Widget _buildAmountTextField(BuildContext context) {
    return BasketAmountSectionNew(
      basketController: controller,
      fund: fund,
    );
  }
}
