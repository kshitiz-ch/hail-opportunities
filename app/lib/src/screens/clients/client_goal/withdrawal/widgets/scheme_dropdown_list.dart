import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/goal/withdrawal_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/user_goal_subtype_scheme_model.dart';
import 'package:flutter/material.dart';

class SchemeDropdownList extends StatelessWidget {
  const SchemeDropdownList({
    Key? key,
    required this.schemes,
    required this.onClick,
    required this.controller,
  }) : super(key: key);

  final List<SchemeMetaModel> schemes;
  final Function(SchemeMetaModel scheme) onClick;
  final WithdrawalController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Container(
        color: Colors.black.withOpacity(0.6),
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(vertical: 80, horizontal: 30),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 5),
                alignment: Alignment.topRight,
                child: CommonUI.bottomsheetRoundedCloseIcon(context),
              ),
              if (schemes.isNullOrEmpty || controller.isAllFoliosSelected)
                _buildEmptyState(context)
              else
                _buildSchemeList(context, controller)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "No Funds ${schemes.isNullOrEmpty ? 'Found' : 'Remaining'}!",
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: ColorConstants.black, fontSize: 13),
      ),
    );
  }

  Widget _buildSchemeList(
      BuildContext context, WithdrawalController controller) {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        radius: Radius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: schemes.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              SchemeMetaModel scheme = schemes[index];

              if (controller.withdrawalSchemesSelected
                  .containsKey(getFundIdentifier(scheme))) {
                return SizedBox();
              }

              return _buildFundCard(context, scheme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFundCard(BuildContext context, SchemeMetaModel scheme) {
    if (!(scheme.folioOverview?.exists ?? false)) {
      return SizedBox();
    }

    return InkWell(
      onTap: () {
        onClick(scheme);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorConstants.borderColor),
          ),
        ),
        child: Column(
          children: [
            SchemeFolioCard(
              displayName: scheme.displayName,
              folioNumber: scheme.folioOverview?.folioNumber,
            ),
            SizedBox(height: 15),
            CommonClientUI.folioUnitAmountRow(context, scheme.folioOverview)
          ],
        ),
      ),
    );
  }
}
