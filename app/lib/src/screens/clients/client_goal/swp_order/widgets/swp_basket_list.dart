import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/client.dart';
import 'package:app/src/controllers/client/goal/create_swp_controller.dart';
import 'package:app/src/screens/clients/client_goal/swp_order/widgets/add_edit_swp_fund_bottomsheet.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/utils/swp_scheme_context.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwpBasketList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateSwpController>(
      builder: (controller) {
        final selectedSwpSchemeList =
            controller.selectedSwpSchemes.values.toList();
        return ListView.separated(
          padding: EdgeInsets.only(bottom: 150),
          itemCount: selectedSwpSchemeList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: ColorConstants.borderColor,
              ),
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final swpSchemeContext = selectedSwpSchemeList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildSchemeDetails(context, swpSchemeContext),
                  _buildSchemeActions(context, swpSchemeContext)
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSchemeDetails(
      BuildContext context, SwpSchemeContext swpSchemeContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SchemeFolioCard(
              displayName: swpSchemeContext.schemeData.displayName,
              folioNumber:
                  swpSchemeContext.schemeData.folioOverview?.folioNumber,
            ),
          ),
          Column(
            children: [
              Text(
                'Withdraw Amount',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 12, color: ColorConstants.tertiaryBlack),
              ),
              SizedBox(height: 4),
              Text(
                WealthyAmount.currencyFormat(swpSchemeContext.amount, 2),
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
    SwpSchemeContext swpSchemeContext,
  ) {
    return GetBuilder<CreateSwpController>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(left: 40),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CommonClientUI.goalTransactDays(
                  context,
                  swpSchemeContext.days ?? [],
                  daysLimit: 2,
                ),
              ),
              Spacer(),
              CommonClientUI.goalTransactSchemeActions(
                context,
                onEdit: () {
                  controller.updateDropdownSelectedScheme(
                    swpSchemeContext,
                    isEdit: true,
                  );

                  CommonUI.showBottomSheet(
                    context,
                    child: AddEditSwpFundBottomSheet(
                      isEdit: true,
                      fundIdSelected: swpSchemeContext.id,
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
                        controller.removeWithdrawalScheme(swpSchemeContext.id);
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
