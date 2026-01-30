import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

import 'goal_scheme_dropdown_list.dart';

class GoalSchemeDropdown extends StatelessWidget {
  const GoalSchemeDropdown({
    Key? key,
    this.label,
    this.selectedScheme, // scheme selected from the dropdown
    this.amcCode, //  For searching switch in funds based on the amcCode
    this.goalSchemes = const [],
    required this.switchFundType,
    required this.onSchemeSelect,
  }) : super(key: key);

  final SchemeMetaModel? selectedScheme;
  final SwitchFundType switchFundType;
  final List<SchemeMetaModel> goalSchemes;
  final String? label;
  final String? amcCode;
  final Function(SchemeMetaModel scheme) onSchemeSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotNullOrEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 12),
            child: Text(
              label!,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        InkWell(
          onTap: () {
            _navigateToSchemeDropdownList(context);
          },
          child: selectedScheme != null
              ? _buildSchemeDetails(context, selectedScheme!)
              : _buildDropdownHintText(context),
        ),
      ],
    );
  }

  Widget _buildSchemeDetails(BuildContext context, SchemeMetaModel scheme) {
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
                  folioNumber: scheme.folioOverview?.folioNumber,
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
          if (scheme.folioOverview?.exists ?? false)
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: CommonClientUI.switchOrderUnitAmountRow(
                context,
                scheme.folioOverview?.currentValue,
                scheme.folioOverview?.units,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDropdownHintText(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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

  void _navigateToSchemeDropdownList(BuildContext context) {
    AutoRouter.of(context).pushNativeRoute(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return GoalSchemeDropdownList(
            amcCode: amcCode,
            goalSchemes: goalSchemes,
            switchFundType: switchFundType,
            onSchemeSelect: onSchemeSelect,
          );
        },
      ),
    );
  }
}
