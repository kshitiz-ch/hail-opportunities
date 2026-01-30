import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/goal/withdrawal_controller.dart';
import 'package:app/src/screens/clients/client_goal/withdrawal/widgets/scheme_dropdown_list.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchemeDropdown extends StatelessWidget {
  const SchemeDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawalController>(
      id: GetxId.schemeForm,
      builder: (controller) {
        bool isSchemeAlreadySelected =
            controller.dropdownSelectedScheme != null &&
                controller.dropdownSelectedScheme!.isNotEmpty;

        return InkWell(
          onTap: () {
            _navigateToSchemeDropdownList(context, controller);
          },
          child: isSchemeAlreadySelected
              ? _buildSchemeDetails(
                  context, controller.dropdownSelectedScheme!.values.first)
              : _buildDropdownHintText(context),
        );
      },
    );
  }

  Widget _buildSchemeDetails(
      BuildContext context, WithdrawalSchemeContext schemeContext) {
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
                  displayName: schemeContext.schemeData.displayName,
                  folioNumber:
                      schemeContext.schemeData.folioOverview?.folioNumber,
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
          SizedBox(height: 15),
          CommonClientUI.folioUnitAmountRow(
            context,
            schemeContext.schemeData.folioOverview,
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
            'Choose Fund for Withdrawal',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
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
      BuildContext context, WithdrawalController controller) {
    AutoRouter.of(context).pushNativeRoute(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => SchemeDropdownList(
          controller: controller,
          schemes: controller.schemeWithFolios,
          onClick: (scheme) {
            if ((scheme.folioOverview?.withdrawalAmountAvailable ?? 0) <= 0) {
              return showToast(
                  text:
                      "Scheme should have Withdrawal Amount greater than zero");
            }

            AutoRouter.of(context).popForced();
            WithdrawalSchemeContext schemeContext =
                WithdrawalSchemeContext(schemeData: scheme);
            controller.updateDropdownSelectedScheme(schemeContext);
          },
        ),
      ),
    );
  }
}
