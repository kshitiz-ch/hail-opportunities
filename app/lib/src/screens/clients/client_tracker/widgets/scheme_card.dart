import 'dart:math' as math;

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/client_tracker_fund_model.dart';
import 'package:flutter/material.dart';

class SchemeCard extends StatelessWidget {
  const SchemeCard({
    Key? key,
    this.clientTrackerFund,
    this.fromSwitchScreen = false,
    this.isSelected = false,
  }) : super(key: key);

  final ClientTrackerFundModel? clientTrackerFund;
  final bool fromSwitchScreen;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final returns = (clientTrackerFund?.absoluteReturns ?? 0.0) * 100.0;
    // String returnType =
    //     mfReturnTypeDescription(clientTrackerFund?.schemeMetaModel?.returnType);
    // String planType =
    //     fundPlanTypeDescription(clientTrackerFund?.schemeMetaModel?.planType);
    // String fundType =
    //     fundTypeDescription(clientTrackerFund?.schemeMetaModel?.fundType);
    // String subtitle = "$folioText${returnType.isNotEmpty ? '$returnType | ' : ''}${planType.isNotEmpty ? '$planType | ' : ''}$fundType";

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            border: Border.all(color: ColorConstants.secondarySeparatorColor),
            shape: BoxShape.circle,
          ),
          child: CommonUI.buildRoundedFullAMCLogo(
              radius: 18,
              amcName: clientTrackerFund?.schemeMetaModel?.displayName ?? ''),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _getSchemeDetails(context),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WealthyAmount.currencyFormat(
                clientTrackerFund?.schemeMetaModel?.folioOverview?.currentValue,
                2,
                showSuffix: true,
              ),
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  !returns.isNegative
                      ? AllImages().gainIcon
                      : AllImages().lossIcon,
                  height: 10,
                  width: 10,
                ),
                Text(
                  ' ${returns.toStringAsFixed(2)}%',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: !returns.isNegative
                                ? ColorConstants.greenAccentColor
                                : ColorConstants.errorColor,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                )
              ],
            )
          ],
        ),
        SizedBox(width: 12),
        if (fromSwitchScreen)
          Transform.rotate(
            angle: isSelected ? math.pi / 2 : 0,
            child: Image.asset(
              AllImages().trackerSwitchIcon,
              color: ColorConstants.primaryAppColor,
              height: 14,
              width: 14,
            ),
          )
        else
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: ColorConstants.black,
            size: 12,
          )
      ],
    );
  }

  Widget _getSchemeDetails(BuildContext context) {
    final headerStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle = context.titleLarge!.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
    );

    final displayName = clientTrackerFund?.schemeMetaModel?.displayName;
    final folio = clientTrackerFund?.schemeMetaModel?.folioOverview;

    if (folio == null) {
      return Text(
        displayName ?? '-',
        style: headerStyle,
      );
    }

    final folioNumber = folio.folioNumber;
    final units = folio.units;
    final lockedUnits = folio.lockedUnits;

    String arnText = '';
    final arn = folio.advisorArn;

    final dematText = 'Demat - ${folio.isDemat == true ? 'Yes' : 'No'}';

    if (arn.isNotNullOrEmpty) {
      final isArnInternal = ["ARN-106846", "WEALTHYON"].contains(arn);
      final arnSource = isArnInternal ? 'wealthy/internal' : 'external';

      if (arn!.toLowerCase().startsWith("arn")) {
        arnText += '$arn (${arnSource})';
      } else {
        arnText += 'ARN $arn (${arnSource})';
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName ?? '-',
          style: headerStyle,
        ),
        SizedBox(height: 4),
        Text(
          'Units: ${units?.toStringAsFixed(2)} ${lockedUnits.isNotNullOrZero ? '(Locked: ${lockedUnits?.toStringAsFixed(2)})' : ''}',
          style: subtitleStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            folioNumber != null ? 'Folio #${folioNumber}' : '',
            style: subtitleStyle,
          ),
        ),
        Text(
          arnText,
          style: subtitleStyle,
        ),
        SizedBox(height: 4),
        Text(
          dematText,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
