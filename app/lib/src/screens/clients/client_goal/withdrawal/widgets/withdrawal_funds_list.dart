import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/client/goal/withdrawal_controller.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_edit_fund_bottomsheet.dart';

class WithdrawalFundsLIst extends StatelessWidget {
  const WithdrawalFundsLIst({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawalController>(
      builder: (controller) {
        return ListView.separated(
          padding: EdgeInsets.only(bottom: 150),
          itemCount: controller.withdrawalSchemesSelected.values.length,
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: ColorConstants.borderColor,
              ),
            );
          },
          itemBuilder: (BuildContext context, int index) {
            WithdrawalSchemeContext schemeContext =
                controller.withdrawalSchemesSelected.values.toList()[index];

            String fundId =
                controller.withdrawalSchemesSelected.keys.toList()[index];

            String? folioNumber =
                schemeContext.schemeData.folioOverview?.folioNumber;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildSchemeNameAmount(context, schemeContext, folioNumber),
                  _buildSchemeActions(context, schemeContext)
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSchemeNameAmount(BuildContext context,
      WithdrawalSchemeContext schemeContext, String? folioNumber) {
    bool isValueTypeUnits = schemeContext.valueType != OrderValueType.Amount;

    String labelText =
        schemeContext.valueType == OrderValueType.Full ? 'Full ' : '';
    labelText += (isValueTypeUnits ? 'Units' : 'Amount');

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: SchemeFolioCard(
              displayName: schemeContext.schemeData.displayName,
              folioNumber: folioNumber,
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
                    ? schemeContext.units
                    : WealthyAmount.currencyFormat(schemeContext.amount, 2),
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
    BuildContext context,
    WithdrawalSchemeContext schemeContext,
  ) {
    return GetBuilder<WithdrawalController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(left: 46),
          child: CommonClientUI.goalTransactSchemeActions(
            context,
            onEdit: () {
              controller.updateDropdownSelectedScheme(schemeContext,
                  isEdit: true);

              CommonUI.showBottomSheet(
                context,
                child: AddEditFundBottomSheet(
                  isEdit: true,
                  fundIdSelected: schemeContext.id,
                ),
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
                    controller.removeWithdrawalScheme(schemeContext.id);
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
