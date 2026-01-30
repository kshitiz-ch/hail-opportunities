import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/goal/switch_order_controller.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_edit_fund_bottomsheet.dart';

class SwitchOrderSchemesList extends StatelessWidget {
  const SwitchOrderSchemesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwitchOrderController>(
      builder: (controller) {
        return ListView.separated(
          padding: EdgeInsets.only(bottom: 150),
          itemCount: controller.switchOrderSchemes.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 30);
          },
          itemBuilder: (BuildContext context, int index) {
            SwitchOrderSchemeContext schemeContext =
                controller.switchOrderSchemes[index];

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          },
        );
      },
    );
  }

  Widget _buildSchemeNameAmount(
      BuildContext context, SwitchOrderSchemeContext switchOrderSchemeContext) {
    final isValueTypeUnits =
        switchOrderSchemeContext.valueType != OrderValueType.Amount;

    String labelText = switchOrderSchemeContext.valueType == OrderValueType.Full
        ? 'Full '
        : '';
    labelText += (isValueTypeUnits ? 'Units' : 'Amount');

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                SchemeFolioCard(
                  displayName: switchOrderSchemeContext.switchOut.displayName,
                  folioNumber: switchOrderSchemeContext.switchOut.folioNumber,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Image.asset(AllImages().switchFundIcon, width: 30),
                ),
                SchemeFolioCard(
                  displayName: switchOrderSchemeContext.switchIn?.displayName,
                  folioNumber: switchOrderSchemeContext.switchIn?.folioNumber,
                )
              ],
            ),
          ),
          Column(
            children: [
              Text(
                labelText,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
              SizedBox(height: 4),
              Text(
                isValueTypeUnits
                    ? switchOrderSchemeContext.units
                    : WealthyAmount.currencyFormat(
                        switchOrderSchemeContext.amount, 2),
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

  Widget _buildSchemeActions(BuildContext context,
      SwitchOrderSchemeContext switchOrderSchemeContext, int index) {
    return GetBuilder<SwitchOrderController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(left: 46),
          child: CommonClientUI.goalTransactSchemeActions(
            context,
            onEdit: () {
              controller.updateDropdownSelectedScheme(switchOrderSchemeContext,
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
                    controller.removeSwitchOrderScheme(index);
                    AutoRouter.of(context).popForced();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
