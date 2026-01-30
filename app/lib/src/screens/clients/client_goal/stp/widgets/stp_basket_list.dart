import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/goal/stp_controller.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_edit_fund_bottomsheet.dart';

class StpBasketList extends StatelessWidget {
  const StpBasketList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StpController>(
      builder: (controller) {
        return ListView.separated(
          padding: EdgeInsets.only(bottom: 180),
          itemCount: controller.stpBasket.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 30);
          },
          itemBuilder: (context, index) {
            StpSchemeContext schemeContext = controller.stpBasket[index];
            return _buildStpFundCard(context, schemeContext, index);
          },
        );
      },
    );
  }

  Widget _buildStpFundCard(
      BuildContext context, StpSchemeContext schemeContext, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        children: [
          _buildSchemeNameAmount(context, schemeContext),
          _buildSchemeActions(context, schemeContext, index)
        ],
      ),
    );
  }

  Widget _buildSchemeNameAmount(
      BuildContext context, StpSchemeContext schemeContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                SchemeFolioCard(
                  displayName: schemeContext.switchOut?.displayName,
                  folioNumber:
                      schemeContext.switchOut?.folioOverview?.folioNumber,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Image.asset(AllImages().switchFundIcon, width: 30),
                ),
                SchemeFolioCard(
                  displayName: schemeContext.switchIn?.displayName,
                  folioNumber:
                      schemeContext.switchIn?.folioOverview?.folioNumber,
                )
              ],
            ),
          ),
          Column(
            children: [
              Text(
                'Amount',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
              SizedBox(height: 4),
              Text(
                WealthyAmount.currencyFormat(schemeContext.amount, 2),
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSchemeActions(
      BuildContext context, StpSchemeContext stpSchemeContext, int index) {
    return GetBuilder<StpController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(left: 25),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CommonClientUI.goalTransactDays(
                  context,
                  stpSchemeContext.days ?? [],
                  daysLimit: 2,
                ),
              ),
              Spacer(),
              CommonClientUI.goalTransactSchemeActions(
                context,
                onEdit: () {
                  controller.updateDropdownSelectedScheme(stpSchemeContext,
                      isEdit: true);

                  CommonUI.showBottomSheet(
                    context,
                    child: AddEditFundBottomSheet(editIndex: index),
                  );
                },
                onDelete: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: DeleteFundBottomSheet(
                      onCancel: () {
                        AutoRouter.of(context).popForced();
                      },
                      onDelete: () {
                        controller.stpBasket.removeAt(index);
                        controller.update();

                        AutoRouter.of(context).popForced();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
