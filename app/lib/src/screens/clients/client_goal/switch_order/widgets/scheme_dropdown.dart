import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/switch_order_controller.dart';
// import 'package:app/src/screens/clients/client_goal/withdrawal/widgets/scheme_dropdown_list.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'switch_in_dropdown_list.dart';
import 'switch_out_dropdown_list.dart';

class SchemeDropdown extends StatelessWidget {
  const SchemeDropdown({
    Key? key,
    required this.switchFundType,
  }) : super(key: key);

  final SwitchFundType switchFundType;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SwitchOrderController>(
      id: GetxId.schemeForm,
      builder: (controller) {
        bool isSchemeAlreadySelected = false;
        if (controller.dropdownSelectedScheme != null) {
          if (switchFundType == SwitchFundType.SwitchIn) {
            isSchemeAlreadySelected =
                controller.dropdownSelectedScheme?.switchIn != null;
          } else {
            isSchemeAlreadySelected =
                controller.dropdownSelectedScheme?.switchOut != null;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Moving ${switchFundType == SwitchFundType.SwitchOut ? 'From' : 'To'}',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () {
                _navigateToSchemeDropdownList(context, controller);
              },
              child: isSchemeAlreadySelected
                  ? _buildSchemeDetails(
                      context,
                      controller.dropdownSelectedScheme!,
                    )
                  : _buildDropdownHintText(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchemeDetails(
      BuildContext context, SwitchOrderSchemeContext schemeContext) {
    SwitchOrderSchemeModel scheme;
    if (switchFundType == SwitchFundType.SwitchIn) {
      scheme = schemeContext.switchIn!;
    } else {
      scheme = schemeContext.switchOut;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.white,
        border: Border.all(color: ColorConstants.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SchemeFolioCard(
                  displayName: scheme.displayName,
                  folioNumber: scheme.folioNumber,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: ColorConstants.tertiaryBlack,
                  size: 24,
                ),
              )
            ],
          ),
          if (scheme.folioNumber.isNotNullOrEmpty)
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: CommonClientUI.switchOrderUnitAmountRow(
                context,
                scheme.currentValue,
                scheme.units,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDropdownHintText(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorConstants.primaryCardColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            switchFundType == SwitchFundType.SwitchIn
                ? 'Select Fund to switch to'
                : 'Select Fund to switch from',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorConstants.tertiaryBlack,
            size: 24,
          )
        ],
      ),
    );
  }

  void _navigateToSchemeDropdownList(
      BuildContext context, SwitchOrderController controller) {
    if (switchFundType == SwitchFundType.SwitchIn) {
      controller.clearSearchBar();
    }

    void onSchemeSelect(SchemeMetaModel scheme) {
      SwitchOrderSchemeModel switchOrderScheme = SwitchOrderSchemeModel(
        displayName: scheme.displayName,
        amc: scheme.amc,
        wschemecode: scheme.wschemecode,
        folioNumber: scheme.folioOverview?.folioNumber,
        units: scheme.folioOverview?.units,
        currentValue: scheme.folioOverview?.currentValue,
        minAmount: scheme.minDepositAmt,
      );

      AutoRouter.of(context).popForced();
      SwitchOrderSchemeContext? schemeContext;

      if (controller.dropdownSelectedScheme != null) {
        schemeContext =
            SwitchOrderSchemeContext.clone(controller.dropdownSelectedScheme!);
      }

      if (switchFundType == SwitchFundType.SwitchOut) {
        schemeContext = SwitchOrderSchemeContext(
          switchOut: switchOrderScheme,
        );

        controller.amountController.clear();
        controller.valueTypeSelected = OrderValueType.Amount;
      } else {
        schemeContext!.switchIn = switchOrderScheme;
      }

      controller.updateDropdownSelectedScheme(schemeContext);
    }

    AutoRouter.of(context).pushNativeRoute(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          if (switchFundType == SwitchFundType.SwitchIn) {
            return SwitchInDropdownList(
              controller: controller,
              schemes: controller.switchInSchemes,
              onSchemeSelect: onSchemeSelect,
            );
          } else {
            return SwitchOutDropdownList(
              controller: controller,
              schemes: controller.isAnyFundPortfolio
                  ? controller.anyFundSwitchOutSchemes
                  : controller.switchOutSchemes,
              onSchemeSelect: onSchemeSelect,
            );
          }
        },
      ),
    );
  }
}
